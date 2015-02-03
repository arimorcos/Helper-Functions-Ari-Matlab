function [HR, HRS, HlR, HlRS, HiR, HiRS, ChiR, HshR, HshRS] = gaussian_method_v10(R, pars)
%GAUSSIAN_METHOD_V9 Estimate entropy values using the Gaussian Method.
%
% ---------
% ARGUMENTS
% ---------
% R    - response matrix
% pars - parameters structure

%   Copyright (C) 2010 Cesare Magri
%   Version 10

% -------
% LICENSE
% -------
% This software is distributed free under the condition that:
%
% 1. it shall not be incorporated in software that is subsequently sold;
%
% 2. the authorship of the software shall be acknowledged and the following
%    article shall be properly cited in any publication that uses results
%    generated by the software:
%
%      Magri C, Whittingstall K, Singh V, Logothetis NK, Panzeri S: A
%      toolbox for the fast information analysis of multiple-site LFP, EEG
%      and spike train recordings. BMC Neuroscience 2009 10(1):81;
%
% 3.  this notice shall remain in place in each source file.

% ----------
% DISCLAIMER
% ----------
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% HiR, HiRS and ChiR are not computed for the gaussian case, null values
% are returned instead:
HiR  = NaN;
HiRS = NaN;
ChiR = NaN;

useGaussianBiasCorrection = pars.biasCorrNum==3;

% We have to recompute Nc, Nt, maxNt (in the case this routine is called by
% quadratic extrapolation)
Nt    = pars.Nt;
Nc    = size(R,1);
maxNt = size(R,2);
totNt = sum(Nt);
Ns    = pars.Ns;

twice_logOf2 = 2*log(2);

ConstantTerm_r  = Nc * (log(2*pi) + 1) - Nc*log(totNt-1);
ConstantTerm_rs = Nc * (log(2*pi) + 1) - Nc*log(Nt-1);

if pars.doHR || pars.doHRS || pars.doHlR || pars.doHlRS
    [covPrs, covPr, diagCovPrs, diagCovPr] = pars.covfunc(R, Nt, Nc, maxNt, Ns, totNt, pars.isBtsp);
end

% H(R)
if pars.doHR
    if Nc==1
        HR = (ConstantTerm_r + log(covPr)) / twice_logOf2;
    else
        HR = (ConstantTerm_r + log(det(covPr))) / twice_logOf2;
    end

    % Bias correction:
    if useGaussianBiasCorrection
        HRbias = gaussian_bias(totNt, Nc);
        HR = HR - HRbias;
    end
else
    HR = 0;
end

% H_lin(R)
if pars.doHlR
    HlR = (ConstantTerm_r + sum(log(diagCovPr), 1)) / twice_logOf2;

    % Bias correction:
    if useGaussianBiasCorrection
        HlRbias = Nc * gaussian_bias(totNt, 1);
        HlR = HlR - HlRbias;
    end
else
    HlR = 0;
end

    
if pars.doHRS
    if Nc==1
        HRS  = (ConstantTerm_rs + log(covPrs(:))) / twice_logOf2;
    else
        switch Nc
            case 2
                detCovPrs = det2D(covPrs, Ns);

            case 3
                detCovPrs = det3D(covPrs, Ns);

            case 4
                detCovPrs = det4D(covPrs, Ns);

            otherwise
                detCovPrs = zeros(Ns,1);
                for s=1:Ns

                    if pars.doHRS
                        detCovPrs(s) = det(covPrs(:,:,s));
                    end;
                end
        end

        HRS = (ConstantTerm_rs + log(detCovPrs)) / twice_logOf2;
    end

    % Bias correction:
    if useGaussianBiasCorrection
        HRSbias = gaussian_bias(Nt, Nc);
        HRS = HRS - HRSbias;
    end
else
    HRS = 0;
end
        
if pars.doHlRS

    HlRS = zeros(Ns,1);
    HlRS(:) = (ConstantTerm_rs + sum(log(diagCovPrs), 2)) / twice_logOf2;

    % Bias correction:
    if useGaussianBiasCorrection
        HlRSbias = Nc * gaussian_bias(Nt, 1);
        HlRS = HlRS - HlRSbias;
    end
else
    HlRS = 0;
end


% H_sh(R) and H_sh(R|S) ---------------------------------------------------
if pars.doHshR || pars.doHshRS
    % In test-mode we do not want to shuffle:
    if pars.testMode
        Rsh = R;
    else
        Rsh = shuffle_R_across_cells(R, Nt);
    end
    [covPshrs, covPshr] = pars.covfunc(Rsh, Nt, Nc, maxNt, Ns, totNt, pars.isBtsp);
end

if pars.doHshR
    HshR = (ConstantTerm_r + log(det(covPshr))) / twice_logOf2;

    % Bias correction:
    if useGaussianBiasCorrection
        if pars.doHR
            HshR = HshR - HRbias;
        else
            HshRbias = gaussian_bias(totNt, Nc);
            HshR = HshR - HshRbias;
        end
    end
else
    HshR = 0;
end

% Remark: HshRS not computed for Nc==1
if pars.doHshRS

    switch Nc
        case 2
            detCovPshrs = det2D(covPshrs, Ns);

        case 3
            detCovPshrs = det3D(covPshrs, Ns);

        case 4
            detCovPshrs = det4D(covPshrs, Ns);

        otherwise
            detCovPshrs = zeros(Ns,1);
            for s=1:Ns

                if pars.doHshRS
                    detCovPshrs(s) = det(covPshrs(:,:,s));
                end;
            end
    end

    HshRS = (ConstantTerm_rs + log(detCovPshrs)) / twice_logOf2;

    % Bias correction:
    if useGaussianBiasCorrection
        if pars.doHRS
            HshRSbias = HRSbias;
        else
            HshRSbias = gaussian_bias(Nt, Nc);
        end
        HshRS = HshRS - HshRSbias;
    end

else
    HshRS = 0;
end


% 2-D determinant ---------------------------------------------------------
function out = det2D(X, Ns)

out = zeros(Ns,1);
out(:) = X(1,1,:) .* X(2,2,:) - ...
         X(1,2,:) .* X(2,1,:);


% 3-D determinant ---------------------------------------------------------
function out = det3D(X, Ns)

out = zeros(Ns,1);
out(:) = X(1,1,:).*(X(2,2,:).*X(3,3,:) - X(2,3,:).*X(3,2,:)) - ...
         X(1,2,:).*(X(2,1,:).*X(3,3,:) - X(2,3,:).*X(3,1,:)) + ...
         X(1,3,:).*(X(2,1,:).*X(3,2,:) - X(2,2,:).*X(3,1,:));


% 4-D determinant ---------------------------------------------------------
function out = det4D(X, Ns)

X32_times_X43_minus_X33_times_X42 = X(3,2,:).*X(4,3,:) - X(3,3,:).*X(4,2,:);
X31_times_X43_minus_X33_times_X41 = X(3,1,:).*X(4,3,:) - X(3,3,:).*X(4,1,:);
X31_times_X42_minus_X32_times_X41 = X(3,1,:).*X(4,2,:) - X(3,2,:).*X(4,1,:);

out = zeros(Ns,1);
out(:) = - X(1,4,:) .* ( X(2,1,:).*(X32_times_X43_minus_X33_times_X42)   - ...
                         X(2,2,:).*(X31_times_X43_minus_X33_times_X41)   + ...
                         X(2,3,:).*(X31_times_X42_minus_X32_times_X41) ) ...
                                                                         ...
         + X(2,4,:) .* ( X(1,1,:).*(X32_times_X43_minus_X33_times_X42)   - ...
                         X(1,2,:).*(X31_times_X43_minus_X33_times_X41)   + ...
                         X(1,3,:).*(X31_times_X42_minus_X32_times_X41) ) ...
                                                                         ...
         - X(3,4,:) .* ( X(1,1,:).*(X(2,2,:).*X(4,3,:) - X(2,3,:).*X(4,2,:))   - ...
                         X(1,2,:).*(X(2,1,:).*X(4,3,:) - X(2,3,:).*X(4,1,:))   + ...
                         X(1,3,:).*(X(2,1,:).*X(4,2,:) - X(2,2,:).*X(4,1,:)) ) ...
                                                                               ...
         + X(4,4,:) .* ( X(1,1,:).*(X(2,2,:).*X(3,3,:) - X(2,3,:).*X(3,2,:)) - ...
                         X(1,2,:).*(X(2,1,:).*X(3,3,:) - X(2,3,:).*X(3,1,:)) + ...
                         X(1,3,:).*(X(2,1,:).*X(3,2,:) - X(2,2,:).*X(3,1,:)) );
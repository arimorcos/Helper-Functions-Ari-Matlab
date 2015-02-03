function additional_checks_v5(R, Par, opts)

%ADDITIONAL_CHECKS Perform additional checks over input to ENTROPY.

%   Copyright (C) 2011 Cesare Magri
%   Version 5

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


disp('===== OPTIONS SUMMARY =========================================')
% Recap of selected options
disp(['  - method: ' Par.methodName]);
disp(['  - bias correction: ' opts.bias]);
disp(['  - btsp repetitions: ' num2str(Par.btsp)]);
disp('===== ADDITIONAL WARNINGS =====================================')

warningFlag = false;

% Are there "wrong" fields in the outpt list? -----------------------------
NmatchingOutputOpts = Par.doHR   + ...
                      Par.doHRS  + ...
                      Par.doHlR  + ...
                      Par.doHlRS + ...
                      Par.doHiR  + ...
                      Par.doHiRS + ...
                      Par.doChiR + ...
                      Par.doHshR + ...
                      Par.doHshR;
                  
if Par.Noutput>NmatchingOutputOpts
    warningFlag = true;
    msg = 'Unknown selection in the output options list.';
    warning('addChecks:unknownOutputOption', msg);
end

numberOfFields = length(fieldnames(opts));
% Are there unused fields in the options structure? -----------------------
if Par.numberOfSpecifiedOptions + 4<numberOfFields
    warningFlag = true;
    msg = 'Number of fields in the options structure greater than number of specified options.';
    warning('addChecks:UnusedFields', msg);
end


% Has the binning been properly done (for direct method only) -------------
mask = findtrial(Par.Nt, max(Par.Nt), Par.Ns);
if strcmp(Par.methodName,'dr')

    % 1. Are response values integers only?
    if sum(sum(abs(R(:, mask) - fix(abs(R(:, mask)))),2),3) ~= 0
        msg = ['Method ''' Par.methodName ''' requires the responses to be discretized into (non-negative) integers.'];
        error('addChecks:Binning:RnotBinned', msg);
    end

    % 2. Have all cells been binned using the same number of bins?
    Nb = max(R(:,mask),[],2);
    if length(unique(Nb))~=1
        warningFlag = true;
        msg = ['The Number of bins used for discretization appears to be different for different responses.'...
               'If the responses are continuous in nature try to discretize them with the same number of bins.'];
        warning('addChecks:Binning:NbNotConstant', msg);
    end
    
    % 3. Does R include all values from 0 to Nb as a response?
    for c=1:Par.Nc
        uniqueR = unique(R(c,mask));
        for bin=1:Nb(c)
            if ~any(uniqueR==bin)
                warningFlag = true;
                msg = ['Trials appear not to include all values from 0 up to the selcted number of bins '...
                       '(this warning holds only for responses which are continuous in nature).'];
                warning('addChecks:Binning:allBinsNotIncludedAsResponse', msg);
            end
        end
    end
end


% Do non-trials all have the same value? ----------------------------------
if any(~Par.trials_indxes(:))
    if length(unique(R(:,~Par.trials_indxes)))~=1
        msg = 'Non-trials appear to have non-unique values.';
        warning('addChecks:NonTrials:nonUniqueValue', msg)
    end
end


% Bias correction 'pt' can only be used with 'dr' method ------------------
if Par.biasCorrNum==2 && ~strcmpi(Par.methodName, 'dr')
    warningFlag = true;
    msg = 'Bias correction ''pt'' can only be used with method ''dr'': returning naive estimates.';
    warning('addChecks:ptAndNonDrMethod', msg);
end

% User-defined bias-corrections can only be used with 'dr' method  (this
% error is disabled in test mode since the user might be calling a
% different method function) ----------------------------------------------
if ~Par.testMode && Par.biasCorrNum==-1 && ~strcmpi(Par.methodName, 'dr')
    msg = 'User-defined bias corrections can only be used with method ''dr'': returning naive estimates.';
    error('addChecks:ptAndNonDrMethod', msg);
end

% Bias corection 'gsb' can only be used with 'gs' method ------------------
if ~Par.testMode && Par.biasCorrNum==3 && ~strcmpi(Par.methodName, 'gs')
    msg = 'Bias correction ''gsb'' can only be used with method ''gs''.';
    error('addChecks:gsbAndNonGsMethod', msg);
end

% Check on compatibilities between computation options and output options:
% H_ind(R)
if Par.doHiR
    warningFlag = H_ind_checks('HiR', Par, warningFlag);
end

% H_ind(R|S)
if Par.doHiRS
    warningFlag = H_ind_checks('HiRS', Par, warningFlag);
end

% Chi(R)
if Par.doChiR
    warningFlag = H_ind_checks('ChiR', Par, warningFlag);
end


% Checks performed on custom bias correction function ---------------------
if Par.biasCorrNum==-1
    check_biasCorr_func(Par)
end


% If no warning was found -------------------------------------------------
if ~warningFlag
    disp('No errors or warnings.');
end

% Done
disp('===============================================================')



% SUBFUNCTIONS ============================================================

function warningFlag = H_ind_checks(output_opt, Par, warningFlag)
%WARNINGFLAG Perform checks for H_ind() entropies

if ~strcmpi(Par.methodName, 'dr')
    warningFlag = true;
    msg = ['Only method opt ''dr'' can be used with output opt ''' output_opt ''': returning NaN'];
    warning(['addChecks:' output_opt ':nonDrMethod'], msg);
end

if ~any(Par.biasCorrNum==[0 1])
    warningFlag = true;
    msg = ['Only bias correction opt ''qe'' can be used with output opt ''' output_opt ''': returning naive estimate'];
    warning(['addChecks:' output_opt ':nonQeBiasCorr'], msg);
end;


function check_biasCorr_func(Par)

biasCorrFuncHandle = str2func(Par.biasCorrFuncName);

x = floor(rand(100,1)*10);
bias = biasCorrFuncHandle(x);

if ~isscalar(bias)
    msg = ['Non-scalar bias-estimate returned by function ''' Par.biasCorrFuncName ''''];
    error('addChecks:nonScalarBiasEstimate', msg)
elseif bias<0
    msg = ['Negative bias estimate returned by function ''' Par.biasCorrFuncName ''''];
    error('addChecks:negativeBiasEstimate', msg);
elseif bias==0
    msg = ['Null bias estimate returned by function ''' Par.biasCorrFuncName ''''];
    warning('addChecks:nullBiasEstimate', msg);
end
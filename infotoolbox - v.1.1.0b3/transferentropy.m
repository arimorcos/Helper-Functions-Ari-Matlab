function varargout = transferentropy(x, y, Opt, varargin)

%TRANSFERENTROPY Computes transfer entropy between two signals.
%
% SINTAX
%   [...] = transferentropy(X, Y, OPT, output list ...)
%
% INPUT
%   X           - The "causing" signal data matrix
%   Y           - The "caused" signal data matrix
%   OPT         - Option structure
%   output list - List of ouput arguments
%
%   -----------------
%   THE DATA MATRICES
%   -----------------
%   The function requires that the user specifies two types of data: the
%   "causing" signal X and the "caused" signal Y. This toolbox allows to
%   estimate transfer entropy, i.e. how much the knowledge of the past of X
%   allows to incrase the predictability over the present of Y.
% 
%   Both X and Y must be matrices of size NPT-by-NTR where NPT is the
%   number of points recorded in each trial while NTR is the number of
%   trials. Trials can be different recordings or the two signals or they
%   can just reflect the way the user wishes to break the data into blocks
%   for statistical testing (see "RANDOM TRIAL PERMUTATION" below).
% 
%   It is important to remind that, in order to compute transfer entropy
%   trials of X and corresponding trials of X must be simultaneously
%   recorded.
%
%   --------------------
%   THE OPTION STRUCTURE
%   --------------------
%   TRANSFERENTROPY is essentially a wrapper around function ENTROPY.
%   Consequently, TRANSFERENTROPY options include many of the options to
%   ENTROPY (exceptions are represented by the number-of-trials per
%   stimulus Opt.ne array and by the usage of the bootstrap option Opt.btsp
%   option, see below). Below is a list of the rquired and optional option
%   parameters: for a description of the inherited input options we refer
%   the user to the documentation of function ENTROPY.
%
%   The option structure includes obligatory and optional fields as
%   follows:
%
%
%      ====================================================
%      |                                                  |
%      | TRANSFERENTROPY-SPECIFIC INPUT OPTIONS           |
%      |                                                  |
%      |==================================================|
%      | REQUIRED PARAMETERS                              |
%      |==================================================|
%      | taux    | Lags considered for the causing signal |
%      |---------|----------------------------------------|
%      | tuay    | Lags considered for the caused signal  |
%      |==================================================|
%      | OPTIONAL PARAMETERS                              |
%      |==================================================|
%      | trperm  | Number of random trial permutations    |
%      ====================================================
%
%
%      ====================================================
%      |                                                  |
%      | INHERITED INPUT OPTIONS FROM FUNCTION ENTROPY    |
%      |                                                  |
%      |==================================================|
%      | REQUIRED PARAMETERS                              |
%      |==================================================|
%      | method  | Estimation method                      |
%      |---------|----------------------------------------|
%      | bias    | Bias correction procedure              |
%      |==================================================|
%      | OPTIONAL PARAMETERS                              |
%      |==================================================|
%      | btsp    | Number of bootstrap iterations         |
%      |---------|----------------------------------------|
%      | verbose | Perform extensive checks on inputs     |
%      ====================================================
%
%   Below is a description of the TRANSFERENTROPY-specific parameters:
%
%   Opt.taux and Opt.tauy
%   ---------------------
%       These field specify the lags in the past that need to be considered
%       for the causing signal X (Opt.taux) and the caused signal
%       (Opt.tauy). Lags are specified as arrays of STRICTLY NEGATIVE
%       integers.
%
%
%   Opt.trperm
%   ----------
%       This field must be a (non-negative) integer scalar specifying how
%       many trial-permutation estimates should be computed.
%
%       Trial-permutation estimates are computed after trials in X and Y
%       have been randomly permuted. This can be useful for bias performing
%       statistics on the transfer-etropy values or to estimate the effect
%       of a causing signal which is common to both X and Y.
%
%       For more information on which quantities allow bootstrapping see
%       see section "OUTPUT LIST" below.
%
%       IMPORTANT!
%       The Opt.trperm option CANNOT be specified in conjunction with the
%       Opt.btsp option. Specifying both options greater than zero will
%       result in an error.
%
%   ---------------
%   THE OUTPUT LIST
%   ---------------
%   The output list is used to specify which transfer-entropy quantities
%   need to be computed: these can be any of the string values in the table
%   below. Note that outputs are returned IN THE SAME ORDER specified in
%   the output list.
%
%       ==========================================================
%       | OPTION  | DECRIPTION                                   |
%       |========================================================|
%       | 'TE'    | X->Y t.e.                                    |
%       | 'TEsh'  | X->Y t.e. with shuffle correction            |
%       | 'NTE'   | normalized X->Y t.e.                         |
%       | 'NTEsh' | normalized X->Y t.e. with shuffle correction |
%       ==========================================================
%
%   WARNING!!!
%   ==========
%   Do not attempt computing NTE with versions of the toolbox prior to
%   v.1.1.0b2. Inovking this output with older versions of the toolbox with
%   result in MATLAB crashing.
%
%   Outputs options with bootstrap or trial-permutations
%   ----------------------------------------------------
%
%       Bootstrap (trial-permuted) estimates are returned to the user in
%       the form of an array of length Opt.trperm (Opt.trperm) concatenated
%       to the actual transfer-entropy estimate. For example, suppose that
%       TE is computed with Opt.btsp = 20. In this case the output
%       corresponding to TE will be an array of length 21: The first
%       element is the actual entropy estimate while the remaining 20
%       elements correspond to 20 distinct bootstrap estimates (see Fig.
%       2).
%
%
%                Actual | bootstrap (trial-permuted)
%              Estimate | estimates
%                       |
%           Index:    1 | 2   3   4      Opt.btsp+1 = 21
%                   ----|------------- ... -----
%                   | x | x | x | x |      | x |
%                   ----|------------- ... -----
%                       |
%
%   --------
%   EXAMPLES
%   --------
%   - The following example shows how to estimate X->Y t.e. using, the
%     direct method, the quadratic extrapolation bias correction, both in
%     the standard and normalized form and using 3 and 6 points in the past
%     for X and 3 points in the past for Y:
%
%       Opt.method = 'dr';
%       Opt.bias   = 'qe';
%       Opt.taux   = [-3 -6];
%       Opt.tauy   = -6;
%       [TE, NTE] = transferentropy(X, Y, Opt, 'TE', 'NTE');
%
%
%
%   -----------------------------------------------------------------------
%   TECHNICAL NOTE 1 - HOW TRANSFER-ENTROPY IS COMPUTED IN THIS ROUTINE
%   -----------------------------------------------------------------------
%   By the chain rule (see the "chain rule for information" in [1]) we have
%
%           I(Y1 Y2; X) = I(Y1; X) + I(Y2; X | Y1)
%
%   from which
%
%           I(Y2; X | Y1) = I(Y1 Y2; X) - I(Y1; X).
%
%   If we substitute Y1 = Ypast, Y2 = Xpast and X = Ypres we obtain
%
%           TE = I(Ypres ; Xpast | Ypast) =
%              = I(Ypast Xpast; Ypres) - I(Ypast; Ypres).
%
%   which expresses transfer entropy as the information about Ypres carried
%   by Xpast beyond that carried by Ypast. Here Ypast and Xpast can be
%   multi-dimensional arrays, e.g.
%
%           Ypres = Y(t);
%           Ypast = [Y(t-ty_1), ..., Y(t-ty_ny)];
%           Xpast = [X(t-tx_1), ..., X(t-tx_nx)];
%
%   where ty_1, ..., ty_ny are the ny delays for signal Y and tx_1, ...,
%   tx_nx are the nx delays for signal X.
% 
%   This formulation of the transfer entropy is also particularly
%   convenient for computation since Ypres is always one-dimensional while
%   Xpast and [Xpast Ypast] can be multi-dimensional responses.
%   Consequently:
%   - we can use the shuffling correction in the best possible way;
%   - bias increases due to increases in the dimensionality of Ypast (while
%     keeping the dimensionality of Xpast constant) will cancel each other
%     in the when taking the difference between the two information terms.
%
%   -----------------------------------------------------------------------
%   TECHNICAL NOTE 2 - HOW GOUREVITCH AND EGGERMONT NORMALIZATION IS 
%   COMPUTED IN THIS ROUTINE
%   -----------------------------------------------------------------------
%   The Normalized Transfer Entropy [2] is defined as
%
%           NTE = TE / H(Ypres | Ypast)
%
%   Using the chain rule for entropy we obtain:
%
%           H(X1 X2) = H(X1) + H(X1|X2)   -->   H(X2|X1) = H(X1 X2) - H(X1)
%
%   Sustituting X2 = Ypres and X1 = Ypast we have:
%
%           H(Ypres | Ypast) = H(Ypres Ypast) - H(Ypres)
%
%   REFERENCES
%   ----------
%   [1] TM Cover, JA Thomas, "Elements of Information Theory - Second
%       Edition", Wiley Interscience
%
%   [2] B Gourevitch, JJ Eggermont, "Evaluating Information Transfer between
%       Auditory Cortical Neurons", Journal of Neurophysiology, 97, 2533-2543

%   Copyright (C) 2010 Cesare Magri
%   Version: 1.1.0

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



% Input parsing -----------------------------------------------------------

xtau = Opt.taux;
ytau = Opt.tauy;

if any(xtau>=0 | ytau>=0)
    error('Only negative delays can be specified.');
end

[nPntX, nTrlX] = size(x);
[nPntY, nTrlY] = size(y);
if nPntX~=nPntY && nTrlX~=nTrlY
    error('Size of the two input matrices must be the same.');
else
    nTrl = nTrlX;
    nPnt = nPntX;
end

whereTE    = strcmpi(varargin, 'te'   );
whereTEsh  = strcmpi(varargin, 'tesh' );
whereNTE   = strcmpi(varargin, 'nte'  );
whereNTEsh = strcmpi(varargin, 'ntesh');

doTE    = true; % we always need to compute TE
doTEsh  = any(whereTEsh);
doNTE   = any(whereNTE);
doNTEsh = any(whereNTEsh);

nOut = any(whereTE) + doTEsh + doNTE + doNTEsh;

% Making BTSP and TRPERM options mutually exclusive
if (isfield(Opt, 'btsp') && Opt.btsp>0) && (isfield(Opt, 'trperm') && Opt.trperm>0)
    msg = 'Options BTSP and TRPERM cannot be specified together.';
    error('TRANSFERENTROPY:btspAndTrperm', msg);
    
elseif (isfield(Opt, 'btsp') && Opt.btsp>0)
    nTestRep = Opt.btsp;
    
elseif (isfield(Opt, 'trperm') && Opt.trperm>0)
    % Are there trials at all?
    if nTrl==1
        msg = 'No trials to permute.';
        error('TRANSFERENTROPY:noTrialForTrperm', msg);
    end

    nTestRep = Opt.trperm;
    
else
    nTestRep = 0;
    
end

% Creating matrices with delayed copies of the signals --------------------
outLen = nPnt + min([xtau(:); ytau(:)]); % Using "+" since all tau are negative!

x_with_delays = subTimeShiftedReplica(x, xtau(:), outLen);

% For Y we include also delay zero:
ytau_with_zero = [0; ytau(:)];
y_with_delays = subTimeShiftedReplica(y, ytau_with_zero, outLen);


% Computing transfer entropy values ---------------------------------------
TE    = zeros(nTestRep+1, 1);
TEsh  = zeros(nTestRep+1, 1);
NTE   = zeros(nTestRep+1, 1);
NTEsh = zeros(nTestRep+1, 1);

% Computing transfer-entropy quantities:
[TE(1), TEsh(1), NTE(1), NTEsh(1)] = subTeEngine(x_with_delays(:,:), y_with_delays(:,:), Opt, doTE, doTEsh, doNTE, doNTEsh);


% Random trial pairing ----------------------------------------------------
for testRepInd=1:Opt.trperm
    % Randomly permuting trials in XMAT:
    x_with_delays = x_with_delays(:, :, randperm(nTrl));
    
    [TE(testRepInd+1), TEsh(testRepInd+1), NTE(testRepInd+1), NTEsh(testRepInd+1)] = ...
        subTeEngine(x_with_delays(:,:), y_with_delays(:,:), Opt, doTE, doTEsh, doNTE, doNTEsh);
    
end

% Assigning output --------------------------------------------------------
varargout = cell(nOut,1);
varargout(whereTE)    = {TE};
varargout(whereTEsh)  = {TEsh};
varargout(whereNTE)   = {NTE};
varargout(whereNTEsh) = {NTEsh};



% =========================================================================
function [TE, TEsh, NTE, NTEsh] = subTeEngine(xmat, ymat, OptInfo, ...
                                  doTE, doTEsh, doNTE, doNTEsh)
% =========================================================================

%SUBTEENGINE Computes the transfer-entropy values
%
% USAGE
%   [TE, TESH, NTE, NTESH] = SUBTEENGINE(XMAT, YMAT, OPTINFO, DOTE, DOTESH, DONTE, DONTESH)
%
% INPUT
%   XMAT
%   YMAT
%   OPTINFO
%   DOTE
%   DOTESH
%   DONTE
%   DONTESH
%
% OUTPUT
%   

% I1 = I(Ypast; Ypres)
[R1, OptInfo.nt] = buildr(ymat(1,:), ymat(2:end,:));
if doTE || doNTE
    I1 = information(R1, OptInfo, 'I');
end
        
if doTEsh || doNTEsh
    I1sh = information(R1, OptInfo, 'Ish');    
end


% I2 = I(Ypast Xpast; Ypres)
[R2, OptInfo.nt] = buildr(ymat(1,:), [ymat(2:end,:); xmat]);
if doTE || doNTE
    I2 = information(R2, OptInfo, 'I');
end

if doTEsh || doNTEsh
    I2sh = information(R2, OptInfo, 'Ish');
end

% Computing normalization factor:
if doNTE || doNTEsh
    % H1 = H(Ypres Ypast)
    OptInfo.nt = size(ymat(:,:),2);
    OptInfo.bias = 'pt';
    HR1 = entropy(ymat(:,:), OptInfo, 'HR');
    
    % H2 = H(Ypres)
    OptInfo.nt = size(ymat(:,:),2);
    HR2 = entropy(ymat(1,:), OptInfo, 'HR');
    
    normFact = HR1 - HR2;
end

% Computing transfer-entropy:
if doTE || doNTE
    TE = I2 - I1;
else
    TE = 0;
end

% Computing transfer entropy with shuffling correction:
if doTEsh || doNTEsh
    TEsh = I2sh - I1sh;
else
    TEsh = 0;
end

% Computing normalized transfer entropy:
if doNTE
    NTE = (I2 - I1) / normFact;
else
    NTE = 0;
end

% Computing normalized transfer entropy with shuffling correction:
if doNTEsh
    NTEsh = (I2sh - I1sh) / normFact;
else
    NTEsh = 0;
end



% =========================================================================
function out = subTimeShiftedReplica(x, negTauVec, outLen)
% =========================================================================

%SHIFTED_REPLICA Returns matrix with replica of an array shifted by
% different negative delays.
%
% USAGE
%   OUT = SHIFTED_REPLICA(X, NEGTAUVEC, OUTLEN)
%
% INPUT
%   X         - array that we wish to time-shift
%   NEGTAUVEC - array of negative time shifts
%   OUTLEN    - desired output length (must be smaller than LENGTH(X))

nTrl = size(x,2);
negTauVecLen = length(negTauVec);
minNegTau = min(negTauVec);

out = zeros(negTauVecLen, outLen, nTrl);

for negTauInd=1:negTauVecLen

    negTau = negTauVec(negTauInd);

    posTau = negTau - minNegTau;

    if negTau<0
        xshift = subIntShift(x, negTau);
    else
        xshift = x;
    end

    if posTau>0
        out(negTauInd, :, :) = subIntShift(xshift, posTau);
    else
        out(negTauInd, :, :) = xshift(1:outLen, :);
    end

end



% =========================================================================
function y = subIntShift(x, tau)
% =========================================================================
%INTSHIFT4TRANSFERENTROPY Shifts a signal in time.
%
% USAGE
%   Y = TIMESHIFT(X, TAU);
%   Y = TIMESHIFT(X, TAU, N);
%
% INPUT
%   X   - time series to be time-shifted. If X is an N-by-M array than each
%         row of X corresponds to a sample of the time-series while the M
%         columns are M distinct observations.
%   TAU - lag by which the signal needs to be shifted (can be negative or
%         positive).

if tau>0
    y = x(tau+1:end, :);
    
elseif tau==0
    y = x;
    
elseif tau<0
    y = x(1:end+tau, :); % Using "+" since tau negative
    
end
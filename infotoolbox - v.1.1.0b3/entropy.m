function varargout = entropy(R, Opt, varargin)

%ENTROPY Compute entropy and entropy-like quantities.
%
%   ------
%   SYNTAX
%   ------
%       [...] = entropy(R, Opt, output list ...)
%
%   ---------
%   ARGUMENTS
%   ---------
%   R           - Response matrix.
%   Opt         - Options structure.
%   output list - List of strings specifying what to compute.
%
%   -------------------
%   THE RESPONSE MATRIX
%   -------------------
%   L-dimensional responses to S distinct stimuli are stored in a response
%   matrix R of size L-by-T-by-S, T being the maximum number of trials
%   available for any of the stimuli. Emtpy trials, i.e., elements of R not
%   corresponding to a recorded response, can take any value.
%
%   Function BUILDR is provided to easily 
%
%   In the figure below an example response matrix is shown which stores
%   two-dimensional responses (L=2) to three stimuli (S=3). The maximum
%   number of trials is 4 (T=4) although the number of trials varies for
%   each stimulus: 4 trials are available for the first stimulus, 2 for the
%   second and 3 for the third. The number of trials per stimulus must be
%   stored separately in the NT array (see "THE OPTION STRUCTURE" section
%   below).
%
%                             ----------------- 
%                             | x | x | x | - |
%                             |---------------|
%                             | x | x | x | - |
%                             -----------------
%                        -----------------        /
%                        | x | x | - | - |       /
%                        |---------------|      /
%                        | x | x | - | - |     / 
%                        -----------------    /
%              |    -----------------        / S=3
%              |    | x | x | x | x |       /
%          L=2 |    |---------------|      /
%              |    | x | x | x | x |     /
%              |    -----------------    /
%      
%                   -----------------
%                          T=4
%
%       FIGURE 1: Example structure of a response matrix storing
%       two-dimensional responses to three distinct stimuli. 
%                         
%                         
%   ---------------------
%   THE OPTIONS STRUCTURE
%   ---------------------
%   The option structure includes obligatory and optional fields as
%   follows:
%
%      ================================================
%      |                                              |
%      | OPTIONS SYNOPSIS                             |
%      |                                              |
%      |==============================================|
%      | REQUIRED PARAMETERS                          |
%      |==============================================|
%      | nt      | Number of trials per stimulus      |
%      |---------|------------------------------------|
%      | method  | Estimation method                  |
%      |---------|------------------------------------|
%      | bias    | Bias correction procedure          |                              
%      |==============================================|
%      | OPTIONAL PARAMETERS                          |
%      |==============================================|
%      | btsp    | Number of bootstrap iterations     |
%      |---------|------------------------------------|
%      | xtrp    | Number of extrapolation iterations |
%      |---------|------------------------------------|
%      | verbose | Perform extensive checks on inputs |
%      ================================================
%
%   Below is a description of the individual parameters.
%
%
%   Opt.nt
%   ------
%       This field specifies the number of trials (responses) recorded for
%       each stimulus. It can be either a scalar (for constant number of
%       trials per stimulus) or an array of length S.
%
%       nt must satisfy the following two conditions:
%       - max(nt) = T
%       - length(nt) = S (if nt is an array)
%
%   Opt.method
%   ----------
%       This field specifies which estimation method to use and can be one
%       of the following strings:
%
%       =============================
%       | OPTION  | DECRIPTION      |
%       =============================
%       | 'dr'    | Direct method   |
%       | 'gs'    | Gaussian method |
%       =============================
%
%   IMPORTANT!
%   ==========
%       The direct method requires the response values to be discretized
%       into non-negative integer values (this is meant only in a numerical
%       sense, the MATLAB variable still needs to be of type double). See
%       function BINR.M for instruction on how to discretize the responses.
%       Failing to properly discretizing the response will result in Matlab
%       crashing.
%
%   Opt.bias
%   --------
%       This field specifies the bias correction procedure. The following
%       options are available as built-in bias correction procedures:
%
%       =====================================
%       | OPTION  | DECRIPTION              |
%       |===================================|
%       | 'qe'    | quadratic extrapolation |
%       | 'pt'    | Panzeri & Treves 1996   |
%       | 'gsb'   | gaussian bias           |
%       | 'naive' | naive estimates         |
%       =====================================
%
%       In addition to the included bias correction listed above, the user
%       can call his/her own custom bias correction functions (see "WRITING
%       AND CALLING CUSTOM BIAS CORRECTION FUNCTIONS" below). To call a
%       custom corrections just set the Opt.bias field to the name of the
%       m-file implementing the correction. Note that not all quantities
%       can be corrected see below.
%
%   Opt.btsp (optional, default: Opt.btsp = 0)
%   ------------------------------------------
%       This field must be a (non-negative) integer scalar specifying how
%       many bootstrap iterations should be performed.
%
%       Bootstrap estimates are computed by means of pairing stimuli and
%       responses at random and computing the entropy quantities for these
%       random pairings. Each estimate corresponds to a different random
%       pairing configuration. These estimates are useful as an additional
%       bias correction or for performing statistics on the entropy values.
%
%       For more information on which quantities allow bootstrapping see
%       see section "OUTPUT LIST" below.
%
%   Opt.xtrp (optional, default: Opt.xtrp = 0)
%   ------------------------------------------
%       This field must be a (non-negative) scalar specifying how many 
%       iterations repetitions of the extrapolation procedure should be
%       performed.
%
%       Extrapolations procedure (such as the quadratic extrapolation)
%       perform bias estimation by computing entropy values on sub-groups
%       of the available trials. These subgroups are created randomly. The
%       xtrp option allows to average the extrapolation values over as many
%       different random partitions as specified by the parameter.
%
%   Opt.verbose (optional, default: Opt.verbose = false)
%   ----------------------------------------------------
%       If this field exists and is set to true a summary of the selected
%       options is displayed and additional checks are performed on the
%       input variables. NO WARNINGS ARE DISPLAYED UNLESS THIS OPTION IS
%       ENABLED.
%
%       This feature is useful to check whether ENTROPY is being called
%       correctly. It is therefore highly reccomended to new users or when
%       first running of the program with new input options. However, keep
%       in mind that these checks drammatically increases computation time
%       and are thus not reccommended for computationally intensive
%       sessions.
%
%       If a custom bias correction function is called (see "BUILDING AND
%       CALLING CUSTOM BIAS CORRECTION FUNCTIONS" below) tests are
%       performed on the invoked function to check whether it satisfied
%       the requirements of the toolbox.
%   
%   ---------------
%   THE OUTPUT LIST
%   ---------------
%   The output list is used to specify which IT quantities need to be
%   computed: these can be any of the string values in the table below.
%   Note that outputs are returned IN THE SAME ORDER specified in the
%   output list.
%
%       ========================
%       | OPTION  | DECRIPTION |
%       |======================|
%       | 'HR'    | H(R)       |
%       | 'HRS'   | H(R|S)     |
%       | 'HlR'   | H_lin(R)   |
%       | 'HiR'   | H_ind(R)   |
%       | 'HiRS'  | H_ind(R|S) |
%       | 'ChiR'  | Chi(R)     |
%       | 'HshR'  | H_sh(R)    |
%       | 'HshRS' | H_sh(R|S)  |
%       ========================
%
%   Outputs options with bootstrap
%   ------------------------------
%       Bootstrap estimates make sense (and can thus be computed) only for
%       the following output quantities: 'HRS', 'HiR', 'HiRS', 'ChiR' and
%       'HshRs'.
%
%       If the user only specifies the number of bootstrap repetitions
%       (through the BTSP parameter) bootstrap estimates are computed for
%       any of the above quantities which appears in the output list.
%
%       However users are given the opportunit to precisely select which
%       quantities to compute bootstrap for by means of appending 'bs' to
%       the output string name of an output quantitie as follows:
%
%                           'HRS'   --> 'HRSbs'
%                           'HiR'   --> 'HiRbs'
%                           'HiRS'  --> 'HiRSbs'
%                           'ChiR'  --> 'ChiRbs'
%                           'HshRS' --> 'HshRSbs'
%
%       Carefully selecting for which quantities to compute bootstrap can
%       greately decrease computation times. For example, bootstrap
%       estimates of HiR and ChiR are often useless although their
%       computation can be very time consuming.
%
%       Bootstrap estimates are returned to the user in the form of an
%       array of length Opt.btsp concatenated to the actual entropy
%       estimate. For example, suppose that HRS is computed with Opt.btsp =
%       20. In this case the output corresponding to HRS will be an array
%       of length 21: The first element is the actual entropy estimate
%       while the remaining 20 elements correspond to 20 distinct bootstrap
%       estimates (see Fig. 2).
%
%
%                Actual | Bootstrap
%              Estimate | Estimates
%                       |
%           Index:    1 | 2   3   4      Opt.btsp+1 = 21
%                   ----|------------- ... -----
%                   | x | x | x | x |      | x |
%                   ----|------------- ... -----
%                       |
%                       
%
%   Allowed combinations
%   --------------------
%       Not all combinations of method, bias and output options are
%       available. For example, bias correction 'pt' can only be used with
%       method 'dr'. If 'pt' is called in conjunction with method 'gs',
%       then ENTROPY will apply no bias correction AT ALL (i.e. it will
%       return naive estimates). However, by default, NO message will be
%       displayed. To be prompted with warnings, the verbose option must be
%       enabled (see above). The possible combinations of method, bias
%       and output options are summarized in the following tables:
%
%       ==========================================================
%       | DIRECT METHOD                                          |
%       |========================================================|
%       |         |         |      |       |       |    user     |
%       |         | 'naive' | 'qe' | 'pt'  | 'gsb' |   defined   |
%       |         |         |      |       |       | corrections |
%       |========================================================|
%       | 'HR'    |    x    |   x  |   x   |   n   |      x      |
%       |---------|--------------------------------|-------------|
%       | 'HRS'   |    x    |   x  |   x   |   n   |      x      |
%       |---------|--------------------------------|-------------|
%       | 'HlR'   |    x    |   x  |   x   |   n   |      x      |
%       |---------|--------------------------------|-------------|
%       | 'HiR'   |    x    |   x  |   n   |   n   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HiRS'  |    x    |   x  |   x   |   n   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'ChiR'  |    x    |   x  |   n   |   n   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HshR'  |    x    |   x  |   x   |   n   |      x      |
%       |---------|--------------------------------|-------------|
%       | 'HshRS' |    x    |   x  |   x   |   n   |      x      |
%       |========================================================|
%       | Legend  | x - combination available                    |
%       |         | n - 'naive' estimate returned                |
%       |         | 0 - zero returned                            |
%       ==========================================================
%
%
%       ==========================================================
%       | GAUSSIAN METHOD                                        |
%       |========================================================|
%       |         |         |      |       |       |    user     |
%       |         | 'naive' | 'qe' | 'pt'  | 'gsb' |   defined   |
%       |         |         |      |       |       | corrections |
%       |========================================================|
%       | 'HR'    |    x    |   x  |   n   |   x   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HRS'   |    x    |   x  |   n   |   x   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HlR'   |    x    |   x  |   n   |   x   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HiR'   |    0    |   0  |   0   |   0   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HiRS'  |    x    |   x  |   n   |   x   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'ChiR'  |    0    |   0  |   0   |   0   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HshR'  |    x    |   x  |   n   |   x   |      n      |
%       |---------|--------------------------------|-------------|
%       | 'HshRS' |    x    |   x  |   n   |   x   |      n      |
%       |========================================================|
%       | Legend  | x - combination available                    |
%       |         | n - 'naive' estimate returned                |
%       |         | 0 - zero returned                            |
%       ==========================================================
%
%   --------
%   EXAMPLES
%   --------
%   In the following examples, we assume R to be a 2-by-10-by-3 matrix
%   i.e., R stores 2-dimensional responses to 3 different stimuli. We also
%   assume that, while 10 trials are available for stimulus 1 and 2, only 7
%   trials have been recorded for stimulus 3.
%
%   - Estimate H(R) using all values in R, the direct method and no bias
%     correction:
%
%       Opt.nt = [10 10 7];
%       Opt.method = 'dr';
%       Opt.bias = 'naive';
%       X = entropy(R, Opt, 'HR');
%
%   - Compute H_ind(R) and H(R) using the direct method and quandratic
%     extrapolation bias correction:
%
%       Opt.nt = [10 10 7];
%       Opt.method = 'dr';
%       Opt.bias = 'qe';
%       [X, Y] = entropy(R, Opt, 'HiR', 'HR');
%
%     where the estimate of H_ind(R) is stored in the X variable and that
%     of H(R) in Y.
%
%   - Compute direct naive gaussian estimtes of H(R) and H(R|S) together 
%     with 20 bootstrap estimates of H(R|S):
%
%       Opt.nt = [10 10 7];
%       Opt.method = 'gs';
%       Opt.bias = 'naive';
%       Opt.btsp = 20;
%       [X, Y] = entropy(R, Opt, 'HR', 'HRS');
%
%     Note that, in this case, Y is an array of size 21-by-1: Y(1) gives
%     the estimate for H(R|S) computed using the input matrix R; Y(2:21)
%     are are 20 distinct bootstrap estimates of H(R|S).
%
%   -------
%   REMARKS
%   -------
%   - Field-names in the option structure are case-sensitive
%
%   - Ouput options are NOT case sensitive, i.e., they are case-INsensitive
%
%   - It is more efficient to call ENTROPY with several output options
%     rather than calling the function repeatedly. For example:
%
%         [X, Y] = entropy(R, Opt, 'HR', 'HRS');
%
%     performs faster than
%
%         X = entropy(R, Opt, 'HR');
%         Y = entropy(R, Opt, 'HRS');
%
%   - Some MEX files in the toolbox create static arrays which are used
%     to store computations performed in previous calls to the routines.
%     This memory is freed automatically when Matlab is quitted. However,
%     consider using
%
%         clear mex;
%
%     when needing to free all of Matlab's available memory.
%
%   - The gaussian method is optimized for call to the toolbox using L
%     lower or equal to 4.
%
%   -----------------------------------------------------
%   BUILDING AND CALLING CUSTOM BIAS CORRECTION FUNCTIONS
%   -----------------------------------------------------
%
%   In the direct method each value, P(r), of a probability distribution is
%   estimated using the normalized count, C(r), of occurrence of the
%   response r as
%
%              C(r)
%       P(r) = ----
%               N
%
%   Let C be an <Nr x 1> array containing the count C(r) for the Nr
%   different responses. Since
%
%       Nr = length(C);
%       N  = sum(C);
%       P  = C ./ N;
%
%   C contains all the information regarding the probability distribution
%   P(r) and thus also all the parameters necessary for estimation of the
%   bias of H(R). The same applies to the estimation of the other stimulus-
%   unconditional probabilities, such as P_sh(r), and also to the stimulus-
%   conditional probabilities: in the stimulus-conditional case bias
%   correction is performed for each of the Ns probability distributions
%   P(r|s) and then averaged across stimuli.
%
%   Users can define their custom bias correction methods as follows: let
%   CUSTOM_BIASCORR_FUNC be the name of the user-defined correction routine
%   (any valid MATLAB function name can be used, see Matlab documentation).
%   This function must receive as input the array C of size <Nr x 1>
%   described above and return the (positive) value to be ADDED to the
%   plugin entropy estimate:
%       
%       bias = custom_biascorr_func(C)
%
%   To call the custom bias correction functon simply pass the name of the
%   function as a string in the Opt.bias field. For the above example we
%   have
%       
%       Opt.bias = 'custom_biascorr_func';
%
%   See also BUILDR, BINR, INFORMATION

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


% ----------------------
% REMARKS FOR DEVELOPERS
% ----------------------
% - Starting with version 1.0.3 the distinction between H_lin(R|S) and
%   H_ind(R|S) is not longer made visible to the user. When invoking HiRS
%   the program actually computes H_lin(R|S) because of its more desirable
%   properties. However, H_ind(R|S) can be still computed according to its
%   P_ind(r|s)-based definition by calling the option 'HiRSdef'. The
%   distinction between the two quantities is, however, kept throughout the
%   program, therefore, remember: HiRS in the program is called HlRS!
%
% - Starting with version 1.1.0b1 an hidden Opt.testMode field was added
%   which sets the toolbox function into "test mode". When set to 'true'
%   (default value is 'false') this option allows to:
%   - skip shuffling before computation of HshR and HshRS (thus making 
%     HshR computation equal to that of HR and that of HshRS equal to the
%     computation of HRS)
%   - skip shuffling before partition extraction in the quadratic
%     extrapolation procedure.
%   - use a custom method function by simply passing the name of the
%     function as a string in the Opt.method field (useful for comparing
%     new method functions with old ones)
%   Test mode simplifies the task of verifying the correctness of the
%   toolbox functions and to compare its results with previous versions or
%   with other routines.

if nargin < 3
	help entropy;
	return;
end



% INPUT PARSING ===========================================================
responseMatrixName = inputname(1);
if isfield(Opt, 'pars')
    pars = Opt.pars;
else
    pars = build_parameters_structure_v6(R, Opt, responseMatrixName, varargin{:});
end
% -------------------------------------------------------------------------



% COMPUTING ENTROPIES =====================================================
HRS   = zeros(pars.Ns, (pars.btsp * pars.doHRSbs  )+1);
HlRS  = zeros(pars.Ns, (pars.btsp * pars.doHlRSbs )+1);
HiR   = zeros(1      , (pars.btsp * pars.doHiRbs  )+1);
ChiR  = zeros(1      , (pars.btsp * pars.doChiRbs )+1);
HshRS = zeros(pars.Ns, (pars.btsp * pars.doHshRSbs)+1);

pars.isBtsp  = 0;
if pars.biasCorrNum==1
    [HR, HRS(:,1), HlR, HlRS(:,1), HiR(1), HiRS, ChiR(1), HshR, HshRS(:,1)] = xtrploop(R, pars);
else
    [HR, HRS(:,1), HlR, HlRS(:,1), HiR(1), HiRS, ChiR(1), HshR, HshRS(:,1)] = pars.methodFunc(R, pars);
end

Ps = pars.Nt ./ pars.totNt;
% Bootstrap
if pars.btsp>0
    
    % Setting bootstrap "do options". No bootstrap is computed for HR, HlR,
    % HiRS (this quantity is only computed for test purposes) and HshR:
    pars.doHR    = false;
    pars.doHRS   = pars.doHRSbs;
    pars.doHlR   = false;
    pars.doHlRS  = pars.doHlRSbs;
    pars.doHiR   = pars.doHiRbs;
    pars.doHiRS  = false;
    pars.doChiR  = pars.doChiRbs;
    pars.doHshR  = false;
    pars.doHshRS = pars.doHshRSbs;
    
    % Signaling that the response matrix needs to be bootstrapped:
    pars.isBtsp  = 1;

    % In the bootstrap loop we use the following trick: suppose we need to
    % compute bootstrap for HRS, then "pars.HRSbs = true" and
    %
    %   k:k*pars.doHRSbs = k:k*1 = k
    %
    % If bootstrap need not be computed we have "pars.HRSbs = false" and
    %
    %   k:k*pars.doHRSbs = k:k*0 = k:0 = []
    %
    % Thus, since the instruction "x([]) = value" does not produce any
    % effect, we have that for "pars.doHRSbs = true" the instruction
    %
    %   HRS(:,k:k*pars.doHRSbs) = value;
    %
    % will store the value on the right in HRS(:,k) while for "pars.doHRSbs
    % = false" the same instruction will produce no effect.
    
    for k=2:pars.btsp+1
        
        % For the direct method (methodNum==1) the bootstrap permutation
        % are currently performed outside the method function:
        if pars.methodNum~=3
            % Randperm (inlining for speed):
            [ignore, randIndxes] = sort(rand(pars.totNt,1));
            % Randomly assigning trials to stimuli as defined by NT:
            R(:, pars.trials_indxes(randIndxes)) = R(:, pars.trials_indxes);
        end
        
        if pars.biasCorrNum==1
            [ignore2, HRS(:,k:k*pars.doHRSbs), ignore3, HlRS(:,k:k*pars.doHlRSbs), HiR(:,k:k*pars.doHiRbs), ignore4, ChiR(:,k:k*pars.doChiRbs), ignore5, HshRS(:,k:k*pars.doHshRSbs)] = ...
                xtrploop(R, pars); %#ok<ASGLU>
        else
            [ignore2, HRS(:,k:k*pars.doHRSbs), ignore3, HlRS(:,k:k*pars.doHlRSbs), HiR(:,k:k*pars.doHiRbs), ignore4, ChiR(:,k:k*pars.doChiRbs), ignore5, HshRS(:,k:k*pars.doHshRSbs)] = ...
                pars.methodFunc(R, pars); %#ok<ASGLU>
        end
    end
    
    Ps_bootstrap = Ps(:, ones(pars.btsp+1,1));
    
end % ---------------------------------------------------------------------



% ASSIGNING OUTPUTS =======================================================
varargout = cell(pars.Noutput,1);

% Assigning HR output
varargout(pars.whereHR) = {HR};

% Assigning HRS output
if pars.doHRSbs && pars.btsp>0
    % Bootstrap case:
    varargout(pars.whereHRS)   = {sum(  HRS .* Ps_bootstrap, 1)};
else
    % NON_bootstrap case:
    varargout(pars.whereHRS)   = {sum(  HRS(:,1) .* Ps, 1)};
end

if pars.Nc==1
    varargout(pars.whereHlR)   = {HR};
    varargout(pars.whereHshR)  = {HR};
    
    if pars.doHlRSbs && pars.btsp>0
        varargout(pars.whereHlRS)  = {sum(  HRS .* Ps_bootstrap, 1)};
    else
        varargout(pars.whereHlRS)  = {sum(  HRS(:,1) .* Ps, 1)};
    end
    
    varargout(pars.whereHiRS)  = {sum(  HRS(:,1) .* Ps, 1)};
    
    if pars.doHshRSbs && pars.btsp>0
        varargout(pars.whereHshRS) = {sum(  HRS .* Ps_bootstrap, 1)};
    else
        varargout(pars.whereHshRS) = {sum(  HRS(:,1) .* Ps, 1)};
    end
    
    switch pars.methodNum
        case 1
            varargout(pars.whereHiR)  = {HR};
            varargout(pars.whereChiR) = {HR};
            
        % In the gaussian method case we return NaN for consistency with
        % the NC>1 case:
        case 2
            varargout(pars.whereHiR)  = {NaN};
            varargout(pars.whereChiR) = {NaN};
    end
else 
    varargout(pars.whereHlR)   = {HlR};
    
    if pars.doHlRSbs && pars.btsp>0
        varargout(pars.whereHlRS)  = {sum( HlRS .* Ps_bootstrap, 1)};
    else
        varargout(pars.whereHlRS)  = {sum( HlRS .* Ps(:, ones((pars.btsp * pars.doHlRSbs) + 1, 1)), 1)};
    end
    varargout(pars.whereHiR)   = {HiR};
    
    % HiRS is simply a test quantity, we don't consider bootstrap for it.
    varargout(pars.whereHiRS)  = {sum( HiRS .* Ps, 1)};
    
    varargout(pars.whereChiR)  = {ChiR};
    varargout(pars.whereHshR)  = {HshR};
    
    if pars.doHshRSbs && pars.btsp>0
        varargout(pars.whereHshRS) = {sum(HshRS .* Ps_bootstrap, 1)};
    else
        varargout(pars.whereHshRS) = {sum(HshRS .* Ps, 1)};
    end
end
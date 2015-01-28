function x = bin(x, nb, opt)

% BINR Discretize the response matrix.
%
%   -----
%   INPUT
%   -----
%       R   - response matrix to be discretized
%       NT  - number of trials per stimulus array
%       NB  - number of bins array
%       OPT - binning options
%       PAR - optional parameters
%
%   -------------------
%   THE RESPONSE MATRIX
%   -------------------
%   L-dimensional responses to S distinct stimuli are stored in a response
%   matrix R of size L-by-T-by-S, T being the maximum number of trials
%   available for any of the stimuli. Emtpy trials, i.e., elements of R not
%   corresponding to a recorded response, can take any value.
%
%   -----------------------------------
%   NUMBER OF TRIALS PER STIMULUS ARRAY
%   -----------------------------------
%   This input specifies the number of trials (responses) recorded for each
%   stimulus. It can be either a scalar (for constant number of trials per
%   stimulus) or an array of length S.
%
%   nt must satisfy the following two conditions:
%   - max(nt) = T
%   - length(nt) = S (only if nt is an array)
%
%   --------------
%   NUMBER OF BINS
%   --------------
%   This input specifies the number of bins used for discretizing each
%   response: these values must be (non-null) intergers.
%
%   NB can be either:
%   - a scalar: in this case all L response are discretized using the same
%     number of bins.
%   - an array of length L: in this case the i-th value in NB specifies the
%     number of bins used to discretize the i-th response.
%
%   ------------------------------
%   BINNING OPTIONS AND PARAMETERS
%   ------------------------------
%
%   The binning option specifies which method to use for discretizing the
%   response matrix. It can be either:
%   - a string or a cell-array of unit length): in thie case all L
%     responses are discretized using the same method;
%   - a cell array of length L: in this case the i-th cell field specifies
%     the  binning method used for the i-th response..
%
%   The table below describe the binning options which are built-in in the
%   toolbox. Alternatively, users can define and plug-in their custom
%   binning methods (see "BUILDING AND CALLING CUSTOM BINNING FUNCTIONS"
%   below).
%
%   Some of the built-in binning options allow a parameter to be specify.
%   Parameters can be passed in a similar fashio to the options:
%   - if a single parameter needs to be specified for all responses it can
%     be passed directly or in the form of a one dimensional cell-array;
%   - if different parameters need to be specified for the different
%     binning options or response, then a cell array of length L must be
%     passed to the function where each field specifies the binnign option
%     for the i-th response. To skip the parameter for a response just pass
%     an empty array [] for that response.
%
%   =======================================================================
%   | OPTION      | DESCRIPTION                                           |
%   =======================================================================
%   | 'eqpop'     | EQUIPOPULATED BINNING                                 |
%   |             | ---------------------                                 |
%   |             | The width of the bins is selected so that each bin    |
%   |             | contains (approximately) the same number of values.   |
%   |             |                                                       |
%   |             | Note: using this option for responses which are not   |
%   |             | continuous in nature (i.e., which contain several     |
%   |             | repeated values) may result in the bins being poorly  |
%   |             | equipopulated.                                        |
%   |-------------|-------------------------------------------------------|
%   | 'eqspace'   | EQUISPACED BINNING                                    |
%   |             | ------------------                                    |
%   |             | The range [a, b], provided as a parameter by the user |
%   |             | in the form of a 2-element array, is divided into bins|
%   |             | of equal width. If no interval is specified, then the |
%   |             | range [m, M] (m and M being the max and min of the    |
%   |             | values to be binned, respectively) is used.           |
%   |             |                                                       |
%   |             | Note: a check is performed on whether the specified   |
%   |             | interval includes all values to be binned.            |
%   |-------------|-------------------------------------------------------|
%   | 'ceqspace'  | CENTERED EQUISPACED BINNING                           |
%   |             | ---------------------------                           |
%   |             | The range [C-D,C+D], C being the mean of the values   |
%   |             | to be binned and D = max(C-m, M-C) (m and M being     |
%   |             | defined as above), is divided into intervals of equal |
%   |             | width.                                                |
%   |-------------|-------------------------------------------------------|
%   | 'gseqspace' | GAUSSIAN EQUISPACED BINNING                           |
%   |             | ---------------------------                           |
%   |             | The range [C-N*STD, C+N*STD] (STD being the standard  |
%   |             | deviation of the values to be binned, C being defined |
%   |             | as above and N being a parameter which is passed to   |
%   |             | the function) is divided into intervals of equal      |
%   |             | width. If no N is specified, N=2 is used.             |
%   |             |                                                       |
%   |             | Note: if any of the values falls outside the selected |
%   |             | range the first and last bin are stretched in order   |
%   |             | to accomodate outliers falling below or above the     |
%   |             | range limits, respectively.                           |
%   =======================================================================
%
%   --------
%   EXAMPLES
%   --------
%
%   1 - Suppose that R contains 10 trials two response (i.e., L=2). The
%       instruction
%
%          R_binned = binr(R, 10, 6, 'eqspace');
%
%       produces a response matrix in which both responses have been binned
%       into 6 equi-sapced bins. The previous instruction is equivalent to
%
%           R_binned = binr(R, 10, 6, {'eqspace'});
%
%       where we used a one-dimensional cell instead of the string.
%
%   2 - Suppose we wish to specify two different binning options for
%       binning the two responses. The instruction
%
%           R_binned = binr(R, 10, 6, {'eqspace'; 'eqpop'};
%
%       produces a deiscretized response matrix in whith the first response
%       (R(1,:,:)) has been binned into 6 equi-spaced bins and the second
%       response (R(2,:,:)) into 6 equi- populated values.
%
%   3 - Additionally, the two responses can be binne dusing different
%       number of bins: the instruction
%
%           R_binned = binr(R, 10, [4, 6], {'eqspace'; 'eqpop'};
%
%       produces a response matrix in which R(1,:,:) has been binned into 4
%       equi-spaced bins while R(2,:,:) takes 6 equi-populated values.
%
%   4 - In the previous examples, when discretizing the responses using the
%       equi-spaced method, we made use of the default option for this
%       binning method which consists in taking the min and max of the
%       response values as a range which is equally partitioned.
%
%   ------
%   OUTPUT
%   ------
%
%   The fuction returns the response matrix R in which the values have been
%   binned, according to the selected method, into integer ranging from 0
%   to NB. Values in the response matrix that do not correspond to trials
%   are set to -1.
%
%   ---------------------------------------------
%   BUILDING AND CALLING CUSTOM BINNING FUNCTIONS
%   ---------------------------------------------
%
%   Users can define their custom binning methods by means of a binning
%   routine of the form:
%       
%       edges = "func_name"(x, nb)
%
%   where
%
%       "FUNC_NAME" - any valid function name (see Matlab documentation for
%                     instructions on how to buil valid function names)
%       X           - a column array contatining the values which need to
%                     be quantized.
%       NB          - the number of bin that need to be used for
%                     discretization.
%       EDGES       - an (NB+1)-long array of strictly monotonically
%                     increasing values corresponding to the edges of the 
%                     quantization bins
%
%   To call the custom plug-in functons simply pass 'func_name' as a string
%   as the OPT parameter.
%
%
%
%   See also BUILDR, ENTROPY, INFORMATION

%   Copyright (C) 2009 Cesare Magri
%   Version 1.1.0

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



edgesFunc = str2func(opt);
edges = edgesFunc(x(:), nb);

% Performing the actual binning:
[ignore, x(:)] = histc(x(:), edges); %#ok<ASGLU>

% Bin values are from 0 to NB:
x = x - 1;
function [R, nt] = buildr(s, RMAT)

%BUILDR Builds response matrix for input to functions ENTROPY and
% INFORMATION
%
%
% NEW INPUT RMAT EACH ROW IS A RESPONSE ARRAY, I.E. RMAT is L-by-NPT
%   ------
%   SYNTAX
%   ------
%
%       [R, nt] = build_R(S, RMAT)
%
%   -----------
%   DESCRIPTION
%   -----------
%   Let's consider an experiment in which, during each trial, a stimulus is
%   presented out of NS available stimuli and L distinct neural responses
%   are recorded simultaneously. Within this framework the input to BUILDR
%   is as follow:
%   - S is the stimulus-array, i.e., S(i) stores the value of the stimulus
%     presented during the i-th trial.
%   - Rj, j=1,...,L, is the j-th response array, i.e., Rj(i) stores the
%     value of the j-th response recorded during the i-th experiment.
%
%   The function will return the response matrix R which can be input to
%   the routines ENTROPY and INFORMATION. The routine also outputs the
%   trials per stimulus array, NT, which can be used as one of the
%   parameters of the option structure for ENTROPY and INFORMATION.
%
%   -------
%   REMARKS
%   -------
%
%   - Although the one described above is the framework which was kept in
%     mind while creating the toolbox functions, it has to be noted that
%     this function (and also the other in the toolbox) can be easily
%     applied to several other situations.
%
%   - The goal of this function is to help the user get familiar with the
%     structure of the response-matrix R which is input to the ENTROPY and
%     INFORMATION functions and, in particular, with the fact that the
%     stimulus values are not provided to these functions. This is because,
%     for the sake of information computation the only important parameter
%     concerning the stimulus is the number of times each stimulus was
%     presented: the value of each stimulus can thus be mapped to an
%     integer value and made implicit as the index to a page of the
%     response matrix R. It needs to be noted, however, that BUILDR, having
%     to be as generic as possible, will also be relatively slow. Often,
%     the way responses are recorded or computed allows building a response
%     matrix much more quickly than the way done by BUILR. For
%     computationally intensive tasks it is thus suggested that custom
%     routines are used instead of this built-in tool.
%
%   See also ENTROPY, INFORMATION

%   Copyright (C) 2009 Cesare Magri
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
% 3. this notice shall remain in place in each source file.

% Changes-log
% - makes use of histc for clearer and faster code.
% - info no longer displayed

if nargin < 2
	help buildr;
	return;
end

if ~isvector(s)
    error('Stimulus array must be a vector.');
end

if length(s)~=size(RMAT,2)
    msg = 'Each response-array must have the same length as the stimulus array';
    error('buildr:differentTotNt', msg);
end

edgVec = unique(s);
nStm = length(edgVec);
nt = zeros(nStm,1);
[nt(:), binIdx] = histc(s, edgVec);

maxNt = max(nt);
minNt = min(nt);

if minNt==0
    msg = 'One or more stimuli with no corresponding response.';
    error('buildr:noResponseStimulus', msg);
end

trl_lin_ind  = findtrial(nt, maxNt, nStm);
[ignore, stm_linear_ind] = sort(binIdx);

L = size(RMAT,1);
R = zeros(L, maxNt, nStm);
R(:,trl_lin_ind) = RMAT(:,stm_linear_ind);
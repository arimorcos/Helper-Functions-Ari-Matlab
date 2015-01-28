function [covPrs, covPr, diagCovPrs, diagCovPr] = slowcov(R, Nt, Nc, maxNt, Ns, totNt, varargin)

%SLOWCOV Computes covariance matrices for gaussian method.
%
% USAGE
% -----
%
%   [covPrs, covPr, diagCovPrs, diagCovPr] = fastcov(R, Nt, Nc, maxNt, Ns, totNt);
%
% INPUTS
% ------
%   R      - response matrix
%   NT     - number of trial per stimulus array
%   NC     - number of cells (must be equal to size(NT,1))
%   MAXNT  - maximum number of trials (must be equal to max(NT) and to size(NT,2))
%   NS     - number of stimuli (must be equal to size(NS,3))
%   TOTNT  - totanl number of trial (must be equal to sum(NT))
%
% OUTPUTS
% -------
%   COVPRS     - Covariance matrices of stimulus conditional probabilities.
%                These are stored in a L-by-L-by-NS matrix.
%   COVPR      - Covariance matrix of stimulus unconditional probability of
%                of size L-by-L.
%   DIAGCOVPRS - diagonal of COVPRS
%   DIAGCOVPR  - diagonal of COVPR
%
% REMARKS
% -------
% FASTCOV computes covariance by subtracting the squared mean value from
% the cross-correlations. This is worse from the point of view of numerical
% precision but faster. Cases which provided serious errors in this
% computation should not be taken into account for estimation of mutual
% information anyways.

covPrs = zeros(Nc, Nc, Ns);
diagCovPrs = zeros(Nc, Ns);

for s=1:Ns
    meanR = sum(R(:, 1:Nt(s), s), 2);
    meanR = meanR ./ Nt(s);
    x = R(:, 1:Nt(s), s) - meanR(:, ones(Nt(s), 1));
    
    covPrs(:,:,s) = x * x.';
    diagCovPrs(:, s) = diag(covPrs(:,:,s));
end

trialind = findtrial(Nt, maxNt, Ns);

meanRvec = sum(R(:,trialind), 2);
meanRvec = meanRvec ./ totNt;
y = R(:,:) - meanRvec(:, ones(maxNt*Ns, 1));
covPr = y(:,trialind) * y(:,trialind).';
diagCovPr = diag(covPr);
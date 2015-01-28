%FASTCOV Computes covariance matrices for gaussian method.
%
% USAGE
%
%   [COVPRS, COVPR, DIAGCOVPRS, DIAGCOVPR] = FASTCOV(R, NT, NC, MAXNT, NS, TOTNT);
%
% INPUTS
%   R      - response matrix
%   NT     - number of trial per stimulus array
%   NC     - number of cells (must be equal to size(NT,1))
%   MAXNT  - maximum number of trials (must be equal to max(NT) and to size(NT,2))
%   NS     - number of stimuli (must be equal to size(NS,3))
%   TOTNT  - totanl number of trial (must be equal to sum(NT))
%
% OUTPUTS
%   COVPRS     - Covariance matrices of stimulus conditional probabilities.
%                These are stored in a L-by-L-by-NS matrix.
%   COVPR      - Covariance matrix of stimulus unconditional probability of
%                of size L-by-L.
%   DIAGCOVPRS - diagonal of COVPRS
%   DIAGCOVPR  - diagonal of COVPR
%
% REMARKS
%   - The covariance matrices returned by FASTCOV are NOT normalized!
%
%   - FASTCOV computes covariance by subtracting the squared mean value from
%     the cross-correlations. This is worse from the point of view of numerical
%     precision but faster. Cases which provided serious errors in this
%     computation should not be taken into account for estimation of mutual
%     information anyways.

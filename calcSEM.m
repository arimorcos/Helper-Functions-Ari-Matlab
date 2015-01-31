function sem = calcSEM(data, dim)
%calcSEM.m Calculates standard error of the mean for a given dataset along
%the requested dimension 
%
%INPUTS
%data 
%dim - dimension to calculate along
%
%OUTPUTS
%sem - array containing sem for each value 
%
%ASM 1/15

if nargin < 2 || isempty(dim)
    dim = 1;
end

%squeeze data 
% data = squeeze(data);
% if size(data,2) > size(data,1)
%     data = data';
% end

%calculate the standard deviation 
dataSTD = std(data, 0, dim);

%get the length of the data 
nVals = size(data, dim);

%calculate sem 
sem = dataSTD/sqrt(nVals);
function out = oneHot(in)
%oneHot.m Converts categorical array into one hot encoding array 
%
%INPUTS
%in - nObservations x 1 array of categories
%
%OUTPUTS
%out - nObservations x nCategories array of one hot encoding 
%
%ASM 10/15

%get unique categories
uniqueCat = unique(in);
nUnique = length(uniqueCat);

%remap in 
remapIn = nan(size(in));
for cat = 1:nUnique
    remapIn(in == uniqueCat(cat)) = cat;
end

%get nobservations
nObservations = length(remapIn);

%initialize matrix 
out = zeros(nObservations, nUnique);
for obs = 1:nObservations
    out(obs, remapIn(obs)) = 1;
end
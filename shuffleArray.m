function out = shuffleArray(in)
%shuffleArray.m Shuffles values in an array
%
%INPUTS
%in - array to shuffle
%
%OUTPUTS
%out - shuffled array
%
%ASM 11/14

%get number of elements in array
arrayLength = numel(in);

%get new indices
newInd = randperm(arrayLength,arrayLength);

%shufle
out = in(newInd);

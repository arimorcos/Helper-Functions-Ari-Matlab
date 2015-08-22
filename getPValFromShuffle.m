function pVal = getPValFromShuffle(real,shuffle,higher)
%getPValFromShuffle.m Calculates a p value relative to a shuffle 
%
%INPUTS
%real - scalar value 
%shuffle - vector of shuffle values 
%higher - boolean of whether real should be higher 
%
%OUTPUTS
%pVal - p value 
%
%ASM 8/15

if nargin < 3 || isempty(higher)
    higher = true;
end

%sort shuffle 
shuffle = sort(shuffle);

%get number of shuffles
nShuffles = length(shuffle);

%find index 
if higher
    ind = find(real >= shuffle,1,'last');
else
    ind = find(real <= shuffle,1,'last');
end

%get pValues
pVal = ind/nShuffles;
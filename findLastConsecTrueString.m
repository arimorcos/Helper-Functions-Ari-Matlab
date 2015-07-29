function ind = findLastConsecTrueString(string, nTrue)
%findLastConsecTrueString.m Finds the index of the last string of
%consecutive trues matching nTrue. 
%
%   For example, findLastConsecTrueString([1 1 1 0 0 1 0 1 0 1 1 1 0 0 1
%   0], 3) would return 12. 
%
%INPUTS
%string - boolean array 
%nTrue - number of true strings to match 
%
%OUTPUTS
%ind - index of end of string 
%
%ASM 7/15

%filter the string 
filtStr = filter(ones(1,nTrue), 1, string);

%find last index matching nTrue 
ind = find(filtStr == nTrue, 1, 'last');
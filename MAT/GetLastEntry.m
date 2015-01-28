function varname=GetLastEntry(filename)
% GetLastEntry checks that a variable is the last entry in a MAT-file
% 
% Example:
% VARNAME=GetLastEntry(FILENAME)
% FILENAME is the name of the MAT-file
% 
% ---------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
% ---------------------------------------------------------------------
%                               LICENSE
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ---------------------------------------------------------------------

% Append default .mat extension if none supplied
filename=argcheck(filename);
s=where(filename);
maxTag=0;
for i=1:length(s)
    if s(i).TagOffset>maxTag
        maxTag=s(i).TagOffset;
        j=i;
    end
end

varname=s(j).name;

return
end
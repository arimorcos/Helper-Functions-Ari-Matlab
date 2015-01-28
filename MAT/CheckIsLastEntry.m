function ret=CheckIsLastEntry(filename, varname)
% CheckIsLastEntry checks that a variable is the last entry in a MAT-file
% 
% Example:
% flag=CheckIsLastEntry(FILENAME, VARNAME)
% FILENAME is the name of the MAT-file
% VARNAME is the variable name
% 
% Returns FLAG==true if check proves OK, false otherwise
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
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

d=dir(filename);

if isempty(d)
    ret=false;
    disp('CheckIsLastEntry: File not found');
    return
end

w=where(filename, varname);

if isempty(w) || d.bytes~=w.TagOffset+w.DiscBytes+8
    ret=false;% Check failed
else
    ret=true;% OK
end

return
end
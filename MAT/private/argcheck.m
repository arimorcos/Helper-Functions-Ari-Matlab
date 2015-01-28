function filename=argcheck(filename, varname)
% argcheck does error checking for the MAT-file utilities
%
% Example:
% filename=argcheck(filename, varname)
% returns the filename with the .mat extension if no other
% is specified
% Where appropriate, also calls CheckIsLastEntry(filename,varname) to
% check varname is OK
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
%
% Revisions: 30.01.07 delete call to which. This would return empty if 
% filename was not on the MATLAB path. Argcheck no longer attempts to
% return the full path of filename.
%

% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

if nargin==2
    if CheckIsLastEntry(filename,varname)==false
        error('RestoreDiscClass: %s is not the last variable in %s',...
            varname,...
            filename);
    end
end

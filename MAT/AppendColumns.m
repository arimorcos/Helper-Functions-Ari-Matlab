function AppendColumns(filename, varname, newdata)
% AppendColumns appends a 2D matrix to an existing 2D matrix in a MAT-file
%
% Example:
% AppendMatrix(FILENAME, VARNAME, NEWDATA)
%
% FILENAME is a string with the name of the file (which should be a v6
% MAT-file).
% VARNAME is a string with the name of the target variable.
% NEWDATA is a column vector or 2D matrix containing the data to add to
% VARNAME
%
% AppendColumns horizontally concatenates the contents of VARNAME and
% NEWDATA
%
% Restrictions: VARNAME must be the name of the final variable in FILENAME.
% NEWNAME and VARNAME must have the same number of rows. The class of 
% VARNAME on disc must be the same as NEWNAME (use RestoreDiscClass 
% after a MATLAB save call,) and both must be real valued. 
%
% AppendColumns produces an identical result to the more general
% AppendMatrix which may be used with higher dimensions matrices
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

% Check var is a standard type - not structure, object etc
% Also, it must be real
if ~isnumeric(newdata) && ~islogical(newdata) && ~ischar(newdata) ||...
        issparse(newdata) || ~isreal(newdata)
    error('AppendColumns: %s is unsupported type',inputname(3));
    return
end


% Append default .mat extension if none supplied and check for problems
filename=argcheck(filename, varname);


w=where(filename, varname);
if ~isempty(w)
    % Return if variable and disc classes not the same
    if strcmp(w.DiscClass{1}, class(newdata))==0
        error('AppendColumns: "%s" (on disc) and "%s" (in memory) must be same class',...
            varname, inputname(3));
        return
    end

    % Make sure we have the right number of rows
    if size(newdata,1)~=w.size(1)
        error('AppendColumns: "%s" and "%s" must have same number of rows',...
            varname, inputname(3));
        return
    end

    AppendData(filename, w, newdata, true);
end



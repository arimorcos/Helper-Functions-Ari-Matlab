function AppendVector(filename, varname, newdata)
% AppendVector adds a vector to an existing vector in a MAT-file
%
% Example:
% AppendVector(FILENAME, VARNAME, NEWDATA)
%
% FILENAME is a string with the name of the file (which should be a v6
% MAT-file).
% VARNAME is a string with the name of the target variable.
% NEWDATA is the matrix containing that data to add to VARNAME
%
% Restrictions: VARNAME must be the name of the final variable in FILENAME.
% VARNAME must be the name of a pre-existing vector and NEWNAME must be
% vector. NEWNAME(:) will be added to the longest dimsension of VARNAME
% preserving row/column vector organization
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
    error('AppendToVector: %s is unsupported type',inputname(3));
    return
end

% Append default .mat extension if none supplied and check for problems
filename=argcheck(filename, varname);

w=where(filename, varname);
if ~isempty(w)
    % Return if variable and disc classes not the same
    if strcmp(w.DiscClass{1}, class(newdata))==0
        error('AppendToVector: "%s" (on disc) and "%s" (in memory) must be same class',...
            varname, inputname(3));
        return
    end

    % Make sure it is not more the 2D
    if length(w.size)>2
        error('AppendToVector: %s is not a vector',varname);
        return
    end

    % Check vector orientation and correct if wrong
    if w.size(1)>1
        if size(newdata,1)==1
            sprintf('AppendToVector: converting %s to a column vector',inputname(3));
            newdata=newdata.';
        end
    else
        if size(newdata,2)==1
            sprintf('AppendToVector: converting %s to a row vector',inputname(3));
            newdata=newdata.';
        end
    end

    AppendData(filename, w, newdata);
end

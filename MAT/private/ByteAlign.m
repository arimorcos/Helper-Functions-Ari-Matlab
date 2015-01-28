function ByteAlign(fh)
% ByteAlign aligns the file position to an 8 byte boundary
%
% Example:
% BYTEALIGN(FH)
% where FH is the file handle
% 
% The file position will be unchanged if already at an 8 byte boundary.
% Otherwise it will be moved to the next boundary.
%
% ---------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006
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
pos=ftell(fh);
o=rem(pos,8);
if o==0
    return;
else
    fseek(fh,8-o,'cof');
    return;
end
end
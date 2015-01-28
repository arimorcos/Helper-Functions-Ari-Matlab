function AddDimension(filename, varname)
% AddDimension adds a trailing singleton dimension to a variable in a
% MAT-file
%
% Example:
% AddDimension(FILENAME, VARNAME)
%
% FILENAME is a string with the name of the file (which should be a v6
% MAT-file).
% VARNAME is a string with the name of the target variable.
% NEWDATA is the matrix containing that data to add to VARNAME
%
% E.g. If VARNAME is a 100x100x3 matrix, AddDimension makes it a
% 100x100x3x1 matrix (on disc - MATLAB's LOAD,  WHOS, SIZE etc will remove
% the singleton dimension). Subsequent calls to AppendMatrix will then add
% data to the fourth dimension creating.
%
% Restrictions: VARNAME must be the name of the final variable in FILENAME.
% VARNAME must be the name of a pre-existing variable. FileName must be a
% v6 MAT-file
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

mi=StandardMiCodes();

% Append default .mat extension if none supplied and check for problems
filename=argcheck(filename, varname);

w=where(filename, varname);

fh=MATOpen(filename,'r+');
fseek(fh,w.TagOffset+24,'bof');

% Get current dimension array
DA_DataType=mi{fread(fh,1,'uint32=>uint32')};
DA_NumberOfBytes=fread(fh,1,DA_DataType);
DimArray=fread(fh,DA_NumberOfBytes/sizeof(DA_DataType),...
    [DA_DataType '=>' DA_DataType]);
ByteAlign(fh);

pos1=ftell(fh);
fseek(fh,0,'eof');
pos2=ftell(fh);
fseek(fh,pos1,'bof');
buf=fread(fh,pos2-pos1,'uint8');

DimArray(end+1)=1;
fseek(fh,w.TagOffset+28,'bof');
fwrite(fh,DA_NumberOfBytes+sizeof(DA_DataType),DA_DataType);
fwrite(fh,DimArray,DA_DataType);
PadToEightByteBoundary(fh);

fwrite(fh, buf, 'uint8');

% Pad to 64 bit boundary
PadToEightByteBoundary(fh)

% Recalculate and save the variable's size (bytes, inclusive of padding)
eof=ftell(fh);
fseek(fh,w.TagOffset+4,'bof');
fwrite(fh,eof-w.TagOffset-8,'uint32');

fclose(fh);
return
end
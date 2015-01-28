function flag=VarRename(filename, Target, NewName)
% VarRename overwrites a variable name in a Level 5 Version 6 MAT-File
% or returns the number of bytes reserved for the name.
%
% Example:
% BYTES=VARRENAME('MYFILE','MICKY')
% returns the number of bytes available for the name of the existing
% variable 'MICKY'
%
% FLAG=VARRENAME('MYFILE','MICKY','MICKEY')
% replaces the existing name with the new name if there is space.
% Returns 0 if the rename has taken place, -1 otherwise
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

mi=StandardMiCodes();

% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

flag=-1;


s=where(filename,Target);
if isempty(s)
    disp(sprintf('VARRENAME: Variable %s not found',Target));
    return;
end

fh=MATOpen(filename,'r+');
    if fh<0
        return
    end
[f1, p1, fileformat]= fopen(fh);

fseek(fh,s.TagOffset+12,'bof');
NumberOfBytes=fread(fh,1,'uint32');
fseek(fh,NumberOfBytes+4,'cof');

NumberOfBytes=fread(fh,1,'uint32');
fseek(fh,NumberOfBytes,'cof');

%Name Array
N_DataType=fread(fh,1,'uint32');
if (N_DataType>2^16)
    fseek(fh,-4,'cof');
    [N_NumberOfBytes, N_DataType, values]=GetSmallDataElement(fh, fileformat);
    N_DataType=mi{N_DataType};
    N_name=char(values);
    ByteAlign(fh);
    fseek(fh,-8,'cof');
    sde=true;
else
    N_DataType=mi{N_DataType};
    N_NumberOfBytes=fread(fh,1,'uint32');
    n=N_NumberOfBytes/sizeof(N_DataType);
    N_name=fread(fh,n,[N_DataType '=>char'])';
    fseek(fh,-(n+4),'cof');
    sde=false;
end

if nargin==2
    flag=NumberOfBytes;
    return
else
    N_name=deblank(N_name);
    if strcmp(N_name,Target)==1
        if strcmp(N_DataType,'int8')==1 && length(NewName)<=NumberOfBytes
            if sde==true
                fwrite(fh,length(NewName),'uint16');
                fseek(fh,6,'cof');
            else
                fwrite(fh,length(NewName),'uint32');
                fwrite(fh, NewName,'int8');
            end
            flag=0;
        end
    end

fclose(fh);
end
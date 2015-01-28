function [fh, swapbyteorder MLLevel info]=MATOpen(filename, permission)
% MATOpen opens a MAT file in appropriate endian mode and returns a handle
%
% Example:
% [FH, SWAP LEVEL]=MATOPEN(FILENAME, PERMISSION)
% FH is the returned file handle
% PERMISSION is the permission string for FOPEN (defaults to 'r')
% SWAP is set true if the byte order is different to the default of the host
% platform
%
% The "appropriate" endian order is either:
% The system default endian if FILENAME does not exist
% The existing endian order for the file if FILENAME does exist
%
% See also endian
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
% Revisions:
% 16.03.08 Remove endian as varname now function endian is defined
% 20.11.10 Return MATLAB level

[platform,maxsize,system_endian] = computer;
if nargin<2
    permission='r';
end
fh=fopen(filename,permission,system_endian);

if fh<0
    swapbyteorder=[];
    fprintf('MATOPEN: Failed to open %s\n',filename);
    return
end



fseek(fh,0,'bof');
info=fread(fh,114,'uint8');
if any(info(1:3)==0)% || level(1)==0 || level(2)==0 || level(3)==0
    fprintf('MATOPEN: unsupported Level 4 MAT-file format\n');
    fclose(fh);
    fh=-1;
    swapbyteorder=[];
    return;
end

info=deblank(char(info'));

fseek(fh,114+10,'bof');
level=fread(fh,1,'uint16=>uint16');
switch level
    case 512
        MLLevel=7;
    case 256
        MLLevel=5;
    otherwise
        error('Unrecognized file format');
end


thisfileendian=fread(fh,1,'uint16=>uint16');
switch thisfileendian
    case 18765
        fclose(fh);
        switch system_endian
            case 'L'
                fh=fopen(filename,permission,'B');
            case 'B'
                fh=fopen(filename,permission,'L');
        end
        swapbyteorder=true;
    case 19785
        swapbyteorder=false;
    otherwise
        fclose(fh);
        fh=-1;
        fprintf('MATOPEN: could not determine file byte order.\n');
end

return
end
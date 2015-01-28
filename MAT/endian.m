function str=endian(filename)
% endian returns the endian format for the specified MAT file
%
% Example:
% endianformat=endian(filename)
%       filename is string
%       endianformat will be returned as 'ieee.le' or 'ieee-be' 
%           (or [] if undetermined)
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


[platform,maxsize,system_endian] = computer;

% 30.10.11 added
if nargin==0
    % No input - return the system endian
    switch system_endian
        case 'L'
            str='ieee-le';
        case 'B'
            str='ieee-be';
    end
    return
end


% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

% Let MATOpen do the work
[fh, swapbyteorder]=MATOpen(filename, 'r');

% Default return value
str=[];

if fh<0
    return
else
    fclose(fh);
    switch system_endian
        case 'L'
            if swapbyteorder==false
                str='ieee-le';
            else
                str='ieee-be';
            end
        case 'B'
            if swapbyteorder==false
                str='ieee-be';
            else
                str='ieee-le';
            end
    end
end
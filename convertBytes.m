function out = convertBytes(in,type)
%convertBytes.m Function to convert bytes into GB, MB, TB, etc. 
%
%INPUTS
%in - double of bytes
%type - string containing output type
%
%OUTPUTS
%out - output in type 
%
%ASM 8/14

if nargin < 1 || isempty(type)
    type = 'GB';
end
switch upper(type)
    case 'KB'
        out = in/1024;
    case 'MB'
        out = in/(1024^2);
    case 'GB'
        out = in/(1024^3);
    case 'TB'
        out = in/(1024^4);
    otherwise 
        error('Unsupported byte type');
end
function out = isfloatinteger(in)
%isfloatinteger.m Function to identify whether floating point variable is
%an integer
%
%INPUTS
%in - variable to test
%
%OUTPUTS
%out - true or false 
%
%ASM 11/13

%check if is float
if ~isfloat(in)
    out = false;
    return;
end

%divide by 1 and see if remainder is present
out = ~logical(mod(in,1));
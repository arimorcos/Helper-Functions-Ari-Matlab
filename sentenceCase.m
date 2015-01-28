function out = sentenceCase(in)
%sentenceCase.m Converts first character of string to uppercase 
%
%ASM 1/15

out = lower(in);
out(1) = upper(out(1));

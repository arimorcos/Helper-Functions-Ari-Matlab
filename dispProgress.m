function outString = dispProgress(string,loopInd,varargin)
%dispProgress.m Displays progress of loop using frprintf on one line
%
%INPUTS
%string - string to display with fields designated by formatSpec
%loopInd - loop index
%varargin - values corresponding to formatSpec fields in string

if any(strcmpi(varargin,'laststring'))
    lastInd = find(strcmpi(varargin,'laststring'));
    lastString = varargin{lastInd+1};
    varargin(lastInd:lastInd+1) = [];
end

%append \n to string
string = [string,'\n'];

%get string length
strLength = length(sprintf(string,varargin{:}));

%modify if changing number of characters
if length(num2str(loopInd)) > length(num2str(loopInd-1))
    strLength = strLength - 1;
end

if exist('lastString','var') && ~isempty(lastString)
    strLength = length(lastString);
end

if loopInd == 1
    
    fprintf(string,varargin{:});
else
    fprintf(repmat('\b',1,strLength));
    fprintf(string,varargin{:});
end

%outString
outString = sprintf(string,varargin{:});
function convertScatterMarker(axH, new_marker)

if nargin < 2 || isempty(new_marker)
    new_marker = '.';
end

%get children
children = axH.Children;

for child = 1:length(children)
    
    if scatter
    
end
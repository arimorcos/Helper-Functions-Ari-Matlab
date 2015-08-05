function decreaseMarkerSize(axH,size)
%
%



%get chilren 
children = axH.Children;

%loop through
for child = 1:length(children)
    
    if strcmpi(children(child).Type,'line')
        children(child).MarkerSize = size;
    end
    
    if strcmpi(children(child).Type,'errorbar')
        children(child).MarkerSize = size;
    end
    
    if strcmpi(children(child).Type,'scatter')
        children(child).SizeData = size;
    end
end
        
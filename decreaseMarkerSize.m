function decreaseMarkerSize(figH,size)
%
%



if strcmpi(figH.Type,'figure')
    axH = figH.Children;
elseif strcmpi(figH.Type,'axes')
    axH = figH;
end
nAx = length(axH);

for ax = 1:nAx
    
    %get chilren
    children = axH(ax).Children;
    
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
        
        if strcmpi(children(child).Type,'text')
            children(child).FontSize = 6;
        end
    end
end
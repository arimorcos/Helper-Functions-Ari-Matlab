function modifyTransGraphforEPS(axH,revert)

if nargin < 2 || isempty(revert)
    revert = false;
end

%check if ax or fig
if strcmp(axH.Type,'figure')
    children = axH.Children;
    axH = gobjects(0);
    cH = gobjects(0);
    for child = 1:length(children)
        if strcmp(children(child).Type,'axes')
            axH(length(axH) + 1) = children(child);
        end
        if strcmp(children(child).Type,'colorbar')
            cH(length(cH) + 1) = children(child);
        end
    end
else
    cH = [];
end
for i = 1:length(axH)
    if revert
        axH(i).Units = 'Normalized';
        axH(i).Position = [0.13 0.11 0.775 0.815];
        axH(i).FontSize = 20;
        axH(i).XLabel.FontSize = 30;
        axH(i).YLabel.FontSize = 30;
        
    else
        % font to arial
        axH(i).FontName = 'Arial';
        axH(i).Units = 'centimeters';
        axH(i).Position = [2 2+5*(i-1) 4 4];
        axH(i).FontSize = 6;
        axH(i).XLabel.FontSize = 7;
        axH(i).YLabel.FontSize = 7;
        
        % get children
        axChildren = axH(i).Children;
        scaleFacLines = 0.01;
        scaleFac = 0.1;
        for child = 1:length(axChildren)
            if strcmpi(axChildren(child).Type,'line')
                axChildren(child).LineWidth = scaleFac*axChildren(child).LineWidth;
            elseif strcmpi(axChildren(child).Type,'scatter')
                axChildren(child).LineWidth = scaleFac*axChildren(child).LineWidth;
                axChildren(child).SizeData = scaleFac*axChildren(child).SizeData;
            end
        end
    end
end

for i = 1:length(cH)
    cH(i).FontName = 'Arial';
    cH(i).FontSize = 6;
    cH(i).Label.FontSize = 7;
    cH(i).Units = 'centimeters';
    cH(i).Position = [7 2+5*(i-1) 0.5 4];
end
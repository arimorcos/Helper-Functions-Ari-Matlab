function modifyForEPS(axH,revert)

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
        if i > 4
            axH(i).Position = [2+5*(i-1) 2 3.2 3.2];
        else
            axH(i).Position = [2 2+5*(i-1) 3.2 3.2];
        end
        axH(i).FontSize = 6;
        axH(i).XLabel.FontSize = 7;
        axH(i).YLabel.FontSize = 7;
    end
end

for i = 1:length(cH)
    cH(i).FontName = 'Arial';
    cH(i).FontSize = 6;
    cH(i).Label.FontSize = 7;
    cH(i).Units = 'centimeters';
    cH(i).Position = [7 2+5*(i-1) 0.5 3.2];
end
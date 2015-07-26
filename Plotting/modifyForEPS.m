function modifyForEPS(axH,revert)

if nargin < 2 || isempty(revert)
    revert = false;
end

if revert
    axH.Units = 'Normalized';
    axH.Position = [0.13 0.11 0.775 0.815];
    axH.FontSize = 20;
    axH.XLabel.FontSize = 30;
    axH.YLabel.FontSize = 30;
    
else
    % font to arial
    axH.FontName = 'Arial';
    axH.Units = 'centimeters';
    axH.Position = [2 2 4 4];
    axH.FontSize = 6;
    axH.XLabel.FontSize = 7;
    axH.YLabel.FontSize = 7;
end
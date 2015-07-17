function axH = equalAxes(axH,unity)
%equalAxes.m Remaps the axes bounds to make them equal 
%
%INPUTS
%axH - axis to equalize 
%unity - show unity line? 
%
%OUTPUTS
%axH - axies 
%
%ASM 7/15

if nargin < 2 || isempty(unity)
    unity = false;
end

%get axis bounds
newMin = min(axH.XLim(1), axH.YLim(1));
newMax = max(axH.XLim(2), axH.YLim(2));

%set 
axH.XLim = [newMin newMax];
axH.YLim = [newMin newMax];

%add unity 
if unity 
    lineH = line([newMin newMax], [newMin newMax]);
    lineH.Color = 'k';
    lineH.LineWidth = 1;
    lineH.LineStyle = '--';
end
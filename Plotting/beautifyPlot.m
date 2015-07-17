function beautifyPlot(figH,axH)
%beautifyPlot.m Beautifies the plot!
%
%INPUTS
%figH - figure handle
%axH - axes handle
%
%ASM 6/15

%maximize figure 
figH.Units = 'Normalized';
figH.OuterPosition = [0 0 1 1];

%change font size 
axH.FontSize = 20;
axH.LabelFontSizeMultiplier = 1.5;

%square 
axis(axH,'square');
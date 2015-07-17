function h = addBracket(xRange,yPos,label)
%addBracket.m Adds a bracket to designated axis at the given xRange and y
%position with the label specified 
%
%INPUTS
%xRange - 1 x 2 array of x range 
%yPos - yPosition of plot 
%label - label above plot
%
%OUTPUTS
%h - structure of handles 
%
%ASM 4/15

%plot line 
h.horizLine = line(xRange,[yPos yPos]);
h.horizLine.Color = 'k';

%currAx 
axH = gca;

%plot ticks 
h.leftTick = line([xRange(1) xRange(1)], [yPos - 0.01*range(axH.YLim) yPos]);
h.rightTick = line([xRange(2) xRange(2)], [yPos - 0.01*range(axH.YLim) yPos]);
h.rightTick.Color = 'k';
h.leftTick.Color = 'k';

%add label 
h.label = text(mean(xRange),1.01*yPos,label);
h.label.HorizontalAlignment = 'Center';
h.label.VerticalAlignment = 'Bottom';
h.label.Color = 'k';
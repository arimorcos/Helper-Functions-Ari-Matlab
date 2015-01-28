function handles = plotTradeVolume(data,avgPer,plotAxes)
%plotTradeVolume.m Function to plot bar graph of trading volume
%
%INPUTS
%data - nPoints x 6 array. {'DateNum','Open','High','Low','Close','Volume'}
%avgPer - period for moving average. If empty, no moving average plotted
%plotAxes - axes in which to plot
%
%OUTPUTS
%handles - structure of handles
%
%ASM 1/14

if nargin < 3 || isempty(plotAxes) ||   ~ishandle(plotAxes)
    figure;
    plotAxes = axes;
else
    axes(plotAxes);
end
if nargin < 2
    avgPer = [];
end

%get volume
volume = data(:,6)';

%normalize
ind = 3;
found = false;
while ~found
   %divide every volume by 10^ind
   newVol = volume./(10^ind);
   
   %check if any less than 1 and nonzero
   if any(newVol < 1 & newVol ~= 0)
       found = true;
       ind = ind - 3;
   else
       ind = ind + 3;
   end
end
volume = volume./(10^ind);
switch ind
    case 0
        units = '';
    case 3 
        units = '(Thousands)';
    case 6 
        units = '(Millions)';
    case 9
        units = '(Billions)';
    case 12
        units = '(Trillions)';
end

%get dates
dates = data(:,1)';

%get diff of close price
priceDiff = diff(data(:,5));

%find pos and neg days
posDays = [1 (find(priceDiff >= 0) + 1)']; %add in first value
negDays = (find(priceDiff < 0) + 1)';

%create bar graph
hold on;
handles.volumePlotPos = bar(dates(posDays),volume(posDays),'g','EdgeColor','g');
handles.volumePlotNeg = bar(dates(negDays),volume(negDays),'r','EdgeColor','r');

%plot moving average
if ~isempty(avgPer)
    
    %calculate moving average
    volAvg = filter(ones(1,avgPer)/avgPer,1,volume);
    volAvg(1:avgPer-1) = nan;
    
    %plot
    handles.volAvg = plot(dates,volAvg,'b','LineWidth',2);
    
end

%create datetick
dynamicDateTicks(plotAxes, [], 'mm/dd/yy');

%limits
xlim([min(dates) - 10 max(dates) + 10]);

%labels
handles.yLabel = ylabel(sprintf('Volume %s',units));
handles.xLabel = xlabel('Date');


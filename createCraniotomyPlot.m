figure;

cranDiam = 3.1; %craniotomy diameter
centerCoord = [-1.75 -2.0]; %circle center coordinates
injectCoord = [0.46 0.11; 0.65 0; 0.46 -0.11]; %injection coordinates relative to center

[circPlot, xp, yp] = plotCircle(centerCoord(1),centerCoord(2),cranDiam/2);
axis square;
xlim([(centerCoord(1) - cranDiam/2 - 0.75) (centerCoord(1) + cranDiam/2 + 0.75)]);
ylim([(centerCoord(2) - cranDiam/2 - 0.75) (centerCoord(2) + cranDiam/2 + 0.75)]);
line([0 0],[-10 10],'Color','k');
line([-10 10],[0 0],'Color','k');
text(0.1,0.1,'Bregma','VerticalAlignment','Bottom',...
    'HorizontalAlignment','Left','FontWeight','Bold');

%get points 
ind1 = round(linspace(1,length(xp)/2,5));
ind2 = round(linspace(length(xp)/2,length(xp),5));
ind = [ind1 ind2(2:end-1)];
xMarkCoord = xp(ind);
yMarkCoord = yp(ind);

%add center
xMarkCoord(length(xMarkCoord)+1) = centerCoord(1);
yMarkCoord(length(yMarkCoord)+1) = centerCoord(2);

%plot markers
hold on;
scatter(xMarkCoord,yMarkCoord,100,'k','fill');
xMarkCoord = round(100*xMarkCoord)/100;
yMarkCoord = round(100*yMarkCoord)/100;
for i=1:length(xMarkCoord) 
    h(i) = text(xMarkCoord(i),yMarkCoord(i),['[',num2str(xMarkCoord(i)),', ',...
        num2str(yMarkCoord(i)),']']);
    if abs(xMarkCoord(i)) >= abs(centerCoord(1))
        set(h(i),'HorizontalAlignment','Right');
    else
        set(h(i),'HorizontalAlignment','Left');
    end
    if abs(yMarkCoord(i)) >= abs(centerCoord(2))
        set(h(i),'VerticalAlignment','Top');
    else
        set(h(i),'VerticalAlignment','Bottom');
    end
end

%plot injection coordinates
scatter(injectCoord(:,1) + centerCoord(1),injectCoord(:,2) + centerCoord(2),...
    100,'r','Marker','x');
for i=1:size(injectCoord,1) 
    text(injectCoord(i,1) + centerCoord(1),injectCoord(i,2) + centerCoord(2),...
        ['[',num2str(injectCoord(i,1)),', ',...
        num2str(injectCoord(i,2)),']'],'VerticalAlignment','Bottom',...
        'HorizontalAlignment','Left','Color','r');
    
end


title([num2str(cranDiam),' mm coordinates']);
xlabel('X Coordinate');
ylabel('Y Coordinate');

function convertHistogramToOutline(axH)
%convertHistogramToOutline.m Convert histogram to outline 
%
%INPUTS
%axH - axes handle
%
%ASM 7/15

% get axes children 
children = axH.Children;

%loop through 
ind = 1;
for child = 1:length(children)
    
    %check if histogram 
    if ~strcmpi(children(child).Type,'histogram')
        continue;
    end
    
    %set faceColor to none 
    children(child).FaceColor = 'none';
    
    %set edge color properly
    children(child).EdgeColor = axH.ColorOrder(ind,:);
    
    %set line width 
    
    %increment 
    ind = ind + 1;
    
end
function out = loadCell(fileBase)
%loadCell.m Function to load in cells or structs split of by saveCell
%
%INPUTS
%fileBase - base name for file. May include path
%
%OUTPUTS
%out - cell or struct in same format 
%
%ASM 4/14

%get list of files matching file base
fileList = dir(sprintf('%s_part*.mat',fileBase));
fileList = {fileList(:).name};

%change to directory if necessary
path = fileparts(fileBase);
if ~isempty(path)
    oldDir = cd(path);
end

%initialize ind
ind = 1;

%loop through each file
for i = 1:length(fileList)
    
    %load file 
    load(fileList{i});
    
    %if first file and cell, initialize
    if i == 1 && iscell(portionToSave)
        
        %get numel in cell
        totCellSize = prod(cellSize);
        
        %initialize
        out = cell(totCellSize,1);
    elseif i == 1 && isstruct(portionToSave)
        out = portionToSave;
        ind = ind + length(portionToSave);
        continue;
    end
    
    %add on portion to save
    out(ind:ind + length(portionToSave) - 1) = portionToSave;
    ind = ind + length(portionToSave);
    
end

%reshape if cell
if iscell(portionToSave)
    out = reshape(out,cellSize);
end
    
%change back 
if ~isempty(path)
    cd(oldDir);
end
        
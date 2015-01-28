function saveCell(fileBase,cellToSave,fileSize)
%saveCell.m function to save large cell arrays. Breaks up cell arrays into
%partitions of 50 MB columnwise and saves each file using the fileBase
%str. Also works for structure arrays.
%
%INPUTS
%fileBase - base name for the file
%cellToSave - cell array to be saved
%fileSize - number of bytes per file. Default to 50 MB (~5e7)
%
%ASM 4/14

% %determine if cell array or structure
% if isstruct(cellToSave)
%     structFlag = true;
% elseif iscell(cellToSave)
%     structFlag = false;
% else
%     error('file not in a recognized format.');
% end

if nargin < 3 
    fileSize = 5e7;
end

%determine size of array
nCells = numel(cellToSave);
cellSize = size(cellToSave);

%get size of array per element
cellInfo = whos('cellToSave');
totBytes = cellInfo.bytes;
bytesPerEl = totBytes/nCells;

%get nCells per file
if totBytes > fileSize
    nCellsPer = ceil((fileSize)/bytesPerEl);
else
    nCellsPer = nCells;
end

%get nFiles
nFiles = ceil(nCells/nCellsPer);

%generate indices for saving
saveIndices = bsxfun(@plus,1:nCellsPer,(0:nCellsPer:nCells)');

%loop through each and save
for i = 1:nFiles
    
    %generate file name
    saveName = sprintf('%s_part%06d.mat',fileBase,i);
    
    %get indices
    thisInd = saveIndices(i,:);
    if i == nFiles %if last one 
        thisInd = thisInd(thisInd <= nCells); %crop out indices greater than nFiles
        if isempty(thisInd)
            continue;
        end
    end
    
    %crop out portion to save
    portionToSave = cellToSave(thisInd);
    
    %save 
    save(saveName,'portionToSave','cellSize')

end
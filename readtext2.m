function output = readtext2(fileName, varargin)
% READTEXT2 uses readtext, but if it fails because of a lack of memory,
% will try to split the file up into chunks.

% checks the number of arguments
error(nargchk(4, 5, nargin))

% only currently works for files
if ~exist(fileName, 'file')
    % errors
    error('File does not exist.')
end

% tries it normally
try
    % tries it
    output = readtext(fileName, varargin{:});
   
catch
    % gets the last error
    lastError = lasterror;
    
    % get rid of the waitbar if it was used
    if any(~cellfun('isempty', strfind(varargin, 'usewaitbar')))
        % clean it up
        deletewaitbars('(readtext)')
    end
    
    % gets the fids of everything that is open
    fid = fopen('all');

    % for each one...
    for m = 1:numel(fid)
        % if it matches...
        if strcmp(fopen(fid(m)), fileName)
            % close it
            closeStatus = fclose(fid(m));

            % warns it it didn't
            if ~closeStatus
                % warning
                warning('readtext2:cleanup', 'Did not close file properly.')
            end
        end
    end

    % if the message didn't say out of memory, something else went wrong
    if isempty(strfind(lastError.message, 'Out of memory'))
        % errors
        error(['Error was not an out of memory error so something else probably went wrong. ', lastError.message])
    end

    % its errored, so now we need to read in the file in small pieces -
    % although small pieces, the peak memory footprint is quite large
    fileID = fopen(fileName, 'r');

    % if its 0, it didn't work
    if ~fileID
        % errors
        error('Could not open the file to try a second time.')
    end

    % defines the chunk size - although only 5,000,000 characters, the peak
    % memory footprint is a lot larger
    chunkSize = 5e6;
    chunks = ceil(getfilesize(fileName) / chunkSize);

    % pre-allocates the output
    output = cell(chunks, 1);
    columns = zeros(chunks, 1);
    iterations = 1;
    
    % defines the optional argument
    optionalArgs = 'textsource';
    
    % defines the optional arguments
    if nargin == 5
        % append these on
        optionalArgs = [optionalArgs, '-', varargin{4}];
    end

    % try-catched for robustness
    try
        % splits it up into chunks
        while ~feof(fileID)
            % reads in some of the file
            data = fread(fileID, chunkSize, 'uchar=>char')';
            
            % if its not at the end of the file, go to the end of the line
            if ~feof(fileID)
                % reads out to the end of the line
                data = [data, fgets(fileID)];
            end
            
            % runs readtext on it
            output{iterations} = readtext(data, varargin{1:3}, optionalArgs);
            
            % counts the number of columns
            columns(iterations) = size(output{iterations}, 2);
            
            % increases the counter
            iterations = iterations + 1;
        end
        
        % finds the maximum number of columns
        maxWidth = max(columns);
        
        % for each part, might need to pad out cell array
        for n = 1:numel(output)
            % is the width the right size?
            if columns(n) ~= maxWidth
                % append on some blanks at the end
                output{n} = [output{n}, cell(size(output{n}, 1), maxWidth - columns(n))];
            end
        end
        
        % try to concatenate the outputs
        output = vertcat(output{:});
        
    catch
        % clearly, something went wrong
        
        % gets the last error
        lastError = lasterror;

        % get rid of the waitbar
        if any(~cellfun('isempty', strfind(varargin, 'usewaitbar')))
            % clean it up
            deletewaitbars('readtext')
        end
        
        % close the file
        closeStatus = fclose(fileID);

        % checks the close status
        if ~closeStatus
            % displays a warning
            warning('readtext2:cleanup', 'Did not close file properly.')
        end

        % rethrows the error
        rethrow(lastError);
    end

    % closes the file
    closeStatus = fclose(fileID);

    % checks the close status
    if ~closeStatus
        % displays a warning
        warning('readtext2:cleanup', 'Did not close file properly.')
    end
end
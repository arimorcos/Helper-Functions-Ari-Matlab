%%%%%%%%% INPUT FOLDER HERE %%%%%%%%%%%%%
folderName = 'D:\Mouse Recordings\Mouse Races';
load([folderName,filesep,'horseNames.mat']);
nRacers = 2;
frameLength = 1/30;
vidThresh = [110];

%%%%%%%%%%%% SCRIPT
%% INITIALIZE
%get list of all files in folder
fileList = dir(folderName);
fileList = {fileList(:).name};
fileList = fileList(~cellfun(@isempty,regexp(fileList,'.*.mp4')));

%append folder
fileList = cellfun(@(x) [folderName,filesep,x],fileList,'UniformOutput',false);

%load in movies
nMovies = length(fileList);
movieArray = cell(1,nMovies);
movieInfo = cell(1,nMovies);
trialEnds = cell(1,nMovies);
trialStarts = cell(1,nMovies);
nFrames = cell(1,nMovies);
nTrials = zeros(1,nMovies);
for videoInd = 1:nMovies
    movieInfo{videoInd} = VideoReader(fileList{videoInd});
    movieArray{videoInd}(1:movieInfo{videoInd}.NumberOfFrames) = ...
        struct('cdata',zeros(movieInfo{videoInd}.Height,movieInfo{videoInd}.Width, 3,'uint8'),...
        'colormap',[]);
    findTrialArray = zeros(movieInfo{videoInd}.Height,movieInfo{videoInd}.Width,movieInfo{videoInd}.NumberOfFrames);
    for frameInd = 1:movieInfo{videoInd}.NumberOfFrames
        movieArray{videoInd}(frameInd).cdata = read(movieInfo{videoInd},frameInd);
        findTrialArray(:,:,frameInd) = sum(movieArray{videoInd}(frameInd).cdata,3);
    end

    %find trial starts and ends
    findTrialMeans = squeeze(mean(mean(findTrialArray)));
    firstShift = findTrialMeans(1:end-1);
    secondShift = findTrialMeans(2:end);
    trialStarts{videoInd} = find(secondShift >= vidThresh(videoInd) & firstShift < vidThresh(videoInd)) + 1;
    trialEnds{videoInd} = find(secondShift < vidThresh(videoInd) & firstShift >= vidThresh(videoInd)) + 1;
    if trialStarts{videoInd}(1) > trialEnds{videoInd}(1); trialEnds{videoInd}(1) = [];end
    if trialStarts{videoInd}(end) > trialEnds{videoInd}(end); trialStarts{videoInd}(end) = [];end
    nFrames{videoInd} = trialEnds{videoInd} - trialStarts{videoInd} + 1;
    nTrials(videoInd) = length(trialStarts{videoInd});
end


%% run loop
notBroken = true;
mouseFig = figure('Name','Mouse Derby 9000','MenuBar','None');
for videoInd = 1:nRacers
    raceAx(videoInd) = subplot(1,2,videoInd);
end
timerH = uicontrol('style','text','BackgroundColor',[0.8 0.8 0.8],'String',datestr(0,'MM:SS:FFF'),...
    'Units','Normalized','FontSize',30,'Position',[0.47 0.48 0.1 0.04]);

while notBroken
    
    %generate mouseInd
    mouseInd = randi(nMovies);
    
    %generate random trial
    trialInds = randperm(nTrials(mouseInd),nRacers);
    nameInd = randperm(length(horseNames),nRacers);
    [nFramesToShow,winnerInd] = min(nFrames{mouseInd}(trialInds));
    if nFramesToShow < 120
        continue;
    end
    
    for plotInd = 1:nRacers
        axes(raceAx(plotInd));
        cla;
        hold off;
    end
    set(timerH,'String',datestr(0,'MM:SS:FFF')); 
    if exist('raceStart','var')
        clear raceStart;
    end
    
    
    for frameInd = 1:nFramesToShow
        
        for plotInd = 1:nRacers
            axes(raceAx(plotInd));
            imagesc(movieArray{mouseInd}(trialStarts{mouseInd}(trialInds(plotInd))+frameInd-1).cdata)
            set(raceAx(plotInd),'XTick',[],'YTick',[],'YTickLabel',[],'XTickLabel',[],...
                'PlotBoxAspectRatio',[movieInfo{mouseInd}.Width movieInfo{mouseInd}.Height 1]);
            title(horseNames{nameInd(plotInd)},'FontSize',30);
            drawnow;
        end             
        
        if frameInd == 1
            result = input('Start Race? y/n:   ','s');
            if strcmpi(result,'n')
                notBroken = false;
                break;
            end
            raceStart = now;
        else
            set(timerH,'String',datestr(now-raceStart,'MM:SS:FFF'));  
        end
        
        if frameInd == nFramesToShow
            for videoInd = 1:5
                textH = gobjects(1,nRacers);
                for plotInd = 1:nRacers 
                    axes(raceAx(plotInd));
                    hold on;
                    if plotInd == winnerInd
                        textStr = 'WINNER!!!!';
                        textColor = 'g';
                    else
                        textStr = 'LOSER';
                        textColor = 'r';
                    end
                    textH(plotInd) = text(movieInfo{mouseInd}.Width/2,movieInfo{mouseInd}.Height/2,textStr,...
                        'Color',textColor,'HorizontalAlignment','center','FontSize',30);
                end
                pause(0.5);
                delete(textH);
                pause(0.2);
            end
        end
                
        
        timeStart = tic;
        while toc(timeStart) < frameLength
            continue;
        end
    end
end



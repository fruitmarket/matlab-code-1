function psthCC(sessionFolder,includeAllTrial)
% psthCC Converts data from MClust t files to Matlab mat files
narginchk(0, 2);

% Task variables
binSize = 0.01; % unit: sec, = 10 msec
resolution = 10; % sigma = resolution * binSize = 100 msec
rewardWin = [-2 4]*10^3;
rewardWindow = [-1 3];

% Tag variables
winTagBlue = [-20 100]; % unit: msec
binTagSizeBlue = 2;
binTagBlue = winTagBlue(1):binTagSizeBlue:winTagBlue(2);

winTagRed = [-500 2000]; % unit: msec
binTagSizeRed = 10;
binTagRed = winTagRed(1):binTagSizeRed:winTagRed(2);

% Find files
if nargin == 0 % Input�� ���� ��� �׳� �������� t ������ �˻�
    ttFile = FindFiles('T*.t','CheckSubdirs',0); % Subfolder�� �˻����� �ʴ´�
else % Input�� �ִ� ���
    if ~iscell(sessionFolder) % �� array���� Ȯ��
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder) % Cell�� ������ �� ������� �׳� ���� ���� t���� �˻�
        ttFile = FindFiles('T*.t','CheckSubdirs',1);
    else % Cell�� �°� �� array�� �ƴϸ�, ���ʴ�� cell ���빰 Ȯ��
        nFolder = length(sessionFolder);
        ttFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 % �����̸� �� �Ʒ� �������� t���� �˻�
                cd(sessionFolder{iFolder});
                ttFile = [ttFile;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') % t�����̸� �ٷ� ��ģ��.
                ttFile = [ttFile;sessionFolder{iFolder}];
            end
        end
    end
end
if nargin == 2
    includeAllTrial = logical(includeAllTrial);
else
    includeAllTrial = false;
end
if isempty(ttFile)
    disp('TT file does not exist!');
    return;
end
ttData = LoadSpikes(ttFile,'tsflag','ts','verbose',0);

nCell = length(ttFile);
for iCell = 1:nCell
    disp(['### Analyzing ',ttFile{iCell},'...']);
    [cellPath,cellName,~] = fileparts(ttFile{iCell});
    cd(cellPath);

    % Event variables
    if includeAllTrial
        load('Events.mat');
    else
        load('EventsValid.mat');
    end
    win = [-1 maxTrialDuration]*10^3; % unit: msec, window for binning
    window = [-0.5 maxTrialDuration-0.5]; % unit: sec, final view window
    
    yTemp = [0:nTrial-1; 1:nTrial; NaN(1,nTrial)]; % ypt ���� �� ���
    resultSum = [0 cumsum(trialResult)];
    
    spikeData = Data(ttData{iCell})/10; % unit: msec
    spikeTime = cell(nTrial,1);
    spikeTimeAfterReward = cell(nTrial,1);
    
    % Firing rate
    fr_base = sum(histc(spikeData,baseTime))/diff(baseTime/1000);
    fr_task = sum(histc(spikeData,taskTime))/diff(taskTime/1000);
        
    % Making raster, PSTH
    for iTrial = 1:nTrial
        timeIndex = [];
        if isnan(eventTime(iTrial,1)); continue; end;
        [~,timeIndex] = histc(spikeData,eventTime(iTrial,1)+win);
        if isempty(timeIndex); continue; end;
        spikeTime{iTrial} = spikeData(logical(timeIndex))-eventTime(iTrial,1);
        
        % raster for time from reward licking
        [~,timeRewardIndex] = histc(spikeData,rewardLickTime(iTrial)+rewardWin);
        if isempty(timeRewardIndex); continue; end;
        spikeTimeAfterReward{iTrial} = spikeData(logical(timeRewardIndex)) - rewardLickTime(iTrial);
    end

    % Making raster points
    spikeBin = win(1)/10^3:binSize:win(2)/10^3; % unit: sec
    totalHist = histc(cell2mat(spikeTime),spikeBin)/(binSize*nTrial);
    fireMean = mean(totalHist);
    fireStd = std(totalHist);
    
    nCue = length(trialResult);
    nSpikeBin = length(spikeBin);
    xpt = cell(1,nCue);
    ypt = cell(1,nCue);
    spikeHist = zeros(nCue,nSpikeBin);
    spikeConv = zeros(nCue,nSpikeBin);
    
    xptReward = cell(1,nCue);
    yptReward = cell(1,nCue);
    spikeRewardHist = zeros(nCue,nSpikeBin);
    spikeRewardConv = zeros(nCue,nSpikeBin);

    for iCue = 1:nCue % Cue A_rewarded (Ay), An, By, Bn, Cy, Cn, Dy, Dn
        nSpikePerTrial = cellfun(@length,spikeTime(trialIndex(:,iCue)));
        nSpikeTotal = sum(nSpikePerTrial);
        
        nSpikeRewardPerTrial = cellfun(@length,spikeTimeAfterReward(trialIndex(:,iCue)));
        nSpikeRewardTotal = sum(nSpikeRewardPerTrial);
        
        if trialResult(iCue)==0 || nSpikeTotal == 0
            xpt{iCue} = [];
            ypt{iCue} = [];
            if nSpikeRewardTotal == 0
                xptReward{iCue} = [];
                yptReward{iCue} = [];
            end
            continue;
        end

        spikeTemp = cell2mat(spikeTime(trialIndex(:,iCue)))';
        xptTemp = [spikeTemp;spikeTemp;NaN(1,nSpikeTotal)];
        xptTemp = xptTemp(:);

        yptTemp = [];
        for iy = 1:trialResult(iCue)
            yptTemp = [yptTemp repmat(yTemp(:,resultSum(iCue)+iy),1,nSpikePerTrial(iy))];
        end
        yptTemp = yptTemp(:);
        xpt{iCue} = xptTemp/1000;
        ypt{iCue} = yptTemp;
        
        spikeRewardTemp

        % Making PSTH
        spkhist_temp = histc(spikeTemp/1000,spikeBin)/(binSize*trialResult(iCue));
        spkconv_temp = conv(spkhist_temp,fspecial('Gaussian',[1 5*resolution],resolution),'same');
        spikeHist(iCue,:) = spkhist_temp;
        spikeConv(iCue,:) = spkconv_temp;
        
        % PSTH after reward lick onset
        
        
    end
    peth = spikeHist;
    pethconv = spikeConv;
    zpeth = (spikeHist-fireMean)/fireStd;
    zpethconv = (spikeConv-fireMean)/fireStd;

    save([cellName,'.mat'],...
        'fr_base','fr_task',...
        'xpt','ypt',...
        'peth','pethconv',...
        'zpeth','zpethconv',...
        'window','spikeBin');
    
    %% Tagging
    nPulse = length(blueOnsetTime);
    yTagTemp =[0:(nPulse-1);1:nPulse;NaN(1,nPulse)];
    spkTemp = cell(nPulse,1);
    
    for iPulse = 1:nPulse
        timeIndex = [];
        [~,timeIndex] = histc(spikeData,blueOnsetTime(iPulse)+winTagBlue);
        if isempty(timeIndex); continue; end;
        spkTemp{iPulse} = spikeData(logical(timeIndex)) - blueOnsetTime(iPulse);
    end
    spikeTagTime = cell2mat(spkTemp)';
    tagHist = histc(spikeTagTime,binTagBlue)/(binTagSizeBlue/1000*nPulse);
    nTagPerTrial = cellfun(@length,spkTemp);
    nTagTotal = sum(nTagPerTrial);
    xpttag = []; ypttag = [];
    if nTagTotal~=0;
        xpttag = [spikeTagTime;spikeTagTime;NaN(1,nTagTotal)];
        xpttag = xpttag(:);
        for iytag = 1:nPulse
            ypttag = [ypttag repmat(yTagTemp(:,iytag),1,nTagPerTrial(iytag))];
        end
        ypttag = ypttag(:);
    else
        xpttag = []; ypttag = [];
        tagHist = zeros(1,length(binTagBlue));      
    end
    save([cellName,'.mat'],...
        'xpttag','ypttag','binTag','tagHist','-append');
end
disp('### Making Raster, PSTH is done!');
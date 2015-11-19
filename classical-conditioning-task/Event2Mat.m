function Event2Mat(sessionFolder,modOff)
% Event2Mat Converts data from Neuralynx NEV files to Matlab mat files

% Make lists of event files
narginchk(0, 2);
if nargin == 0
    eventFile = FindFiles('Events.nev','CheckSubdirs',0);
elseif nargin >= 1
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eventFile = FindFiles('Events.nev','CheckSubdirs',0);
    else
        nFolder = length(sessionFolder);
        eventFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder},'dir')
                cd(sessionFolder{iFolder});
                eventFile = [eventFile;FindFiles('Events.nev','CheckSubdirs',1)];
            end
        end
    end
end
if isempty(eventFile)
    disp('Event file does not exist!');
    return;
end
if nargin < 2
    modOff = 0;
end

nFile = length(eventFile);
for iFile = 1:nFile
    disp(['Analyzing ',eventFile{iFile}]);
    cd(fileparts(eventFile{iFile}));
    
    [timeStamp, eventString] = Nlx2MatEV(eventFile{iFile}, [1 0 0 0 1], 0, 1, []);
    timeStamp = timeStamp'/1000; % unit: ms
    
    % epoch
    recStart = find(strcmp(eventString,'Starting Recording'));
    recEnd = find(strcmp(eventString,'Stopping Recording'));
    baseTime = timeStamp([recStart(1),recEnd(1)]);
    taskTime = timeStamp([recStart(2),recEnd(2)]);
    
    % lick time
    lickITIThreshold = 1000/20; % lick intervals shorter than 20 Hz (50 ms) are usually artifacts.
    lickOnsetIndex = strcmp(eventString, 'Sensor');
    lickOnsetTime = timeStamp(lickOnsetIndex);
    lickOut = [false; (diff(lickOnsetTime(:,1)) < lickITIThreshold)];
    lickOnsetTime(lickOut,:) = [];
    
    % trial
    trialStartIndex = find(strcmp(eventString, 'Baseline'));
    nTrial = length(trialStartIndex) - 1;
    
    eventTime = NaN(nTrial, 6);
    cue = NaN(nTrial, 1);
    reward = NaN(nTrial, 1);
    punishment = NaN(nTrial, 1);
    modulation = NaN(nTrial, 1);
    rewardLickTime = NaN(nTrial,1);
    punishYes = any(strcmp(eventString, 'Punishment'));
    for iTrial = 1:nTrial
        inTrial = (timeStamp>=timeStamp(trialStartIndex(iTrial)) & timeStamp<timeStamp(trialStartIndex(iTrial+1)));
        
        % cue
        cueIndex = strncmp(eventString, 'Cue', 3) & inTrial;
        if ~any(cueIndex); continue; end;
        
        % reward
        rewardIndex = (strcmp(eventString, 'Reward') | strcmp(eventString, 'Non-reward') | strcmp(eventString, 'Punishment')) & inTrial;
        if ~any(rewardIndex); continue; end;

        % TTL off (1. cue onset, 2. delay onset, 3. reward offset)
        offsetTemp = find(strncmp(eventString, 'TTL Input on AcqSystem1_0 board 0 port 2', 40) & inTrial);
        if length(offsetTemp)~=3; continue; end;
        
        % modulation
        modulationIndex = strcmp(eventString, 'Red') & inTrial;
        
        % time variables
        % col1: baseline
        % col2: cue onset
        % col3: delay onset
        % col4: reward onset
        % col5: reward offset
        % col6: trial end
        eventTime(iTrial,1) = timeStamp(cueIndex);
        eventTime(iTrial, [2:3 5]) = timeStamp(offsetTemp);
        eventTime(iTrial,4) = timeStamp(rewardIndex);
        eventTime(iTrial,6) = timeStamp(trialStartIndex(iTrial+1));
        
        % trial variables
        cue(iTrial) = str2double(eventString{cueIndex}(4));
        reward(iTrial) = any(strcmp(eventString, 'Reward') & inTrial);
        punishment(iTrial) = any(strcmp(eventString, 'Punishment') & inTrial);
        modulation(iTrial) = any(modulationIndex);
        
        % find first lick after reward presentation time
        if punishYes && cue(iTrial) == 4
            rewardLickTime(iTrial) = eventTime(iTrial,4);
        else
            rewardTempTime = find(lickOnsetTime>=eventTime(iTrial,4) & lickOnsetTime<eventTime(iTrial,6),1,'first');
            if ~isempty(rewardTempTime)
                rewardLickTime(iTrial) = lickOnsetTime(rewardTempTime);
            end
        end
    end
    errorTrial = isnan(cue) | isnan(reward) | isnan(modulation) | isnan(eventTime(:,1));
    errorTrialNum = sum(errorTrial);
    
    eventTime(errorTrial,:) = [];
    cue(errorTrial) = [];
    reward(errorTrial) = [];
    punishment(errorTrial) = [];
    modulation(errorTrial) = [];
    rewardLickTime(errorTrial) = [];
    
    % Extract non-valid trials
    % If reward is not taken during current trial, it is not valid
    % trial until mouse licks.
    notValidTrial = false(nTrial,1);
    notValidIndex = find(isnan(rewardLickTime) & reward==1)';
    for jTrial = notValidIndex
        [~,notValidUntil] = histc(lickOnsetTime(find(lickOnsetTime>=eventTime(jTrial,4),1,'first')),eventTime(:,6));
        if isempty(notValidUntil); continue; end;
        notValidTrial(jTrial:(notValidUntil+1)) = true;
    end

    notValidTrialNum = sum(notValidTrial);
    
    eventTime(notValidTrial,:) = [];
    cue(notValidTrial) = [];
    reward(notValidTrial) = [];
    punishment(notValidTrial) = [];
    modulation(notValidTrial) = [];
    rewardLickTime(notValidTrial) = [];
    
    if modOff==1
        modulation(modulation==1)=0;
    end
       
    nTrial = size(eventTime,1);
    nTrialRw = sum(~isnan(rewardLickTime));
    trialDuration = eventTime(:,6) - eventTime(:,1);
    maxTrialDuration = round(max(trialDuration)/1000);
    
    eventDuration = round(mean(eventTime - repmat(eventTime(:,2),1,6))/500)/2;

    % trial summary
    cueIndex = false(nTrial,8); % [CueA&noMod CueA&Mod ...]
    trialIndex = false(nTrial,16);% [CueA&noMod&Reward CueA&Mod&Reward CueA&noMod&noReward CueA&Mod&noReward ...]
    for iCue = 1:4
        for iModulation = 1:2
            cueIndex(:,(iCue-1)*2 + iModulation) = (cue==iCue) & (modulation==(iModulation-1));
            for iReward = 1:2
                iCol = (iCue-1)*4 + (iReward-1)*2 + iModulation;
                trialIndex(:,iCol) = (cue==iCue) & ((reward+punishment)==(2-iReward)) & (modulation==(iModulation-1));
            end
        end
    end
    cueResult = sum(cueIndex);
    trialResult = sum(trialIndex);
    
    % tagging
    tagIndex = timeStamp > taskTime(2);
    blueOnsetIndex = strcmp(eventString, 'Blue') & tagIndex;
    redOnsetIndex = strcmp(eventString, 'Red') & tagIndex;
    blueOnsetTime = timeStamp(blueOnsetIndex);
    redOnsetTime = timeStamp(redOnsetIndex);
    
    save('Events.mat', ...
        'baseTime', 'taskTime', 'lickOnsetTime', 'rewardLickTime', ...
        'eventTime', 'cue', 'reward', 'punishment', 'modulation', ...
        'nTrial', 'nTrialRw', 'errorTrialNum', 'notValidTrialNum', 'maxTrialDuration', 'eventDuration', ...
        'cueIndex', 'cueResult', 'trialIndex', 'trialResult', ...
        'blueOnsetTime', 'redOnsetTime');   
end
disp('Done!');
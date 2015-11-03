function discriminabilityCC(sessionFolder)

saveDir = pwd;

if nargin == 0
    matFile = FindFiles('T*.mat','CheckSubdirs',1); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        matFile = FindFiles('T*.t','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        matFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                matFile = [matFile;FindFiles('T*.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                matFile = [matFile;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(matFile)
    disp('TT file does not exist!');
    return;
end

nFile = length(matFile);

dCue = zeros(nFile,2);
dRw = zeros(nFile,2);

cueWindow = [0 2]*10^3;
cueWinLength = diff(cueWindow);
rewardWindow = [0 1]*10^3;
rewardWinLength = diff(rewardWindow);

for iFile = 1:nFile
    [cellPath,cellName,~] = fileparts(matFile{iFile});
    cd(cellPath);
    load(matFile{iFile});
    load('Events.mat');
    
    if find(trialResult==0,1)<9; 
        dCue(iFile,:) = NaN;
        dRw(iFile,:) = NaN;
        continue;
    end
    
    spikeTime4Cue = [];
    spikeTime4Rw = [];
   
    [~,spikeTime4Cue] = spikeBin(spikeTime, cueWindow, cueWinLength, cueWinLength);
    [~,spikeTime4Rw] = spikeBin(spikeTimeRw, rewardWindow, rewardWinLength, rewardWinLength);
    
    meanFR4Cue = mean(repmat(spikeTime4Cue,1,4).*cueIndex(:,1:4));
    stdFR4Cue = std(repmat(spikeTime4Cue,1,4).*cueIndex(:,1:4));
    meanFR4Rw = mean(repmat(spikeTime4Rw,1,8).*trialIndex(:,1:8));
    stdFR4Rw = std(repmat(spikeTime4Rw,1,8).*trialIndex(:,1:8));
        
    dCue(iFile,1) = abs(meanFR4Cue(1)-meanFR4Cue(3))/sqrt(stdFR4Cue(1)^2/cueResult(1)+stdFR4Cue(3)^2/cueResult(3)); % d' for cue in no mod trials
    dCue(iFile,2) = abs(meanFR4Cue(2)-meanFR4Cue(4))/sqrt(stdFR4Cue(2)^2/cueResult(2)+stdFR4Cue(4)^2/cueResult(4)); % d' for cue in mod trials
    
    for iType = 1:4
        dRw(iFile,iType) = abs(meanFR4Rw(iType)-meanFR4Rw(iType+2))/sqrt(stdFR4Rw(iType)^2/trialResult(iType)+stdFR4Rw(iType+2)^2/trialResult(iType+2));
         % d' for reward in (cueA, no mod trials / cueA,mod trials / ..)
    end    
end

pRw = NaN(1,2);
[~,pCue] = ttest(dCue(:,1),dCue(:,2));
[~,pRw(1)] = ttest(dRw(:,1),dRw(:,2));
[~,pRw(2)] = ttest(dRw(:,3),dRw(:,4));

cd(saveDir);
save('discrimination.mat','dCue','dRw','matFile','pCue','pRw');
end
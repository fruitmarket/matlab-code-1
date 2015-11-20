function decodingCC(sessionFolder)

saveDir = pwd;
matFile = FindFiles('T*.t','CheckSubdirs',1);
nFile = length(matFile);
binWindow = [500 500]; %[for cue; for reward], unit: ms
binStep = [100 100]; % [for cue; for reward], unit: ms
meanFR4Cue = {};
meanFR4Rw = {};
cellFile = {};

for iFile = 1:nFile
    [cellPath,cellName,~] = fileparts(matFile{iFile});
    cd(cellPath);
    load([cellName,'.mat'],'spikeTime','spikeTimeRw');
    load('Events.mat','eventDuration','modulation','cueIndex','nTrial','trialIndex');
    
    timeWindow = [eventDuration(1) eventDuration(6)]*10^3;
    
    if sum(modulation)==0; 
        matFile{iFile} = NaN; continue; end % modulation 없는 session의 경우 분석에서 제외
    
    cellFile = [cellFile; matFile{iFile}];
    spk4Cue = [];
    spk4Rw = [];
   
    [time4Cue,spk4Cue] = spikeBin(spikeTime, timeWindow, binWindow(1), binStep(1));
    [time4Rw,spk4Rw] = spikeBin(spikeTimeRw, timeWindow, binWindow(2), binStep(2));
     
    
    save([cellName, '.mat'],'time4Cue','spk4Cue','time4Rw','spk4Rw','-append');
end

nTime = 50;
nCell = length(cellFile);
nBin = length(time4Cue);
       totalTest4Cue = zeros(4,nBin);
       totalTest4Rw = zeros(8,nBin);
       correctTest4Cue = zeros(4,nBin);
       correctTest4Rw = zeros(8,nBin);
                   trainingVector4Rw = {};
            trainingVector4Cue = {};
            testVector4Rw = {};
            testVector4Cue = {};
for iTime = 1:nTime
       for iCell = 1:nCell
            [cellPath,cellName,~] = fileparts(cellFile{iCell});
            cd(cellPath);
            load([cellName,'.mat'],'time4Cue','spk4Cue','time4Rw','spk4Rw');
            load('Events.mat','eventDuration','modulation','cueIndex','nTrial','trialIndex');

            [~,trainingInd] = datasample(1:nTrial,round(nTrial/2),'Replace',false);
            testInd = 1:nTrial;
            testInd(trainingInd) = NaN;
            testInd = testInd(~isnan(testInd));
            testInd = sort(testInd);
            for iTrialType = 1:8
                trainingVector4Rw{iTrialType}(iCell,:) = mean(spk4Rw(trialIndex(trainingInd,iTrialType),:),1);
                testVector4Rw{iTrialType}(iCell,:) = mean(spk4Rw(trialIndex(testInd,iTrialType),:),1);
                if iTrialType>4; continue; end;
                trainingVector4Cue{iTrialType}(iCell,:) = mean(spk4Cue(cueIndex(trainingInd,iTrialType),:),1);
                testVector4Cue{iTrialType}(iCell,:) = mean(spk4Cue(cueIndex(testInd,iTrialType),:),1);
            end
       end
       
     
       for iTrialType = 1:8
           for iBin = 1:nBin
               dot4Cue = []; 
               dot4Rw = [];
               if iTrialType<3
                   dot4Cue(1,:) = dot(repmat(trainingVector4Cue{iTrialType}(:,iBin),1,length(testVector4Cue{iTrialType}(1,iBin))),testVector4Cue{iTrialType}(:,iBin));
                   dot4Cue(2,:) = dot(repmat(trainingVector4Cue{iTrialType+2}(:,iBin),1,length(testVector4Cue{iTrialType}(1,iBin))),testVector4Cue{iTrialType}(:,iBin));
                   % <Cue discrimination> 1st Row : Cue A, 2nd Row : Cue B
                   totalTest4Cue(iTrialType,iBin) = totalTest4Cue(iTrialType,iBin)+ sum((dot4Cue(1,:)-dot4Cue(2,:))~=0);
                   sum((dot4Cue(1,:)-dot4Cue(2,:))~=0)
                   correctTest4Cue(iTrialType,iBin) = correctTest4Cue(iTrialType,iBin)+ sum((dot4Cue(1,:)-dot4Cue(2,:))>0);
                   % <Cue discrimination> 1st Row : no mod, 2nd Row : mod

                   dot4Rw(1,:) = dot(repmat(trainingVector4Rw{iTrialType}(:,iBin),1,length(testVector4Rw{iTrialType}(1,iBin))),testVector4Rw{iTrialType}(:,iBin)); 
                   dot4Rw(2,:) = dot(repmat(trainingVector4Rw{iTrialType+2}(:,iBin),1,length(testVector4Rw{iTrialType}(1,iBin))),testVector4Rw{iTrialType}(:,iBin));
                   % <Reward discrimination> 1st Row : Reward in Cue A, 2nd Row : no Reward in Cue A
                   totalTest4Rw(iTrialType,iBin) = totalTest4Rw(iTrialType,iBin)+ sum((dot4Rw(1,:)-dot4Rw(2,:))~=0);
                   correctTest4Rw(iTrialType,iBin) = correctTest4Rw(iTrialType,iBin)+ sum((dot4Rw(1,:)-dot4Rw(2,:))>0);
                   % <Reward discrimination> 1st Row : no mod in Cue A, 2nd Row: mod in Cue A
                   
               elseif 4<iTrialType && iTrialType<7
                   dot4Rw(3,:) = dot(repmat(trainingVector4Rw{iTrialType}(:,iBin),1,length(testVector4Rw{iTrialType}(1,iBin))),testVector4Rw{iTrialType}(:,iBin)); 
                   dot4Rw(4,:) = dot(repmat(trainingVector4Rw{iTrialType+2}(:,iBin),1,length(testVector4Rw{iTrialType}(1,iBin))),testVector4Rw{iTrialType}(:,iBin));
                   % <Reward discrimination> 3rd Row : Reward in Cue B, 2nd Row : no Reward in Cue B
                   totalTest4Rw(iTrialType-2,iBin) = totalTest4Rw(iTrialType-2,iBin)+ sum((dot4Rw(3,:)-dot4Rw(4,:))~=0);
                   correctTest4Rw(iTrialType-2,iBin) = correctTest4Rw(iTrialType-2,iBin)+ sum((dot4Rw(3,:)-dot4Rw(4,:))>0);
                   % <Reward discrimination> 1st Row : no mod in Cue B, 2nd Row: mod in Cue B
               end
           end
       end
end
cd(saveDir);
save('Decoding.mat','totalTest4Rw','totalTest4Cue','correctTest4Cue','correctTest4Rw');
end

       
               
               
               
               
               
       
                
        

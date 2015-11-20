function performanceCC(sessionFolder)

saveDir = pwd;

if nargin == 0
    eventFile = FindFiles('Events.mat','CheckSubdirs',1); 
else
    if ~iscell(sessionFolder)
        disp('Input argument is wrong. It should be cell array.');
        return;
    elseif isempty(sessionFolder)
        eventFile = FindFiles('Events.mat','CheckSubdirs',1);
    else
        nFolder = length(sessionFolder);
        eventFile = cell(0,1);
        for iFolder = 1:nFolder
            if exist(sessionFolder{iFolder})==7 
                cd(sessionFolder{iFolder});
                eventFile = [eventFile;FindFiles('Events.t','CheckSubdirs',1)];
            elseif strcmp(sessionFolder{iFolder}(end-1:end),'.t') 
                eventFile = [eventFile;sessionFolder{iFolder}];
            end
        end
    end
end
if isempty(eventFile)
    disp('TT file does not exist!');
    return;
end

nFile = length(eventFile);


meanLick = [];
jFile = 1;
subMeanLick = cell(1,2);

for iFile = 1:nFile
    [cellPath,~,~] = fileparts(eventFile{iFile});
    cd(cellPath);
    load(eventFile{iFile});
    if find(trialResult==0,1)<9 || find(cueResult==0,1)<5; 
        continue;
    end;
    lickBin = -1:0.01:(maxTrialDuration+0.5);
    delayLick = sum(lickHist(:,(find(lickBin==1):find(lickBin==2))),2).*0.01;
    subCueIndex = {};
    subCueIndex{1} = zeros(nTrial,8);
    subCueIndex{2} = cueIndex;
    for iType = 1:8
        if cueResult(iType)==0; continue; end;
        subCueIndex{1}(datasample(find(cueIndex(:,iType)),round(cueResult(iType)/2)),iType) = 1;
        subCueIndex{2}(:,iType) = subCueIndex{2}(:,iType)-subCueIndex{1}(:,iType);
        subMeanLick{1}(jFile,iType) = mean(delayLick(subCueIndex{1}(:,iType)==1));
        subMeanLick{2}(jFile,iType) = mean(delayLick(subCueIndex{2}(:,iType)==1));        
    end
    jFile = jFile+1;
end


plot(repmat(1,length(subMeanLick{1}(:,1)),1),subMeanLick{1}(:,1)./subMeanLick{1}(:,2),...
    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
hold on;
%plot(repmat(1,length(subMeanLick{1}(:,1)),1),subMeanLick{1}(:,1)./subMeanLick{2}(:,2),...
%    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
%hold on;
%plot(repmat(1,length(subMeanLick{2}(:,1)),1),subMeanLick{2}(:,1)./subMeanLick{1}(:,2),...
%    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
%hold on;
%plot(repmat(1,length(subMeanLick{2}(:,1)),1),subMeanLick{2}(:,1)./subMeanLick{2}(:,2),...
%    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);

plot(repmat(2,length(subMeanLick{1}(:,1)),1),subMeanLick{1}(:,1)./subMeanLick{2}(:,1),...
    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);

plot(repmat(3,length(subMeanLick{1}(:,2)),1),subMeanLick{1}(:,2)./subMeanLick{2}(:,2),...
    'LineStyle','none','Marker','.','MarkerSize',9,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
end


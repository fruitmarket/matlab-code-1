%% glm for head-fixed mice
clc; clearvars; close all; warning off;

%% Variables
winSize = 100;

% for Cue-modulation sessions (Prep cue is same to Laser onset)
winStep = {-200:winSize:1300; -200:winSize:1300; -200:winSize:1300; -200:winSize:1300; ...
    -200:winSize:2200; -200:winSize:2200; -200:winSize:2200; -200:winSize:2200};
winStep = [winStep; winStep; {-200:winSize:4700; -600:winSize:1400; -600:winSize:2900; -600:winSize:7900;}];

nWinBin = cellfun(@length, winStep);
nVar = 2*(4+2+2)+4;
varName = {'Cue A', 'Cue B', 'Cue C', 'Cue D', ...
    'Reward', 'Non-reward', 'Punishment', 'Non-punishment', ...
    'mod_Cue A', 'mod_Cue B', 'mod_Cue C', 'mod_Cue D', ...
    'mod_Reward', 'mod_Non-reward', 'mod_Punishment', 'mod_Non-punishment', ...
    'Laser','Mid-bout lick', 'Lick onset', 'Lick offset'};
% 
% % for Reward-modulation sessions
% winStep{2} = {-200:winSize:3200; ...
%     -200:winSize:1300; -200:winSize:1300; -200:winSize:1300; -200:winSize:1300; ...
%     -200:winSize:2200; -200:winSize:2200; -200:winSize:2200; -200:winSize:2200};
% winStep{2} = [winStep{2}; winStep{2}; {-600:winSize:1400; -600:winSize:2900; -600:winSize:7900;}];
% 
% nWinBin{2} = cellfun(@length, winStep{2});
% 
% % for Total-modulation sessions (Prep cue is same to Laser onset)
% winStep{3} = {-200:winSize:5200; ...
%     -200:winSize:1700; -200:winSize:1700; -200:winSize:1700; -200:winSize:1700; ...
%     -200:winSize:2200; -200:winSize:2200; -200:winSize:2200; -200:winSize:2200};
% winStep{3} = [winStep{3}; winStep{3}; {-600:winSize:1400; -600:winSize:2900; -600:winSize:7900;}];
%   
% nWinBin{3} = cellfun(@length, winStep{3});

%% Load cell list
load('D:\Cheetah_data\Classical_conditioning\cellTable.mat');
cellNm = {'pv','vip','pv_inhibited','vip_inhibited','fs', 'pc'};

condition = {'Cue','Reward','Total'};
modType = 1; % 1:Cue-modulation, 2:Reward-modulation, 3:Total-modulation
inType = T.modType==condition(modType);
T = T(inType,:);

tag.inh = T.pLR<0.01 & T.act==0 ;
tag.act = T.pLR<0.01 & T.act==1 ;

tag.pv = tag.inh & T.mouseLine=='PV';
tag.vip = tag.inh & T.mouseLine=='VIP';
tag.pv_inhibited = tag.act & T.mouseLine=='PV';
tag.vip_inhibited = tag.act & T.mouseLine=='VIP';
tag.fs = T.class == 1;
tag.pc = T.class == 2;

T = T(tag.pv_inhibited,:);
cellList = T.cellList;
nC = length(cellList);

%% Load cell data
mFile = cellList;

preext = '.mat';
curext = '.t';

tFile = cellfun(@(x) regexprep(x,preext,curext), mFile, 'UniformOutput', false);
[tData, tList] = tLoad(tFile);

[betas, sems] = deal(cell(nC, nVar));
for iC = 1:5 % will be replaced with for-loop
    %% Load event data
    disp(['Cell ', num2str(iC), ' / ', num2str(nC)]);
    load([fileparts(tList{iC}), '\Events.mat'], ...
        'taskTime', 'eventTime', 'rewardLickTime', 'lickOnsetTime', 'cue',...
        'reward', 'punishment','modOnsetTime','modOffsetTime','modulation');
    
    [varTime, varData] = deal(cell(1, nVar));
    modulation = logical(modulation);
           
    for iCue = 1:4
        varTime{iCue} = eventTime(~modulation & cue==iCue, 2);
        varTime{8+iCue} = eventTime(modulation & cue==iCue, 2);
    end
    
    varTime{5} = rewardLickTime(~modulation & logical(reward));
    varTime{6} = rewardLickTime(~modulation & cue<4 & reward==0);
    varTime{7} = rewardLickTime(~modulation & logical(punishment));
    varTime{8} = rewardLickTime(~modulation & cue==4 & punishment==0);
    
    varTime{13} = rewardLickTime(modulation & logical(reward));
    varTime{14} = rewardLickTime(modulation & cue<4 & reward==0);
    varTime{15} = rewardLickTime(modulation & logical(punishment));
    varTime{16} = rewardLickTime(modulation & cue==4 & punishment==0);
    
    varTime{17} = modOnsetTime;
    
    lickRest = find(diff(lickOnsetTime) >= 2000);
    varTime{18} = lickOnsetTime;
    varTime{18}([lickRest; lickRest+1]) = [];
    varTime{19} = lickOnsetTime(lickRest+1);
    varTime{20} = lickOnsetTime(lickRest);
            
    timeBin = taskTime(1):winSize:taskTime(2);
    nTimeBin = length(timeBin);
    
    for iV = 1:nVar
        if isempty(varTime{iV}); varData{iV} = []; continue; end;
        varData{iV} = zeros(nTimeBin, nWinBin(iV));
        for iB = 1:nWinBin(iV)
            varData{iV}(:, iB) = logical(histc(varTime{iV}, timeBin - winStep{iV}(iB)));
        end
    end
   
%     switch modType
%         case 1
%             varTime{1} = eventTime(~modulation,1);
%             varTime{2} = eventTime(~modulation,1)+2000;
%             varTime{11} = modOnsetTime;
%             varTime{12} = modOffsetTime;
%             jAdd = 2;
%         case 2
%             varTime{1} = eventTime(~modulation, 1);
%             varTime{2} = eventTime(~modulation,1)+2000;
%             varTime{3} = eventTime(~modulation,1)+5000;
%             varTime{11} = eventTime(modulation, 1);
%             varTime{12} = modOnsetTime;
%             varTime{13} = modOffsetTime;
%             jAdd = 3;
%         case 3
%             varTime{1} = eventTime(~modulation,1);
%             varTime{2} = eventTime(~modulation,1)+5000;
%             varTime{11} = modOnsetTime;
%             varTime{12} = modOffsetTime;
%             jAdd = 2;
%     end
%            
%     for iCue = 1:4
%         varTime{jAdd+iCue} = eventTime(~modulation & cue==iCue, 2);
%         varTime{2*jAdd+8+iCue} = eventTime(modulation & cue==iCue, 2);
%     end
%     
%     varTime{jAdd+5} = rewardLickTime(~modulation & logical(reward));
%     varTime{jAdd+6} = rewardLickTime(~modulation & cue<4 & reward==0);
%     varTime{jAdd+7} = rewardLickTime(~modulation & logical(punishment));
%     varTime{jAdd+8} = rewardLickTime(~modulation & cue==4 & punishment==0);
%     
%     varTime{2*jAdd+13} = rewardLickTime(modulation & logical(reward));
%     varTime{2*jAdd+14} = rewardLickTime(modulation & cue<4 & reward==0);
%     varTime{2*jAdd+15} = rewardLickTime(modulation & logical(punishment));
%     varTime{2*jAdd+16} = rewardLickTime(modulation & cue==4 & punishment==0);
%     
%     lickRest = find(diff(lickOnsetTime) >= 2000);
%     varTime{21} = lickOnsetTime;
%     varTime{21}([lickRest; lickRest+1]) = [];
%     varTime{22} = lickOnsetTime(lickRest+1);
%     varTime{23} = lickOnsetTime(lickRest);
%         
%     timeBin = taskTime(1):winSize:taskTime(2);
%     nTimeBin = length(timeBin);
%     
%     for iV = 1:nVar
%         if isempty(varTime{iV}); varData{iV} = []; continue; end;
%         varData{iV} = zeros(nTimeBin, nWinBin{modType}(iV));
%         for iB = 1:nWinBin{modType}(iV)
%             varData{iV}(:, iB) = logical(histc(varTime{iV}, timeBin - winStep{modType}{iV}(iB)));
%         end
%     end
    nVarBin = cellfun(@(x) size(x,2), varData);
    X = cell2mat(varData);
    
    %% Rearrange data
    spike = histc(tData{iC}, timeBin);
    nSpike = length(spike);
    inBin = 1:(nSpike-1);
    
    [b, dev, stats] = glmfit(X(inBin, :), spike(inBin), 'poisson');
    m = mat2cell(stats.beta(2:end)', 1, nVarBin);
    s = mat2cell(stats.se(2:end)', 1, nVarBin);
    
    for iVar = 1:nVar
        if isempty(m{iVar})
            betas{iC,iVar} = NaN(1, nWinBin(iVar));
            continue;
        end
        betas{iC,iVar} = m{iVar};
        sems{iC,iVar} = s{iVar};
    end    
end

T2_label = {'b_A', 'b_B', 'b_C', 'b_D', 'b_rw', 'b_nrw', 'b_pn', 'b_npn',...
    'mod_b_A', 'mod_b_B', 'mod_b_C', 'mod_b_D', 'mod_b_rw', 'mod_b_nrw', 'mod_b_pn', 'mod_b_npn',...
    'b_laser','b_lkmid', 'b_lkon', 'b_lkoff'};

T2 = cell2table(betas);
T2.Properties.VariableNames = T2_label;

T3_label = {'se_A', 'se_B', 'se_C', 'se_D', 'se_rw', 'se_nrw', 'se_pn', 'se_npn',...
    'mod_se_A', 'mod_se_B', 'mod_se_C', 'mod_se_D', 'mod_se_rw', 'mod_se_nrw', 'mod_se_pn', 'mod_se_npn',...
    'se_laser','se_lkmid', 'se_lkon', 'se_lkoff'};

T3 = cell2table(sems);
T3.Properties.VariableNames = T3_label;

T = [T T2 T3];

winStep = cellfun(@(x) x/1000,winStep','UniformOutput',false);
label = {'A', 'B', 'C', 'D', 'rw', 'nrw', 'pn', 'npn',...
    'mod_A', 'mod_B', 'mod_C', 'mod_D', 'mod_rw', 'mod_nrw', 'mod_pn', 'mod_npn',...
    'laser','lkmid', 'lkon', 'lkoff'};
plotTime = cell2table(winStep);
plotTime.Properties.VariableNames = label;



% T2_label{1} = {'b_pc', 'b_lsoff', 'b_A', 'b_B', 'b_C', 'b_D', 'b_rw', 'b_nrw', 'b_pn', 'b_npn',...
%     'mod_b_pc', 'mod_b_lsoff','mod_b_A', 'mod_b_B', 'mod_b_C', 'mod_b_D', 'mod_b_rw', 'mod_b_nrw', 'mod_b_pn', 'mod_b_npn',...
%     'b_lkmid', 'b_lkon', 'b_lkoff'};
% T2_label{2} = {'b_pc', 'b_lson', 'b_lsoff', 'b_A', 'b_B', 'b_C', 'b_D', 'b_rw', 'b_nrw', 'b_pn', 'b_npn',...
%     'mod_b_pc', 'mod_b_lson', 'mod_b_lsoff','mod_b_A', 'mod_b_B', 'mod_b_C', 'mod_b_D', 'mod_b_rw', 'mod_b_nrw', 'mod_b_pn', 'mod_b_npn',...
%     'b_lkmid', 'b_lkon', 'b_lkoff'};
% T2_label{3} = T2_label{1};
% 
% T2 = cell2table(betas);
% T2.Properties.VariableNames = T2_label{modType};
% 
% T3_label{1} = {'se_pc', 'se_lsoff', 'se_A', 'se_B', 'se_C', 'se_D', 'se_rw', 'se_nrw', 'se_pn', 'se_npn',...
%     'mod_se_pc', 'mod_se_lsoff', 'mod_se_A', 'mod_se_B', 'mod_se_C', 'mod_se_D', 'mod_se_rw', 'mod_se_nrw', 'mod_se_pn', 'mod_se_npn',...
%     'se_lk', 'se_lkon', 'se_lkoff'};
% T3_label{2} = {'se_pc', 'se_lson', 'se_lsoff', 'se_A', 'se_B', 'se_C', 'se_D', 'se_rw', 'se_nrw', 'se_pn', 'se_npn',...
%     'mod_se_pc', 'mod_se_lson', 'mod_se_lsoff', 'mod_se_A', 'mod_se_B', 'mod_se_C', 'mod_se_D', 'mod_se_rw', 'mod_se_nrw', 'mod_se_pn', 'mod_se_npn',...
%     'se_lk', 'se_lkon', 'se_lkoff'};
% T3_label{3} = T3_label{1};
% 
% T3 = cell2table(sems);
% T3.Properties.VariableNames = T3_label{modType};
% 
% T = [T T2 T3];

% save(['D:\Cheetah_data\Classical_conditioning\glmCC_', condition{modType}, '_mod.mat']);
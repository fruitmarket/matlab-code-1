clc; clearvars; close all;
load('C:\Users\Lapis\OneDrive\git\matlab-code\classical-conditioning-task\cell_classification\cellTable.mat');

cellNm = {'nssom', 'wssom', 'fs', 'pc'};
trialType = [1, 3, 13, 15];
lineClr = {[0 0.447 0.741], [0.235 0.235 0.235], [0 0 1], [0.5 0.5 1]};
fillClr = {[0 0.447 0.741], [0.494 0.494 0.494]};

tag.p = T.pLR < 0.01 & T.pSalt < 0.01;
tag.pv = tag.p & T.mouseLine=='PV';
tag.nspv = tag.p & T.mouseLine=='PV' & T.class == 1;
tag.som = tag.p & T.mouseLine=='SOM';
tag.nssom = tag.p & T.mouseLine=='SOM' & T.class == 1;
tag.wssom = tag.p & T.mouseLine=='SOM' & T.class == 2;
tag.fs = ~tag.p & T.class == 1;
tag.pc = ~tag.p & T.class == 2;

fHandle = figure('PaperUnits','centimeters','PaperPosition',[2 2 8.5/2/1.75 6.375/2]);
gapL = [0.1 0.1];

hA = zeros(1, 3);
for iT = 1:2
    cellList.(cellNm{iT}) = T.cellList(tag.(cellNm{iT}));
    n.(cellNm{iT}) = length(cellList.(cellNm{iT}));
    
    [psth{1} psth{2} psth{3} psth{4}] = deal(zeros(n.(cellNm{iT}), 601));
    for iC = 1:n.(cellNm{iT})
        load(cellList.(cellNm{iT}){iC});
        inTime = (psthtime >= -1 & psthtime < 0);
        
        test = psthconvzRw(trialType, :);
        
        for iCue = 1:2
            psth{iCue}(iC, :) = test(iCue, :);
        end
    end
    nC = cellfun(@(x) sum(~isnan(x(:,1))), psth, 'UniformOutput', false);
    
    mpsth = cellfun(@nanmean, psth, 'UniformOutput', false);
    spsth = cellfun(@(x, y) nanstd(x) / sqrt(y), psth, nC, 'UniformOutput', false);
    spsth = cellfun(@(x,y) [x-y flip(x+y)], mpsth, spsth, 'UniformOutput', false);
    
    hA(iT) = axes('Position', axpt(1, 2, 1, iT, [], gapL));
    hold on;
    plot([0 0], [-2.5 2.5], 'LineStyle', '-', 'LineWidth', 0.3, 'Color', [0.8 0.8 0.8]);
    for jC = 1:2
        fill([psthtimeRw flip(psthtimeRw)], spsth{jC}, fillClr{jC}, 'LineStyle', 'none');
        plot(psthtimeRw, mpsth{jC}, 'Color', lineClr{jC}, 'LineWidth', 0.5);
    end
    if iT==1; 
        title('ns-SOM', 'FontSize', 6, 'Color', [0.929 0.694 0.125]);
%         axes('Position',[0.80 0.80 0.1 0.1]);
%         hold on;
%         plot([0 0.25],[0.75 0.75],'LineWidth',0.5,'Color',[0 0.447  0.741]);
%         text(0.3,0.75,'Rewarded','FontSize',4);
%         plot([0 0.25],[0.25 0.25],'LineWidth',0.5,'Color',[0.235 0.235 0.235]);
%         text(0.3,0.25,'Unrewarded','FontSize',4);
%         set(gca,'visible','off');
    elseif iT==2
        title('ws-SOM', 'FontSize', 6, 'Color', [0.078 0.447 0.188]);
        xlabel('Time from reward onset (s)', 'FontSize', 5);
        ylabel('Normalized firing rate', 'FontSize', 5);
    end
end
set(hA(1:2), 'TickDir', 'out', 'LineWidth', 0.2, 'FontSize', 4, ...
        'XLim', [-1 3], 'XTick', [-1 0 1 2 3], ...
        'YLim', [-2 2], 'YTick', -2:2, 'YTickLabel', {-2, '', 0, '', 2});
set(hA(1), 'XTickLabel', []);
set(hA(2), 'XTickLabel', {'', '0', '', '2', ''});

print(fHandle, '-depsc', 'C:\Users\Lapis\OneDrive\project\workingmemory_interneuron\manuscript\Neuron\Fig\fig5e.eps');
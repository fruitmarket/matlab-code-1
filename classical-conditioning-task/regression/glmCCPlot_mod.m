close all;

iC =1;

lineClrRed = [0.8 0 0];
lineClrLightRed = [1 0.6 0.6];
lineClrBlue = [0 0 0.8];
lineClrLightBlue = [0.6 0.6 1];
lineClrGrey = [0.4 0.4 0.4];

fillClrRed = [237 50 52] ./ 255;
fillClrLightRed = [242 138 130] ./ 255;
fillClrBlue = [0 153 227] ./ 255;
fillClrLightBlue = [223 239 252] ./ 255;
fillClrGrey = [0.6 0.6 0.6];

%% modulation
% subplot(5,6,1:6)
% 
% cfInt = [T.b_laser{iC}+1.96*T.se_laser{iC} flip(T.b_laser{iC}-1.96*T.se_laser{iC})];
% plotLim = [plotTime.laser(1), plotTime.laser(end);
%     floor(min(cfInt)), ceil(max(cfInt))];
% 
% F = fill([plotTime.laser flip(plotTime.laser)],cfInt,fillClrGrey);
% F.FaceAlpha = 0.3;
% F.EdgeColor = 'none';
% hold on;
% P = plot(plotTime.laser,T.b_laser{iC});
% P.Color = lineClrGrey;
% P.LineWidth = 2;
% 
% xlim(plotLim(1,:));
% ylim(plotLim(2,:));

%% cue
subplot(5,6,7:9)

cfInt_A = [T.b_A{iC}+1.96*T.se_A{iC} flip(T.b_A{iC}-1.96*T.se_A{iC})];
F = fill([plotTime.A flip(plotTime.A)],cfInt_A,fillClrRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.A,T.b_A{iC});
P.Color = lineClrRed;
P.LineWidth = 2;

cfInt_D = [T.b_D{iC}+1.96*T.se_D{iC} flip(T.b_D{iC}-1.96*T.se_D{iC})];
F = fill([plotTime.D flip(plotTime.D)],cfInt_D,fillClrBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.D,T.b_D{iC});
P.Color = lineClrBlue;
P.LineWidth = 2;

plotLim = [plotTime.D(1), plotTime.D(end);
    floor(min([cfInt_D cfInt_A]*10))/10,...
    ceil(max([cfInt_D cfInt_A]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

subplot(5,6,10:12)

cfInt_modA = [T.mod_b_A{iC}+1.96*T.mod_se_A{iC} flip(T.mod_b_A{iC}-1.96*T.mod_se_A{iC})];
F = fill([plotTime.mod_A flip(plotTime.mod_A)],cfInt_modA,fillClrLightRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_A,T.mod_b_A{iC});
P.Color = lineClrLightRed;
P.LineWidth = 2;

cfInt_modD = [T.mod_b_D{iC}+1.96*T.mod_se_D{iC} flip(T.mod_b_D{iC}-1.96*T.mod_se_D{iC})];
F = fill([plotTime.mod_D flip(plotTime.mod_D)],cfInt_modD,fillClrLightBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_D,T.mod_b_D{iC});
P.Color = lineClrLightBlue;
P.LineWidth = 2;

plotLim = [plotTime.D(1), plotTime.D(end);
    floor(min([cfInt_modD cfInt_modA]*10))/10,...
    ceil(max([cfInt_modD cfInt_modA]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

%% Reward

subplot(5,6,13:15)

cfInt_rw = [T.b_rw{iC}+1.96*T.se_rw{iC} flip(T.b_rw{iC}-1.96*T.se_rw{iC})];
F = fill([plotTime.rw flip(plotTime.rw)],cfInt_rw,fillClrRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.rw,T.b_rw{iC});
P.Color = lineClrRed;
P.LineWidth = 2;

cfInt_nrw = [T.b_nrw{iC}+1.96*T.se_nrw{iC} flip(T.b_nrw{iC}-1.96*T.se_nrw{iC})];
F = fill([plotTime.nrw flip(plotTime.nrw)],cfInt_nrw,fillClrRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.nrw,T.b_nrw{iC});
P.Color = lineClrRed;
P.LineStyle = '--';
P.LineWidth = 2;

plotLim = [plotTime.nrw(1), plotTime.nrw(end);
    floor(min([cfInt_nrw cfInt_rw]*10))/10,...
    ceil(max([cfInt_nrw cfInt_rw]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

subplot(5,6,16:18)

cfInt_modrw = [T.mod_b_rw{iC}+1.96*T.mod_se_rw{iC} flip(T.mod_b_rw{iC}-1.96*T.mod_se_rw{iC})];
F = fill([plotTime.mod_rw flip(plotTime.mod_rw)],cfInt_modrw,fillClrLightRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_rw,T.mod_b_rw{iC});
P.Color = lineClrLightRed;
P.LineWidth = 2;

cfInt_modnrw = [T.mod_b_nrw{iC}+1.96*T.mod_se_nrw{iC} flip(T.mod_b_nrw{iC}-1.96*T.mod_se_nrw{iC})];
F = fill([plotTime.mod_nrw flip(plotTime.mod_nrw)],cfInt_modnrw,fillClrLightRed);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_nrw,T.mod_b_nrw{iC});
P.Color = lineClrLightRed;
P.LineStyle = '--';
P.LineWidth = 2;

plotLim = [plotTime.nrw(1), plotTime.nrw(end);
    floor(min([cfInt_modnrw cfInt_modrw]*10))/10,...
    ceil(max([cfInt_modnrw cfInt_modrw]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

%% Punishment

subplot(5,6,19:21)

cfInt_pn = [T.b_pn{iC}+1.96*T.se_pn{iC} flip(T.b_pn{iC}-1.96*T.se_pn{iC})];
F = fill([plotTime.pn flip(plotTime.pn)],cfInt_pn,fillClrBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.pn,T.b_pn{iC});
P.Color = lineClrBlue;
P.LineWidth = 2;

cfInt_npn = [T.b_npn{iC}+1.96*T.se_npn{iC} flip(T.b_npn{iC}-1.96*T.se_npn{iC})];
F = fill([plotTime.npn flip(plotTime.npn)],cfInt_npn,fillClrBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.npn,T.b_npn{iC});
P.Color = lineClrBlue;
P.LineStyle = '--';
P.LineWidth = 2;

plotLim = [plotTime.npn(1), plotTime.npn(end);
    floor(min([cfInt_npn cfInt_pn]*10))/10,...
    ceil(max([cfInt_npn cfInt_pn]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

subplot(5,6,22:24)

cfInt_modpn = [T.mod_b_pn{iC}+1.96*T.mod_se_pn{iC} flip(T.mod_b_pn{iC}-1.96*T.mod_se_pn{iC})];
F = fill([plotTime.mod_pn flip(plotTime.mod_pn)],cfInt_modpn,fillClrLightBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_pn,T.mod_b_pn{iC});
P.Color = lineClrLightBlue;
P.LineWidth = 2;

cfInt_modnpn = [T.mod_b_npn{iC}+1.96*T.mod_se_npn{iC} flip(T.mod_b_npn{iC}-1.96*T.mod_se_npn{iC})];
F = fill([plotTime.mod_npn flip(plotTime.mod_npn)],cfInt_modnpn,fillClrLightBlue);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.mod_npn,T.mod_b_npn{iC});
P.Color = lineClrLightBlue;
P.LineStyle = '--';
P.LineWidth = 2;

plotLim = [plotTime.npn(1), plotTime.npn(end);
    floor(min([cfInt_modnpn cfInt_modpn]*10))/10,...
    ceil(max([cfInt_modnpn cfInt_modpn]*10))/10];
xlim(plotLim(1,:));
ylim(plotLim(2,:));

%% Lick

subplot(5,6,25:26)
cfInt = [T.b_lkmid{iC}+1.96*T.se_lkmid{iC} flip(T.b_lkmid{iC}-1.96*T.se_lkmid{iC})];
plotLim = [plotTime.lkmid(1), plotTime.lkmid(end);
    floor(min(cfInt*10))/10, ceil(max(cfInt*10))/10];

F = fill([plotTime.lkmid flip(plotTime.lkmid)],cfInt,fillClrGrey);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.lkmid,T.b_lkmid{iC});
P.Color = lineClrGrey;
P.LineWidth = 2;

xlim(plotLim(1,:));
ylim(plotLim(2,:));


subplot(5,6,27:28)
cfInt = [T.b_lkon{iC}+1.96*T.se_lkon{iC} flip(T.b_lkon{iC}-1.96*T.se_lkon{iC})];
plotLim = [plotTime.lkon(1), plotTime.lkon(end);
    floor(min(cfInt*10))/10, ceil(max(cfInt*10))/10];

F = fill([plotTime.lkon flip(plotTime.lkon)],cfInt,fillClrGrey);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.lkon,T.b_lkon{iC});
P.Color = lineClrGrey;
P.LineWidth = 2;

xlim(plotLim(1,:));
ylim(plotLim(2,:));


subplot(5,6,29:30)
cfInt = [T.b_lkoff{iC}+1.96*T.se_lkoff{iC} flip(T.b_lkoff{iC}-1.96*T.se_lkoff{iC})];
plotLim = [plotTime.lkoff(1), plotTime.lkoff(end);
    floor(min(cfInt*10))/10, ceil(max(cfInt*10))/10];

F = fill([plotTime.lkoff flip(plotTime.lkoff)],cfInt,fillClrGrey);
F.FaceAlpha = 0.3;
F.EdgeColor = 'none';
hold on;
P = plot(plotTime.lkoff,T.b_lkoff{iC});
P.Color = lineClrGrey;
P.LineWidth = 2;

xlim(plotLim(1,:));
ylim(plotLim(2,:));



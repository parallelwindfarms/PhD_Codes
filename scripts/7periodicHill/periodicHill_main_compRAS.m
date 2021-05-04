function [ ] = periodicHill_main_compRAS(data, caseName, plotU_xByd, ...
                    plotUU_xByd, plotVV_xByd, plotUV_xByd, plotTauW, ...
                    plotnut_xByd, tauWTimeDir, is3D)
%% Make new dirs

uqPlotsDir = [data '/' caseName];

if ~exist(uqPlotsDir, 'dir')
    mkdir(uqPlotsDir);
end
if ~exist([uqPlotsDir '/tex'])
    mkdir([uqPlotsDir '/tex']);
end
if ~exist([uqPlotsDir '/pdf'])
    mkdir([uqPlotsDir '/pdf']);
end
if ~exist([uqPlotsDir '/png'])
    mkdir([uqPlotsDir '/png']);
end

%% Load old data and all the scripts

SCRIPTS = getenv('SCRIPTS');
addpath([SCRIPTS '/7periodicHill']);
addpath([SCRIPTS '/matlabScripts']);
addpath([SCRIPTS '/matlabScripts/matlab2tikz-master/src']);
addpath([SCRIPTS '/matlabScripts/export_fig/export_fig-master']);

sample_xByd = {'0.05','0.50','1.00','2.00','3.00',...
               '4.00','5.00','6.00','7.00','8.00'}; 
sample = {'0_05','0_50','1_00','2_00','3_00',...
          '4_00','5_00','6_00','7_00','8_00'};   
line_num_max  = length(sample);

% DNS data
files = dir([data '0DNS/DNS*']);
DNS = {length(files)};
for i=1:length(files)
    tmpDNS = dlmread([files(i).folder '/' files(i).name], ' ', 37, 0);
    DNS(i) = {tmpDNS};
end
DNStauW = dlmread([data '0DNS/tauW'], ',', 0, 0);

% DET & UQ data
sampleTimeDir = './postProcessing/sample/latestTimeDir';
files = dir([sampleTimeDir '/*xByd']);  
for i=1:length(files)
    load([sampleTimeDir '/' files(i).name]);
end
files = dir([sampleTimeDir '/*c']);
for i=1:length(files)
    load([sampleTimeDir '/' files(i).name]);
end

% Reading tauW 
sampleTimeDir = ['postProcessing/sampleTauW/surface/' tauWTimeDir];
files = dir([sampleTimeDir '/tauW*']);
tauWDET       = dlmread([sampleTimeDir '/' files(3).name], ' ', 2, 0);
tauW0         = dlmread([sampleTimeDir '/' files(1).name], ' ', 2, 0);
tauWSigma     = dlmread([sampleTimeDir '/' files(2).name], ' ', 2, 0);


H    = 28/1000;
D    = H;
R    = D/2;
x    = pc(:,1);
y    = p_xByd(:,1);
tmpxByd = x/D;

% Periodic Hill Geometry
Nx = 500;
[hillX, hillY] = periodicHill_geom(H*1000, Nx);
hillX = hillX/H/1000;
hillY = hillY/H/1000 -1e-3;

hillLS = '-';
hillLW = 1;
hillClr = [.0 .5 .0];

%% Initialization

rhoInf= 1.10;
nu    = 1e-5;
Uinf  = 1;
Uinf2 = Uinf^2;
uCol  = 3;
RCol  = 6;
yuCol = 10;
yRCol = 13;
xDirIdx = 2;
yDirIdx = 3;
yNutCol = 7;

%% Plot settings

% Defaults 
meanClr = '-k';%[0.6350, 0.0780, 0.1840];%'-b';%[0.9290, 0.6940, 0.1250];
% fill_color = rgb('blue');
% fill_color = [0.6350, 0.0780, 0.1840];
fill_color = rgb('orange');

FaceAlpha = 0.2;
EdgeColor = 'none';

tclr   = '-r';
t_fill_color = rgb('red');%[.5 .5 .5];
t_FaceAlpha = 0.4;
t_EdgeColor = 'none';

DNSclr   = '-k';
DNSedge  = 'none';
DNSsize  = 5;
LW2      = 2;
LW1      = 1;
LW0_5    = 0.5;

DETclr   = [0.6350, 0.0780, 0.1840];%'r';

legBool    = 'on';
leg_DNS_IPC = {'DNS', '$\mathbf{E}[\bullet]$', '$\mathbf{E}[\bullet] \pm 2\sqrt{\mathbf{V}[\bullet]}$'};

fSize = 12;
txtFSize = 12;
set(0, 'defaultAxesTickLabelInterpreter', 'latex');
set(0, 'defaultLegendInterpreter', 'latex');
set(0, 'defaultTextInterpreter', 'latex');
set(0, 'defaultAxesFontSize', fSize);
% set(0,'DefaultLegendFontSize',fSize);
% set(0,'DefaultTextFontSize',fSize);

% set(groot, 'units', 'inches', 'position', [0 0 8 4])
set(groot, 'defaultFigureUnits','inches')
set(groot, 'defaultFigurePosition',[2.5 1.5 9 3])

% set(groot, 'defaultFigurePaperPositionMode', 'manual');
set(groot, 'defaultFigurePaperUnits', 'inches');
set(groot, 'defaultFigurePaperPosition', [2.5 1.5 9 3]);

%% nut_xByD_...

scaling = 2e-3;
N = 2*scaling;

for makePlot = 0 : plotnut_xByd-1

plotOffset = [0.05, 0.5, 1,2,3,4,5,6,7,8];  
textOffset = [4.75,3.2,2.2,1.15,0.85,0.28];

for line_num=3:line_num_max
    yByd(:,line_num) = p_xByd(:, 1 + (line_num-1)*yNutCol)/D;
    Mean(:,line_num) = scaling*p_xByd(:, 2 + (line_num-1)*yNutCol)/nu + plotOffset(line_num);
    ub(:,line_num)   = Mean(:,line_num)+N*p_xByd(:, 3 + (line_num-1)*yNutCol)/nu;
    lb(:,line_num)   = Mean(:,line_num)-N*p_xByd(:, 3 + (line_num-1)*yNutCol)/nu;
%     DET(:,line_num)  = scaling*p_xByd(:, 4 + (line_num-1)*yNutCol)/nu + plotOffset(line_num);
end

figure(10)
    hold on;
    grid off;

    ylabel("$y/H$"');
    if scaling~=1
        xlabel(string(scaling)+"$\nu_t/\nu + x/H$");
    else
        xlabel("$\nu_t/\nu + x/H$");
    end
    
    for line_num=3:line_num_max
        
%         plt3 = plot(DET(:,line_num), yByd(:,line_num), 'color', DETclr,'LineWidth',LW1);
        plt2 = plot(Mean(:,line_num), yByd(:,line_num), meanClr, 'color', fill_color, 'LineWidth',LW1);
        fl1  = fill([ub(:,line_num)', fliplr(lb(:,line_num)')], [yByd(:,line_num)', fliplr(yByd(:,line_num)')], ...
                  fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
        uistack(fl1,'bottom'); 
        
%         text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    end
    
    pltHill = plot(hillX, hillY, hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltX0   = plot(0*hillX, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltx1   = plot(0*hillX+9, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltY3H  = plot(hillX, 0*hillY+85/H/1000, hillLS,'LineWidth', hillLW,'color', hillClr);
    
    axis([0 11 0 3.1]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
% %     yticks([-0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.2]);
%     leg1 = legend([plt1(1) plt1(2) plt1(3) plt3 plt2 fl1],leg_EXP_IPC,'Location','southeast');
%     leg1 = legend([plt2 fl1],{'$\mathbf{E}[u]$', '$\pm 2\sqrt{\mathbf{V}[u]}$'},'Location','northwest');
%     set(leg1,'Visible',legBool);
%     set(leg1,'Color','none');
%     set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'nut_xByd_compRAS',0,1);
end
%% U_xByD_...

scaling = 2;
N = 2*scaling;

for makePlot = 0 : plotU_xByd-1

plotOffset = [0.05, 0.5, 1,2,3,4,5,6,7,8];  
textOffset = [4.75,3.2,2.2,1.15,0.85,0.28];

for line_num=3:line_num_max
    yByd(:,line_num) = U_xByd(:, 1 + (line_num-1)*yuCol)/D;
    Mean(:,line_num) = scaling*U_xByd(:, xDirIdx + (line_num-1)*yuCol)/Uinf + plotOffset(line_num);
    ub(:,line_num)   = Mean(:,line_num)+N*U_xByd(:, xDirIdx+uCol + (line_num-1)*yuCol)/Uinf;
    lb(:,line_num)   = Mean(:,line_num)-N*U_xByd(:, xDirIdx+uCol + (line_num-1)*yuCol)/Uinf;
%     DET(:,line_num)  = scaling*U_xByd(:, xDirIdx+2*uCol + (line_num-1)*yuCol)/Uinf + plotOffset(line_num);
end

figure(1)
    hold on;
    grid off;

    ylabel("$y/H$"');
    if scaling>1
        xlabel(string(scaling)+"$u/u_{b} + x/H$");
    else
        xlabel("$u/u_{b} + x/H$");
    end
    
    for line_num=3:line_num_max
        
        plt1 = plot(scaling*DNS{line_num}(:,3) + plotOffset(line_num), DNS{line_num}(:,2), ...
                    DNSclr,'MarkerSize',DNSsize,'LineWidth',LW1);
%         plt3 = plot(DET(:,line_num), yByd(:,line_num), 'color', DETclr,'LineWidth',LW1);                
        plt2 = plot(Mean(:,line_num), yByd(:,line_num), meanClr,'color', fill_color,'LineWidth',LW1);
        fl1  = fill([ub(:,line_num)', fliplr(lb(:,line_num)')], [yByd(:,line_num)', fliplr(yByd(:,line_num)')], ...
                  fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
        uistack(fl1,'bottom'); 
        
%         text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    end
    
    pltHill = plot(hillX, hillY, hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltX0   = plot(0*hillX, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltx1   = plot(0*hillX+9, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW, 'color', hillClr);
    pltY3H  = plot(hillX, 0*hillY+85/H/1000, hillLS,'LineWidth', hillLW,'color', hillClr);
    
    axis([0 11 0 3.1]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
% %     yticks([-0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.2]);
%     leg1 = legend([plt1(1) plt1(2) plt1(3) plt3 plt2 fl1],leg_EXP_IPC,'Location','southeast');
%     leg1 = legend([plt2 fl1],{'$\mathbf{E}[u]$', '$\pm 2\sqrt{\mathbf{V}[u]}$'},'Location','northwest');
%     set(leg1,'Visible',legBool);
%     set(leg1,'Color','none');
%     set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'U_xByd_DNS_compRAS',0,1);
end

%% UU_xByD_...
 
scaling = 10;
N = [2,2,2,2,2,2,2,2,2,2]*scaling;

for makePlot = 0 : plotUU_xByd-1

plotOffset = [0.05, 0.5, 1,2,3,4,5,6,7,8]; 
textOffset = plotOffset + 0.05;

for line_num=3:line_num_max
    yByd(:,line_num) = R_xByd(:, 1 + (line_num-1)*yRCol)/D;
    Mean(:,line_num) = scaling*R_xByd(:, xDirIdx + (line_num-1)*yRCol)/Uinf2 + plotOffset(line_num);
    ub(:,line_num)   = Mean(:,line_num)+N(line_num)*R_xByd(:, xDirIdx+RCol + (line_num-1)*yRCol)/Uinf2;
    lb(:,line_num)   = Mean(:,line_num)-N(line_num)*R_xByd(:, xDirIdx+RCol + (line_num-1)*yRCol)/Uinf2;
%     DET(:,line_num)  = R_xByd_DET(:, xDirIdx + (line_num-1)*(RCol+1))/Uinf2 + plotOffset(line_num);    
end

figure(2)
    hold on;
    grid off;

    ylabel("$y/H$"');
    if scaling>1
        xlabel(string(scaling)+"$u'u' + x/H$");
    else
        xlabel("$u'u' + x/H$");
    end
    
    for line_num=3:line_num_max
        
%         for EXP_num=1:EXP_num_max
%             try
%             plt1(EXP_num) = plot(UU_xByd_EXP{EXP_num,line_num}(:,1), UU_xByd_EXP{EXP_num,line_num}(:,2), ...
%                             EXPclr{EXP_num},'MarkerFaceColor',EXPfill{EXP_num}, ...
%                             'MarkerSize',EXPsize,'MarkerEdgeColor',EXPedge{EXP_num});
%             catch
%             end
%         end
        
        plt2 = plot(Mean(:,line_num),yByd(:,line_num), meanClr,'LineWidth',LW0_5);
        fl1  = fill([ub(:,line_num)', fliplr(lb(:,line_num)')], [yByd(:,line_num)', fliplr(yByd(:,line_num)')], ...
                  fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
        uistack(fl1,'bottom'); 
        
%         plt3 = plot(yByd, DET(:,line_num), DETclr,'LineWidth',LW0_5);
% 
%         text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    end
    
    pltHill = plot(hillX, hillY, hillLS,'LineWidth', hillLW);
    pltX0   = plot(0*hillX, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltx1   = plot(0*hillX+9, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltY3H  = plot(hillX, 0*hillY+85/H/1000, hillLS,'LineWidth', hillLW);
    
    axis([0 11 0 3.1]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
%     yticks([-1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0]);
%     leg1 = legend([plt1(1) plt1(2) plt1(3) plt3 plt2 fl1],leg_EXP_IPC,'Location','southeast');
%     set(leg1,'Visible',legBool);
%     set(leg1,'Color','none');
%     set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'UU_xByd');
end

%% VV_xByD_...

scaling = 10;
N = [2,2,2,2,2,2,2,2,2,2]*scaling;

for makePlot = 0 : plotVV_xByd-1

plotOffset = [0.05, 0.5, 1,2,3,4,5,6,7,8]; 
textOffset = plotOffset + 0.05;

for line_num=3:line_num_max
    yByd(:,line_num) = R_xByd(:, 1 + (line_num-1)*yRCol)/D;
    Mean(:,line_num) = scaling*R_xByd(:, 2*xDirIdx+1 + (line_num-1)*yRCol)/Uinf2 + plotOffset(line_num);
    ub(:,line_num)   = Mean(:,line_num)+N(line_num)*R_xByd(:, 2*xDirIdx+1+RCol + (line_num-1)*yRCol)/Uinf2;
    lb(:,line_num)   = Mean(:,line_num)-N(line_num)*R_xByd(:, 2*xDirIdx+1+RCol + (line_num-1)*yRCol)/Uinf2;
%     DET(:,line_num)  = R_xByd_DET(:, xDirIdx + (line_num-1)*(RCol+1))/Uinf2 + plotOffset(line_num);    
end

figure(3)
    hold on;
    grid off;

    ylabel("$y/H$"');
    if scaling>1
        xlabel(string(scaling)+"$v'v' + x/H$");
    else
        xlabel("$v'v' + x/H$");
    end    
    
    for line_num=3:line_num_max
        
%         for EXP_num=1:EXP_num_max
%             try
%             plt1(EXP_num) = plot(UU_xByd_EXP{EXP_num,line_num}(:,1), UU_xByd_EXP{EXP_num,line_num}(:,2), ...
%                             EXPclr{EXP_num},'MarkerFaceColor',EXPfill{EXP_num}, ...
%                             'MarkerSize',EXPsize,'MarkerEdgeColor',EXPedge{EXP_num});
%             catch
%             end
%         end
        
        plt2 = plot(Mean(:,line_num),yByd(:,line_num), meanClr,'LineWidth',LW0_5);
        fl1  = fill([ub(:,line_num)', fliplr(lb(:,line_num)')], [yByd(:,line_num)', fliplr(yByd(:,line_num)')], ...
                  fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
        uistack(fl1,'bottom'); 
        
%         plt3 = plot(yByd, DET(:,line_num), DETclr,'LineWidth',LW0_5);
% 
%         text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    end
    
    pltHill = plot(hillX, hillY, hillLS,'LineWidth', hillLW);
    pltX0   = plot(0*hillX, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltx1   = plot(0*hillX+9, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltY3H  = plot(hillX, 0*hillY+85/H/1000, hillLS,'LineWidth', hillLW);
    
    axis([0 11 0 3.1]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
%     yticks([-1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0]);
%     leg1 = legend([plt1(1) plt1(2) plt1(3) plt3 plt2 fl1],leg_EXP_IPC,'Location','southeast');
%     set(leg1,'Visible',legBool);
%     set(leg1,'Color','none');
%     set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'VV_xByd');
end

%% UV_xByD_...

scaling = 10;
N = [2,2,2,2,2,2,2,2,2,2]*scaling;

for makePlot = 0 : plotUV_xByd-1

plotOffset = [0.05, 0.5, 1,2,3,4,5,6,7,8]; 
textOffset = plotOffset + 0.05;

for line_num=3:line_num_max
    yByd(:,line_num) = R_xByd(:, 1 + (line_num-1)*yRCol)/D;
    Mean(:,line_num) = -scaling*R_xByd(:, xDirIdx+1 + (line_num-1)*yRCol)/Uinf2 + plotOffset(line_num);
    ub(:,line_num)   = Mean(:,line_num)+N(line_num)*R_xByd(:, xDirIdx+1+RCol + (line_num-1)*yRCol)/Uinf2;
    lb(:,line_num)   = Mean(:,line_num)-N(line_num)*R_xByd(:, xDirIdx+1+RCol + (line_num-1)*yRCol)/Uinf2;
%     DET(:,line_num)  = R_xByd_DET(:, xDirIdx + (line_num-1)*(RCol+1))/Uinf2 + plotOffset(line_num);    
end

figure(4)
    hold on;
    grid off;

    ylabel("$y/H$"');
    if scaling>1
        xlabel("-"+string(scaling)+"$u'v' + x/H$");
    else
        xlabel("$-u'v' + x/H$");
    end    
    
    for line_num=3:line_num_max
        
%         for EXP_num=1:EXP_num_max
%             try
%             plt1(EXP_num) = plot(UU_xByd_EXP{EXP_num,line_num}(:,1), UU_xByd_EXP{EXP_num,line_num}(:,2), ...
%                             EXPclr{EXP_num},'MarkerFaceColor',EXPfill{EXP_num}, ...
%                             'MarkerSize',EXPsize,'MarkerEdgeColor',EXPedge{EXP_num});
%             catch
%             end
%         end
        
        plt2 = plot(Mean(:,line_num),yByd(:,line_num), meanClr,'LineWidth',LW0_5);
        fl1  = fill([ub(:,line_num)', fliplr(lb(:,line_num)')], [yByd(:,line_num)', fliplr(yByd(:,line_num)')], ...
                  fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
        uistack(fl1,'bottom'); 
        
%         plt3 = plot(yByd, DET(:,line_num), DETclr,'LineWidth',LW0_5);
% 
%         text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    end
    
    pltHill = plot(hillX, hillY, hillLS,'LineWidth', hillLW);
    pltX0   = plot(0*hillX, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltx1   = plot(0*hillX+9, linspace(1,85/H/1000,Nx), hillLS,'LineWidth', hillLW);
    pltY3H  = plot(hillX, 0*hillY+85/H/1000, hillLS,'LineWidth', hillLW);
    
%     axis([-3 3 -1.4 0]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
%     yticks([-1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0]);
%     leg1 = legend([plt1(1) plt1(2) plt1(3) plt3 plt2 fl1],leg_EXP_IPC,'Location','southeast');
%     set(leg1,'Visible',legBool);
%     set(leg1,'Color','none');
%     set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'UV_xByd');
end

%% tauW_xByD_...

if(is3D)
    firtXVal = tauW0(1,1);
    nextXVal = firtXVal;
    NzCells = 0;
    while(nextXVal==firtXVal)
        nextXVal = tauW0(NzCells+1,1);
        NzCells = NzCells + 1;
    end
    NzCells = NzCells -1

    firtZVal = tauW0(1,3);
    nextZVal = firtZVal+rand;
    NxCells = 1;
    tmpxByd = [];
    tmpxByd(1) = tauW0(1,1);
    for i=2:length(tauW0(:,1))
        nextZVal = tauW0(i,3);
        if(nextZVal==firtZVal)
            NxCells = NxCells + 1;
            tmpxByd(NxCells) = tauW0(i,1);
        end    
    end
    NxCells

    tmpTauW0Avg = zeros(NxCells,4);
    tmpTauW0Avg(:,1) = tmpxByd;
    tmpTauWSigmaAvg = zeros(NxCells,4);
    tmpTauWSigmaAvg(:,1) = tmpxByd;
    for i=0:NxCells-1
        tmpTauW0Avg(i+1,4) = sum(tauW0((i*NzCells +1) : ((i+1)*NzCells), 4)) / NzCells;
        tmpTauWSigmaAvg(i+1,4) = sum(tauWSigma((i*NzCells +1) : ((i+1)*NzCells), 4)) / NzCells;
    end
    tauW0 = tmpTauW0Avg;
    tauWSigma = tmpTauWSigmaAvg;
end

scaling = 1;
N = 2*scaling;

for makePlot = 0 : plotTauW -1
xByd = tauW0(:,1)/D;
Mean = -scaling*tauW0(:, 4)/Uinf;
ub   = Mean+N*tauWSigma(:, 4)/Uinf;
lb   = Mean-N*tauWSigma(:, 4)/Uinf;
% DET  = -scaling*tauWDET(:, 4)/Uinf;

figure(5)
    hold on;
    grid off;
    
    xlabel("$x/H$");
    if scaling>1
        ylabel(string(scaling)+"$\tau_{w}/u_{b}$");
    else
        ylabel("$\tau_{w}/u_{b}$");
    end
        
    plt0 = plot(DNStauW(:,1), DNStauW(:,2)*0, '--k');
    plt1 = plot(DNStauW(:,1), DNStauW(:,2), '-k','MarkerSize',DNSsize,'LineWidth',LW1);
%     plt3 = plot(xByd, DET, 'color', DETclr,'LineWidth',LW1);
    plt2 = plot(xByd, Mean, meanClr,'color', fill_color,'LineWidth',LW1);
    fl1  = fill([xByd', fliplr(xByd')], [ub', fliplr(lb')], ...
              fill_color, 'FaceAlpha', FaceAlpha,'EdgeColor', EdgeColor);
    uistack(fl1,'bottom'); 

%     plt3 = plot(yByd, DET(:,line_num), DETclr,'LineWidth',LW0_5);

%     text(2, textOffset(line_num),['$x/D =$ ' sample_xByd{line_num}],'FontSize',txtFSize);
    
    fakePlt1 = plot(100,100,'color',rgb('blue'));
    fakePlt2 = plot(100,100,'color',[0.6350, 0.0780, 0.1840]);
    fakePlt3 = plot(100,100,'color',rgb('orange')); 

    axis([0 11 -0.02 0.04]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
    leg1 = legend([plt1 fakePlt1 fakePlt2 fakePlt3],...
        {"DNS","$k-\omega$","$k-\omega$ SST","Launder-Sharma $k-\epsilon$"}...
        ,'Location','northwest','Orientation','horizontal');
    set(leg1,'Visible',legBool);
    set(leg1,'Color','none');
    set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'tauW_xByd_DNS_compRAS','0','2');
    %uqPlotsPrint(uqPlotsDir,'tauW_xByd','0','2');
    
figure(6)
    hold on;
    grid off;
    
    xlabel("$x_{reattach}/H$");
    
    DNS_xReattch = 5.5;
    
    %kOm
    IPC_xReattch = 3.8;
    bound1 = 2.8;
    bound2 = 7.8;
    
%     %kOmSST
%     IPC_xReattch = 5.8;
%     bound1 = 4.1;
%     bound2 = 7.8;

%     %LaSh
%     IPC_xReattch = 3.5;
%     bound1 = 2.3;
%     bound2 = 7;
    
    c = tauWSigma(:, 4)/max(tauWSigma(:, 4));
    c = c(xByd>=bound1 & xByd<=bound2)';
    IPC_uncBound = linspace(bound1,bound2, length(c));
    z = zeros(size(c));
    y = 1.5+0.15;%1.5;1.0;0.5
    
    fl1  = surface([IPC_uncBound;IPC_uncBound], [c*0+y;c*0+y], [z;z],...
        [c;c], 'FaceColor','none','EdgeColor','interp',...
        'EdgeAlpha', 0.3,'LineWidth',LW1*10);
    colormap winter;
    
    plt0 = plot(DNS_xReattch, y, 'sk','MarkerSize',DNSsize,'LineWidth',LW1);
%     plt1 = plot(DET_xReattch, y, '^r','MarkerSize',DNSsize,'LineWidth',LW1);
    plt2 = plot(IPC_xReattch, y, 'o','color',fill_color,'MarkerSize',DNSsize,'LineWidth',LW1);

    fakePlt1 = plot(100,100,'o','color',rgb('blue'));
    fakePlt2 = plot(100,100,'o','color',[0.6350, 0.0780, 0.1840]);
    fakePlt3 = plot(100,100,'o','color',rgb('orange')); 
    
    axis([0 11 0 6]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11]);
    yticks([]);
    leg1 = legend([plt0 fakePlt1 fakePlt2 fakePlt3],...
        {"DNS","$k-\omega$","$k-\omega$ SST","Launder-Sharma $k-\epsilon$"}...
        ,'Location','southeast','Orientation','vertical');
    set(leg1,'Visible',legBool);
    set(leg1,'Color','none');
    set(leg1,'EdgeColor','none');
    hold off;

    uqPlotsPrint(uqPlotsDir,'tauW_xByd_DNS_reattach_compRAS','0','2');
end



%% Save mat file

% save([uqPlotsDir '/' caseName '.mat'])


end
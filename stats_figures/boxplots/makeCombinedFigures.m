clear; close all; clc

%% Load data from both experiments

scriptPath = fileparts(matlab.desktop.editor.getActiveFilename);
baseDir = scriptPath;

dirs = {'251027_SMAD1_BMPligands_live','251111_SMAD1_BMP6_ActA'};
ndir = length(dirs);

% X in each signalData.mat is normalized: median across cells, then
% baseline-subtracted (mean of tvec<=0 per condition), then rescaled so
% that mincond->0 and maxcond->1 using per-experiment reference conditions.
minconds = [13, 1];   % ctrl condition index per experiment
maxconds = [3,  6];   % saturating BMP condition index per experiment

signalDatas  = cell(ndir,1);
Xs           = cell(ndir,1);
Xstds        = cell(ndir,1);
Xsems        = cell(ndir,1);
Xwellstds    = cell(ndir,1);  % std across positions (wells), for error bands
Xwellmeans   = cell(ndir,1);  % mean across positions (for sanity check vs X)
Xposs        = cell(ndir,1);  % full per-position normalized data (ntime x ncond x ppc)
tvecs        = cell(ndir,1);
metas        = cell(ndir,1);

for di = 1:ndir
    load(fullfile(baseDir,dirs{di},'meta.mat'),'meta')
    metas{di} = meta;
    load(fullfile(baseDir,dirs{di},'signalData.mat'))
    signalDatas{di} = signalData;
    tvecs{di} = tvec;

    % baseline-subtract then normalize: ctrl->0, mean steady-state of maxcond->1
    % (same window as ct/ct2: t = 5–12 hrs)
    Xmed = cellfun(@(x) median(x,'omitnan'), signalData);
    Xmed = Xmed - mean(Xmed(tvec <= 0,:), 1);
    minval = mean(Xmed(:, minconds(di)));
    maxval = mean(Xmed(tvec > 0, maxconds(di)), 'all');
    Xs{di} = (Xmed - minval) / (maxval - minval);
    Xstd_raw = cellfun(@(x) std(x, 0, 'omitnan'), signalData);
    Ncells   = cellfun(@(x) sum(~isnan(x)), signalData);
    Xstds{di} = Xstd_raw / (maxval - minval);
    Xsems{di} = (Xstd_raw ./ sqrt(Ncells)) / (maxval - minval);

    % reconstruct per-position (well-level) medians from positions.mat;
    % Sall{ti,cidx,cpi} = N:C ratios for position cpi at time ti, condition cidx
    load(fullfile(baseDir,dirs{di},'positions.mat'),'positions')
    chan = 1;
    ppc  = unique(meta.posPerCondition);
    ntime = length(tvec);
    ncond = size(Xmed, 2);
    Sall = cell(ntime, ncond, ppc);
    for ti = 1:ntime
        for cidx = 1:ncond
            for cpi = 1:ppc
                pidx = ppc*(cidx-1) + cpi;
                nuc = positions(pidx).cellData(ti).nucLevel(:, chan+1);
                cyt = positions(pidx).cellData(ti).cytLevel(:, chan+1);
                nuccyt = nuc ./ cyt;
                if numel(nuccyt) > 10
                    Sall{ti,cidx,cpi} = nuccyt;
                end
            end
        end
    end
    % per-position median, then apply the same baseline + amplitude
    % normalization used for X so units are directly comparable
    Xpos = cellfun(@(x) median(x,'omitnan'), Sall);  % ntime x ncond x ppc
    Xpos = Xpos - mean(Xpos(tvec <= 0,:,:), 1);
    Xpos = (Xpos - minval) / (maxval - minval);
    Xwellstds{di}  = std(Xpos, 0, 3);   % std across positions
    Xwellmeans{di} = mean(Xpos, 3);     % mean across positions
    Xposs{di}      = Xpos;
end

%% Load crosstalk experiment (250529_SMAD1_SMAD2_BMP9_Act_crosstalk)

ctDir = fullfile(baseDir, '250529_SMAD1_SMAD2_BMP9_Act_crosstalk');
load(fullfile(ctDir, 'meta.mat'), 'meta')
meta_ct = meta;

% tvec from analyze_514_561.m: timeInterval = '12.5min', treatmentTime = 4
treatmentTime_ct = 4;
tscale_ct        = 12.5/60;   % frames -> hours
ntime_ct         = meta_ct.nTime;
tvec_ct          = (1-treatmentTime_ct : ntime_ct-treatmentTime_ct) * tscale_ct;

load(fullfile(ctDir, 'positions.mat'), 'positions')
ncond_ct = meta_ct.nWells;
ppc_ct   = unique(meta_ct.posPerCondition);
npos_ct  = ncond_ct * ppc_ct;

% channel setup from analyze_514_561.m:
%   chan=0 SMAD2: label=2, maxcond=5 (BMP4+A100), bg-subtracted ratio
%   chan=1 SMAD1: label=1, maxcond=2 (BMP4),      plain ratio
channames_ct = {'SMAD2','SMAD1'};
labels_ct    = [2 1];
maxconds_ct  = [5 2];
mincond_ct   = 1;   % ctrl for both channels
X_ct         = cell(2,1);
Xwellstd_ct  = cell(2,1);
Xposs_ct     = cell(2,1);

% constant background per channel (median across positions, then mean over time)
bg_ct = zeros(1,2);
for chan_ct = 0:1
    all_bg = zeros(ntime_ct, npos_ct);
    for pidx = 1:npos_ct
        all_bg(:,pidx) = cellfun(@(x) x(chan_ct+1), {positions(pidx).cellData.background}');
    end
    bg_ct(chan_ct+1) = mean(median(all_bg, 2));
end

for chani_ct = 1:2
    chan_ct    = chani_ct - 1;
    label_ct   = labels_ct(chani_ct);
    maxcond_ct = maxconds_ct(chani_ct);
    bg         = bg_ct(chani_ct);

    Sall_ct = cell(ntime_ct, ncond_ct, ppc_ct);
    for ti = 1:ntime_ct
        for cidx = 1:ncond_ct
            for cpi = 1:ppc_ct
                pidx = ppc_ct*(cidx-1) + cpi;
                lbl  = positions(pidx).cellData(ti).labels;
                nuc  = positions(pidx).cellData(ti).nucLevel(lbl == label_ct, chan_ct+1);
                cyt  = positions(pidx).cellData(ti).cytLevel(lbl == label_ct, chan_ct+1);
                if chan_ct == 0
                    nuccyt = (nuc - bg) ./ (cyt - bg);
                else
                    nuccyt = nuc ./ cyt;
                end
                if numel(nuccyt) > 10
                    Sall_ct{ti,cidx,cpi} = nuccyt;
                end
            end
        end
    end

    Xpos_ct  = cellfun(@(x) median(x,'omitnan'), Sall_ct);
    Xpos_ct  = Xpos_ct - mean(Xpos_ct(tvec_ct <= 0, :, :), 1);
    Xmean_ct = mean(Xpos_ct, 3);
    minval_ct = mean(Xmean_ct(:, mincond_ct), 'omitnan');
    maxval_ct = mean(Xmean_ct(tvec_ct > 0, maxcond_ct), 'omitnan');
    Xpos_ct   = (Xpos_ct - minval_ct) / (maxval_ct - minval_ct);
    X_ct{chani_ct}        = mean(Xpos_ct, 3);
    Xwellstd_ct{chani_ct} = std(Xpos_ct, 0, 3);
    Xposs_ct{chani_ct}    = Xpos_ct;
end

%% Load extra-ligands crosstalk experiment (250225_SMAD1_SMAD2_crosstalk_extraligands)
% Conditions: BMP2(1),BMP6(2),BMP7(3),BMP7+ActA(4),BMP6+ActA(5),BMP6+BMP4+ActA(6),
%             BMP7+BMP4+ActA(7),BMP7+BMP4(8),BMP6+BMP4(9),BMP4(10),BMP4+ActA(11),
%             ActA(12),ctrl(13),BMP2+BMP4(14),BMP2+BMP4+ActA(15),BMP2+ActA(16)

ct2Dir = fullfile(baseDir, '250225_SMAD1_SMAD2_crosstalk_extraligands');
load(fullfile(ct2Dir, 'meta.mat'), 'meta')
meta_ct2 = meta;

treatmentTime_ct2 = 4;
tscale_ct2        = 12.5/60;
ntime_ct2         = meta_ct2.nTime;
tvec_ct2          = (1-treatmentTime_ct2 : ntime_ct2-treatmentTime_ct2) * tscale_ct2;

load(fullfile(ct2Dir, 'positions.mat'), 'positions')
ncond_ct2 = meta_ct2.nWells;
ppc_ct2   = unique(meta_ct2.posPerCondition);
npos_ct2  = ncond_ct2 * ppc_ct2;

channames_ct2 = {'SMAD2','SMAD1'};
labels_ct2    = [2 1];
maxconds_ct2  = [12 10];   % SMAD2: ActA(12), SMAD1: BMP4(10)
mincond_ct2   = 13;        % ctrl
X_ct2         = cell(2,1);
Xwellstd_ct2  = cell(2,1);
Xposs_ct2     = cell(2,1);

bg_ct2 = zeros(1,2);
for chan_ct2_bg = 0:1
    all_bg = zeros(ntime_ct2, npos_ct2);
    for pidx = 1:npos_ct2
        all_bg(:,pidx) = cellfun(@(x) x(chan_ct2_bg+1), {positions(pidx).cellData.background}');
    end
    bg_ct2(chan_ct2_bg+1) = mean(median(all_bg, 2));
end

for chani_ct2 = 1:2
    chan_ct2    = chani_ct2 - 1;
    label_ct2   = labels_ct2(chani_ct2);
    maxcond_ct2 = maxconds_ct2(chani_ct2);
    bg          = bg_ct2(chani_ct2);

    Sall_ct2 = cell(ntime_ct2, ncond_ct2, ppc_ct2);
    for ti = 1:ntime_ct2
        for cidx = 1:ncond_ct2
            for cpi = 1:ppc_ct2
                pidx = ppc_ct2*(cidx-1) + cpi;
                lbl  = positions(pidx).cellData(ti).labels;
                nuc  = positions(pidx).cellData(ti).nucLevel(lbl == label_ct2, chan_ct2+1);
                cyt  = positions(pidx).cellData(ti).cytLevel(lbl == label_ct2, chan_ct2+1);
                if chan_ct2 == 0
                    nuccyt = (nuc - bg) ./ (cyt - bg);
                else
                    nuccyt = nuc ./ cyt;
                end
                if numel(nuccyt) > 10
                    Sall_ct2{ti,cidx,cpi} = nuccyt;
                end
            end
        end
    end

    Xpos_ct2   = cellfun(@(x) median(x,'omitnan'), Sall_ct2);
    Xpos_ct2   = Xpos_ct2 - mean(Xpos_ct2(tvec_ct2 <= 0, :, :), 1);
    Xmean_ct2  = mean(Xpos_ct2, 3);
    minval_ct2 = mean(Xmean_ct2(:, mincond_ct2), 'omitnan');
    maxval_ct2 = mean(Xmean_ct2(tvec_ct2 > 0, maxcond_ct2), 'omitnan');
    Xpos_ct2   = (Xpos_ct2 - minval_ct2) / (maxval_ct2 - minval_ct2);
    X_ct2{chani_ct2}        = mean(Xpos_ct2, 3);
    Xwellstd_ct2{chani_ct2} = std(Xpos_ct2, 0, 3);
    Xposs_ct2{chani_ct2}    = Xpos_ct2;
end

%% Load TGFβ ligands experiment (250910_SMAD1_TGFbligands_live)
% Conditions: BMP4(1), BMP4+ActA(2), BMP4+myostatin(3), BMP4+GDF11(4),
%             BMP4+TGFβ1(5), BMP4+TGFβ2(6), BMP4+TGFβ3(7),
%             ctrl(8), ActA(9), myostatin(10), GDF11(11), TGFβ1(12), TGFβ2(13), TGFβ3(14)

ct3Dir = fullfile(baseDir, '250910_SMAD1_TGFbligands_live');
load(fullfile(ct3Dir, 'meta.mat'), 'meta')
meta_ct3 = meta;

treatmentTime_ct3 = 3;
tscale_ct3        = 12/60;   % frames -> hours
ntime_ct3         = meta_ct3.nTime;
tvec_ct3          = (1-treatmentTime_ct3 : ntime_ct3-treatmentTime_ct3) * tscale_ct3;

load(fullfile(ct3Dir, 'positions.mat'), 'positions')
ncond_ct3 = meta_ct3.nWells;
ppc_ct3   = unique(meta_ct3.posPerCondition);
chan_ct3  = 1;   % SMAD1 only, channel index for nucLevel/cytLevel (column 2)
mincond_ct3 = 8;   % ctrl
maxcond_ct3 = 1;   % BMP4

Sall_ct3 = cell(ntime_ct3, ncond_ct3, ppc_ct3);
for ti = 1:ntime_ct3
    for cidx = 1:ncond_ct3
        for cpi = 1:ppc_ct3
            pidx = ppc_ct3*(cidx-1) + cpi;
            nuc = positions(pidx).cellData(ti).nucLevel(:, chan_ct3+1);
            cyt = positions(pidx).cellData(ti).cytLevel(:, chan_ct3+1);
            nuccyt = nuc ./ cyt;
            if numel(nuccyt) > 10
                Sall_ct3{ti,cidx,cpi} = nuccyt;
            end
        end
    end
end

Xpos_ct3   = cellfun(@(x) median(x,'omitnan'), Sall_ct3);
Xpos_ct3   = Xpos_ct3 - mean(Xpos_ct3(tvec_ct3 <= 0, :, :), 1);
Xmean_ct3  = mean(Xpos_ct3, 3);
minval_ct3 = mean(Xmean_ct3(:, mincond_ct3), 'omitnan');
maxval_ct3 = mean(Xmean_ct3(tvec_ct3 > 0, maxcond_ct3), 'omitnan');
Xpos_ct3   = (Xpos_ct3 - minval_ct3) / (maxval_ct3 - minval_ct3);
X_ct3        = mean(Xpos_ct3, 3);
Xwellstd_ct3 = std(Xpos_ct3, 0, 3);
Xposs_ct3    = Xpos_ct3;

%% Time series plots — one figure per ligand group

close all
savedir = fullfile(baseDir,'figures_combined');

fs = 26; lfs = 18; %font size %legend font size
lw = 3; %line width
wh = [560 560]; figpos = figurePosition(wh);

% each entry of allconds is a set of condition indices to plot together;
% dirids maps each condition to the experiment it came from (1 or 2)
allconds = {[2 3 7 8 1], [1 2 3 4 13], 9:13};
dirids = {[2 2 1 1 2], [1 1 1 1 1], [1 1 1 1 1]};
titlestrs = {'BMP6/7','BMP2/4','BMP9/10'};
savelabels = strrep(titlestrs,'/','_');
savelabels = strrep(savelabels,' ','_');
lgdtitles = {'','','','',''};

% y-axis limits shared across all time series plots (SMAD2=row 1, SMAD1=row 2)
ylims_smad = [-0.1 5;   % SMAD2
              -0.1 1.5];  % SMAD1

% color by ligand identity; conditions containing '+ActA' are dashed
colors = lines(7);
ligands = {'BMP4','BMP2','BMP6','BMP7','BMP9','BMP10'};
plotErrBand = true;        % shaded error band around time series
errType = 'wellstd';       % 'std' = std across cells, 'sem' = SEM across cells, 'wellstd' = std across positions

for ii = 1:length(allconds)
    conds = allconds{ii};
    titlestr = titlestrs{ii};
    savelabel = savelabels{ii};

    figure('Position',figpos); hold on
    % colors = turbo(length(conds)+1); colors = colors(end:-1:1,:);
    % colors = lines(length(conds));
    % I = find(strcmp(meta.conditions(conds),'ctrl'));
    % if ~isempty(I)
    %     colors(I,:) = [0 0 0];
    % end
    legstr = {};
    hasActA = false;
    for cidx = 1:length(conds)
        di = dirids{ii}(cidx);
        condlabel = char(metas{di}.conditions{conds(cidx)});

        % assign color by ligand name, with special cases for non-BMP ligands
        I = find(cellfun(@(x) contains(condlabel,x), ligands));
        if ~isempty(I)
            color = colors(I,:);
        else
            if strcmp(condlabel,'ActA')
                color = 0.8*[1 0 0];
            elseif strcmp(condlabel,'ctrl')
                color = [0 0 0];
            elseif contains(condlabel,'ActB')
                color = 0.8*[0 1 0];
            end
        end

        if contains(condlabel,'+ActA')
            ls = '--';
            hvis = 'off';   % excluded from legend; represented by dummy entry
            hasActA = true;
        else
            ls = '-';
            hvis = 'on';
            legstr{end+1} = condlabel;
        end

        v = Xs{di}(:,conds(cidx));
        % plot(tvec,v,ls,'LineWidth',lw,'Color',colors(cidx,:))
        plot(tvecs{di},v,ls,'LineWidth',lw,'Color',color,'HandleVisibility',hvis)
        if plotErrBand
            if strcmp(errType,'sem')
                s = Xsems{di}(:,conds(cidx));
            elseif strcmp(errType,'wellstd')
                s = Xwellstds{di}(:,conds(cidx));
            else
                s = Xstds{di}(:,conds(cidx));
            end
            tv = tvecs{di}(:);
            fill([tv; flipud(tv)], [v(:)+s(:); flipud(v(:)-s(:))], color, ...
                'FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off')
        end
    end

    % single dummy entry for all +ActA conditions
    if hasActA
        plot(nan, nan, '--','Color',[0.5 0.5 0.5], 'LineWidth', lw)
        legstr{end+1} = '+ActA';
    end

    hold off
    cleanSubplot(fs);% axis square
    xlim([-0.4,12])
    % xlim([min(tvec),max(tvec)])
    ylim(ylims_smad(2,:))
    xlabel('time (hrs)'); ylabel('SMAD1 (N:C)')

    if ~isempty(lgdtitles{ii})
        legstr = strrep(legstr,[lgdtitles{ii},','],'');
    end
    lgd = legend(legstr,'FontSize',lfs,'Interpreter','none','Location','NorthEast');
    lgd.NumColumns = 2 ;
    lgd.ItemTokenSize(1) = 32;  % wider line swatch so dashes are visible
    lgd.Position(2) = lgd.Position(2) + 0.05;
    lgd.LineWidth = 0.5;


    channame = 'SMAD1';% meta.channelLabel{chan+1};
    axis square
    savename = [channame,'_',savelabel,'.png'];
    savefigure(fullfile(savedir,savename))
    %th = title(titlestr); th.Units = 'normalized'; th.Position(2) = th.Position(2) - 0.02;
    set(lgd,'Visible','off')
    savefigure(fullfile(savedir,strrep(savename,'.png','_noleg.png')))
    close
end

%% Time series plots — crosstalk experiment

% Set 1: ctrl, BMP4, BMP9, BMP4+BMP9, and each +ActA100
% Set 2: BMP9 vs BMP9+GDF11
% One figure per channel (SMAD2 and SMAD1)

ct_condsets  = {[1 2 9 16 5 12 17], [9 15], [2 8], [1 2 5 8], [1 9 12 15]};
ct_titles    = {'BMP4_BMP9_ActA',    'BMP9_GDF11', 'BMP4_GDF11', 'BMP4_ActA_GDF11', 'BMP9_ActA_GDF11'};
color_bmp4bmp9 = [0.5 0 0.8];   % purple for the combination

for ci_set = 1:length(ct_condsets)
    conds_ct    = ct_condsets{ci_set};
    titlestr_ct = ct_titles{ci_set};

    for chan_ct = 1:2   % 1=SMAD2, 2=SMAD1
        figure('Position',figpos); hold on
        legstr_ct = {};
        hasActA_ct = false;  hasGDF11_ct = false;

        for cidx = 1:length(conds_ct)
            ci           = conds_ct(cidx);
            condlabel_ct = char(meta_ct.conditions{ci});

            % color by ligand identity
            if strcmp(condlabel_ct,'ctrl')
                color_ct = [0 0 0];
            elseif contains(condlabel_ct,'BMP4') && contains(condlabel_ct,'BMP9')
                color_ct = color_bmp4bmp9;
            else
                I = find(cellfun(@(x) contains(condlabel_ct,x), ligands));
                if ~isempty(I), color_ct = colors(I(1),:);
                else,           color_ct = [0.5 0.5 0.5];
                end
            end

            if contains(condlabel_ct,'+A')
                ls = '--';  hvis = 'off';  hasActA_ct  = true;
            elseif contains(condlabel_ct,'+G')
                ls = ':';   hvis = 'off';  hasGDF11_ct = true;
            else
                ls = '-';   hvis = 'on';
                legstr_ct{end+1} = condlabel_ct;
            end

            v  = X_ct{chan_ct}(:, ci);
            s  = Xwellstd_ct{chan_ct}(:, ci);
            tv = tvec_ct(:);
            plot(tv, v, ls, 'LineWidth', lw, 'Color', color_ct, 'HandleVisibility', hvis)
            fill([tv; flipud(tv)], [v+s; flipud(v-s)], color_ct, ...
                'FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off')
        end

        if hasActA_ct
            plot(nan, nan, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', lw)
            legstr_ct{end+1} = '+ActA';
        end
        if hasGDF11_ct
            plot(nan, nan, ':', 'Color', [0.5 0.5 0.5], 'LineWidth', lw)
            legstr_ct{end+1} = '+GDF11';
        end

        hold off
        cleanSubplot(fs);
        xlim([-0.4 12])
        ylim(ylims_smad(chan_ct,:))
        xlabel('time (hrs)')
        ylabel([channames_ct{chan_ct}, ' (N:C)'])
        lgd_ct = legend(legstr_ct,'FontSize',lfs,'Interpreter','none','Location','NorthEast');
        lgd_ct.NumColumns = 1;
        lgd_ct.ItemTokenSize(1) = 32;
        lgd_ct.LineWidth = 0.5;

        axis square
        savename_ct = [channames_ct{chan_ct}, '_', titlestr_ct, '.png'];
        savefigure(fullfile(savedir, savename_ct))
        set(lgd_ct,'Visible','off')
        savefigure(fullfile(savedir, strrep(savename_ct,'.png','_noleg.png')))
        close
    end
end

%% Time series plots — ct2 experiment (250225_SMAD1_SMAD2_crosstalk_extraligands)
% BMP2, BMP4, BMP2+BMP4 and their +ActA versions; one figure per channel

% ctrl(13), BMP4(10), BMP2(1), BMP2+BMP4(14), BMP4+ActA(11), BMP2+ActA(16), BMP2+BMP4+ActA(15)
ct2_condsets  = {[13 10 1 14 11 16 15]};
ct2_titles    = {'BMP2_BMP4_ActA'};
color_bmp2bmp4 = (colors(2,:) + colors(1,:)) / 2;   % mix of BMP2 and BMP4 colors

for ci_set = 1:length(ct2_condsets)
    conds_ct2    = ct2_condsets{ci_set};
    titlestr_ct2 = ct2_titles{ci_set};

    for chan_ct2_plot = 1:2   % 1=SMAD2, 2=SMAD1
        figure('Position',figpos); hold on
        legstr_ct2 = {};
        hasActA_ct2 = false;

        for cidx = 1:length(conds_ct2)
            ci             = conds_ct2(cidx);
            condlabel_ct2  = char(meta_ct2.conditions{ci});

            if strcmp(condlabel_ct2,'ctrl')
                color_ct2 = [0 0 0];
            elseif contains(condlabel_ct2,'BMP2') && contains(condlabel_ct2,'BMP4')
                color_ct2 = color_bmp2bmp4;
            else
                I = find(cellfun(@(x) contains(condlabel_ct2,x), ligands));
                if ~isempty(I), color_ct2 = colors(I(1),:);
                else,           color_ct2 = [0.5 0.5 0.5];
                end
            end

            if contains(condlabel_ct2,'+A')
                ls = '--';  hvis = 'off';  hasActA_ct2 = true;
            else
                ls = '-';   hvis = 'on';
                legstr_ct2{end+1} = condlabel_ct2;
            end

            v  = X_ct2{chan_ct2_plot}(:, ci);
            s  = Xwellstd_ct2{chan_ct2_plot}(:, ci);
            tv = tvec_ct2(:);
            plot(tv, v, ls, 'LineWidth', lw, 'Color', color_ct2, 'HandleVisibility', hvis)
            fill([tv; flipud(tv)], [v+s; flipud(v-s)], color_ct2, ...
                'FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off')
        end

        if hasActA_ct2
            plot(nan, nan, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', lw)
            legstr_ct2{end+1} = '+ActA';
        end

        hold off
        cleanSubplot(fs);
        xlim([-0.4 12])
        ylim(ylims_smad(chan_ct2_plot,:))
        xlabel('time (hrs)')
        ylabel([channames_ct2{chan_ct2_plot}, ' (N:C)'])
        lgd_ct2 = legend(legstr_ct2,'FontSize',lfs,'Interpreter','none','Location','NorthEast');
        lgd_ct2.NumColumns = 1;
        lgd_ct2.ItemTokenSize(1) = 32;
        lgd_ct2.LineWidth = 0.5;

        axis square
        savename_ct2 = [channames_ct2{chan_ct2_plot}, '_', titlestr_ct2, '.png'];
        savefigure(fullfile(savedir, savename_ct2))
        set(lgd_ct2,'Visible','off')
        savefigure(fullfile(savedir, strrep(savename_ct2,'.png','_noleg.png')))
        close
    end
end

%% Define analysis parameters

steadyThresh = 4;   % hours after which signal is approximately at steady state
integralTmin = 0;   % start of integration window (hrs, post-treatment)
integralTmax = 12;  % end of integration window (hrs)

    %% Combined conditions — build condition lists and per-condition statistics

% collect all unique (di, condidx) pairs across groups, preserving order,
% excluding ctrl (minconds)
all_di   = cell2mat(dirids);
all_cidx = cell2mat(allconds);
[~, ia]  = unique([all_di; all_cidx]', 'rows', 'stable');
all_di   = all_di(ia);
all_cidx = all_cidx(ia);
isctrl   = arrayfun(@(di,ci) ci == minconds(di), all_di, all_cidx);
all_di   = all_di(~isctrl);
all_cidx = all_cidx(~isctrl);
nconds_all = length(all_cidx);

yval_ss  = zeros(1,nconds_all);
yerr_ss  = zeros(1,nconds_all);
yval_int = zeros(1,nconds_all);
yerr_int = zeros(1,nconds_all);
barcolors_all = zeros(nconds_all,3);
legstr_all    = cell(1,nconds_all);

for cidx = 1:nconds_all
    di       = all_di(cidx);
    condidx  = all_cidx(cidx);
    condlabel = char(metas{di}.conditions{condidx});
    legstr_all{cidx} = condlabel;
    I = find(cellfun(@(x) contains(condlabel,x), ligands));
    if ~isempty(I)
        color = colors(I,:);
    else
        if strcmp(condlabel,'ActA'),        color = 0.8*[1 0 0];
        elseif strcmp(condlabel,'ctrl'),    color = [0 0 0];
        elseif contains(condlabel,'ActB'), color = 0.8*[0 1 0];
        end
    end
    barcolors_all(cidx,:) = color;

    tv      = tvecs{di};
    v       = Xs{di}(:,condidx);
    s       = Xwellstds{di}(:,condidx);
    tsteady = tv >= steadyThresh;
    yval_ss(cidx)  = mean(v(tsteady));
    yerr_ss(cidx)  = mean(s(tsteady));

    tmask = tv >= integralTmin & tv <= integralTmax;
    yval_int(cidx) = trapz(tv(tmask), v(tmask));
    Xpos_cond      = squeeze(Xposs{di}(tmask, condidx, :));
    yerr_int(cidx) = std(trapz(tv(tmask), Xpos_cond, 1));
end

%% Ratio — compute per-position (BMP+ActA)/BMP ratios for box plots and ANOVA
% ratio computed per position, then mean and std taken across positions

% find all +ActA conditions and pair with their base BMP
ratio_labels = {};
ratio_colors = zeros(0,3);
ratio_exps   = [];   % experiment index per ratio condition (1=exp1, 2=exp2, 3=crosstalk)
ratio_ss  = []; ratio_ss_err  = [];
ratio_int = []; ratio_int_err = [];
ratio_ss_perpos  = {};   % per-position ratios for ANOVA
ratio_int_perpos = {};

for cidx = 1:nconds_all
    condlabel = legstr_all{cidx};
    if ~contains(condlabel, '+ActA'), continue; end

    base_label = strrep(condlabel, '+ActA', '');
    di         = all_di(cidx);
    base_idx   = find(strcmp(legstr_all, base_label) & (all_di == di));
    if isempty(base_idx), continue; end

    ratio_labels{end+1}    = condlabel;
    ratio_colors(end+1,:)  = barcolors_all(cidx,:);
    ratio_exps(end+1)      = di;

    di      = all_di(cidx);
    condidx = all_cidx(cidx);
    base_condidx = all_cidx(base_idx);
    tv      = tvecs{di};

    % per-position steady-state mean, then ratio across positions
    tsteady = tv >= steadyThresh;
    ss_A = squeeze(mean(Xposs{di}(tsteady, condidx,      :), 1));
    ss_B = squeeze(mean(Xposs{di}(tsteady, base_condidx, :), 1));
    r_ss = ss_A ./ ss_B;
    ratio_ss(end+1)          = mean(r_ss);
    ratio_ss_err(end+1)      = std(r_ss);
    ratio_ss_perpos{end+1}   = r_ss(:);

    % per-position integral, then ratio across positions
    tmask = tv >= integralTmin & tv <= integralTmax;
    int_A = trapz(tv(tmask), squeeze(Xposs{di}(tmask, condidx,      :)), 1);
    int_B = trapz(tv(tmask), squeeze(Xposs{di}(tmask, base_condidx, :)), 1);
    r_int = int_A ./ int_B;
    ratio_int(end+1)         = mean(r_int);
    ratio_int_err(end+1)     = std(r_int);
    ratio_int_perpos{end+1}  = r_int(:);
end

% append ratios from crosstalk experiment: [+ActA cond, BMP-only cond]
ct_ratio_pairs  = {[5 2], [12 9], [17 16]};
ct_ratio_names  = {'BMP4+ActA', 'BMP9+ActA', 'BMP4+BMP9+ActA'};
tmask_ct_int    = tvec_ct >= integralTmin & tvec_ct <= integralTmax;
tsteady_ct      = tvec_ct >= steadyThresh;

for k = 1:length(ct_ratio_pairs)
    ci_A = ct_ratio_pairs{k}(1);
    ci_B = ct_ratio_pairs{k}(2);

    ss_A = squeeze(mean(Xposs_ct{2}(tsteady_ct, ci_A, :), 1));
    ss_B = squeeze(mean(Xposs_ct{2}(tsteady_ct, ci_B, :), 1));
    r_ss = ss_A ./ ss_B;

    int_A = trapz(tvec_ct(tmask_ct_int), squeeze(Xposs_ct{2}(tmask_ct_int, ci_A, :)), 1);
    int_B = trapz(tvec_ct(tmask_ct_int), squeeze(Xposs_ct{2}(tmask_ct_int, ci_B, :)), 1);
    r_int = int_A ./ int_B;

    cl_B = char(meta_ct.conditions{ci_B});
    if contains(cl_B,'BMP4') && contains(cl_B,'BMP9')
        col = color_bmp4bmp9;
    else
        I = find(cellfun(@(x) contains(cl_B,x), ligands));
        col = colors(I(1),:);
    end

    ratio_labels{end+1}      = ct_ratio_names{k};
    ratio_colors(end+1,:)    = col;
    ratio_ss(end+1)          = mean(r_ss);
    ratio_ss_err(end+1)      = std(r_ss);
    ratio_ss_perpos{end+1}   = r_ss(:);
    ratio_int(end+1)         = mean(r_int);
    ratio_int_err(end+1)     = std(r_int);
    ratio_int_perpos{end+1}  = r_int(:);
end
ratio_exps = [ratio_exps, 3*ones(1, length(ct_ratio_pairs))];

% append ratios from ct2 experiment (250225_SMAD1_SMAD2_crosstalk_extraligands)
% pairs: [ActA cond, BMP-only cond]
ct2_ratio_pairs = {[11 10], [16 1], [5 2], [6 9], [15 14]};
ct2_ratio_names = {'BMP4+ActA', 'BMP2+ActA', 'BMP6+ActA', 'BMP6+BMP4+ActA', 'BMP2+BMP4+ActA'};
tmask_ct2_int   = tvec_ct2 >= integralTmin & tvec_ct2 <= integralTmax;
tsteady_ct2     = tvec_ct2 >= steadyThresh;

for k = 1:length(ct2_ratio_pairs)
    ci_A = ct2_ratio_pairs{k}(1);
    ci_B = ct2_ratio_pairs{k}(2);

    ss_A = squeeze(mean(Xposs_ct2{2}(tsteady_ct2, ci_A, :), 1));
    ss_B = squeeze(mean(Xposs_ct2{2}(tsteady_ct2, ci_B, :), 1));
    r_ss = ss_A ./ ss_B;

    int_A = trapz(tvec_ct2(tmask_ct2_int), squeeze(Xposs_ct2{2}(tmask_ct2_int, ci_A, :)), 1);
    int_B = trapz(tvec_ct2(tmask_ct2_int), squeeze(Xposs_ct2{2}(tmask_ct2_int, ci_B, :)), 1);
    r_int = int_A ./ int_B;

    cl_B = char(meta_ct2.conditions{ci_B});
    if contains(cl_B,'BMP6') && contains(cl_B,'BMP4')
        col = (colors(3,:) + colors(1,:)) / 2;
    elseif contains(cl_B,'BMP2') && contains(cl_B,'BMP4')
        col = (colors(2,:) + colors(1,:)) / 2;
    else
        I = find(cellfun(@(x) contains(cl_B,x), ligands));
        col = colors(I(1),:);
    end

    ratio_labels{end+1}      = ct2_ratio_names{k};
    ratio_colors(end+1,:)    = col;
    ratio_ss(end+1)          = mean(r_ss);
    ratio_ss_err(end+1)      = std(r_ss);
    ratio_ss_perpos{end+1}   = r_ss(:);
    ratio_int(end+1)         = mean(r_int);
    ratio_int_err(end+1)     = std(r_int);
    ratio_int_perpos{end+1}  = r_int(:);
end
ratio_exps = [ratio_exps, 4*ones(1, length(ct2_ratio_pairs))];

nratio = length(ratio_labels);

%% Integral ratio — box and whisker with individual data points

vals   = cell2mat(cellfun(@(x) x(:)', ratio_int_perpos, 'UniformOutput', false));
groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), ratio_int_perpos, ...
                  num2cell(1:nratio), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
boxplot(vals(:), groups(:), 'Labels', strrep(strrep(ratio_labels,'+ActA',''),'+BMP','+'), ...
    'Symbol', '', 'Widths', 0.5)

% make all boxplot elements black and thick (before scatter so only
% boxplot objects are present in the axes at this point)
lw = 2;
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')

% overlay individual data points with jitter
rng(0);  % fixed seed for reproducible jitter
for cidx = 1:nratio
    pts = ratio_int_perpos{cidx};
    xjit = cidx + 0.15*(rand(size(pts)) - 0.5);
    scatter(xjit, pts, 60, ratio_colors(cidx,:), 'filled', ...
        'MarkerEdgeColor','k','LineWidth',0.5)
end
yline(1, '--k', 'LineWidth', 1);
hold off

cleanSubplot(fs);
set(gca, 'LineWidth', lw);
xlim([0.5, nratio + 0.5])
xtickangle(45)
yticks([0 0.25 0.5 0.75 1])
yticklabels({'0', '', '', '', '1'})
ylabel({'SMAD1 integral ratio', '(BMP+ActA) / BMP'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_boxplot.png'))

% combined: all BMPs except BMP4+BMP9; markers by experiment (o=exp1, s=exp2, ^=ct, d=ct2)
exp_markers = {'o','s','^','d'};
exp_dates   = {'251027', '251111', '250529', '250225'};

[unique_ratio_labels_all, ~, ic_r] = unique(ratio_labels, 'stable');
% exclude combination-BMP conditions (base label contains '+'); those go in _crosstalk plot
keep_r = ~contains(strrep(unique_ratio_labels_all, '+ActA', ''), '+');
unique_ratio_labels = unique_ratio_labels_all(keep_r);
nunique_r = length(unique_ratio_labels);
kept_r = find(keep_r);
ic_r2  = zeros(size(ic_r));
for ki = 1:nunique_r, ic_r2(ic_r == kept_r(ki)) = ki; end

comb_ratio_perpos = cell(1, nunique_r);
comb_ratio_exp    = cell(1, nunique_r);
comb_ratio_colors = zeros(nunique_r, 3);
for k = 1:nunique_r
    idx = find(ic_r2 == k);
    comb_ratio_perpos{k} = cell2mat(cellfun(@(x) x(:)', ratio_int_perpos(idx), 'UniformOutput', false));
    ep = [];
    for ii = 1:length(idx)
        ep = [ep, ratio_exps(idx(ii))*ones(1, numel(ratio_int_perpos{idx(ii)}))];
    end
    comb_ratio_exp{k}      = ep;
    comb_ratio_colors(k,:) = ratio_colors(idx(1),:);
end

% exclude 250225 (exp4) from combined plot
for k = 1:nunique_r
    keep = comb_ratio_exp{k} ~= 4;
    comb_ratio_perpos{k} = comb_ratio_perpos{k}(keep);
    comb_ratio_exp{k}    = comb_ratio_exp{k}(keep);
end

comb_ratio_vals   = cell2mat(cellfun(@(x) x(:)', comb_ratio_perpos, 'UniformOutput', false));
comb_ratio_groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), comb_ratio_perpos, ...
                   num2cell(1:nunique_r), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
boxplot(comb_ratio_vals(:), comb_ratio_groups(:), ...
    'Labels', strrep(strrep(unique_ratio_labels,'+ActA',''),'+BMP','+'), 'Symbol', '', 'Widths', 0.5)
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')

rng(0);
for k = 1:nunique_r
    pts  = comb_ratio_perpos{k};
    ep   = comb_ratio_exp{k};
    xjit = k + 0.15*(rand(size(pts)) - 0.5);
    col  = comb_ratio_colors(k,:);
    for ei = 1:4
        mask = ep == ei;
        if any(mask)
            scatter(xjit(mask), pts(mask), 60, col, exp_markers{ei}, 'filled', ...
                'MarkerEdgeColor','k','LineWidth',0.5)
        end
    end
end
present_exps_r = unique(cell2mat(cellfun(@(ep) ep(:)', comb_ratio_exp, 'UniformOutput', false)));
h_leg_comb = gobjects(length(present_exps_r),1);
for ki = 1:length(present_exps_r)
    ei = present_exps_r(ki);
    h_leg_comb(ki) = scatter(nan, nan, 60, [0.5 0.5 0.5], exp_markers{ei}, 'filled', ...
        'MarkerEdgeColor','k','LineWidth',0.5);
end
yline(1, '--k', 'LineWidth', 1);
hold off
cleanSubplot(fs);
set(gca,'LineWidth',lw);
xlim([0.5, nunique_r+0.5])
xtickangle(45)
yticks([0 0.25 0.5 0.75 1])
yticklabels({'0', '', '', '', '1'})
ylabel({'SMAD1 integral ratio', '(BMP+ActA) / BMP'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
lgd_comb = legend(h_leg_comb, exp_dates(present_exps_r), 'FontSize', lfs-4, 'Interpreter', 'none', 'Location', 'NorthEast');
lgd_comb.ItemTokenSize = [12 12];
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_combined_boxplot.png'))
set(lgd_comb, 'Visible', 'off')
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_combined_boxplot_noleg.png'))

% crosstalk-only: all conditions from ct/ct2 experiments; BMP6 excluded (adds little)
ct_only_mask   = ratio_exps >= 3 & ~contains(ratio_labels, 'BMP6');
ct_only_perpos = ratio_int_perpos(ct_only_mask);
ct_only_labels = strrep(ratio_labels(ct_only_mask), '+ActA', '');
ct_only_colors = ratio_colors(ct_only_mask, :);
ct_only_exps   = ratio_exps(ct_only_mask);
nct = sum(ct_only_mask);

ct_vals   = cell2mat(cellfun(@(x) x(:)', ct_only_perpos, 'UniformOutput', false));
ct_groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), ct_only_perpos, num2cell(1:nct), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
boxplot(ct_vals(:), ct_groups(:), 'Labels', strrep(ct_only_labels,'+BMP','+'), 'Symbol', '', 'Widths', 0.5)
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')
rng(0);
for k = 1:nct
    pts  = ct_only_perpos{k};
    xjit = k + 0.15*(rand(size(pts)) - 0.5);
    ep   = ct_only_exps(k) * ones(size(pts));
    for ei = 3:4
        mask = ep == ei;
        if any(mask)
            scatter(xjit(mask), pts(mask), 60, ct_only_colors(k,:), exp_markers{ei}, 'filled', ...
                'MarkerEdgeColor','k','LineWidth',0.5)
        end
    end
end
h_leg_ct = gobjects(2,1);
for ei = 3:4
    h_leg_ct(ei-2) = scatter(nan, nan, 60, [0.5 0.5 0.5], exp_markers{ei}, 'filled', ...
        'MarkerEdgeColor','k','LineWidth',0.5);
end
yline(1, '--k', 'LineWidth', 1);
hold off
cleanSubplot(fs);
set(gca,'LineWidth',lw);
xlim([0.5, nct+0.5])
xtickangle(45)
yticks([0 0.25 0.5 0.75 1])
yticklabels({'0', '', '', '', '1'})
ylabel({'SMAD1 integral ratio', '(BMP+ActA) / BMP'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
lgd_ct = legend(h_leg_ct, exp_dates(3:4), 'FontSize', lfs-4, 'Interpreter', 'none', 'Location', 'NorthEast');
lgd_ct.ItemTokenSize = [12 12];
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_crosstalk_boxplot.png'))
set(lgd_ct, 'Visible', 'off')
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_crosstalk_boxplot_noleg.png'))

%% ANOVA on ratios — are the ActA effects different across ligands?

% match combined ratio plot: single-BMP conditions (no '+' in base name), exp1-3 only
bmp_labels   = strrep(ratio_labels, '+ActA', '');
anova_mask   = ~contains(bmp_labels, '+') & ratio_exps ~= 4;
an_labels_all = bmp_labels(anova_mask);
[unique_an_labels, ~, ic_an] = unique(an_labels_all, 'stable');
nan_unique = length(unique_an_labels);
an_ss_masked  = ratio_ss_perpos(anova_mask);
an_int_masked = ratio_int_perpos(anova_mask);
an_pooled_ss  = cell(1, nan_unique);
an_pooled_int = cell(1, nan_unique);
for k = 1:nan_unique
    idx_an = find(ic_an == k);
    an_pooled_ss{k}  = cell2mat(cellfun(@(x) x(:)', an_ss_masked(idx_an),  'UniformOutput', false));
    an_pooled_int{k} = cell2mat(cellfun(@(x) x(:)', an_int_masked(idx_an), 'UniformOutput', false));
end

for testtype = 1:2
    if testtype == 1
        perpos = an_pooled_ss;  label = 'steady-state';
    else
        perpos = an_pooled_int; label = 'integral';
    end

    % build group vectors for anova1
    vals   = cell2mat(cellfun(@(x) x(:)', perpos, 'UniformOutput', false));
    groups = cell2mat(cellfun(@(x,n) repmat(n, 1, numel(x)), perpos, ...
                     num2cell(1:nan_unique), 'UniformOutput', false));

    fprintf('\n--- One-way ANOVA on %s ratios ---\n', label)
    [p, tbl, stats] = anova1(vals(:), groups(:), 'off');
    fprintf('ANOVA p = %.4f\n', p)
    disp(tbl)

    fprintf('Pairwise comparisons (Tukey):\n')
    [c, ~, ~, gnames] = multcompare(stats, 'Display', 'off');
    gnames = unique_an_labels;
    for row = 1:size(c,1)
        fprintf('  %s vs %s:  p = %.4f\n', ...
            gnames{c(row,1)}, gnames{c(row,2)}, c(row,6))
    end

    % heatmap of Tukey p-values (upper triangle only)
    n = length(gnames);
    pmat = nan(n,n);
    for row = 1:size(c,1)
        pmat(c(row,1), c(row,2)) = c(row,6);
    end
    figure('Position', figurePosition([756 630]));
    im = imagesc(-log10(pmat), [0 3]);
    set(im, 'AlphaData', ~isnan(pmat));   % NaN cells (lower tri + diagonal) → transparent
    colormap(parula); cb = colorbar;
    cb.Label.String = '-log_{10}(p)';
    cb.Label.Rotation = 270; cb.Label.VerticalAlignment = 'bottom';
    cb.Ticks = [0 1 2 3]; cb.TickLabels = {'1','0.1','0.01','0.001'};
    set(gca, 'XTick',1:n,'XTickLabel',gnames,'YTick',1:n,'YTickLabel',gnames)
    xtickangle(45)
    for i = 1:n
        for j = 1:n
            if ~isnan(pmat(i,j))
                if     pmat(i,j) < 0.001, txt = '***';
                elseif pmat(i,j) < 0.01,  txt = '**';
                elseif pmat(i,j) < 0.05,  txt = '*';
                else,                      txt = 'ns';
                end
                text(j, i, txt, 'HorizontalAlignment','center', ...
                    'VerticalAlignment','middle', 'FontSize', lfs)
            end
        end
    end
    cleanSubplot(fs);
    set(gca, 'Color', 'white', 'Position', [0.22 0.22 0.50 0.60]);
    title(sprintf('Tukey p-values: ActA effect (%s)', label))
    savefigure(fullfile(savedir, sprintf('SMAD1_ratio_%s_anova_heatmap.png', label)))
end

%% BMP average — box and whisker (BMP-only conditions, no +ActA)

% select non-+ActA conditions from legstr_all
bmp_only_mask   = cellfun(@(s) ~contains(s,'+ActA'), legstr_all);
bmp_only_idx    = find(bmp_only_mask);
nbmp            = numel(bmp_only_idx);
bmp_only_labels = legstr_all(bmp_only_idx);
bmp_only_colors = barcolors_all(bmp_only_idx,:);

% per-position mean over all positive timepoints
bmp_int_perpos = cell(1,nbmp);
for k = 1:nbmp
    di_k   = all_di(bmp_only_idx(k));
    cond_k = all_cidx(bmp_only_idx(k));
    tv     = tvecs{di_k};
    tmask  = tv >= 0;
    Xpos_cond = squeeze(Xposs{di_k}(tmask, cond_k, :));
    bmp_int_perpos{k} = mean(Xpos_cond, 1)';
end
bmp_exps = arrayfun(@(k) all_di(bmp_only_idx(k)), 1:nbmp);

% append BMP4, BMP9, BMP4+BMP9 from crosstalk experiment (SMAD1 channel)
ct_bmp_conds = [2, 9, 16];
tmask_ct = tvec_ct >= 0;
ct_bmp_perpos = cell(1, length(ct_bmp_conds));
ct_bmp_labels = cell(1, length(ct_bmp_conds));
ct_bmp_colors = zeros(length(ct_bmp_conds), 3);
for k = 1:length(ct_bmp_conds)
    ci = ct_bmp_conds(k);
    Xpos_cond_ct = squeeze(Xposs_ct{2}(tmask_ct, ci, :));
    ct_bmp_perpos{k} = mean(Xpos_cond_ct, 1)';
    cl = char(meta_ct.conditions{ci});
    ct_bmp_labels{k} = cl;
    if contains(cl,'BMP4') && contains(cl,'BMP9')
        ct_bmp_colors(k,:) = color_bmp4bmp9;
    else
        I = find(cellfun(@(x) contains(cl,x), ligands));
        ct_bmp_colors(k,:) = colors(I(1),:);
    end
end
bmp_int_perpos  = [bmp_int_perpos,  ct_bmp_perpos];
bmp_only_labels = [bmp_only_labels, ct_bmp_labels];
bmp_only_colors = [bmp_only_colors; ct_bmp_colors];
bmp_exps        = [bmp_exps, 3*ones(1, length(ct_bmp_conds))];
nbmp            = nbmp + length(ct_bmp_conds);

% append single and combination BMP conditions from ct2 (SMAD1 channel)
% BMP2(1), BMP6(2), BMP4(10), BMP2+BMP4(14), BMP6+BMP4(9); BMP7 excluded
ct2_bmp_conds  = [1, 2, 10, 14, 9];   % BMP2, BMP6, BMP4, BMP2+BMP4, BMP6+BMP4 (no BMP7)
tmask_ct2_bmp  = tvec_ct2 >= 0;
ct2_bmp_perpos = cell(1, length(ct2_bmp_conds));
ct2_bmp_labels = cell(1, length(ct2_bmp_conds));
ct2_bmp_colors = zeros(length(ct2_bmp_conds), 3);
for k = 1:length(ct2_bmp_conds)
    ci = ct2_bmp_conds(k);
    Xpos_cond_ct2     = squeeze(Xposs_ct2{2}(tmask_ct2_bmp, ci, :));
    ct2_bmp_perpos{k} = mean(Xpos_cond_ct2, 1)';
    cl = char(meta_ct2.conditions{ci});
    ct2_bmp_labels{k} = cl;
    if contains(cl,'BMP6') && contains(cl,'BMP4')
        ct2_bmp_colors(k,:) = (colors(3,:) + colors(1,:)) / 2;
    elseif contains(cl,'BMP2') && contains(cl,'BMP4')
        ct2_bmp_colors(k,:) = (colors(2,:) + colors(1,:)) / 2;
    else
        I = find(cellfun(@(x) contains(cl,x), ligands));
        ct2_bmp_colors(k,:) = colors(I(1),:);
    end
end
bmp_int_perpos  = [bmp_int_perpos,  ct2_bmp_perpos];
bmp_only_labels = [bmp_only_labels, ct2_bmp_labels];
bmp_only_colors = [bmp_only_colors; ct2_bmp_colors];
bmp_exps        = [bmp_exps, 4*ones(1, length(ct2_bmp_conds))];
nbmp            = nbmp + length(ct2_bmp_conds);

bmp_vals   = cell2mat(cellfun(@(x) x(:)', bmp_int_perpos, 'UniformOutput', false));
bmp_groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), bmp_int_perpos, ...
             num2cell(1:nbmp), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
lw = 2;
boxplot(bmp_vals(:), bmp_groups(:), 'Labels', strrep(bmp_only_labels,'+BMP','+'), 'Symbol', '', 'Widths', 0.5)
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')

rng(0);
for k = 1:nbmp
    pts  = bmp_int_perpos{k};
    xjit = k + 0.15*(rand(size(pts)) - 0.5);
    scatter(xjit, pts, 60, bmp_only_colors(k,:), 'filled', ...
        'MarkerEdgeColor','k','LineWidth',0.5)
end
hold off
cleanSubplot(fs);
set(gca,'LineWidth',lw);
xlim([0.5, nbmp+0.5])
xtickangle(45)
ylabel({'', 'Avg. SMAD1 (N:C)'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
savefigure(fullfile(savedir,'SMAD1_bmp_avg_boxplot.png'))

% combined: single-BMP conditions only; markers by experiment (o=exp1, s=exp2, ^=ct, d=ct2)
% exclude combination conditions (BMP4+BMP9, BMP6+BMP4, BMP2+BMP4) — those are in _crosstalk plots
single_bmp_mask  = ~contains(bmp_only_labels, '+');
sb_labels = bmp_only_labels(single_bmp_mask);
sb_perpos = bmp_int_perpos(single_bmp_mask);
sb_exps   = bmp_exps(single_bmp_mask);
sb_colors = bmp_only_colors(single_bmp_mask, :);

[unique_bmp_labels, ~, ic] = unique(sb_labels, 'stable');
nunique = length(unique_bmp_labels);

comb_perpos = cell(1, nunique);
comb_exp    = cell(1, nunique);
comb_colors = zeros(nunique, 3);
for k = 1:nunique
    idx = find(ic == k);
    comb_perpos{k} = cell2mat(cellfun(@(x) x(:)', sb_perpos(idx), 'UniformOutput', false));
    ep = [];
    for ii = 1:length(idx)
        ep = [ep, sb_exps(idx(ii))*ones(1, numel(sb_perpos{idx(ii)}))];
    end
    comb_exp{k}    = ep;
    comb_colors(k,:) = sb_colors(idx(1),:);
end

% exclude 250225 (exp4) from combined plot
for k = 1:nunique
    keep = comb_exp{k} ~= 4;
    comb_perpos{k} = comb_perpos{k}(keep);
    comb_exp{k}    = comb_exp{k}(keep);
end

comb_vals   = cell2mat(cellfun(@(x) x(:)', comb_perpos, 'UniformOutput', false));
comb_groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), comb_perpos, ...
              num2cell(1:nunique), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
boxplot(comb_vals(:), comb_groups(:), 'Labels', strrep(unique_bmp_labels,'+BMP','+'), 'Symbol', '', 'Widths', 0.5)
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')

rng(0);
for k = 1:nunique
    pts  = comb_perpos{k};
    ep   = comb_exp{k};
    xjit = k + 0.15*(rand(size(pts)) - 0.5);
    col  = comb_colors(k,:);
    for ei = 1:4
        mask = ep == ei;
        if any(mask)
            scatter(xjit(mask), pts(mask), 60, col, exp_markers{ei}, 'filled', ...
                'MarkerEdgeColor','k','LineWidth',0.5)
        end
    end
end
present_exps_b = unique(cell2mat(cellfun(@(ep) ep(:)', comb_exp, 'UniformOutput', false)));
h_leg_bmp = gobjects(length(present_exps_b),1);
for ki = 1:length(present_exps_b)
    ei = present_exps_b(ki);
    h_leg_bmp(ki) = scatter(nan, nan, 60, [0.5 0.5 0.5], exp_markers{ei}, 'filled', ...
        'MarkerEdgeColor','k','LineWidth',0.5);
end
hold off
cleanSubplot(fs);
set(gca,'LineWidth',lw);
xlim([0.5, nunique+0.5])
xtickangle(45)
ylabel({'', 'Avg. SMAD1 (N:C)'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
lgd_bmp = legend(h_leg_bmp, exp_dates(present_exps_b), 'FontSize', lfs-4, 'Interpreter', 'none', 'Location', 'NorthEast');
lgd_bmp.ItemTokenSize = [12 12];
savefigure(fullfile(savedir,'SMAD1_bmp_avg_combined_boxplot.png'))
set(lgd_bmp, 'Visible', 'off')
savefigure(fullfile(savedir,'SMAD1_bmp_avg_combined_boxplot_noleg.png'))

%% ANOVA on BMP average — do BMPs differ in potency?

fprintf('\n--- One-way ANOVA on BMP integrals ---\n')
[p, tbl, stats] = anova1(bmp_vals(:), bmp_groups(:), 'off');
fprintf('ANOVA p = %.4f\n', p)
disp(tbl)

fprintf('Pairwise comparisons (Tukey):\n')
[c, ~, ~, gnames] = multcompare(stats, 'Display', 'off');
gnames = bmp_only_labels;
for row = 1:size(c,1)
    fprintf('  %s vs %s:  p = %.4f\n', gnames{c(row,1)}, gnames{c(row,2)}, c(row,6))
end

% heatmap of Tukey p-values (upper triangle only)
n = length(gnames);
pmat = nan(n,n);
for row = 1:size(c,1)
    pmat(c(row,1), c(row,2)) = c(row,6);
end
figure('Position', figurePosition([756 630]));
im = imagesc(-log10(pmat), [0 3]);
set(im, 'AlphaData', ~isnan(pmat));
colormap(parula); cb = colorbar;
cb.Label.String = '-log_{10}(p)';
cb.Label.VerticalAlignment = 'top'; %cb.Label.Rotation = 270; 
cb.Ticks = [0 1 2 3]; cb.TickLabels = {'0','1','2','3'};
set(gca, 'XTick',1:n,'XTickLabel',gnames,'YTick',1:n,'YTickLabel',gnames)
xtickangle(45)
for i = 1:n
    for j = 1:n
        if ~isnan(pmat(i,j))
            if     pmat(i,j) < 0.001, txt = '***';
            elseif pmat(i,j) < 0.01,  txt = '**';
            elseif pmat(i,j) < 0.05,  txt = '*';
            else,                      txt = 'ns';
            end
            text(j, i, txt, 'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', 'FontSize', lfs)
        end
    end
end
cleanSubplot(fs);
set(gca, 'Color', 'white', 'Position', [0.22 0.22 0.50 0.60]);
savefigure(fullfile(savedir, 'SMAD1_bmp_avg_anova_heatmap.png'))

%% Sanity check: recompute normalization from signalDatas and compare to X
% Fig 1 — solid = X from file, dashed = median recomputed from signalDatas;
%          should overlap exactly
% Fig 2 — solid = X from file, dashed = mean of per-position medians from
%          positions.mat; should be close but not identical (pooled median
%          vs mean of medians)

for di = 1:ndir
    Xcheck = cellfun(@(x) median(x,'omitnan'), signalDatas{di});
    Xcheck = Xcheck - mean(Xcheck(tvecs{di} <= 0,:), 1);
    minval = mean(Xcheck(:, minconds(di)));
    maxval = mean(Xcheck(:, maxconds(di)));
    Xcheck = (Xcheck - minval) / (maxval - minval);
    nconds_di = size(Xs{di}, 2);

    figure; hold on
    for cidx = 1:nconds_di
        h1 = plot(tvecs{di}, Xs{di}(:,cidx), '-', 'LineWidth', 2);
        plot(tvecs{di}, Xcheck(:,cidx), '--', 'Color', h1.Color, 'LineWidth', 1)
    end
    hold off
    title(sprintf('dir %d: X (solid) vs recomputed pooled median (dashed)', di))
    xlabel('time (hrs)'); ylabel('SMAD1 (N:C)')

    figure; hold on
    for cidx = 1:nconds_di
        h1 = plot(tvecs{di}, Xs{di}(:,cidx), '-', 'LineWidth', 2);
        plot(tvecs{di}, Xwellmeans{di}(:,cidx), '--', 'Color', h1.Color, 'LineWidth', 1)
    end
    hold off
    title(sprintf('dir %d: X (solid) vs mean of per-position medians (dashed)', di))
    xlabel('time (hrs)'); ylabel('SMAD1 (N:C)')
end

%% Integral ratio — TGFβ ligands experiment (250910)
% ratios: (BMP4+X) / BMP4, per position

ct3_ratio_pairs = {[2 1], [3 1], [4 1], [5 1], [6 1], [7 1]};
ct3_ratio_names = {'ActA', 'myostatin', 'GDF11', 'TGFβ1', 'TGFβ2', 'TGFβ3'};
ct3_colors = [0.8 0 0;        % ActA — dark red
              0.2 0.6 0.2;    % myostatin — green
              0   0.7 0.7;    % GDF11 — teal
              0.5 0   0.8;    % TGFβ1 — purple
              0.8 0.3 0.5;    % TGFβ2 — pink
              0.3 0.3 0.8];   % TGFβ3 — blue

tsteady_ct3     = tvec_ct3 >= steadyThresh;
tmask_ct3_int   = tvec_ct3 >= integralTmin & tvec_ct3 <= integralTmax;
nct3 = length(ct3_ratio_pairs);

ct3_ratio_int_perpos = cell(1, nct3);
for k = 1:nct3
    ci_A = ct3_ratio_pairs{k}(1);
    ci_B = ct3_ratio_pairs{k}(2);
    int_A = trapz(tvec_ct3(tmask_ct3_int), squeeze(Xposs_ct3(tmask_ct3_int, ci_A, :)), 1);
    int_B = trapz(tvec_ct3(tmask_ct3_int), squeeze(Xposs_ct3(tmask_ct3_int, ci_B, :)), 1);
    ct3_ratio_int_perpos{k} = (int_A ./ int_B)';
end

ct3_vals   = cell2mat(cellfun(@(x) x(:)', ct3_ratio_int_perpos, 'UniformOutput', false));
ct3_groups = cell2mat(cellfun(@(x,n) repmat(n,1,numel(x)), ct3_ratio_int_perpos, ...
             num2cell(1:nct3), 'UniformOutput', false));

figure('Position',figurePosition([630 630])); hold on
lw = 2;
boxplot(ct3_vals(:), ct3_groups(:), 'Labels', ct3_ratio_names, 'Symbol', '', 'Widths', 0.5)
set(findobj(gca,'Type','line'),  'Color','k','LineWidth',lw)
set(findobj(gca,'Type','patch'), 'EdgeColor','k','LineWidth',lw,'FaceColor','none')
rng(0);
for k = 1:nct3
    pts  = ct3_ratio_int_perpos{k};
    xjit = k + 0.15*(rand(size(pts)) - 0.5);
    scatter(xjit, pts, 60, ct3_colors(k,:), 'filled', 'MarkerEdgeColor','k','LineWidth',0.5)
end
yline(1, '--k', 'LineWidth', 1);
hold off
cleanSubplot(fs);
set(gca,'LineWidth',lw);
xlim([0.5, nct3+0.5])
xtickangle(45)
yticks([0 0.25 0.5 0.75 1])
yticklabels({'0', '', '', '', '1'})
ylabel({'SMAD1 integral ratio', '(BMP4+ligand) / BMP4'})
set(gca, 'Position', [0.22 0.22 0.60 0.60])
savefigure(fullfile(savedir, 'SMAD1_ratio_integral_TGFb_boxplot.png'))
close

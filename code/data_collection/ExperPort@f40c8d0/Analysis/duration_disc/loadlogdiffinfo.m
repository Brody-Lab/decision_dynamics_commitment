function [] = loadlogdiffinfo(ratname,varargin)

pairs = { ...
    'infile', 'logdiff' ; ...
    'experimenter','Shraddha' ; ...
    'action','load' ; ... [save | load]
    };
parse_knownargs(varargin, pairs);

global Solo_rootdir;
global Solo_datadir;
if isempty(Solo_rootdir), mystartup; end;
stat_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'stat_sandbox'];
event_analysis_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'Event_Analysis'];

if ~is_in_path(stat_dir)
    fprintf(1,'Adding stat_sandbox to path ...\n');
    addpath(stat_dir);
    addpath(event_analysis_dir);
end;
outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];

ratrow = rat_task_table(ratname);
task = ratrow{1,2};

switch action
    case 'save'

        fname = [outdir infile '.mat'];
        fprintf(1,'Saving to:\n%s\n',fname);

        logdates = ratrow{1,rat_task_table('','action','get_sharp_col')};
        from= logdates{1};
        to=logdates{2};

        psychf = 'psych';
        if strcmpi(task(1:3),'dua'), psychf = 'pitch_psych'; end;
        datafields = {'logdiff', 'logflag', psychf, 'bbspl','left_prob'};
        get_fields(ratname,'from',from,'to',to, 'datafields',datafields);

        if strcmpi(task(1:3),'dua'), psychflag=pitch_psych; else psychflag=psych; end;
        save(fname, 'logdiff','logflag', 'psychflag','dates', ...
            'numtrials','hit_history','bbspl','left_prob');

        return;
    case 'load'
        fname = [outdir infile '.mat'];
        load(fname);
    otherwise error('invalid action');
end;



% got logdiff, hit_history, max_trials, logflag, psychflag,dates, bbspl,
% lprob


figure;
set(gcf,'Position', [76         852        1390         220]);

if exist('numtrials')
    max_trials = numtrials;
end;

% hit history plot
%plot(1:length(hit_history),hit_history,'.r'); hold on;
axes;
patch([0 0 sum(max_trials) sum(max_trials)], [0 0.5 0.5 0],[1 0.8 0.8]); hold on;
%patch([0 0 sum(max_trials) sum(max_trials)], [0.5 0.8 0.8 0.5],[1 0.8 0.6]);
patch([0 0 sum(max_trials) sum(max_trials)], [0.8 1 1 0.8],[1 1 0.6]);
plot_hitrate(hit_history,max_trials);
draw_separators(max_trials,0,1);
offset=0;
for k = 1:length(max_trials),
    t= text(offset+ 10, 1.05, dates{k});
    set(t,'FontWeight','bold');
    offset=offset+max_trials(k);
end;
%title('Hit history (Raw)');
pos = get(gca,'Position');
set(gca,'Position',[0.04 0.6 0.9 0.35],'XLim',[0 sum(max_trials)],'XTick',[sum(max_trials)]);

% logdiff plot
axes;
plot(1:length(logdiff), logdiff,'.b','MarkerSize',6); hold on;
line([0 sum(max_trials)], [min(logdiff) min(logdiff)], 'LineStyle',':','Color','r');
draw_separators(max_trials,0,1);
offset=0;
for k = 1:length(max_trials),
    text(offset+5, logdiff(offset+2)-0.2, sprintf('%1.1f',logdiff(offset+2)));
    offset=offset+max_trials(k);
end;

ylabel('Logdiff');
pos = get(gca,'Position');
set(gca,'Position',[0.04 0.35 0.9 0.2],'XLim',[0 sum(max_trials)],'XTick',[sum(max_trials)]);

% Sharpening and psych flags
axes;
l = plot(1:length(logflag), logflag+3,'-r'); set(l,'Color',[1 0.7 0.7],'LineWidth',3);
hold on;
l = plot(1:length(psychflag), psychflag,'-r'); set(l,'Color',[0.7 1 0.7],'LineWidth',3);
draw_separators(max_trials,-1,5);
line([1 length(logflag)], [2 2],'Color', [0.5 0.5 0.5],'LineStyle',':');
set(gca, 'YLim', [-1 5], 'YTickLabel', {'off', 'on','off','on'}, 'YTick', ...
    [0 1 3 4],'XTick',[sum(max_trials)]);
%t = title(sprintf('Sharpening flag(PINK)\nPsych trials (Blue) switches'));
pos = get(gca,'Position');
set(gca,'Position',[0.04 0.07 0.9 0.2],'XLim',[0 sum(max_trials)]);
ylabel(sprintf('Sharp. flag (pk)\nPsych flag(gr)'));

axes;
set(gca,'Position',[0.96 0, 0.04,1],'XLim',[0 1], 'YLim',[0 1],'XTick',[],'YTick',[]);
patch([0 0 1 1],[0 1 1 0],[1 0.8 0.4]);
t=text(0.5,0.1,sprintf('%s\n%s-%s',ratname,dates{1},dates{end}));
set(t,'FontWeight','bold','FontSize',18,'Rotation',90);

datacursormode on;

% Plot bias correction parameters
figure;
% badboyspl
subplot(2,1,1);
set(gcf,'Position',[1082      10         360         280] , 'Toolbar', 'none')
bb = flatten_bbspl(bbspl);
plot(1:length(bb), bb, '.r');
ylabel('BadboySPL');
set(gca,'YTick', 1:3, 'YTickLabel', {'normal','Louder','LOUDEST'}, 'XLim', ...
    [1 length(bb)], 'YLim', [0 4]);
xlabel('Trial #');
s = sprintf('%s: %s (%s)\nBadBoySPL', make_title(ratname), make_title(task), date);
t = title(s); set(t,'FontSize',14);

% lprob
subplot(2,1,2);
plot(1:length(left_prob), left_prob,'-b');
if length(unique(left_prob)) > 1
    %warndlg('LProb is being changed!','LProb alert');
    set(gca,'Color','y');
end;
set(gcf,'Tag','sessionview');
title('Value of LeftProb');
xlabel('Trial #');
ylabel('LProb');
datacursormode on

figure;
hh = hit_history;
barweb(mean(hh),std(hh)/(length(hh)-1));
t=title(sprintf('%s: Avg %% correct:(%s-%s)', ratname, dates{1}, dates{end}));
set(t,'FontSize',16,'FontWeight','bold');
t=text(0.8, 1.2, sprintf('%i%% (%i)', round(mean(hh)*100), round((std(hh)/(length(hh)-1))*100)));
set(t,'FontSize',14, 'FontWeight','bold');
set(gca, 'XLim',[0 2],'XTIck',[],'FontSize',16,'FontWeight','bold','YLim',[0 1.5],'YTick',[0:0.2:1], 'YTickLabel',0:20:100);
set(gcf,'Position',[587   431   403   314],'Toolbar','none');
ylabel('%% Correct (SEM)');


% ------------------------------------------------------------------------
% Helper functions
% ------------------------------------------------------------------------

% Draws vertical lines separating session info
function [] = draw_separators(max_trials,low,hi);
offset=0;
for k = 1:length(max_trials),
    offset=offset+max_trials(k);
    line([offset offset], [low hi], 'LineStyle','-', 'Color','k');

end;


% Calculates and plots hit rate
function [] = plot_hitrate(hit_history,max_trials)
bout_size=15;
good=0.8;

% lookback hit rate
last_win = length(hit_history) - (bout_size-1);
first_win = bout_size;
binned = zeros(1, length(hit_history)-(bout_size-1));
for idx = bout_size:length(hit_history)
    start_idx = max(1, (idx-bout_size)+1);
    binned(idx - (bout_size-1)) = mean(hit_history(start_idx:idx));
end;

start_idx = 1; end_idx = last_win;

x = start_idx:end_idx;
xx = start_idx:0.01:end_idx;
yy = spline(x, binned, xx);
l = plot(x,binned, '-k');
line([start_idx end_idx], [good good], 'LineStyle','--','Color','b');
line([start_idx end_idx], [0.5 0.5], 'LineStyle', '--', 'Color', 'r');

%set(t,'FontSize',fsize,'FontWeight','bold');
xlabel('Trial #');
ylabel('Hit rate');
set(gca,'YLim',[0.35 1.1]);

offset =0;
for k=1:length(max_trials)
    currhh = hit_history(offset+1:offset+max_trials(k));
    t=text(offset+(max_trials(k)/2), 0.4, sprintf('%i', round(mean(currhh) * 100)));
    set(t,'FontWeight','bold');
    offset = offset+max_trials(k);
end;

% Plots the logistic-fitted psychometric graph
function [] = plot_psych_curve(ltone, rtone, hit_history, max_trials, psych_on, slist)

[dummy bins] = generate_bins(binmin, binmax, num_bins);
replong = zeros(1,cols(bins)-1); tally = zeros(1, cols(bins)-1);

offset = 0;
for d = 1:length(max_trials)

    % Set up tones array
    t1 = ltone(offset+1:offset+max_trials(d));
    t2 = rtone(offset+1:offset+max_trials(d));

    left = 1; right = 1-left;
    tones = zeros(size(t1));

    sides = slist(offset+1:offset+max_trials(d));
    tones(find(sides == left)) = t1(find(sides == left));
    tones(find(sides == right)) = t2(find(sides == right));

    % Set up "reported long array"
    left_t = find(sides == left);
    hh = hit_history(offset+1:offset+max_trials(d)); rep_long = hh;
    rep_long(intersect(left_t, find(hh == 0))) = 1;
    rep_long(intersect(left_t,find(hh==1))) = 0;

    % now get psychometric trials
    psych = psych_on(offset+1:max_trials(d));
    psych = find(psych > 0);
    contigs = make_contigs(psych);

    if cols(contigs) >1
        sprintf('Found > 1 contig of randomised trials; taking only the last one')
        trials = contigs{cols(contigs)};
    else
        trials = contigs{1};
    end;
    if length(trials) > 0
        numt = max_trials(d);
        if d > 1, numt = max_trials(d) - max_trials(d-1); end;
        i = find(trials > numt);
        if ~isempty(i)
            trials = trials(1:i(1)-1);
        end;

        % Analyse only psychometric trials
        rep_long = rep_long(trials);
        tones = tones(trials) * 1000;


        % need to do this for LHS endpoint; everything else is taken care of
        idx = find(tones == bins(1));
        tally(1) = tally(1) + length(idx); replong(1) = replong(1) + sum(rep_long(idx));

        for k = 2:length(bins)
            idx = intersect(find(tones > bins(k-1)), find(tones <= bins(k)));
            tally(k-1) = tally(k-1) + length(idx);
            replong(k-1) = replong(k-1) + sum(rep_long(idx));
        end;

    end;

end;

% now plot
p = replong ./ tally;
variance = (p .* (1-p)) ./ tally ;
stdev = sqrt(variance);

% perform logistic regression and calculate Weber ratio
[out] = weber_caller(bins, replong, tally, 0,binmin,binmax)

fnames = fieldnames(out);
for f = 1:length(fnames)
    eval([fnames{f} ' = out.' fnames{f} ';']);
end;
xx = interp_x;
yy = interp_y;
x=logbins;

% Plotting begins here ---------------------------
fig = figure;
%set(gcf,
%        'Name', sprintf('%s: Pooled psychometric trials', rat));
curr_x = 0.05; curr_width = 0.4;
if nodist == 0
    axes('Position', [curr_x 0.1 curr_width 0.8]);
    bar(bins(1:end-1), tally, 'stacked');
    for k = 1:length(bins)-1
        h = text(bins(k)-10, tally(k)+(0.08*tally(k)), int2str(tally(k)));
        set(h, 'FontSize',fsize,'FontWeight','bold');
    end;
    xlabel('Bins of tone duration (milliseconds)');
    ylabel('Sample size (n)');
    title('Psych curve');
    axis([binmin-25 binmax+25 0 max(tally)+(0.1*max(tally))]);
    curr_x = curr_x + 0.5;
else
    curr_x = 0.1; curr_width = 0.85;
end;

axes('Position', [curr_x 0.1 curr_width 0.8]);
graf = plot(xx, yy, '-r'); set(graf, 'LineWidth', 2);hold on;

graf = errorbar(log(bins(1:end-1)), p, stdev, stdev, '.r');
set(graf, 'MarkerSize',10,'LineWidth',2);
set(gca,'XTick', log(bins(1:end-1)),'YTick',0:0.2:1,'YTickLabel',[0:20:100]);
set(gca, 'XTickLabel',bins(1:end-1));

for k = 1:length(bins)-1
    ypos = p(k)+stdev(k)+0.04;
    h = text(log(bins(k))-0.03, ypos, sprintf('%i%%',round(p(k)*100)));
    set(h, 'FontSize',fsize, 'FontWeight','bold');
    if nodist > 0
        h = text(log(bins(k))-0.03, ypos+0.05, sprintf('(%i)', tally(k)));
        set(h, 'FontSize',fsize, 'FontWeight','bold');
    end;
end;

axis([log(binmin)-0.1 log(binmax)+0.1 0 1.1])
t= xlabel('Tone Duration (ms)'); set(t,'FontSize',16,'FontWeight','bold');
t= ylabel('frequency of reporting "Long" (%)'); set(t,'FontSize',16,'FontWeight','bold');
t = title(sprintf('%s: %s (%s to %s): \n[Min,Max] = [%i,%i]ms', make_title(rat), make_title(task), date_set{1}, date_set{end}, binmin, binmax));
set(t, 'FontSize', fsize, 'FontWeight', 'bold');

if nodist > 0
    set(fig,'Position', [225 279 485 435]);
else
    set(fig, 'Position', [225 279 800 419]);
end;


% concatenates rows of the cell and converts them to numbers
function [flat] = flatten_bbspl(mycell)

flat = [];
flat = zeros(size(mycell));
flat(find(strcmpi(mycell, 'normal'))) = 1;
flat(find(strcmpi(mycell, 'Louder'))) = 2;
flat(find(strcmpi(mycell, 'LOUDEST'))) = 3;


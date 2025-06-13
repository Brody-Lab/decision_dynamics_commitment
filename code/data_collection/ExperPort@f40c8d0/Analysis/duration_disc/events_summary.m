function [cpoke_stats apoke_stats] = events_summary(ratname, varargin)
% Analyzes the duration of various trial epochs across sessions.
% In particular, looks at the average duration of wait_for_cpoke (state where rat
% initiates trial) and wait_for_apoke (state where we wait for rat to make
% an answer poke)
% Note: Uses *median* values as the average because distributions are very
% skewed to the right

pairs = { ...

'logdiff', 0; ...       % sessions with sharpening
'use_file', 0 ; ...     % if true, ignore above date-range flags and load data from file
'graphic', 1; ...       % when set to 0, the daily averages will not be plotted
'daily_graphs', 0 ; ... % when set to 1, will show a graph for each day's data
% Which dateset to use?
'infile', 'psych' ; ... % file to look into if "use_file" is set to > 0
'after_psych', 0; ...   % get dates for psych sessions after surgery
'before_psych', 0; ...  % psych sessions before surgery
'from', '000000' ; ...
'to', '999999'; ...
% Which sessions to use? -------------------
'dstart',1 ; ...        % first session in set
'dend', 1000; ...       % last session in set
'lastfew', 1000; ...
'experimenter', 'Shraddha'; ...
};
parse_knownargs(varargin, pairs);

if use_file > 0
    global Solo_datadir;
    if isempty(Solo_datadir), mystartup; end;
    outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ratname filesep];
    fname = [outdir infile '.mat'];

    load(fname);
    fprintf(1,'Loading from file: Dates from %s to %s...\n',dates{1},dates{end});

    % -----------------------------------
    % Variables to filter a range of sessions
    % in your dataset >> BEGIN
    dend = min(dend, rows(dates));
    cumtrials = cumsum(numtrials(1:dend));
    lastidx = cumtrials(end);
    startidx = 1;

    if lastfew < 1000
        lastfew = min(rows(dates), lastfew);
        dstart = rows(dates)-(lastfew-1);
    end;

    if dstart > 1
        startidx= cumtrials(dstart-1) +1;
    end;
    fprintf(1,'*** %s: Date filter: Using %i to %i (%i to %i)\n', mfilename, dstart, dend, startidx, lastidx);
    % << END filtering session dates

    dates = dates(dstart:dend);
    numtrials = numtrials(dstart:dend);
    evs = events(startidx:lastidx);
    fprintf(1,'\tFilter: Using only %s to %s\n', dates{1}, dates{end});

else
    ratrow = rat_task_table(ratname);
    if after_psych > 0
        dates = ratrow{1,5};
        from = dates{1}; to = dates{2};
    elseif before_psych > 0
        dates = ratrow{1,4};
        from = dates{1}; to = dates{2};
    elseif logdiff > 0
        dates = ratrow{1,3};
        from = dates{1}; to = dates{2};
    end;

    fprintf(1,'Using data from %s to %s...\n',from,to);
    datafields = {'events'};
    get_fields(ratname,'from', from, 'to',to,'datafields', datafields);
end;

% metrics from states wait_for_cpoke and wait_for_apoke
% rx2 matrices: r is the date.
% Col 1: average occurrence count for the session
% Col 2: average duration for the session
cpoke_stats=[];
apoke_stats=[];

offset = 1;
for d = 1:length(numtrials)
    [cpoke_meanct cpoke_meandur] = show_state_metrics('wait_for_cpoke', ...
        evs(offset:offset+(numtrials(d)-1)),...
        daily_graphs,dates{d}, ...
        [840 300 300 200]);
    [apoke_meanct apoke_meandur] = show_state_metrics('wait_for_apoke',...
        evs(offset:offset+(numtrials(d)-1)), ...
        daily_graphs,dates{d}, ...
        [200 300 300 200]);

    cpoke_stats = vertcat(cpoke_stats, [cpoke_meanct cpoke_meandur]);
    apoke_stats = vertcat(apoke_stats, [apoke_meanct apoke_meandur]);

    offset = offset+numtrials(d);
end;

if graphic
    figure;
    subplot(2,1,1);
    plot(1:length(cpoke_stats(:,2)), cpoke_stats(:,2),'.g');
    title([ratname ':cpoke dur']);
    set(gca,'XLim',[0 length(cpoke_stats(:,2))+1]);

    subplot(2,1,2);
    plot(1:length(apoke_stats(:,2)), apoke_stats(:,2), '.k');
    title([ratname ':apoke dur']);
    set(gca,'XLim',[0 length(cpoke_stats(:,2))+1]);
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% For given set of trials, returns one number: average set of cpokes
% plots histogram showing # occurrences of wait_for_cpoke stage
function [avg_occur avg_dur] = show_state_metrics(statename, p,graphic,date,figpos)

dur = []; % duration of state occurrence (col 2 is trial #)
ct = []; % count
for r = 1:rows(p)
    ct = horzcat(ct, eval(['rows(p{r}.' statename ')']));
    for j = 1:rows(eval(['p{r}.' statename]))
        tmp = eval(['p{r}.' statename '(j,:)']);
        dur = vertcat(dur, [tmp(1,2) - tmp(1,1) r]);

    end;
end;

% Filter out durations longer than specified time
% idx = find(dur > 20);
% dur = setdiff(dur, dur(idx));

statestr = statename;
idx = find(statestr == '_');
statestr(idx) = ' ';



if graphic > 0
    figure;
    % Plot histogram of # occurrences of the state in a trial
    subplot(1,2,1);
    hist(dur(:,1));
    blah=findobj(gcf,'Type','patch');
    set(blah,'Facecolor','r');
    title([date ': "' statestr '"' ': Distribution of # occurrences per trial']);

    % Plot state duration as function of trial #
    subplot(1,2,2);
    plot(dur(:,2), dur(:,1),'.b');
    ylabel('Time (seconds)');
    xlabel('Trial #');
    title([date ': "' statestr '"' ' state duration']);
    set(gcf,'Position',figpos);
end;

avg_occur = mean(ct);
avg_dur = median(dur(:,1));

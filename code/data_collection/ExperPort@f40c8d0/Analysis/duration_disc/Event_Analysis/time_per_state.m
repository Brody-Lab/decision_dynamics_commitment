function [] = time_per_state(ratname,from,to,varargin)
% returns a pie chart showing distribution of trial time in various states.


pairs = { ...
    'plot_avgtime',1 ; ...% plots stats for avg. time spent in each state
    'pies_only', 1; ...
    'plot_totaltime', 1 ; ... % plots state for total time spent in each state
    };
parse_knownargs(varargin,pairs);

% from = getdate(f);
% to = getdate(t);

dates = get_files(ratname, 'fromdate',from, 'todate',to);


% curr = p{1};
% f = fieldnames(curr);
% for m = 1:length(f)
%     eval(['times.' f{m} ' = [];']);
% end;


r = rat_task_table(ratname);
task = r{1,2};

times =  state_times(ratname, from,to);

if strcmpi(task(1:3),'dur')
    plot_states = {'wait_for_cpoke','wait_for_apoke', 'pre_chord','chord','cue', ...
        'iti','timeout','drink_time','dead_time','extra_iti'};
else
    plot_states =  {'wait_for_cpoke','wait_for_apoke', ...
        'iti','drink_time','dead_time','extra_iti'};
end;

% average duration of each state
durations = [];
total_time = [];
for k = 1:length(plot_states)
    if isfield(times,plot_states{k})
    eval(['tmp = times.' plot_states{k} ';']);
    tmp1 = mean(tmp(:,2)-tmp(:,1));
    eval(['durations.' plot_states{k} ' = tmp1;']);

    tmp2 = sum(tmp(:,2)-tmp(:,1));
    eval(['total_time.' plot_states{k} ' = tmp2;']);
    end;
end;

% lump reward states
tmp = [ times.left_reward; times.right_reward];
tmp1 = mean(tmp(:,2)-tmp(:,1));
durations.reward = tmp1;
tmp2 = sum(tmp(:,2)-tmp(:,1));
total_time.reward = tmp2;

% lump trial time
tmp = times.pre_chord;
tmp1 = mean(tmp(:,2)-tmp(:,1));
tmp1b = sum(tmp(:,2)-tmp(:,1));
tmp = times.chord;
tmp2 = mean(tmp(:,2)-tmp(:,1));
tmp2b = sum(tmp(:,2)-tmp(:,1));
tmp = times.cue;
tmp3 = mean(tmp(:,2)-tmp(:,1));
tmp3b = sum(tmp(:,2)-tmp(:,1));

tmp = tmp1+tmp2+tmp3; % sum of the average of the pre-chord and chord states
durations.trial_time = tmp;
tmp = tmp1b+tmp2b+tmp3b; % total time spent doing the trial
total_time.trial_time = tmp;

durations = orderfields(durations);
total_time = orderfields(total_time);
titles = fieldnames(durations);
n = cell2mat(struct2cell(durations));
n_total = cell2mat(struct2cell(total_time)) / (60 * 60); % total times shown in hours

lbls_duration = {};
for k = 1:length(titles),
    tmp = strrep(titles{k},'_',' ');
    titles{k} = tmp;
    lbls_duration{k} = sprintf('%s (%i%%)',tmp, round((n(k)/sum(n)) * 100));
end;
lbls_total = {};
for k = 1:length(titles),
    lbls_total{k} = sprintf('%s (%i%%)',titles{k}, round((n_total(k)/sum(n_total)) * 100));
end;


% Figure 1: Show AVERAGE DURATION OF A STATE
% -------------------------------------------

if plot_avgtime > 0
    figure;
    if pies_only < 1
        subplot(2,1,1);
    end;
    % pie chart
    maxidx = find(n == max(n)); xplode = zeros(size(n)); xplode(maxidx) =1;

    p = pie(n,xplode,lbls_duration);
    toppos = 0.5;% get(gcf,'Position'); toppos = (toppos(2) + toppos(4)) - (0.25 * toppos(4));
    for k = 2:2:length(p),
        set(p(k-1), 'EdgeColor','none');
        set(p(k),'FontWeight','bold','FontSize',12);%'Position',[-2 toppos 0]);
        toppos = toppos - 0.3;
    end;
    s = sprintf('%s: %s (%s)\nWhich states does he spend his time in?.', make_title(ratname), make_title(task), date);
    t= title(s); set(t,'FontSize', 16);
    set(gcf,'Position',[10 50 700 650],'Menubar','none','Toolbar','none');
    colormap summer;

    if pies_only < 1
        subplot(2,1,2);
        bar(1:length(n), n);
        set(gca,'XTick',1:length(n), 'XTickLabel',titles);
        ylabel('seconds');
        xlabel('states');
        s = sprintf('%s: %s (%s)\nAverage time per state', make_title(ratname), make_title(task), date);
        t= title(s); set(t,'FontSize', 16);
        colormap summer;
    end;
end;

% Figure 2: Show TOTAL TIME SPENT IN A STATE
% -------------------------------------------

if plot_totaltime
    figure;
    if pies_only<1
        axes('Position',[0.3 0.45 0.4 0.5])
    end;
    % pie chart
    maxidx = find(n_total == max(n_total)); xplode = zeros(size(n_total)); xplode(maxidx) =1;
    p = pie(n_total,xplode,lbls_total);
    for k = 2:2:length(p),
        set(p(k-1), 'EdgeColor','none');
        set(p(k),'FontWeight','bold','FontSize',12);
    end;
    s = sprintf('%s: %s (%s)\nWhich states does he spend his time in (total)?.', make_title(ratname), make_title(task), date);
    t= title(s); set(t,'FontSize', 16);
    set(gcf,'Position',[10 50 700 650],'Menubar','none','Toolbar','none');
    colormap summer;

    if pies_only < 1
        axes('Position',[0.05 0.1 0.85 0.3]);
        bar(1:length(n_total), n_total);
        set(gca,'XTick',1:length(n_total), 'XTickLabel',titles);
        ylabel('hours');
        xlabel('states');
        s = sprintf('%s: %s (%s)\nTotal time per state', make_title(ratname), make_title(task), date);
        t= title(s); set(t,'FontSize', 16);
        colormap summer;
    end;
end;
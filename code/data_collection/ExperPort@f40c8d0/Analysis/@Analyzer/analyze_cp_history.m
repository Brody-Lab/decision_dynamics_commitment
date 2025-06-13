function [ana] = analyze_cp_history(ana, varargin)

% ro_args:
% PreSoundMeanTime, SoundDur, Delay, Del2Cd_Mean
%   nCenterPokes: Number of center pokes so far
%   CenterPokeTimes: Time of each center poke (sec)
%   CenterPokeDurations: Duration of each center poke
%   CenterPokeStateHist: Which state was CenterPokeTimes(i) made in?
%   LastCPokeMins: Time between current cin and last cout
% Base State
% Update:   SSP     092605      Method should no longer need
% PreSoundMeanTime, SoundDur, Delay, nor Del2Cd_Mean

GetSoloFunctionArgs;

FIG_WIDTH = 550;
FIG_HEIGHT = 250;
FIG_X = 500;
FIG_Y = 500;

pairs = {'calling_ctrl', 'start';};
parse_knownargs(varargin, pairs);

% Set up figure
me = lower(mfilename);
fig_name = [ 'fig_' me ];
fig = findobj('Tag', fig_name);

my_owner = determine_owner;
my_funcname = determine_fullfuncname;

if isempty(fig)
    fig = figure('Tag', fig_name, 'Position', [FIG_X FIG_Y FIG_WIDTH FIG_HEIGHT], ...
        'Toolbar', 'none', 'Menubar', 'none', ...
        'Name', 'Center Poke History');

    % Initialise plot
    u = find(CenterPokeTimes(nCenterPokes) - CenterPokeTimes < LastCpokeMins*60  &  ...
        CenterPokeDurations>0);
    from = min(CenterPokeTimes(u))-1;       to  = max(CenterPokeTimes(u))+1;

    % textbox controls
    starttime = EditParam(obj, 'startTime', from, 50, FIG_HEIGHT-25, ...
        'TooltipString', 'Start Time', 'label', 'Start Time (s)', ...
        'labelpos', 'left');
    set_callback(starttime, {'analyze_cp_history', 'start'});

    endtime = EditParam(obj, 'endTime', to, 250, FIG_HEIGHT-25, ...
        'TooltipString', 'End Time', 'label', 'End Time (s)', ...
        'labelpos', 'left');
    set_callback(endtime,{'analyze_cp_history', 'end'});

    % Add above textboxes to functions r/w list
    %SoloFunctionAddRWArgs(my_owner, me, {starttime, endtime});

    h = axes('Position', [0.3 0.25 0.6 0.5]);
    set(h, 'Tag', 'CenterPokesPlot');
    xlabel('Time (s)');
    ylabel('CPoke Duration (red: Base State)');

    %vpd = PreSoundMeanTime + 2*SoundDur + Delay + Del2Cd_Mean;
    %l = line([0 100], [vpd vpd]);
    %set(l, 'Color', 0.8*[1 1 1], 'Tag', 'vpdline');

    pd = line([0], [0]);
    set(pd, 'Color', 'k', 'Marker', '.', 'LineStyle', '-', 'Tag', 'pdline');

    r = line([0], [0]);
    set(r, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none', 'Tag', 'rline');
    %axis([0 100 0 1.5*vpd]);
    %set(h, 'YAxisLocation', 'right');

    h2 = axes('Position', [0.1 0.25 0.17 0.5]);
    set(h2, 'Tag', 'CenterPokesHist', 'XLim', [0 0.95], 'YLim', [0 1]);
    xlabel(h2, 'Percentile')
    ylabel(h2, 'CPoke duration (s)')
end;


% Now fill in the data
h     = findobj(fig, 'Tag', 'CenterPokesPlot');
h2    = findobj(fig, 'Tag', 'CenterPokesHist');

if ~isempty(h) | ~isempty(h2),

    u = find(CenterPokeTimes(nCenterPokes) - CenterPokeTimes < LastCpokeMins*60  &  ...
        CenterPokeDurations>0);

    from = value(startTime);
    to = value(endTime);
    view_time = to - from + 1;

    if strcmpi(calling_ctrl,'start')
        min_val = min(abs(CenterPokeTimes(1:nCenterPokes) - value(startTime)));
        ind = min(find(abs(CenterPokeTimes(1:nCenterPokes) - value(startTime)) == min_val));

        u = find(CenterPokeTimes - CenterPokeTimes(ind) < view_time  &  ...
            CenterPokeDurations>0);
        
      %      to = value(startTime)+LastCpokeMins*60;

    elseif strcmpi(calling_ctrl, 'end')
        min_val = min(abs(CenterPokeTimes(1:nCenterPokes) - value(endTime)));
        ind = find(abs(CenterPokeTimes(1:nCenterPokes) - value(endTime)) == min_val);
        
        u = find(CenterPokeTimes(ind) - CenterPokeTimes < view_time  &  ...
            CenterPokeDurations>0);
        
      %      from = value(endTime)-LastCpokeMins*60;
    else
        error('Invalid mode: %s', calling_ctrl);
    end;
end;

if ~isempty(h),
    %vline = findobj(h, 'Tag', 'vpdline');
    pline = findobj(h, 'Tag', 'pdline');
    rline = findobj(h, 'Tag', 'rline');

    if length(u)>0,
        set(pline, 'XData', CenterPokeTimes(u), 'YData', CenterPokeDurations(u));

        bot  = min(CenterPokeDurations(u))*0.9; top = max(CenterPokeDurations(u))*1.1;
        set(h, 'XLim', [from to], 'YLim', [bot top]);

        red_u = find(CenterPokeStateHist(u) == BaseState);
        set(rline, 'XData', CenterPokeTimes(u(red_u)), 'YData', CenterPokeDurations(u(red_u)));
     %   vpd = PreSoundMeanTime + 2*SoundDur + Delay + Del2Cd_Mean;
     %   set(vline, 'XData', [from to], 'YData', [vpd vpd]);

    end;
    set(h, 'YAxisLocation', 'right');
    xlabel('Time (s)');
    ylabel('CPoke Duration (red: Base State)');
end;

if ~isempty(h2) & length(u) > 1,
    axes(h2);
    n = CenterPokeDurations(u);  [n, x] = hist(n, 0:0.001:max(n)); n = 100*cumsum(n)/length(u);
    plot(n, x); set(h2, 'Tag', 'CenterPokesHist');
    xlabel(h2, 'Percentile')
    ylabel(h2, 'CPoke duration (s)')
    gridpts = [0 25 50 75 95]; % must always contain 0
    set(gca, 'XTick', gridpts, 'XGrid', 'on', 'Xlim', gridpts([1 end]));

    p = zeros(size(gridpts)); p(1) = 1; empty_flag = 0;
    for i=2:length(gridpts),
        z = max(find(n <= gridpts(i)));
        if isempty(z), empty_flag = 1;
        else p(i) = z;
        end;
    end;
    if ~empty_flag,
        if min(diff(x(p)))>0, set(gca, 'YTick', x(p), 'Ygrid', 'on', 'YLim', x(p([1 end]))); end;
    end;
    
    
end;

b= PushbuttonParam(obj, 'closer', FIG_WIDTH/2-50, 10, 'label', 'Close me');
set(get_ghandle(b), 'Callback', 'close');


return;

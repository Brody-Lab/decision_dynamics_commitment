function [x, y] = CurrentTrialPokesSubsection(obj, action, x, y)
%
% [x, y] = InitPoke_Measures(x, y, obj)
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%

GetSoloFunctionArgs;
%  SoloFunction('CurrentTrialPokesSubsection', ...
%        'ro_args', {'LastTrialEvents', 'RealTimeStates', 'n_started_trials'});

switch action,
    case 'init',  % ---------- CASE INIT ----------

        fig = gcf; % This is the protocol's main window, to which we add a menu:
        MenuParam(obj, 'CurrentTrialPokes', {'hidden', 'view'}, 2, x, y); next_row(y);

        next_row(y,0.5);
        SubheaderParam(obj, 'pk_sbh', 'Poke Measures & History', x, y);next_row(y);

        set_callback(CurrentTrialPokes, ...
            {'CurrentTrialPokesSubSection', 'view'});

        % Now make a figure for our Pokes Plot:
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
        screen_size = get(0, 'ScreenSize');
        set(value(myfig),'Position',[1 350, 400 613]); 
        set(value(myfig), ...
            'Visible', 'on', 'MenuBar', 'none', 'Name', 'Pokes Plot', ...
            'NumberTitle', 'off', 'CloseRequestFcn', ...
            ['CurrentTrialPokesSubSection(' class(obj) '(''empty''), ''hide'')']);



        % UI param that controls what t=0 means in pokes plot:
        SoloParamHandle(obj, 'alignon', 'label', 'alignon', 'type', 'menu', 'string', ...
            {'base state', '1st Cpoke', 'wait_for_apoke', ...
            '1st Side poke', 'Outcome'}, ...
            'position', [1 1 160 20], 'value', 1);
        set_callback(alignon, {'CurrentTrialPokesSubSection', 'alignon'});

        % Left edge of pokes plot:
        SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
            'position', [165 1 60 20], 'ToolTipString', ...
            'time axis left edge');
        % Right edge of pokes plot:
        SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
            'position', [230 1 60 20], 'ToolTipString', ...
            'time axis right edge');
        % Choosing to display last n trials or specifying start and ending trials
        SoloParamHandle(obj, 'trial_limits', 'type', 'menu', 'label', 'trials:', ...
            'string', {'last n', 'from, to'}, 'value', 1, ...
            'position', [105 22 140 20], 'labelpos', 'left', ...
            'TooltipString', ['Show latest trials vs show specific ' ...
            'set of trials']);
        set_callback(trial_limits, { ...
            'CurrentTrialPokesSubsection', 'trial_limits' ; ...
            'CurrentTrialPokesSubsection', 'redraw'});

        SoloParamHandle(obj, 'hide_hist','type','menu', 'label', 'Histogram', ...
            'string', {'hide','show'}, 'value', 2, ...
            'position', [1 22 140 20], 'labelpos', 'right',...
            'TooltipString', 'Hides or shows histogram of center poke distribution');
        set_callback(hide_hist, { ...
            'CurrentTrialPokesSubsection', 'hide_cpoke_hist' ; ...
            'CurrentTrialPokesSubsection', 'redraw'});

        % For last n trials case:
        SoloParamHandle(obj, 'ntrials', 'label', 'ntrials', ...
            'type','numedit','value',25, ...
            'position', [250 22 80 20], 'TooltipString', ...
            'how many trials to show');
        % start_trial, for from, to trials case:
        SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
            'value', 1, 'position', [250 22 60 20]);
        % end_trial, for from, to trials case:
        SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
            'value', 15, 'position', [315 22 60 20]);
        set([get_ghandle(ntrials);get_lhandle(ntrials)], 'Visible', 'off');

        % Manual redraw:
        PushbuttonParam(obj, 'redraw', 295, 1, 'position', [295 1 100 20]);
        set_callback({t0;t1;ntrials;redraw;start_trial;end_trial}, ...
            {'CurrentTrialPokesSubSection', 'redraw'});


        % An axis for the pokes plot:
        SoloParamHandle(obj, 'axpatches', 'saveable', 0, ...
            'value', axes('Position', [0.1 0.39 0.8 0.59]));
        xlabel('secs'); ylabel('trials'); hold on;
        set(value(axpatches), 'Color', 0.3*[1 1 1]);

        % get state names and colours
        [SC, plottables] = state_colors(obj);
        SoloParamHandle(obj, 'SC', 'value', SC);
        SoloParamHandle(obj, 'plottables', 'value', plottables);

        % An axis for the histogram of center pokes:
        SoloParamHandle(obj, 'room','value', 0.2);
        SoloParamHandle(obj, 'axhist', 'saveable', 0, ...
            'value', axes('Position', [0.15 0.22 0.7 0.1]));
        ylabel('n Center pokes'); hold on;
        % Variable that'll hold accumulated cpoke statistics:
        SoloParamHandle(obj, 'cpokestats', 'value', ...
            compile_cpoke_stats([], RealTimeStates));
        % Variable holding graphics handles for the cpoke histogram patches:
        SoloParamHandle(obj, 'histhandles', ...
            'value', hist_cpoke_stats_SC(cpokestats,'SC', value(SC), 'plottables', value(plottables)), ...
            'saveable', 0);

        SoloParamHandle(obj, 'realign', 'value', 0); % default - set to 1 when loading realigned data

        % An axis for the color codes and labels:
        SoloParamHandle(obj, 'axhistlabels', 'saveable', 0, ...
            'value', axes('Position', [0.15 0.2 0.7 0.015]));
        hist_cpoke_stats_SC('make_labels', 'SC', value(SC), 'plottables', value(plottables));

        figure(fig); % After finishing with our fig, go back to whatever was
        % the current fig before.

        CurrentTrialPokesSubsection(obj,'hide_cpoke_hist');
        
    case 'update_events',
        Event = GetParam('rpbox', 'event', 'user');
        LastTrialEvents.value = [value(LastTrialEvents) ; Event];
        
        CurrentTrialPokesSubsection(obj, 'update');

    case 'update', % ------ CASE UPDATE
                
        if strcmp(value(CurrentTrialPokes), 'view'),
            if n_started_trials > 0,
                plot_single_trial(value(LastTrialEvents), RealTimeStates, ...
                    value(n_done_trials), value(alignon), value(axpatches), ...
                    'custom_colors', value(SC), 'plottables', value(plottables));
                switch value(trial_limits),
                    case 'last n',
                        bot  = max(0, n_started_trials-ntrials);
                        dtop = bot+ntrials;
                    case 'from, to',
                        bot  = value(start_trial)-1;
                        dtop = value(end_trial);
                    otherwise error('whuh?');
                end;
                set(value(axpatches), 'Ylim',[bot, dtop], ...
                    'Xlim', [value(t0), value(t1)]);
            end;
        end;

    case 'redraw', % ------- CASE REDRAW

        % Check that trial limits are sane
        if start_trial<1, start_trial.value = 1; end;
        if end_trial<start_trial, end_trial.value = start_trial+1; end;
        if ntrials<1, ntrials.value = 1; end;

        % Ok, on with redrawing
        if strcmp(value(CurrentTrialPokes), 'view'),
            if n_started_trials >= 1,
                delete(get(value(axpatches), 'Children'));
                LHistory = [get_history(LastTrialEvents); {value(LastTrialEvents)}];
                if value(realign)>0
                    RHistory = [RealTimeStates_history; {RealTimeStates}];
                else
                    RHistory = RealTimeStates_history;
                end;
                switch value(trial_limits),
                    case 'last n',
                        bot  = max(0, length(LHistory)-ntrials);
                        dtop = bot+ntrials;
                    case 'from, to',
                        bot  = value(start_trial)-1;
                        dtop = value(end_trial);
                    otherwise error('whuh?');
                end;
                ttop = min([dtop, length(LHistory), length(RHistory)]);
                plot_many_trials(LHistory(bot+1:ttop), RHistory(bot+1:ttop), ...
                    bot, value(alignon), value(axpatches), 'custom_colors', value(SC), 'plottables', value(plottables));
                % for i=bot+1:ttop,
                % plot_single_trial(LHistory{i}, RHistory{i}, i-1, value(alignon),...
                % value(axpatches));
                % end;
                set(value(axpatches), 'Ylim',[bot, dtop], ...
                    'Xlim', [value(t0), value(t1)]);

                if iscell(RHistory) && all(size(LHistory)==size(RHistory)),
                    cpokestats.value = compile_cpoke_stats(LHistory, RHistory);
                    hist_cpoke_stats_SC(cpokestats, 'handles', value(histhandles), 'SC', value(SC), 'plottables', value(plottables));
                end;
                drawnow;
            end;
        end;
    case 'alignon',  % ---- CASE ALIGNON
        switch value(alignon),
            case 'base state',    t0.value = -3;   t1.value = 25;
            case '1st Cpoke',     t0.value = -4;   t1.value = 15;
            case 'wait_for_apoke',t0.value = -9;   t1.value = 11;
            case '1st Side poke', t0.value = -10;  t1.value = 9;
            case 'Outcome',       t0.value = -14;  t1.value = 5;
            otherwise,
        end;
        CurrentTrialPokesSubsection(obj, 'redraw');


    case 'view', % ------ CASE VIEW
        switch value(CurrentTrialPokes),
            case 'hidden', set(value(myfig), 'Visible', 'off');
            case 'view',
                set(value(myfig), 'Visible', 'on');
                CurrentTrialPokesSubsection(obj, 'redraw');
        end;

    case 'hide', % ------ CASE HIDE
        CurrentTrialPokes.value = 'hidden';
        set(value(myfig), 'Visible', 'off');


    case 'reinit',  % ----  CASE REINIT
        delete(value(myfig));
        delete_sphandle('handlelist', ...
            get_sphandle('owner', class(obj), 'fullname', mfilename));
        CurrentTrialPokesSubsection(obj, 'init', 372, 261);
        CurrentTrialPokesSubsection(obj, 'redraw');


    case 'trial_limits', % ----  CASE TRIAL_LIMITS
        switch value(trial_limits),
            case 'last n',
                set([get_ghandle(ntrials);    get_lhandle(ntrials)],    'Visible', 'on');
                set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','off');
                set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','off');

            case 'from, to',
                set([get_ghandle(ntrials);    get_lhandle(ntrials)],    'Visible','off');
                set([get_ghandle(start_trial);get_lhandle(start_trial)],'Visible','on');
                set([get_ghandle(end_trial);  get_lhandle(end_trial)],  'Visible','on');

            otherwise
                error(['Don''t recognize this trial_limits val: ' value(trial_limits)]);
        end;
        drawnow;

    case 'delete', % ------------ case DELETE ----------
        delete(value(myfig));

    case 'set_realign',
        realign.value = 1;
    case 'clear_realign',
        realign.value = 0;
    case 'hide_cpoke_hist'
        if strcmpi(value(hide_hist), 'hide')
            set(value(axhist),                        'Visible','off');
            set(get(value(axhist),       'Children'), 'Visible','off');
            set(get(value(axhistlabels), 'Children'), 'Visible','off');

            poke_pos = get(value(axpatches), 'Position');
            hist_pos = get(value(axhist),    'Position');
            set(value(axpatches),'Position', ...
                              [poke_pos(1) hist_pos(2)-0.1 poke_pos(3) ...
                               1-hist_pos(2)+0.05]);
        else
            set(value(axhist),                       'Visible', 'on');
            set(get(value(axhist),       'Children'), 'Visible','on');
            set(get(value(axhistlabels), 'Children'), 'Visible','on');

            poke_pos = get(value(axpatches), 'Position');
            hist_pos = get(value(axhist),    'Position');
            set(value(axpatches),'Position', ...
                              [poke_pos(1) hist_pos(2)+hist_pos(4)+0.05 ...
                               poke_pos(3) 1-hist_pos(2)-hist_pos(4)-0.1]);

        end;

    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;





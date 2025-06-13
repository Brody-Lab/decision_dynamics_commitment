function [] = pokeviewer(ratname, indate, action,varargin)

pairs = {'classical',0; };
parse_knownargs(varargin,pairs);


persistent fig;
persistent LastTrialEvents RealTimeStates;
persistent task;
persistent SC  plottables  n_started_trials;
%persistent alignon, t0,t1, ntrials, start_trial, end_trial;


switch action,
    case 'init',  % ---------- CASE INIT ----------

        f = findobj('Tag','pokeviewer');
        if ~isempty(f)
            for k = 1:length(f), close(f(k)); end;
        end;

        load_datafile(ratname, indate,'','classical',classical);
        fprintf(1,'Loading %s for %s ...\n',indate, ratname);
        ratrow = rat_task_table(ratname);
        task = ratrow{1,2};
                
        if classical > 0
            task = 'classical2afc_soloobj';
        end;


        eval(['LastTrialEvents = saved_history.' task '_LastTrialEvents;']);
        if classical > 0
         RealTimeStates = saved_history.make_and_upload_state_matrix_RealTimeStates;
        else
        eval(['RealTimeStates = saved_history.' task '_RealTimeStates;']);
        end;
        eval(['n_started_trials = saved.' task '_n_done_trials;']);


        fig = figure;
        screen_size = get(0, 'ScreenSize');

        set(gcf,'Tag','pokeviewer','Position',[1 screen_size(4)-700, 400 540],  'MenuBar', 'none', 'Name', 'Pokes Plot', ...
            'NumberTitle', 'off','Name', sprintf('%s: %s',ratname, indate));

        % UI param that controls what t=0 means in pokes plot:
        tmp = {'base state', '1st Cpoke', 'wait_for_apoke','Outcome'};
        sub__mkcontrl('alignon',[1 1 100 20],'popupmenu',1,tmp,{'pokeviewer','alignon'});

        % Left edge of pokes plot:
        sub__mkcontrl('t0', [165 1 30 20],'edit', -20, -20,{'pokeviewer','redraw'});
        %         % Right edge of pokes plot:
        sub__mkcontrl('t1',[230 1 30 20], 'edit',40,40,{'pokeviewer','redraw'});
        %         % Choosing to display last n trials or specifying start and ending trials
        sub__mkcontrl('trial_limits',[1 22 100 20], 'popupmenu',1, {'last n', 'from, to'},{'pokeviewer','trial_limits'});
        %         % For last n trials case:
        sub__mkcontrl('ntrials',[150 22 30 20], 'edit', 100, 100,{'pokeviewer','redraw'});
        %         % start_trial, for from, to trials case:
        sub__mkcontrl('start_trial',[230 22 30 20], 'edit', 1, 1,{'pokeviewer','redraw'});

        %         % end_trial, for from, to trials case:
        sub__mkcontrl('end_trial',[315 22 30 20], 'edit', 25, 25,{'pokeviewer','redraw'});

        %
        %         % An axis for the pokes plot:
        axes('Position', [0.1 0.15 0.8 0.8],'Tag','axpatches','Color',0.3*[1 1 1]);
        %         SoloParamHandle(obj, 'axpatches', 'saveable', 0, ...
        %             'value', axes('Position', [0.1 0.39 0.8 0.59]));
        xlabel('secs'); ylabel('trials'); hold on;
        %         set(value(axpatches), 'Color', 0.3*[1 1 1]);
        %
        %         % get state names and colours
        % Colors that the various states take when plotting
        SC = struct( ...
            'wait_for_cpoke',  'w',              ...
            'wait_for_apoke',  [0.7 0.7 0.95],   ...
            'left_reward',     [0.5 0.9 0.5],    ...
            'right_reward',    [0.5 0.9 0.5],    ...
            'drink_time',      [0.5 0.9 0.5],    ...
            'left_dirdel',     [0.5 0.9 0.5],    ...
            'right_dirdel',    [0.5 0.9 0.5],    ...
            'pre_chord',       [0.7 0.7 0.7],    ...
            'chord',           [0.28 0.28 0.7],  ...
            'timeout',         [0.6 0.12 0.12],  ...
            'iti',             [0.7 0.7 0.7],    ...
            'dead_time',       [1 0.75 0.75],    ...
            'state35',         [0.3 0.3 0.3],    ...
            'extra_iti',       [0.9 0 0],  ...
              'drink_grace', [1 0.2 0.2], ...
            'pre_go',   [0.7 0.7 0.7],    ...
                    'cue',      [0.6 0.4 1] ...
              );


        % Which states to plot, together with which event indices indicate an
        % exit from that type of state
        plottables = { ...
            'dead_time'          1:7   ; ...
            'wait_for_cpoke'     1:6   ; ...
            'pre_chord'          1:7   ; ...
            'chord'              1:7   ; ...
            'wait_for_apoke'     1:6   ; ...
            'left_reward'        1:7   ; ...
            'right_reward'       1:7   ; ...
            'drink_time'         1:7   ; ...
            'timeout'            1:7   ; ...
            'extra_iti'          1:7   ; ...
            'iti'                1:7   ; ...
              'drink_grace', 1:7 ; ...
              'cue', 1:7 ; ...
              'pre_go', 1:7 ; ...
              
            };

        pokeviewer(ratname,indate,'redraw');
        pokeviewer(ratname,indate,'trial_limits');
    case 'update', % ------ CASE UPDATE
        ax = findobj('Tag','axpatches');
        tmp = findobj('Tag','alignon'); v=get(tmp,'value'); s = get(tmp,'string'); alignon = s{v};
        tmp = findobj('Tag','start_trial'); start_trial=str2double(get(tmp,'string'));
        tmp = findobj('Tag','end_trial'); end_trial=str2double(get(tmp,'string'));
        tmp = findobj('Tag','ntrial'); ntrial=str2double(get(tmp,'string'));
        tmp = findobj('Tag','trial_limits'); trial_limits=get(tmp,'value');
        tmp = findobj('Tag','t1'); t1=str2double(get(tmp,'string'));
        tmp = findobj('Tag','t0'); t0=str2double(get(tmp,'string'));

        plot_single_trial(LastTrialEvents, RealTimeStates, ...
            n_started_trials-1, alignon,ax, ...
            'custom_colors', SC, 'plottables', plottables);
        switch trial_limits,
            case 'last n',
                bot  = max(0, n_started_trials-ntrials);
                dtop = bot+ntrials;
            case 'from, to',
                bot  = start_trial-1;
                dtop = end_trial;
            otherwise error('whuh?');
        end;
        set(ax, 'Ylim',[bot, dtop],'Xlim', [t0, t1]);

    case 'redraw', % ------- CASE REDRAW
        ntrials = str2double(get(findobj('Tag','ntrials'),'string'));
        % Ok, on with redrawing
        if n_started_trials >= 1,
            delete(get(findobj('Tag','axpatches'), 'Children'));
            LHistory = LastTrialEvents;
            RHistory = RealTimeStates;
            switch get(findobj('Tag','trial_limits'),'value')
                case 1,
                    bot  = max(0, length(LHistory)-ntrials);
                    dtop = bot+ntrials;


                case 2,
                    st = str2double(get(findobj('Tag','start_trial'),'string'));
                    et = str2double(get(findobj('Tag','end_trial'),'string'));
                    ntrials = str2double(get(findobj('Tag','ntrials'),'string'));

                    if st > et,
                        et = st + min(ntrials, (n_started_trials-st)+1);
                        set(findobj('Tag','end_trial'), 'string', et);
                    end;
                    bot  = st-1;
                    dtop =et;
                otherwise error('whuh?');
            end;



            ttop = min(dtop, length(LHistory));
            a = findobj('Tag','alignon'); v = get(a,'value'); s = get(a,'String'); alignon = s{v};
            plot_many_trials(LHistory(bot+1:ttop), RHistory(bot+1:ttop), ...
                bot, alignon, findobj('Tag','axpatches'), 'custom_colors', SC, 'plottables', plottables);
            t0 = str2double(get(findobj('Tag','t0'),'string'));
            t1 = str2double(get(findobj('Tag','t1'),'string'));
            set(findobj('Tag','axpatches'), 'Ylim',[bot, dtop], ...
                'Xlim', [t0, t1]);
            
            yl=get(gca,'YLim');
             set(gca,'YTick', yl(1)+0.5:1:yl(2)+0.5,'YTickLabel', yl(1)+1:yl(2)+1);


            drawnow;

        end;
    case 'alignon',  % ---- CASE ALIGNON
        a = findobj('Tag','alignon'); v = get(a,'Value'); s = get(a,'String');tmp = s{v};
        t0 = findobj('Tag','t0');
        t1 = findobj('Tag','t1');

        switch tmp
            case 'base state',    set(t0,'string',-3);   set(t1,'string',25);
            case '1st Cpoke',     set(t0,'string',-4);   set(t1,'string',15);
            case 'wait_for_apoke',set(t0,'string',-9);   set(t1,'string',11);
            case 'Outcome',       set(t0,'string',-14);  set(t1,'string',5);
            otherwise,
        end;
        pokeviewer(0,0, 'redraw');

    case 'reinit',  % ----  CASE REINIT
        delete(fig);
        pokeviewer(obj, 'init', 372, 261);

    case 'trial_limits', % ----  CASE TRIAL_LIMITS
        switch get(findobj('Tag','trial_limits'), 'value'),
            case 1,
                set(findobj('Tag','ntrials'),   'Enable', 'on');
                set(findobj('Tag','start_trial'),'Enable','off');
                set(findobj('Tag','end_trial'), 'Enable','off');

            case 2,
                set(findobj('Tag','ntrials'),  'Enable', 'off');
                set(findobj('Tag','start_trial'),'Enable','on');
                set(findobj('Tag','end_trial'), 'Enable','on');
            otherwise
                error(['Don''t recognize this trial_limits val: ' value(trial_limits)]);
        end;
        drawnow;
        pokeviewer('','', 'redraw');

    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;



% makes uicontrol and label
function [] = sub__mkcontrl(tag, pos, type, val, strg,cbk)
uicontrol(gcf,'position',pos,'Style', type,'value',val,'Tag',tag,'BackgroundColor',[1 1 1],'String', strg,'Callback',cbk);
uicontrol(gcf,'position',[pos(1)+pos(3)+2 pos(2) 50 20],'STyle','text','String', tag);

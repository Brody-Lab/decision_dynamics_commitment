function [x, y] = SidesSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

MAX_TRIALS = 3000;
MAX_CLASSES = 30;

switch action
    %% case init
    case 'init',
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'saveable', 0);
        
        % Non-gui spms:
        SoloParamHandle(obj, 'ntrials_ll_default','value',1);
        SoloParamHandle(obj, 'ntrials_ul_default','value',40);
        SoloParamHandle(obj, 'ntrials_default','value',25);
        SoloParamHandle(obj, 'ntrials_ll','value',1);
        SoloParamHandle(obj, 'ntrials_ul','value',value(n_done_trials));
        
        % Choosing to display last n trials or specifying start and ending trials
        % For last n trials case:
        SoloParamHandle(obj, 'ntrials', 'label', 'ntrials', 'type','numedit','value',value(ntrials_default), ...
            'position', [x y 80 20], 'TooltipString', 'how many trials to show');
        % start_trial, for from, to trials case:
        SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
            'value', value(ntrials_ll_default), 'position', [x y 60 20]);
        % end_trial, for from, to trials case:
        SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
            'value', value(ntrials_ul_default), 'position', [x+70 y 60 20]); next_row(y);
        set([get_glhandle(start_trial);get_glhandle(end_trial);get_glhandle(ntrials)], 'Visible', 'off'); %#ok<NODEF>
        MenuParam(obj, 'trial_limits', {'all', 'last n', 'from, to'}, 'all', x,y,'position', [x y 180 20], 'label', 'trials:', ...
                'labelpos', 'left', 'TooltipString', 'Show latest trials vs show specific set of trials'); next_row(y);

        DispParam(obj, 'LastSide', 'none', x, y, 'TooltipString', 'Last intended side'); next_row(y);
        DispParam(obj, 'LastTrialClass', 'none', x, y); next_row(y);
        ToggleParam(obj, 'intent_motoract', 1, x, y, 'OnString', 'Showing Intent', ...
            'OffString', 'Showing Motor Act'); next_row(y);
        
        HeaderParam(obj, 'SidesSectionHeader', 'SidesSection', x, y, ...
            'position', [x y 200 20]); next_row(y);
        
        
        % We'll init as if nClasses were 1; we'll change to the real number
        % of nClasses later: when TrialsSection inits, it does the callback
        % for nClasses which in turns calls SidesSection(obj,'change_nClasses');
        
        fpos = get(gcf, 'Position');
        SoloParamHandle(obj, 'myax', 'value', axes('Units', 'pixels'), 'TickDir', 'out', 'saveable', 0);
        set(value(myax), 'Position', [100 fpos(4)-25-20 fpos(3)-110 10], 'XLim', [0 20]);
        
        SoloParamHandle(obj, 'horizontal_dashed_lines', 'value', hlines(1:MAX_CLASSES, 0, MAX_TRIALS), 'saveable', 0);
        set(value(horizontal_dashed_lines), 'Color', 'k', 'LineStyle', '--');
        set(value(myax), 'TickDir', 'out');
        set(get(value(myax), 'Xlabel'), 'String', 'trial #');
        set(get(value(myax), 'Ylabel'), 'String', 'trial class');
        
        SoloParamHandle(obj, 'solid_greens', 'value', ...
            line(1:MAX_TRIALS, -10*zeros(1, MAX_TRIALS), 'LineStyle', 'none', ...
            'Marker', '.', 'MarkerSize', 16, 'Color', 'g'), 'saveable', 0);
        SoloParamHandle(obj, 'solid_reds', 'value', ...
            line(1:MAX_TRIALS, -10*zeros(1, MAX_TRIALS), 'LineStyle', 'none', ...
            'Marker', '.', 'MarkerSize', 16, 'Color', 'r'), 'saveable', 0);
        SoloParamHandle(obj, 'open_greens', 'value', ...
            line(1:MAX_TRIALS, -10*zeros(1, MAX_TRIALS), 'LineStyle', 'none', ...
            'Marker', 'o', 'MarkerSize', 7, 'Color', 'g'), 'saveable', 0);
        SoloParamHandle(obj, 'open_reds', 'value', ...
            line(1:MAX_TRIALS, -10*zeros(1, MAX_TRIALS), 'LineStyle', 'none', ...
            'Marker', 'o', 'MarkerSize', 7, 'Color', 'r'), 'saveable', 0);
        
        % A dummy SoloParamHandle that will ensure that plot_all_trials gets
        % called when data gets loaded:
        SoloParamHandle(obj, 'dummy', 'callback_on_load', 1);
        set_callback(dummy, {mfilename, 'plot_all_trials'});
        set_callback(intent_motoract, {mfilename, 'plot_all_trials'});
        set_callback({trial_limits;ntrials;start_trial;end_trial}, {mfilename, 'trial_limits'});

    case 'trial_limits'
        if isnan(value(start_trial)) || value(start_trial)<1 || value(start_trial)>value(end_trial); start_trial.value=value(ntrials_ll_default); end
        if isnan(value(end_trial)) || value(end_trial)<1 || value(end_trial)<value(start_trial) ; end_trial.value=value(ntrials_ul_default); start_trial.value=value(ntrials_ll_default); end
        if isnan(value(ntrials)) || value(ntrials)<1 || value(ntrials)>value(n_done_trials); ntrials.value=value(ntrials_default); end
        switch value(trial_limits),
            case 'all',
                set([get_glhandle(start_trial);get_glhandle(end_trial);get_glhandle(ntrials)], 'Visible', 'off');
                ntrials_ll.value=1;ntrials_ul.value=n_done_trials+1;
            case 'from, to',
                set([get_glhandle(start_trial);get_glhandle(end_trial)], 'Visible', 'on');
                set(get_glhandle(ntrials), 'Visible', 'off');
                ntrials_ll.value=value(start_trial);ntrials_ul.value=value(end_trial);
            case 'last n',
                set([get_glhandle(start_trial);get_glhandle(end_trial)], 'Visible', 'off');
                set(get_glhandle(ntrials), 'Visible', 'on');
                ntrials_ll.value=max(1,n_done_trials-value(ntrials));ntrials_ul.value=max(value(n_done_trials)+1,value(ntrials_default));
        end;
        feval(mfilename,obj,'plot_all_trials');
        
        %% case plot_just_finished_trial
    case 'plot_just_finished_trial'
        if n_done_trials < 1, return; end;
        
        if hit==1,
            if n_cpokes==1, gh = value(solid_greens);
            else            gh = value(open_greens);
            end;
        else
            if n_cpokes==1, gh = value(solid_reds);
            else            gh = value(open_reds);
            end;
        end;
        inverse_trialclass=mod(trialclass,2)+1;
        ys = get(gh, 'YData');
        if intent_motoract~=1 && hit~=1; ys(n_done_trials) = inverse_trialclass; else ys(n_done_trials) = value(trialclass); end
        set(gh, 'YData', ys);
        if strcmpi(value(trial_limits),'last n') && value(ntrials)+2<n_done_trials && value(ntrials)>1
            set(value(myax), 'XLim', [n_done_trials-value(ntrials), max(20, n_done_trials+1)]);
        else
            set(value(myax), 'XLim', [1, max(20, n_done_trials+1)]);
        end
        LastTrialClass.value = value(trialclass);
        LastSide.value = TrialsSection(obj, 'get', value(trialclass), 'side');
        
        
        
        %% case plot_all_trials
    case 'plot_all_trials'
        if n_done_trials<1, return; end;
        inverse_trialclass_history=mod(trialclass_history,2)+1;
        
        u = find(hit_history==1 & n_cpokes_history==1);
        gh = value(solid_greens);
        ys = get(gh, 'YData'); ys = -10*ones(size(ys)); ys(u) = trialclass_history(u); set(gh, 'YData', ys);
        
        u = find(hit_history==1 & n_cpokes_history>1);
        gh = value(open_greens);
        ys = get(gh, 'YData'); ys = -10*ones(size(ys)); ys(u) = trialclass_history(u); set(gh, 'YData', ys);
        
        u = find(hit_history==0 & n_cpokes_history==1);
        gh = value(solid_reds);
        ys = get(gh, 'YData'); ys = -10*ones(size(ys));
        if intent_motoract==1; ys(u) = trialclass_history(u); else ys(u) = inverse_trialclass_history(u); end
        set(gh, 'YData', ys);
        
        u = find(hit_history==0 & n_cpokes_history>1);
        gh = value(open_reds);
        ys = get(gh, 'YData'); ys = -10*ones(size(ys));
        if intent_motoract==1; ys(u) = trialclass_history(u); else ys(u) = inverse_trialclass_history(u); end
        set(gh, 'YData', ys);
        
        if strcmpi(value(trial_limits),'all') && value(ntrials_ul)<value(n_done_trials); ntrials_ul=value(n_done_trials); end
        set(value(myax), 'XLim', [value(ntrials_ll), max(20, value(ntrials_ul))]);
        
        
        %% case change_nClasses
    case 'change_nClasses',
        nClasses = TrialsSection(obj, 'get', 'nClasses');
        
        fpos = get(my_gui_info(3), 'Position');
        set(value(myax), 'Position', [100 fpos(4)-25-(nClasses*20+20) fpos(3)-110 nClasses*20]);
        
        sides_vector = cell(nClasses, 1); ytick_label = cell(nClasses,1);
        for i=1:numel(sides_vector),
            sides_vector{i} = TrialsSection(obj, 'get', i, 'side');
            ytick_label{i} = sprintf('class %d (%s)', i, upper(sides_vector{i}));
        end;
        
        set(value(myax), 'YLim', [0.5, nClasses+0.5], ...
            'YTick', 1:nClasses, 'YTickLabel', ytick_label);
        
        
        %% case close
    case 'close'
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        
        % Delete the axes if we still have them.
        if ishandle(value(myax)),
            try delete(value(myax))
            catch ME %#ok<NASGU>
            end;
        end;
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        figure(currfig);
        
        
        %% case reinit
    case 'reinit',
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); start_fig = my_gui_info(3);
        
        feval(mfilename, obj, 'close');
        
        % Reinitialise at the original GUI position and figure:
        figure(start_fig);
        [x, y] = feval(mfilename, obj, 'init', x, y);
        
        % Restore the current figure:
        figure(currfig);
end




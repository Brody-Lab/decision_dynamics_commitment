% [x, y] = PokesPlotSection(obj, action, [arg1], [arg2])

function [x, y] = PokesPlotSection(obj, action, varargin)

try
    % Nothing that happens in pokesplot should cause a session to abort.
    % So the whole thing is getting wrapped in a try catch.
    
GetSoloFunctionArgs(obj);


empty_trial_info = ...
  struct('start_time', [], 'align_time', [], 'align_found', [], 'ydelta', [], 'visible', [], ...
  'ghandles', [], 'select_value', [], 'mainsort_value', [], 'subsort_value', []);
    
switch action,

%% init    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'I_am_PokesPlotSection');
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
    ToggleParam(obj, 'PokesPlotShow', 1, x, y, 'OnString', 'PokesPlot showing', ...
      'OffString', 'PokesPlot hidden', 'TooltipString', 'Show/Hide Pokes Plot window'); next_row(y);
    set_callback(PokesPlotShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    
    screen_size = get(0, 'ScreenSize');
    SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [1 screen_size(4)-740, 435 700], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename)), 'saveable', 0);
    origfig_xy = [x y];


    % ---

    if length(varargin) >= 3,                                     scolors = varargin{3};
    elseif ~isempty(which(['state_colors(' class(obj) ')'])), scolors = state_colors(obj);
    else warning('%s : was neither given state_colors on init nor found state_colors.m for %s objects', ...
        mfilename, class(obj));
      scolors = struct('states', [], 'pokes', [], 'spikes', []);
    end;
    fnames = fieldnames(scolors);
    if isempty(fnames), warning('state_colors passed as empty'); scolors = struct('states', [], 'pokes', [], 'spikes', []); %#ok<WNTAG> (This line OK.)
    elseif length(fnames)==1 &&  strcmp(fnames{1}, 'states'), scolors = add_default_spike_colors(add_default_poke_colors(scolors));
    elseif length(fnames)==1 && ~strcmp(fnames{1}, 'states')
      error('If state_colors has exactly one field, it must be ''states''');
    elseif length(fnames)==2 && isempty(setdiff(fnames, {'states' 'pokes'})),
      scolors = add_default_spike_colors(scolors);
    elseif length(fnames)==2 && ~isempty(setdiff(fnames, {'states' 'pokes'})),
      error('If state_colors has exactly two fields, they must be ''states'' and ''pokes''');
    elseif length(fnames)==3 && ~isempty(setdiff(fnames, {'states' 'pokes', 'spikes'})),
      error('If state_colors has exactly three fields, they must be ''states'' and ''pokes'' and ''spikes''');
    elseif length(fnames)>3,
      scolors = struct('states', scolors); add_default_spike_colors(add_default_poke_colors(scolors));
    end;
    SoloParamHandle(obj, 'my_state_colors', 'value', scolors, 'saveable', 0);
    set_default_reset_value(my_state_colors, {scolors});

    x = 3; y = 3; %#ok<NASGU> (This line OK.)

    % UI param that controls what t=0 means in pokes plot:
    EditParam(obj, 'alignon', 'wait_for_cpoke1(1,1)', 1, 1, ...
      'position', [1 1 160 20], 'labelpos', 'right', 'labelfraction', 0.25, ...
      'TooltipString', sprintf(['\nTime on which to align t=0 for each trial. Format is statename(i,j)\n' ...
      'where statename must be one of the protocol''s StateMachine state names,\n' ...
      'i means the i''th time the machine was in that state in each trial (use "end" for last time)\n', ...
      'and j=1 means the start of being in that state, j=2 means the end of being in that state.\n', ...
      '   For example, "chord(end,1)" means align on the start of the last time machine was in\n', ...
      'any state named "chord"']));
    set_callback(alignon, {mfilename, 'alignon'}); %#ok<NODEF> (Defined just above)

    % Left edge of pokes plot:
    SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
      'position', [165 1 60 20], 'TooltipString', 'time axis left edge');
    % Right edge of pokes plot:
    SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
      'position', [230 1 60 20], 'TooltipString', 'time axis right edge');
    set_callback({t0;t1}, {mfilename, 'time_axis'});



    SoloParamHandle(obj, 'last_ypos_drawn', 'value', 0);
    
    
    %     Choosing consequence of clicking on plot.
    %     Right now, there is only [nothing] and [external script hooking],
    %       but one could imagine lots of simple little functions that
    %       would be very handy here....
    %     We might want a special plugin for such analysis actions if this
    %       becomes popular, and then pokes plot would simply always defer
    %       to it if it exists when a click is detected, and do nothing
    %       itself.
    MenuParam(obj, 'plotclick_action', ...              %owner and name
        {'does nothing', 'runs external script'}, ...   %possible vals
        'does nothing', ...                             %default vals
        100, 52, 'position', [100 52 300 20], ...       %position info
        'label', 'Clicking on plot:', ...
        'labelpos', 'left', ...
        'TooltipString', ['When the plot above is clicked, the action' ...
        ' specified here is performed.' sprintf('\n') 'The external' ...
        ' script is specified in the settings files.']);
    set_saveable({plotclick_action}, 0); %value won't be saved on save data or settings
    
    
    % Choosing to display last n trials or specifying start and ending trials
    SoloParamHandle(obj, 'trial_limits', 'type', 'menu', 'label', 'trials:', ...
      'string', {'last n', 'from, to'}, 'value', 2, 'position', [165 22 140 20], 'labelpos', 'left', ...
      'TooltipString', 'Show latest trials vs show specific set of trials');

    % For last n trials case:
    SoloParamHandle(obj, 'ntrials', 'label', 'ntrials', 'type','numedit','value',25, ...
      'position', [310 22 80 20], 'TooltipString', 'how many trials to show');
    % start_trial, for from, to trials case:
    SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
      'value', 1, 'position', [310 22 60 20]);
    % end_trial, for from, to trials case:
    SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
      'value', 15, 'position', [375 22 60 20]);
    set([get_ghandle(ntrials);get_lhandle(ntrials)], 'Visible', 'off');
    set_callback({trial_limits;ntrials;start_trial;end_trial}, {mfilename, 'trial_limits'});


    % Manual redraw:
    PushbuttonParam(obj, 'redraw', 295, 1);
    set_callback(redraw, {mfilename, 'redraw'});
    set_callback_on_load(redraw, 1);  % Set it so its callback will always be called when loading data or settings.

    % An axis for the pokes plot:
    SoloParamHandle(obj, 'axpokesplot', 'saveable', 0, 'value', double(axes('Position', [0.1 0.38 0.8 0.54])));
    xlabel('secs'); ylabel('trials'); hold on;
    set(value(axpokesplot), 'Color', 0.3*[1 1 1]);
    
    %     Set the callback for the plot in the pokes plot so that when the
    %       plot is clicked, PokesPlotSection(obj,'plotclick',<cp>) is
    %       called, where <cp> is a matrix specifying the point clicked
    %       on the scale defined by the axes.
    %     What plotclick does with this information depends on settings and
    %       toggles.
    set(value(axpokesplot), 'ButtonDownFcn', [mfilename ...
        '(' class(obj) ', ''plotclick'', get(gca,''CurrentPoint''))']);

    % An axis for the color codes and labels:
    SoloParamHandle(obj, 'axhistlabels', 'saveable', 0, 'value', double(axes('Position', [0.15 0.29 0.7 0.03])));

    fnames = fieldnames(my_state_colors.states);
    for i=1:length(fnames),
      fill([i-0.9 i-0.9 i-0.1 i-0.1], [0 1 1 0], my_state_colors.states.(fnames{i}));
      hold on; t = text(i-0.5, -0.5, fnames{i});
      set(t, 'Interpreter', 'none', 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', 'Rotation', 90);
      set(gca, 'Visible', 'off');
    end;
    ylim([0 1]); xlim([0 length(fnames)]);
              
    % If the requested align time for a trial is not found, that trial is plotted aligned to trial start.
    SoloParamHandle(obj, 'trial_info', 'value', empty_trial_info);
    % make the length of trial_info be zero:
    trial_info.value = trial_info([]); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    

    
    SoloFunctionAddVars(obj, 'pokesplot_preferences_pane', 'rw_args', {trial_info}, ...
      'ro_args', {axpokesplot; t0; t1; alignon});
    
      pokesplot_preferences_pane(obj, 'init', 1, 120);
  
    % ---
    x = origfig_xy(1); y = origfig_xy(2);
    figure(value(my_xyfig(3)));
    
%% update    
  % ------------------------------------------------------------------
  %              UPDATE
  % ------------------------------------------------------------------    

  case 'update',
    % We initialize a new trial once it's started, so as to have access to its start time:
    if length(trial_info) < n_started_trials, %#ok<NODEF> (defined by GetSoloFunctionArgs)
      initialize_trial(n_started_trials, parsed_events, value(my_state_colors), value(alignon), trial_info); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    end;

    time = dispatcher('get_time');
    update_already_started_trial(dispatcher('get_time'), ...
      n_started_trials, parsed_events, latest_parsed_events, ...
      value(my_state_colors), value(alignon), value(axpokesplot), trial_info);
  
    
    set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
    set_ylimits(n_started_trials, value(axpokesplot), value(trial_limits), ...
      value(start_trial), value(end_trial), value(ntrials));

    drawnow;

%% trial_completed    
  % ------------------------------------------------------------------
  %              TRIAL_COMPLETED
  % ------------------------------------------------------------------    

  case 'trial_completed',
    trial_info(n_done_trials).visible = trial_selection(value(trial_selector), parsed_events);
    trial_info(n_done_trials).ydelta  = 0;
    if trial_info(n_done_trials).visible == 0, 
      for guys = {'states' 'pokes'},
        fnames = fieldnames(trial_info(n_done_trials).ghandles.(guys{1}));
        for j=1:length(fnames),
          ghandles = trial_info(n_done_trials).ghandles.(guys{1}).(fnames{j});
          set(ghandles, 'Visible', 'off');
        end;
      end;
    end;
    
    if collapse_selection==1,
      last_yposition_drawn = value(last_ypos_drawn);
      if trial_info(n_done_trials).visible == 1,
        last_yposition_drawn = last_yposition_drawn + 1;
        if isempty(trial_info(n_done_trials).ydelta), trial_info(n_done_trials).ydelta = 0; end;
        delta = n_done_trials + trial_info(n_done_trials).ydelta - last_yposition_drawn;
        vertical_shift(trial_info(n_done_trials).ghandles, -delta);
        trial_info(n_done_trials).ydelta = trial_info(n_done_trials).ydelta - delta; %#ok<NASGU> (This line OK.)
      end;
      last_ypos_drawn.value = last_yposition_drawn;
    end;

    
%% redraw
  % ------------------------------------------------------------------
  %              REDRAW
  % ------------------------------------------------------------------    
  
  case 'redraw',
    set(get_ghandle(redraw), 'Enable', 'off'); drawnow; % Avoid double-clicks while we're processing
    % We're going to redraw completely, delete all axes contents:
    delete(get(value(axpokesplot), 'Children'));
    % And delete all previous trial_info values
    trial_info.value = empty_trial_info;
    trial_info.value = trial_info([]); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    % And now remove all old, deleted ghandle information:
%     for i=1:length(trial_info), %#ok<NODEF> (defined by GetSoloFunctionArgs)
%       for guys = {'states' 'pokes'},
%         ghandles = trial_info(i).ghandles.(guys{1});
%         if ~isempty(ghandles),
%           fnames = fieldnames(ghandles);
%           for j=1:length(fnames), 
%             trial_info(i).ghandles.(guys).(fnames{j}) = []; 
%           end;
%         end;
%       end;
%     end;
    
    for i=1:n_started_trials-1, 
      initialize_trial(i, parsed_events_history{i}, value(my_state_colors), value(alignon), trial_info);
      time = parsed_events_history{i}.states.state_0(end,1);
      update_already_started_trial(time, i, parsed_events_history{i}, parsed_events_history{i}, ...
        value(my_state_colors), value(alignon), value(axpokesplot), trial_info);
      trial_info(i).ydelta = 0;
    end;

    if n_started_trials >= 1,
      if dispatcher('is_running'), time = dispatcher('get_time');
      else                       time = latest_time(parsed_events);
      end;
      initialize_trial(n_started_trials, parsed_events, value(my_state_colors),value(alignon),trial_info);
      update_already_started_trial(time, n_started_trials, parsed_events, parsed_events, ...
        value(my_state_colors), value(alignon), value(axpokesplot), trial_info);
      trial_info(n_started_trials).ydelta = 0;
    end;
      
    set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
    set_ylimits(n_started_trials, value(axpokesplot), value(trial_limits), ...
      value(start_trial), value(end_trial), value(ntrials));

  
    drawnow('expose');
    pokesplot_preferences_pane(obj, 'main_sort');
    set(get_ghandle(redraw), 'Enable', 'on');
    drawnow('expose');

    pokesplot_preferences_pane(obj, 'redraw');
    
    
    
%% alignon    
  % ------------------------------------------------------------------
  %              ALIGNON
  % ------------------------------------------------------------------    

  case 'alignon'
    g = value(trial_info(1:n_started_trials)); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    [X{1:n_started_trials}] = deal(g.align_time);
    old_align_times = cell2mat(X);
    for i=1:min(n_started_trials, length(parsed_events_history))      
      % First, see whether we can get the new alignment time:
      if i<n_started_trials, pevs = parsed_events_history{i};
      else                   pevs = parsed_events;
      end;
      atime = find_align_time(value(alignon), pevs); %#ok<NODEF> (defined by GetSoloFunctionArgs)

      % If we can't find the alignment time for a trial, align it on trial
      % start:
      if ~isnan(atime), trial_info(i).align_found = 1;
      else              trial_info(i).align_found = 0; atime = trial_info(i).start_time;
      end;
      trial_info(i).align_time = atime;

      % delta is how much we have to shift the plots by
      delta = atime - old_align_times(i);
      if delta ~= 0,
        % Now shift the x position of all of this trial's graphics handles
        ghandles = trial_info(i).ghandles; 
        for guy = {'states' 'pokes'},
          fnames = fieldnames(ghandles.(guy{1}));
          for j=1:length(fnames),
            gh = ghandles.(guy{1}).(fnames{j});
            if all(ishandle(gh)), % Only try it if the handles are vald
              for k=1:length(gh), set(gh(k), 'XData', get(gh(k), 'XData') - delta); end;
            end;
          end; % for j
        end; % for guy
        if isfield(ghandles, 'spikes') && ~isempty(ghandles.spikes) && ishandle(ghandles.spikes),
           set(ghandles.spikes, 'XData', get(ghandles.spikes, 'XData') - delta);
        end;
      end;
    end;

    
%% set_alignon    
  % ------------------------------------------------------------------
  %              SET_ALIGNON
  % ------------------------------------------------------------------    
  
  case 'set_alignon'
    if length(varargin) < 1,
      warning('Need at least one argument for newalignon'); %#ok<WNTAG> (This line OK.)
      return;
    end;
    alignon.value = varargin{1};
    
    callback(alignon);
      

%% trial_limits    
  % ------------------------------------------------------------------
  %              TRIAL_LIMITS
  % ------------------------------------------------------------------    
  
  case 'trial_limits'
    switch value(trial_limits),
      case 'from, to',
        set([get_glhandle(start_trial);get_glhandle(end_trial)], 'Visible', 'on');
        set(get_glhandle(ntrials), 'Visible', 'off');
      case 'last n',
        set([get_glhandle(start_trial);get_glhandle(end_trial)], 'Visible', 'off');
        set(get_glhandle(ntrials), 'Visible', 'on');
    end;
    
    set_ylimits(n_started_trials, value(axpokesplot), value(trial_limits), ...
      value(start_trial), value(end_trial), value(ntrials));
  

%% time_axes

  % ------------------------------------------------------------------
  %              TIME_AXIS
  % ------------------------------------------------------------------    

  case 'time_axis'
    set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);

    
%% hide    
    
  % ------------------------------------------------------------------
  %              HIDE
  % ------------------------------------------------------------------    

  case 'hide',
    pokesplot_preferences_pane(obj, 'hide');
    if exist('myfig','var')  % deals with case where trying to close.
    PokesPlotShow.value = 0; set(value(myfig), 'Visible', 'off');
    end
    
%% show_hide    
    
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    
  
  case 'show_hide',
    if PokesPlotShow == 1,  %#ok<NODEF>
      set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else
      set(value(myfig), 'Visible', 'off');
      pokesplot_preferences_pane(obj, 'hide');
    end;
    
    
%% close

  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    pokesplot_preferences_pane(obj, 'close');
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);

    
%% reinit    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
  case 'reinit'
    x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3); scolors = value(my_state_colors);
    currfig = double(gcf);
    
    feval(mfilename, obj, 'close');
    
    figure(origfig);
    feval(mfilename, obj, 'init', x, y, scolors);
    figure(currfig);

    
    

%% plotclick

    % ------------------------------------------------------------------
    %              PLOTCLICK
    % ------------------------------------------------------------------
    case 'plotclick'
        %     When settings are set to enable this feature, and the option 
        %       is enabled on the pull-down menu in the pokes plot,
        %       clicking on the plot calls a script specified in the
        %       settings, with the arguments specified in the settings plus
        %       the following args, in this order:
        %        1* - Experimenter NAME
        %        2* - Rat NAME
        %        3* - DAY this data was saved (yymmdd)
        %        4  - PROTOCOL name
        %        5  - SELECTED TRIAL
        %        6  - SELECTED TIME, in seconds SINCE EXPERIMENT START
        %        7  - SELECTED TIME, in seconds SINCE TRIAL      START
        %        8**- SELECTED TRIAL'S END TIME, in seconds since exp start
        %       
        %       *  If the protocol does not use the saving plugin,
        %            arguments 1, 2, and 3 will be the character '_'
        %       ** If the clicked trial is the last trial in the plot, this
        %            will be the character '_'
        %
        %       To select a full trial (arg 6 = trial start & arg 7 = 0),
        %         click to the left of the pokes plot (anywhere around the
        %         y axis labels or scale). This is a documented feature,
        %         and works regardless of the align time.
        %
        %       The motivation for this plot click script hooking was to
        %         allow display of relevant video segments, but it can be
        %         used for other analytical purposes.
        %
        if length(varargin) ~= 1,
            error([mfilename '(obj,''plotclick'',<cp>) incorrectly' ...
                ' called - current point matrix (e.g. from' ...
                ' get(gca,''CurrentPoint'')) omitted, or extra' ...
                ' arguments passed in.']);
        end;

		cp = varargin{1}; % point clicked in plot, in axes' scales
        %     The matrix looks like this:
        %           xPosition       yPosition       whocares?
        %           whocares?       whocares?       whocares?

		%     Trial Number
        trialNum = round(cp(1,2)); %     the easiest: round y axis pos
        % the trials have been reordered, need to recalcualte the true
        % trialnumber by reconstructing which row each trial is on, then
        % matching the y axis position to the correct trial
        if collapse_selection==1 || ~isempty(main_sort_separators), 
            s = trial_info(:); %#ok<NODEF>
            clear ydelta; [ydelta{1:length(s)}] = deal(s.ydelta);  ydelta = cell2mat(ydelta);
            clear visibl; [visibl{1:length(s)}] = deal(s.visible); vis = zeros(size(visibl));
            for i=1:length(visibl), if isempty(visibl{i}) || visibl{i}==1, vis(i) = 1; end; end;
            tr = 1:rows(s);
            newrow  = (tr + ydelta).*vis;  % the row each trial has been mapped to, or 0 if not visible 
            trialNum = find(newrow == trialNum, 1);
        end
        
        if     trialNum < 1 ...
            || trialNum > value(n_done_trials),
            return;
        end;

		
        if ~strcmp(value(plotclick_action),'runs external script'), 
			fprintf(1, 'Trial number is %d\n', trialNum);
			return;
		end;
        
        [enable_script_hooks errID1] = ...
            bSettings('compare','AUX_SCRIPT','Disable_Aux_Scripts',0);
        [enable_ppclick_hook errID2] = ...
            bSettings('compare','AUX_SCRIPT','Enable_On_PPClick_Script',1);
        [script errID3] = ...
            bSettings('get','AUX_SCRIPT','On_PPClick_Script');
        [args errID4] = ...
            bSettings('get','AUX_SCRIPT','On_PPClick_Args');

        if errID1 || errID2 || errID3 || errID4 ...
                || ~enable_script_hooks ...
                || ~enable_ppclick_hook,
            return;
        elseif ~ischar(script) ...
                || isempty(script) ...
                || ~exist(script,'file'),
            warning(['Script hook on pokes plot click is enabled,' ...
                ' but the script is not specified, the setting is' ...
                ' not a string, or the file specified does not exist.']); %#ok<WNTAG> (This line OK.)
            return;
        end; %     end if/elseif we should not run the script

        %     Add default arguments afterwards.
        fix_date_format=1;
		if find(strcmp('SavingSection',methods(obj,'-full'))),
            [experimenter_v ratname_v savedate_v] = SavingSection(obj,'get_info');
		elseif isa(obj,'neurobrowser')
		   infoS = neurobrowser('get_info');
		   experimenter_v = infoS.experimenter; ratname_v = infoS.ratname; savedate_v = infoS.sessdate;
		   savedate_v=savedate_v(savedate_v~='-');
		   % The save date should be in YYYYMMDD format.  MySQL is YYYY-MM-DD
		   % format.  So i get rid of the - 
		   fix_date_format=0;
		else
			experimenter_v = '_'; ratname_v = '_'; savedate_v = '_';
        end;
        
        if fix_date_format && ~strcmp(savedate_v,'_'), savedate_v = yearmonthday(savedate_v); end;
        %     Note that the savedate_v will be '_' if the saving plugin is
        %       not being used *OR* if get_info returns '_' (meaning that
        %       no save has taken place for this data).
        
        
        %     Calculate time in trial, and time in
        %       experiment from the position in the figure and event
        %       information.
        
        
        %     temps for convenience
        tInfo_temp = value(trial_info); %     plot info for all trials
        this_trial_info = tInfo_temp(trialNum); %#ok<NODEF> (trial_info defined by GetSoloFunctionArgs)
        
        time_relative_to_trial_align = floor(cp(1,1));

        %     For reasons not worth explaining here, the actual start time
        %       registered for the first trial is not 0, so we subtract it
        %       from all absolute experiment times.
        experiment_start_time = tInfo_temp(1).start_time;

         
        %     Handle click on left.
        if time_relative_to_trial_align < value(t0),
            timeTri = 0;                    %     0 seconds into trial
            timeExp = this_trial_info.start_time - experiment_start_time; %     start of this trial
        else %     Otherwise, click was in plot proper.
            %     Time in Experiment
            %     time 0 in trial's row + click distance from 0 in seconds
            timeExp = ...
                this_trial_info.align_time + time_relative_to_trial_align - experiment_start_time;
            %     Time in Trial
            %     time in exp - time of trial start
            timeTri = timeExp - this_trial_info.start_time + experiment_start_time;
        end;
        %     End-of-Trial time is the same in both cases.
        if length(value(trial_info)) < trialNum + 1, %     If last trial, report that (so that end of experiment time can be used).
            timeExpEoT = '_';
        else
            timeExpEoT = tInfo_temp(trialNum+1).start_time - experiment_start_time; %     If not last trial, report time of start of next trial.
        end;
        

        %     Add the information retrieved together into a string of
        %        filename + args.
        evalstring = [	script				...	%     filename of script
            ' '			experimenter_v		...	%     name of experimenter
            ' '			ratname_v			...	%     name of rat
            ' '			savedate_v			...	%     date data was saved
            ' '         int2str(timeExp)	];	%     selected trial's end time

        %     There may be a more delicate way to do this....
        eval(['!' evalstring ' &']); %     fork
        
        
  otherwise
    warning('%s : action "%s" is unknown!', mfilename, action); %#ok<WNTAG> (This line OK.)

end; %     end of switch action
catch
    showerror
end
%     end of function PokesPlotSection






% ------------------------------------------------------------------
%
%              FUNCTION LATEST_TIME
%
% ------------------------------------------------------------------


function [t] = latest_time(pe)

   states = rmfield(rmfield(pe.states, 'starting_state'), 'ending_state');
   pokes  = rmfield(rmfield(pe.pokes,  'starting_state'), 'ending_state');
   
   states = struct2cell(states);
   pokes  = struct2cell(pokes);
   
   ts = [];
   for i=1:length(states), ts = [ts ; states{i}(:)]; end;
   for i=1:length(pokes), ts = [ts ; pokes{i}(:)]; end;
   ts = ts(~isnan(ts));
   
   if isempty(ts), t = 10000; 
   else            t = max(ts);
   end;

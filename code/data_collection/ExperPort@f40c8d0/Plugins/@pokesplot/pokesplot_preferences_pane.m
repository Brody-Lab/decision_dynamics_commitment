function [varargout] = pokesplot_preferences_pane(obj, action, varargin)
try
GetSoloFunctionArgs(obj);

switch action

      

%% close

  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);

    
%% collapse_selection

  % ------------------------------------------------------------------
  %              COLLAPSE_SELECTION
  % ------------------------------------------------------------------    

  case 'old_collapse_selection',
    if collapse_selection==0,
      for i=1:n_done_trials,
        if ~isempty(trial_info(i).ydelta) && trial_info(i).ydelta ~= 0,
          vertical_shift(trial_info(i).ghandles, -trial_info(i).ydelta);
          trial_info(i).ydelta = 0; %#ok<AGROW>
        end; 
      end;
    end; 
    try
    if collapse_selection==1,
      last_yposition_drawn = 0;
      for i=1:n_done_trials,
        if trial_info(i).visible == 1,
          last_yposition_drawn = last_yposition_drawn + 1;
          if isempty(trial_info(i).ydelta), trial_info(i).ydelta = 0; end; %#ok<AGROW>
          delta = i + trial_info(i).ydelta - last_yposition_drawn;
          vertical_shift(trial_info(i).ghandles, -delta);
          trial_info(i).ydelta = trial_info(i).ydelta - delta; %#ok<AGROW>
        end;
      end;
      last_ypos_drawn.value = last_yposition_drawn;
    end;
    catch
    end
        
    
%% export_spike_counts
  % ------------------------------------------------------------------
  %              EXPORT_SPIKE_COUNTS
  % ------------------------------------------------------------------    
  case 'export_spike_counts',    
    s = trial_info(1:n_done_trials); %#ok<NODEF>
    clear vsbl;   [vsbl{1:length(s)}]   = deal(s.visible);        vsbl   = cell2mat(vsbl);
    clear msv;    [msv{1:length(s)}]    = deal(s.mainsort_value); msv    = cell2mat(msv);

    trialnums = 1:n_done_trials; msv = msv(vsbl); trialnums = trialnums(vsbl);
    sc = zeros(size(msv));
    for i=1:length(msv);
      shandle = s(trialnums(i)).ghandles.spikes;
      if ishandle(shandle),
        xdata = get(shandle, 'XData'); xdata = xdata(1:3:end);
        sc(i) = length(find( t0<=xdata & xdata <= t1 ));
      end;
    end;

    assignin('base', 'msv', msv);
    assignin('base', 'sc',  sc);
    
    
    
    
%% hide    
    
  % ------------------------------------------------------------------
  %              HIDE
  % ------------------------------------------------------------------    

  case 'hide',
    if exist('myfig','var')
      PreferencesPane.value = 0; set(value(myfig), 'Visible', 'off');
    end
    
%% init
% ------------------------------------------------------------------
%              INIT
% ------------------------------------------------------------------    
  
  case 'init',
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
    ToggleParam(obj, 'PreferencesPane', 0, x, y, 'TooltipString', 'Show/Hide Preferences Pane'); next_row(y);
    set_callback(PreferencesPane, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)

    screen_size = get(0, 'ScreenSize');
    SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [300 screen_size(4)-240, 500 230], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', ['PokesPlot/' mfilename])), 'saveable', 0);
    origfig_xy = [x y];

    
    SoloParamHandle(obj, 'main_sort_separators', 'saveable', 0);
    
    % ---  Start new figure window:

    x= 10; y = 10;
    
    
    % What kind of trials to display:
    EditParam(obj, 'sub_sort', 'trialnum', 1, 1, 'labelpos', 'left', 'labelfraction', 0.2, ...
      'position', [x, y, 480, 45], 'nlines', 3, 'HorizontalAlignment', 'left', ...
      'TooltipString', sprintf(['\nMatlab numeric expression that defines sorting order within each main block.\n', ...
	  'Syntax is the same as in main_sort and trial_selector. Default is to sort by "trialnum", i.e., trial number.\n', ...
	  'For example, to sort by the duration of the first center poke, you could write   "pk.C(1,2)-pk.C(1,1)".'])); y = y+50;
    set_callback(sub_sort, {mfilename, 'main_sort'});

    EditParam(obj, 'main_sort', '', 1, 1, 'labelpos', 'left', 'labelfraction', 0.2, ...
      'position', [x, y, 480, 45], 'nlines', 3, 'HorizontalAlignment', 'left', ...
      'TooltipString', sprintf(['\nMatlab numeric expression for grouping trials into main blocks\n', ...
	  'The syntax is just like the syntax for trial_selector, except the expression is not a boolean.\n', ...
	  'Trials will be chunked into groups where the result of the expression is the same for all trials within each group.\n', ...
	  'For example, to group by number of center pokes you could write:   "rows(pk.C)"'])); y = y+50;
    set_callback(main_sort, {mfilename, 'main_sort'});

    EditParam(obj, 'trial_selector', '', 1, 1, 'labelpos', 'left', 'labelfraction', 0.2, ...
      'position', [x, y, 480, 45], 'nlines', 3, 'HorizontalAlignment', 'left', ...
      'TooltipString', sprintf(['\nMatlab boolean expression for selecting which trials are shown\n', ...
	  'Only trials for which the expression evaluates to true will be shown\n', ...
	  'States are in a structure called "ps", pokes are in a structure called "pk":\n', ...
	  'For example, "rows(ps.violation_state)" is the number of times violation_state occurred,\n', ...
	  'and "pk.C(1,1)" is the time of the first C poke.\n', ...
	  '   Thus you can write:    "rows(ps.violation_state)==1 & pk.C(1,2)-ps.center_poke(1,1)>0.5"'])); y = y+50;
    set_callback(trial_selector, {mfilename, 'main_sort'});

    ToggleParam(obj, 'collapse_selection', 0, 1, 75, ...
      'position', [x, y, 100 20], 'OnString', 'collapse', 'OffString', 'don''t collapse', ...
      'TooltipString', 'Collapse selected trials together or show them separately'); 
    set_callback(collapse_selection, {mfilename, 'main_sort'});
    x = x+200;
    
    PushbuttonParam(obj, 'plotPSTH', 1, 75, 'position', [x, y, 100 20]); x = x+100;
    set_callback(plotPSTH, {mfilename, 'plot_psth'});
    NumeditParam(obj, 'smoother', 0.02, 1, 75, 'position', [x, y, 100 20], ...
      'labelfraction', 0.6, 'TooltipString', 'PSTH smoothing, in secs'); x= x+110;
    PushbuttonParam(obj, 'export', 1, 75, 'position', [x, y, 80 20], ...
      'TooltipString', sprintf(['\ninstantiate the variables sc (spike count) and ' ...
      '\nmsv (major sort value) in base workspace'])); 
    set_callback(export, {mfilename, 'export_spike_counts'});   
    
    y = y+40; x=10;
    
    ToggleParam(obj, 'see_states', 1, x, y, 'position', [x y 100 20]); x = x+110;
    set_callback(see_states, {mfilename, 'see_states'});

    ToggleParam(obj, 'see_pokes', 1, x, y, 'position', [x y 100 20]); x = x+110;
    set_callback(see_pokes, {mfilename, 'see_pokes'});

    ToggleParam(obj, 'see_spikes', 1, x, y, 'position', [x y 100 20]); 
    set_callback(see_spikes, {mfilename, 'see_spikes'});

    SoloFunctionAddVars(obj, 'PokesPlotSection', 'rw_args', {trial_selector; collapse_selection; main_sort_separators});
    
    figure(my_xyfig(3)); x = origfig_xy(1); y = origfig_xy(2);
    varargout{1} = x; varargout{2} = y;
    feval(mfilename, obj, 'show_hide');
    


%% main_sort    
    
  % ------------------------------------------------------------------
  %              MAIN_SORT
  % ------------------------------------------------------------------    
  case 'main_sort',    
    set(value(myfig),'Pointer','watch'); drawnow;
    % And erase any previous separators
    for i=1:length(value(main_sort_separators)), %#ok<NODEF>
      if ishandle(main_sort_separators(i)), delete(main_sort_separators(i)); end;
    end;
    main_sort_separators.value = [];
    
    % Ok, now figure out the sort value for every trial:    
    spvalue({'set_owner', obj});
    for i=1:min(n_started_trials-1, length(parsed_events_history)) %#ok<USENS>
      spvalue({'set_trialnum', i});
      trial_info(i).mainsort_value = trial_parsing(  value(main_sort),      parsed_events_history{i}, i); %#ok<AGROW>
      trial_info(i).subsort_value  = trial_parsing(  value(sub_sort),       parsed_events_history{i}, i); %#ok<AGROW>
      trial_info(i).visible        = trial_selection(value(trial_selector), parsed_events_history{i}, i); %#ok<AGROW>

      adjust_visibility(trial_info(i));
    end;

    s = trial_info(:); %#ok<NODEF>
    s = s(1:min(n_started_trials-1, length(parsed_events_history)));
    clear ydelta; [ydelta{1:length(s)}] = deal(s.ydelta);         ydelta = cell2mat(ydelta);
    clear vsbl;   [vsbl{1:length(s)}]   = deal(s.visible);        vsbl   = cell2mat(vsbl);
    clear msv;    [msv{1:length(s)}]    = deal(s.mainsort_value); msv    = cell2mat(msv);
    clear ssv;    [ssv{1:length(s)}]    = deal(s.subsort_value);  ssv    = cell2mat(ssv);

    trialnums = 1:length(s);
    if collapse_selection,
      msv = msv(vsbl); ssv = ssv(vsbl); trialnums = trialnums(vsbl);
    end;
    
    umsv = unique(msv);
    group_lengths = zeros(size(umsv));

    for i=1:length(umsv), group_lengths(i) = length(find(msv == umsv(i))); end;
    l = [];  hold(axpokesplot, 'on');    
    for i=1:length(umsv)-1,
      l = [l ; plot(axpokesplot, [-1000 1000], (i+ sum(group_lengths(1:i)))*[1 1])]; 
    end;
    set(l, 'Color', 'w');
    main_sort_separators.value = l;
    
    
    for i=1:length(umsv),
      my_base = sum(group_lengths(1:i-1)) + i;
      my_guys = find(msv == umsv(i));
      [trash, sorti] = sort(ssv(my_guys)); %#ok<FNDSB>
      
      for j=1:length(sorti),
        mytrialnum = trialnums(my_guys(sorti(j)));
        my_target = my_base + j-1;
        current_ydelta = ydelta(mytrialnum);
        new_ydelta     = my_target - mytrialnum;
        vertical_shift(trial_info(mytrialnum).ghandles, new_ydelta - current_ydelta);
        trial_info(mytrialnum).ydelta = new_ydelta; %#ok<AGROW>
      end;
    end;

    if see_states==0, feval(mfilename, obj, 'see_states'); end;
    if see_pokes==0,  feval(mfilename, obj, 'see_pokes');  end;
    if see_spikes==0, feval(mfilename, obj, 'see_spikes');  end;
   
    set(value(myfig),'Pointer','arrow'); drawnow;


%% plot_psth 
  % ------------------------------------------------------------------
  %              PLOT_PSTH
  % ------------------------------------------------------------------    
  case 'plot_psth',    
    s = trial_info(1:n_done_trials); %#ok<NODEF>
    clear vsbl;   [vsbl{1:length(s)}]   = deal(s.visible);        vsbl   = cell2mat(vsbl);
    clear msv;    [msv{1:length(s)}]    = deal(s.mainsort_value); msv    = cell2mat(msv);

    trialnums = 1:n_done_trials; msv = msv(vsbl); trialnums = trialnums(vsbl);
    
    ev = []; ts = [];
    for i=1:length(msv), 
      shandle = s(trialnums(i)).ghandles.spikes;
      ev = [ev ; s(trialnums(i)).align_time];
      if ishandle(shandle),
        xdata = get(shandle, 'XData');
        ts = [ts xdata(1:3:end)+ev(end)];
      end;
    end;

    psthC(ev, ts, -t0*1000, t1*1000, 10, msv,0,value(smoother)*1000);
    xlim([t0 t1]);
    set(gca, 'TickDir', 'out', 'FontSize', 16);
    xlabel(sprintf('time from %s', value(alignon)))
    set(get(gca, 'XLabel'), 'Interpreter', 'none');
    ylabel('spikes/sec +/- std. err.');


    
%% redraw    
    
  % ------------------------------------------------------------------
  %              REDRAW
  % ------------------------------------------------------------------    
  case 'redraw',    

    if see_states==0, feval(mfilename, obj, 'see_states'); end;
    if see_pokes==0,  feval(mfilename, obj, 'see_pokes');  end;
    if see_spikes==0, feval(mfilename, obj, 'see_spikes');  end;
    
    
%% set_spike_color
  % ------------------------------------------------------------------
  %              SET_SPIKE_COLOR
  % ------------------------------------------------------------------    

  case 'set_spike_color'
    tinfo = value(trial_info); %#ok<NODEF>
    for i=1:length(tinfo),
      set(tinfo(i).ghandles.spikes, 'Color', varargin{1});
    end;
    

        
%% see_states
  % ------------------------------------------------------------------
  %              SEE_STATES
  % ------------------------------------------------------------------    

  case 'see_states'
    vis = value(see_states);
    tinfo = value(trial_info); %#ok<NODEF>
    for i=1:length(tinfo),
      guys = cell2mat(struct2cell(tinfo(i).ghandles.states));
      if     vis==0,               set(guys, 'Visible', 'off');
      elseif tinfo(i).visible==1,  set(guys, 'Visible', 'on');
      end;
    end;

%% see_pokes
  % ------------------------------------------------------------------
  %              SEE_POKES
  % ------------------------------------------------------------------    

  case 'see_pokes'
    vis = value(see_pokes);
    tinfo = value(trial_info); %#ok<NODEF>
    for i=1:length(tinfo),
      guys = cell2mat(struct2cell(tinfo(i).ghandles.pokes));
      if     vis==0,              set(guys, 'Visible', 'off');
      elseif tinfo(i).visible==1, set(guys, 'Visible', 'on');
      end;
    end;

    
%% see_spikes
  % ------------------------------------------------------------------
  %              SEE_SPIKES
  % ------------------------------------------------------------------    

  case 'see_spikes'
    vis = value(see_spikes);
    tinfo = value(trial_info); %#ok<NODEF>
    for i=1:length(tinfo),
      guys = tinfo(i).ghandles.spikes;
      if     vis==0,              set(guys, 'Visible', 'off');
      elseif tinfo(i).visible==1, set(guys, 'Visible', 'on');
      end;
    end;
    

%% show    
    
  % ------------------------------------------------------------------
  %              SHOW
  % ------------------------------------------------------------------    
  case 'show',
    PreferencesPane.value = 1;
    set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    

%% show_hide    
    
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    
  case 'show_hide',
    if PreferencesPane == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                     set(value(myfig), 'Visible', 'off');
    end;
        
    
    
%% trial_selector

  % ------------------------------------------------------------------
  %              TRIAL_SELECTOR
  % ------------------------------------------------------------------    

  case 'old_trial_selector',
    set(value(myfig),'Pointer','watch'); drawnow;

    spvalue({'set_owner', obj});
    for i=1:min(n_started_trials-1, length(parsed_events_history))
      spvalue({'set_trialnum', i});
      trial_info(i).visible = trial_selection(value(trial_selector), parsed_events_history{i}, i); %#ok<AGROW>
      for guys = {'states' 'pokes'},
        fnames = fieldnames(trial_info(i).ghandles.(guys{1}));
        for j=1:length(fnames),
          ghandles = trial_info(i).ghandles.(guys{1}).(fnames{j});
          if trial_info(i).visible == 1, set(ghandles, 'Visible', 'on');
          else                           set(ghandles, 'Visible', 'off');
          end;
        end;
      end; % for guys
      % Now spikes:
      ghandles = trial_info(i).ghandles;
      if isfield(ghandles, 'spikes') && ~isempty(ghandles.spikes) && ishandle(ghandles.spikes),
        if trial_info(i).visible == 1, set(ghandles.spikes, 'Visible', 'on');
        else                           set(ghandles.spikes, 'Visible', 'off');
        end;
      end;
    end;

    if see_states==0, feval(mfilename, obj, 'see_states'); end;
    if see_pokes==0,  feval(mfilename, obj, 'see_pokes');  end;
    if see_spikes==0, feval(mfilename, obj, 'see_spikes');  end;

    if collapse_selection, feval(mfilename, obj, 'collapse_selection'); end;
    
    set(value(myfig),'Pointer','arrow'); drawnow;


    

%% otherwise    
  otherwise,
    fprintf(1, '??? %s doesn''t know action %s\n', mfilename, action);
end;
catch
    showerror;
end



  
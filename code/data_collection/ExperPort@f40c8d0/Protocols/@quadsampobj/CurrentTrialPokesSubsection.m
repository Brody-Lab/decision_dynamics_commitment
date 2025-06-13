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
%        'ro_args', {'LastTrialEvents', 'RealTimeStates', ...
%                    'n_started_trials', 'Sound_type'});
%

switch action,
 case 'init',  % ---------- CASE INIT ----------

   fig = gcf; % This is the protocol's main window, to which we add a menu:   
   SoloParamHandle(obj, 'my_xyfig', 'value', [x y fig]);

   MenuParam(obj, 'CurrentTrialPokes', {'hidden', 'view'}, 2, x, y); next_row(y);
   set_callback(CurrentTrialPokes, ...
                {'CurrentTrialPokesSubsection', 'view'});
   
   % Now make a figure for our Pokes Plot:
   SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
   screen_size = get(0, 'ScreenSize');
   set(value(myfig),'Position',[1 screen_size(4)-740, 435 700]); % put fig
                                                                 % at top left
   set(value(myfig), ...
       'Visible', 'on', 'MenuBar', 'none', 'Name', 'Pokes Plot', ...
       'NumberTitle', 'off', 'CloseRequestFcn', ...
       ['CurrentTrialPokesSubsection(' class(obj) '(''empty''), ''hide'')']);
   
   % UI param that controls what t=0 means in pokes plot:
   EditParam(obj, 'alignon', 'wait_for_apoke(1,1)', 1, 1, ...
             'position', [1 1 160 20], 'labelpos', 'right', ...
             'labelfraction', 0.25); 

   set_callback(alignon, ...
                {'CurrentTrialPokesSubsection', 'alignon' ; ...
                 'CurrentTrialPokesSubsection', 'redraw'});
   
   % Left edge of pokes plot:
   SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
                   'position', [165 1 60 20], 'ToolTipString', ...
                   'time axis left edge');
   % Right edge of pokes plot:
   SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
                   'position', [230 1 60 20], 'ToolTipString', ...
                   'time axis right edge');
   
   % What kind of trials to display:
   EditParam(obj, 'trial_selector', '', 1, 1, 'labelpos', 'left', ...
             'labelfraction', 0.2, 'position', [1, 70, 420, 45], ...
             'nlines', 3, 'HorizontalAlignment', 'left', ...
             'TooltipString', 'Matlab string for selecting trials');
   PushbuttonParam(obj, 'export',          1, 1, 'position', [362 116 60 20], ...
       'FontWeight', 'normal', 'TooltipString', ...
       sprintf(['\nWhen you click here, trials plotted on the pokes\n' ...
                'plot will be exported to a file called "exportdata.txt"\n'...
                'in the main ExperPort directory. This file is\n' ...
                'real crappy, but suitable for import into Excel.']));
   set_callback(export, {'CurrentTrialPokesSubsection', 'export'});

   PushbuttonParam(obj, 'show_trial_info', 1, 1, 'position', [1 75 83 20], ...
                   'FontWeight', 'normal');
   set_callback(show_trial_info, {'CurrentTrialPokesSubsection', 'tinfo'});
   ToggleParam(obj, 'collapse_selection', 0, 1, 75, ...
               'position', [1 52 83 20], ...
               'OnString', 'collapse', 'OffString', 'don''t collapse', ...
               'TooltipString', ['Collapse selected trials together or ' ...
                       'show them separately']);
   
   set_callback({trial_selector, collapse_selection}, ...
                {'CurrentTrialPokesSubsection', 'redraw'});
   
   % Choosing to display last n trials or specifying start and ending trials
   SoloParamHandle(obj, 'trial_limits', 'type', 'menu', 'label', 'trials:', ...
                   'string', {'last n', 'from, to'}, 'value', 2, ...
                   'position', [165 22 140 20], 'labelpos', 'left', ...
                   'TooltipString', ['Show latest trials vs show specific '...
                       'set of trials']);
   set_callback(trial_limits, { ...
     'CurrentTrialPokesSubsection', 'trial_limits' ; ...
     'CurrentTrialPokesSubsection', 'redraw'});

   % For last n trials case:
   SoloParamHandle(obj, 'ntrials', 'label', 'ntrials', ...
                   'type','numedit','value',25, ...
                   'position', [310 22 80 20], 'TooltipString', ...
                   'how many trials to show');
   % start_trial, for from, to trials case:
   SoloParamHandle(obj, 'start_trial','label', 'start', 'type', 'numedit', ...
                   'value', 1, 'position', [310 22 60 20]);
   % end_trial, for from, to trials case:
   SoloParamHandle(obj, 'end_trial','label', 'end', 'type', 'numedit', ...
                   'value', 15, 'position', [375 22 60 20]);
   set([get_ghandle(ntrials);get_lhandle(ntrials)], 'Visible', 'off');

   
   % Manual redraw:
   PushbuttonParam(obj, 'redraw', 295, 1);
   set_callback({t0;t1}, ...
                {mfilename, 'time_axis' ; ...
                 mfilename, 'redraw'});
   set_callback({ntrials;redraw;start_trial;end_trial}, ...
                {'CurrentTrialPokesSubsection', 'redraw'});
      
   % An axis for the pokes plot:
   SoloParamHandle(obj, 'axpatches', 'saveable', 0, ...
                   'value', axes('Position', [0.1 0.44 0.8 0.54]));
   xlabel('secs'); ylabel('trials'); hold on;
   set(value(axpatches), 'Color', 0.3*[1 1 1]); 
   

   % An axis for the histogram of center pokes:
   SoloParamHandle(obj, 'axhist', 'saveable', 0, ...
                   'value', axes('Position', [0.15 0.31 0.7 0.08]));
   ylabel('n Center pokes'); hold on;
   % Variable that'll hold accumulated cpoke statistics:
   SoloParamHandle(obj, 'cpokestats', 'value', ...
                   compile_cpoke_stats([], RealTimeStates));
   % Variable holding graphics handles for the cpoke histogram patches:
   SoloParamHandle(obj, 'histhandles', 'value', hist_cpoke_stats(cpokestats), ...
                   'saveable', 0);


   % An axis for the color codes and labels:
   SoloParamHandle(obj, 'axhistlabels', 'saveable', 0, ...
                   'value', axes('Position', [0.15 0.29 0.7 0.015]));
   hist_cpoke_stats('make_labels');

   % A variable that holds the event-parsed trials:
   SoloParamHandle(obj, 'pstruct', 'saveable', 0, 'value', cell(1000,1), ...
                   'default_reset_value', {cell(1000,1)});

   % A variable that holds which trials are currently plotted on screen
   SoloParamHandle(obj, 'plotted_trials', 'value', []);
   
   figure(fig); % After finishing with our fig, go back to whatever was
                % the current fig before.

   
   
 case 'update', % ------ CASE UPDATE
   if strcmp(value(CurrentTrialPokes), 'view'),
      if n_started_trials > 0,
         plot_single_trial(LastTrialEvents, RealTimeStates, ...
              n_started_trials-1, value(alignon), value(axpatches)); 
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

   
 case 'time_axis',
   if t1<=t0, t1.value = t0+0.1; end;
   
 case 'redraw', % ------- CASE REDRAW
   % Check that trial limits are sane
   if start_trial<1, start_trial.value = 1; end;
   if end_trial<start_trial, end_trial.value = start_trial+1; end;
   if ntrials<1, ntrials.value = 1; end;
   
   % Ok, on with redrawing
   if strcmp(value(CurrentTrialPokes), 'view'),
      if n_started_trials >= 1,
         delete(get(value(axpatches), 'Children'));
         LHistory   = [LastTrialEvents_history; {LastTrialEvents}];
         RHistory   = RealTimeStates_history;
         SndHistory = [Sound_type_history; {Sound_type}];
         maxnumtrials  = min(length(LHistory), length(RHistory));
         LHistory = LHistory(1:maxnumtrials);
         RHistory = RHistory(1:maxnumtrials);
         switch value(trial_limits),
          case 'last n',
            bot  = max(0, maxnumtrials-ntrials);
            dtop = bot+ntrials;
          case 'from, to',
            bot  = value(start_trial)-1;
            dtop = value(end_trial);
          otherwise error('whuh?');
         end;
         ttop = min(dtop, maxnumtrials);
         % For the trials we are about to plot, parse 'em if not parsed
         % before:
         for i=bot+1:ttop, 
            if isempty(pstruct{i}),
               pstruct{i} = parse_trial(LHistory{i}, RHistory{i});
            end;
            % Always do the latest trial that was finished:
            if i==n_started_trials,
               pstruct{i} = parse_trial(LHistory{i}, RHistory{i});
            end;
         end;
         if bot+1<=length(SndHistory)  &&  ttop<=length(SndHistory),
            plotted_trials.value = ...
                plot_many_trials(LHistory(bot+1:ttop),RHistory(bot+1:ttop),...
                             bot, value(alignon), value(axpatches), ...
                             'trial_types', SndHistory(bot+1:ttop), ...
                             'trial_selector', value(trial_selector), ...
                             'pstruct', pstruct(bot+1:ttop), ...
                             'YLim', [bot dtop], ...
                             'TLim', [value(t0), value(t1)], ...
                             'collapse_selection', value(collapse_selection));
         else
            plotted_trials.value = ...
                plot_many_trials(LHistory(bot+1:ttop),RHistory(bot+1:ttop),...
                             bot, value(alignon), value(axpatches), ...
                             'TLim', [value(t0), value(t1)]);
         end;
         if ~isempty(value(plotted_trials)),
            plotted_trials.value = plotted_trials + bot;
         end;
         
         cpokestats.value = compile_cpoke_stats(LHistory, RHistory);
         hist_cpoke_stats(cpokestats, value(histhandles));
         drawnow;
      end;
   end;


 case 'alignon',  % ---- CASE ALIGNON
   switch value(alignon),
    case 'dead_time(end,2)',       t0.value = -3;   t1.value = 25;       
    case 'wait_for_cpoke(1,1)',    t0.value = -4;   t1.value = 15; 
    case 'center1(1,1)',           t0.value = -4;   t1.value = 15; 
    case 'wait_for_apoke(1,1)',    t0.value = -9;   t1.value = 11;
    case 'wait_for_apoke(end,2)',  t0.value = -14;  t1.value = 5; 
    otherwise,
   end;
   
   
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
   x = my_xyfig(1); y = my_xyfig(2); fig = my_xyfig(3);

   delete(value(myfig));
   delete_sphandle('handlelist', ...
      get_sphandle('owner', class(obj), 'fullname', mfilename));

   figure(fig);
   CurrentTrialPokesSubsection(obj, 'init', x, y);
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

   
 case 'tinfo',
   currfig = gcf;

   str = sprintf(['In %d trials of this protocol, the trial_info ' ...
                  'structure provides the following fieldnames and ' ...
                  'possible values (numeric values given as ranges):' ...
                  '\n\n'], length(Sound_type_history));
   nlines = 3;
   if ~isempty(Sound_type_history),
      fnames = fieldnames(Sound_type_history{1});
      for i=1:length(fnames),
         str = sprintf('%s\n%s', str, fnames{i}); nlines=nlines+1;
         strvalues = {}; numvalues = [];
         for j=1:length(Sound_type_history),
            val = Sound_type_history{j}.(fnames{i});
            if ischar(val) && ~ismember(val, strvalues), 
               strvalues = [strvalues ; {val}]; 
            elseif isnumeric(val) && all(size(val)==1) && ...
                   ~ismember(val, numvalues),
               numvalues = [numvalues ; val];
            end;
         end;
         
         if ~isempty(strvalues) | ~isempty(numvalues),
            str = [str ' : '];
            for j=1:length(strvalues),
               str = sprintf('%s''%s'' | ', str, strvalues{j});
            end;
            if ~isempty(numvalues),
               str = sprintf('%s%g - %g | ', str, min(numvalues(:)), ...
                             max(numvalues(:))); 
            end;
            str = str(1:end-3);
         end;
      end;
   end;

   figure('Position', [300 300 300 20*(nlines)+40], 'MenuBar', 'none', ...
          'Name', 'trial_info', 'NumberTitle', 'off', 'resize', 'off');

   h = uicontrol('Style', 'text', 'Position', [10 10 280 20*nlines+20], ...
                 'HorizontalAlignment', 'left', ...
                 'BackgroundColor', 0.8*[1 1 1]);     
   set(h, 'string', str);
   

   
 case 'export', % ------------ case EXPORT ----------

   global Solo_datadir;
   % outfile = [Solo_datadir filesep 'Poke_Data' filesep rat '_' task '_' ...
   % date f_ver '.txt']; 
   outfile = 'exportdata.txt';
   fp = fopen(outfile, 'w');
   if isempty(value(plotted_trials)), fclose(fp); return; end;
   trial_info = Sound_type_history;
   
   
   % Find maxnumber of each type of state
   fnames = fieldnames(pstruct{plotted_trials(1)});
   maxlen = zeros(size(fnames));
   for i=1:length(value(plotted_trials)),
      for j=1:length(fnames),
         thislen = rows(pstruct{plotted_trials(i)}.(fnames{j}));
         if thislen > maxlen(j), maxlen(j) = thislen; end;
      end;
   end;

   tfnames = fieldnames(trial_info{1});
   
   % Print out header info:
   fprintf(fp, 'trial_num\t');
   % First the trial info:
   for i=1:length(tfnames),
      fprintf(fp, '%s\t', tfnames{i});
   end;
   % Next the pstruct data:
   for i=1:length(fnames),
      fprintf(fp, '%s\t', ['n_' fnames{i}]);
   end;
   for i=1:length(fnames),
      for j=1:maxlen(i), 
         fprintf(fp, '%s\t%s\t', [fnames{i} '_start'], [fnames{i} '_end']); 
      end;     
   end;
   fprintf(fp, '\n');
   
   for i=1:length(value(plotted_trials)),
      fprintf(fp, '%d\t', plotted_trials(i));
      for j=1:length(tfnames),
         if isstr(trial_info{plotted_trials(i)}.(tfnames{j})),
            fprintf(fp, '%s\t', trial_info{plotted_trials(i)}.(tfnames{j}));
         else
            fprintf(fp, '%g\t', trial_info{plotted_trials(i)}.(tfnames{j}));
         end;
      end;
      for j=1:length(fnames),
         fprintf(fp, '%d\t', rows(pstruct{plotted_trials(i)}.(fnames{j})));
      end;

      for j=1:length(fnames),
         theseguys = pstruct{plotted_trials(i)}.(fnames{j});
         if rows(theseguys)==0, thedefault = [0 0]; 
         else                   thedefault = theseguys(end,:);
         end;
         
         for k=1:maxlen(j),
            if k>rows(theseguys),
               fprintf(fp, '%d\t%d\t', thedefault(1), thedefault(2));
            else
               fprintf(fp, '%d\t%d\t', theseguys(k,1), theseguys(k,2));
            end;
         end;
      end;

      fprintf(fp, '\n');
   end;
   
   fclose(fp);
   
   
   
   
 case 'delete', % ------------ case DELETE ----------
  delete(value(myfig));
   
 otherwise,
   error(['Don''t know how to deal with action ' action]);
end;    


    
    

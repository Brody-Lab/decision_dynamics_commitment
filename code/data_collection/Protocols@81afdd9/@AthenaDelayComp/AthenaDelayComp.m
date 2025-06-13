% AthenaDelayComp protocol
% Athena Akrami, Feb 2012

function [obj] = AthenaDelayComp(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, pokesplot2, saveload, sessionmodel, soundmanager, soundui, antibias, ...
  water, distribui, punishui, comments, soundtable, sqlsummary,reinforcement);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')),
   return;
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are
   % Most likely responding to a callback from
   % a SoloParamHandle defined in this mfile.
   if length(varargin) < 2 || ~ischar(varargin{2}),
      error(['If called with a "%s" object as first arg, a second arg, a ' ...
         'string specifying the action, is required\n']);
   else action = varargin{2}; varargin = varargin(3:end); %#ok<NASGU>
   end;
else % Ok, regular call with first param being the action string.
   action = varargin{1}; varargin = varargin(2:end); %#ok<NASGU>
end;

GetSoloFunctionArgs(obj);

switch action,
   
   %% init
   case 'init'
    dispatcher('set_trialnum_indicator_flag');
    hackvar = 10; SoloFunctionAddVars('SessionModel', 'ro_args', 'hackvar'); %#ok<NASGU>
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = double(figure);

    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [485   144   850   680]);

    SoloParamHandle(obj, 'nsessions_healthy_number_of_pokes', 'value', 0, 'save_with_settings', 1);
    SoloParamHandle(obj, 'post_DelComp_protocol', 'value', '', 'save_with_settings', 1);
    SoloParamHandle(obj, 'post_DelComp_settings_filename', 'value', '', 'save_with_settings', 1);

    
    SoloParamHandle(obj, 'hit_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'hit_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'hit_history');
    
    SoloParamHandle(obj, 'pair_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'pair_history'});
    SoloFunctionAddVars('StimulusSection', 'rw_args', 'pair_history');
    
    SoloParamHandle(obj, 'violation_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'violation_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'violation_history');
    
    SoloParamHandle(obj, 'timeout_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'timeout_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'timeout_history');
   
    
    SoundManagerSection(obj, 'init');
    x = 5; y = 5;             % Initial position on main GUI window
    [x, y] = SavingSection(obj,       'init', x, y); 
    
    %% slow ramp up of water amount		
    %%the water volume is controlled by a 5-parameter logistic function: WaterAmount(t) = maxasymp + (minasymp/(1+(t/inflp)^slp).^assym)
    NumeditParam(obj, 'maxasymp', 38, x,y,'label','maxasymp','TooltipString',...
        'the water volume is controlled by a 5-parameter logistic function: WaterAmount(trialnum) = maxasymp + (minasymp/(1+(trialnum/inflp)^slp).^assym)');
	next_row(y);
	NumeditParam(obj, 'slp', 3, x,y,'label','slp','TooltipString','Water Modulation: Slope of the logistic function');	
	next_row(y);
	NumeditParam(obj, 'inflp', 300, x,y,'label','inflp','TooltipString','Water Modulation: concentration at the inflection point');	
	next_row(y);
    NumeditParam(obj, 'minasymp', -20, x,y,'label','inflp','TooltipString','Water Modulation: minimum asymptote');	
	next_row(y);
    NumeditParam(obj, 'assym', 0.7, x,y,'label','assym','TooltipString','Water Modulation: asymmetry factor');	
	next_row(y);
	DispParam(obj, 'trial_1', 0, x, y, 'TooltipString', 'uL on first trial');
	next_row(y);
	DispParam(obj, 'trial_150', 0, x, y, 'TooltipString', 'uL on trial 150');
	next_row(y);
	DispParam(obj, 'trial_300', 0, x, y, 'TooltipString', 'uL on trial 300');
	next_row(y);
	set_callback({maxasymp;slp;inflp;minasymp;assym}, {mfilename, 'change_water_modulation_params'});
	feval(mfilename, obj, 'change_water_modulation_params');
	
	
    SoloFunctionAddVars('AthenaSMA', 'ro_args', ...
			{'maxasymp';'slp';'inflp';'minasymp';'assym'});
    [x, y] = WaterValvesSection(obj,  'init', x, y);
    
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    my_state_colors = AthenaSMA(obj, 'get_state_colors');
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    my_poke_colors = struct( ...
    'L',                  0.6*[1 0.66 0],    ...
    'C',                      [0 0 0],       ...
    'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
    struct('states',  my_state_colors, 'pokes', my_poke_colors)); next_row(y);

    [x, y] = CommentsSection(obj, 'init', x, y);
    SessionDefinition(obj, 'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    SessionDefinition(obj, 'set_old_style_parsing_flag',0);
    % [x, y] = PunishmentSection(obj, 'init', x, y); %#ok<NASGU>
    
    next_column(x); y=5;
	[x, y] = OverallPerformanceSection(obj, 'init', x, y);
    [x, y] = StimulatorSection(obj, 'init', x, y); next_row(y, 1.3);
	[x, y] = SideSection(obj,  'init', x, y); %#ok<NASGU>
    [x, y] = SoundSection(obj,'init',x,y);
%    [x, y] = PlayStimuli(obj,'init',x,y);
    [x, y] = StimulusSection(obj,'init',x,y);

    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], x, y, 'position', [10 figpos(4)-25, 800 20]);

    AthenaSMA(obj, 'init');
    feval(mfilename, obj, 'prepare_next_trial');
         
      %% change_water_modulation_params
   case 'change_water_modulation_params',
	   display_guys = [1 150 300];
	   for i=1:numel(display_guys),
		   t = display_guys(i);
	   
		   myvar = eval(sprintf('trial_%d', t));
		   myvar.value = maxasymp + (minasymp/(1+(t/inflp)^slp).^assym);
	   end;
	
      %% prepare next trial
   case 'prepare_next_trial'

       SideSection(obj, 'prepare_next_trial');
	% Run SessionDefinition *after* SideSection so we know whether the
	% trial was a violation or not
       SessionDefinition(obj, 'next_trial');
       StimulatorSection(obj, 'update_values');
       OverallPerformanceSection(obj, 'evaluate');
       StimulusSection(obj,'prepare_next_trial');
       SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    
    
       nTrials.value = n_done_trials;

       [sma, prepare_next_trial_states] = AthenaSMA(obj, 'prepare_next_trial');

    % Default behavior of following call is that every 20 trials, the data
    % gets saved, not interactive, no commit to CVS.
       SavingSection(obj, 'autosave_data');
    
       CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
       if n_done_trials==1,  % Auto-append date for convenience.
            CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
       end;

       if n_done_trials==1
            [expmtr, rname]=SavingSection(obj, 'get_info');
            prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
       end
      
       try send_n_done_trials(obj); end

      %% trial_completed
   case 'trial_completed'
       
    % Do any updates in the protocol that need doing:
    feval(mfilename, 'update');
    % And PokesPlot needs completing the trial:
    PokesPlotSection(obj, 'trial_completed');
      %% update
   case 'update'
      PokesPlotSection(obj, 'update');
      
      
      %% close
   case 'close'
    PokesPlotSection(obj, 'close');
    %PunishmentSection(obj, 'close');
	SideSection(obj, 'close');
    StimulusSection(obj,'close');
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
      delete(value(myfig));
    end;
    delete_sphandle('owner', ['^@' class(obj) '$']);

      
      %% end_session
   case 'end_session'
      prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
    
      
      %% pre_saving_settings
   case 'pre_saving_settings'
       
    StimulusSection(obj,'hide');
    SessionDefinition(obj, 'run_eod_logic_without_saving');
    perf    = OverallPerformanceSection(obj, 'evaluate');
    cp_durs = SideSection(obj, 'get_cp_history');
    [classperf tot_perf]= StimulusSection(obj, 'get_class_perform');
    [pairs_u pairs_d] = StimulusSection(obj,'get_pairs');
    stim_history = StimulatorSection(obj,'get_history');
    
	CommentsSection(obj, 'append_line', ...
		sprintf(['ntrials = %d, violations = %.2f, timeouts=%.2f, hits = %.2f\n', ...
		'pre-Go cue went from %.3f to %.3f  (delta=%.3f)\n', ...
        'RightLow = %.2f, RightHigh = %.2f, LeftLow = %.2f, LeftHigh = %.2f'], ...
		perf(1), perf(2), perf(3), perf(6), cp_durs(1), cp_durs(end), cp_durs(end)-cp_durs(1), classperf(1),classperf(2),classperf(3),classperf(4)));

    pd.hits=hit_history(:);
    pd.sides=previous_sides(:);
    pd.viols=violation_history(:);
    pd.timeouts=timeout_history(:);
    pd.performance=tot_perf(:);
    pd.cp_durs=cp_durs(:);
    pd.pairs_u=pairs_u(:);
    pd.pairs_d=pairs_d(:);
    pd.pairs=pair_history(:);
    pd.stimul=stim_history(:);
    
    sendsummary(obj,'protocol_data',pd);    
      
      %% otherwise
   otherwise,
      warning('Unknown action! "%s"\n', action);
end;

return;


% Adapted from Athena's Delayed Comparison Task to the head-fixed system
% Christine Constantinople, October 2013

function [obj] = FixedDelayComp(varargin)

% Default object is of our own class (mfilename);
% we inherit only from Plugins

obj = class(struct, mfilename, pokesplot, saveload, sessionmodel, soundmanager, soundui, antibias, ...
  water, distribui, punishui, comments, HFwateradaptor, soundtable, sqlsummary,reinforcement);

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
    %%% CHRISTINE ADDED THESE!!!!
    SoloParamHandle(obj, 'thisside', 'value', []);
    %SoloParamHandle(obj, 'thisdelay', 'value', []);
    SoloParamHandle(obj, 'RandomizePressure', 'value', []);
    %SoloParamHandle(obj, 'thispressure', 'value', []);
    SoloParamHandle(obj, 'ProbMaxPressure', 'value', []);
    SoloParamHandle(obj, 'pressure', 'value', []);
    SoloParamHandle(obj, 'StepSize', 'value', 300);
    SoloParamHandle(obj, 'pair_history', 'value', []);
    SoloParamHandle(obj, 'microswitch_counter', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'thisside', ...
        'RandomizePressure','ProbMaxPressure', 'StepSize', 'pair_history', 'microswitch_counter'});
    SoloFunctionAddVars('StimulusSection', 'rw_args', 'pair_history');
    
    %SoloParamHandle(obj, 'trials_in_stage', 'value', []);
    %SoloParamHandle(obj, 'use_training', 'value', []);
    %DeclareGlobals(obj, 'ro_args', {'use_training', 'trials_in_stage'});
    
    SoloParamHandle(obj, 'hit_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'hit_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'hit_history');
    
    SoloParamHandle(obj, 'violation_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'violation_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'violation_history');
    
    SoloParamHandle(obj, 'error_history', 'value', []);
    DeclareGlobals(obj, 'ro_args', {'error_history'});
    SoloFunctionAddVars('SideSection', 'rw_args', 'error_history');
    
    
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
    NumeditParam(obj, 'Automate_water', 0, x, y, 'label', 'Automate_water', 'TooltipString', 'Automatically increase water params and make decisions about ad lib water');
    next_row(y);
    NumeditParam(obj, 'thisdelay', 0.3, x, y, 'TooltipString', 'Delay on this trial');
    next_row(y, 1);
    NumeditParam(obj, 'pressure', 0, x, y, 'TooltipString', 'PistonPressure; should be [0 90]');  %pisotns actuate beginning at about 20psi
    next_row(y, 1);
    NumeditParam(obj, 'maxpressure', .9, x, y, 'TooltipString', 'maxpressure');
    next_row(y, 1);
    DispParam(obj, 'thispressure', 0, x, y, 'TooltipString', 'thispressure');
    next_row(y, 1);
    NumeditParam(obj, 'ProbMaxPressure', 0.5, x, y, 'TooltipString', 'Prob Max Pressure');
    next_row(y, 1);
    NumeditParam(obj, 'RandomizePressure', 0, x, y, 'TooltipString', 'Randomize Pressure');
    next_row(y, 1);
    NumeditParam(obj, 'StepSize', 300, x, y, 'TooltipString', 'StepSize');
    next_row(y, 1);
    NumeditParam(obj, 'microswitch_counter', 0, x, y, 'TooltipString', 'Microswitch_Counter');
    next_row(y, 1);
    NumeditParam(obj, 'NosPos', 0, x, y, 'TooltipString', 'Lick Tube Position')
    next_row(y, 1);
    NumeditParam(obj, 'use_training_on', 1, x, y,'label','use_training_on','TooltipString','Enable Automated Training');
    next_row(y, 1);
    NumeditParam(obj, 'trials_in_stage_on', 0, x, y, 'label', 'trials_in_stage','TooltipString', 'if use_training_on, trials_in_stage');
    next_row(y, 1);
    
    SoloFunctionAddVars('SMASection', 'ro_args', ...
			{'maxasymp';'slp';'inflp';'minasymp';'assym';'NosPos';...
            'thisdelay'; 'thispressure'; 'use_training_on'; 'trials_in_stage_on'});
    SoloFunctionAddVars('SMASection', 'rw_args', {'StepSize'});
    [x, y] = WaterValvesSection(obj,  'init', x, y);
    
    [x, y] = HFWaterAdaptorSection(obj, 'init', x, y);
    
    % For plotting with the pokesplot plugin, we need to tell it what
    % colors to plot with:
    my_state_colors = SMASection(obj, 'get_state_colors');
    % In pokesplot, the poke colors have a default value, so we don't need
    % to specify them, but here they are so you know how to change them.
    my_poke_colors = struct( ...
    'L',                  0.6*[1 0.66 0],    ...
    'C',                  0.3*[1 0.66 0],    ... 
    'D',                      [0 0 0],       ...
    'R',                  0.9*[1 0.66 0]);
    
    [x, y] = PokesPlotSection(obj, 'init', x, y, ...
    struct('states',  my_state_colors, 'pokes', my_poke_colors)); next_row(y);
    SoloParamHandle(obj, 'have_i_crashed_yet',   'value', 0);
    SoloParamHandle(obj, 'have_i_crashed_point', 'value', '');

    [x, y] = CommentsSection(obj, 'init', x, y);
    SessionDefinition(obj, 'init', x, y, value(myfig)); next_row(y, 2); %#ok<NASGU>
    SessionDefinition(obj, 'set_old_style_parsing_flag',0);
    %[x, y] = PunishmentSection(obj, 'init', x, y); %#ok<NASGU>
    
    next_column(x); y=5;
	[x, y] = OverallPerformanceSection(obj, 'init', x, y);
	[x, y] = SideSection(obj,  'init', x, y); %#ok<NASGU>
    [x, y] = SoundSection(obj,'init',x,y);
    [x, y] = StimulusSection(obj,'init',x,y);
    
    figpos = get(gcf, 'Position');
    [expmtr, rname]=SavingSection(obj, 'get_info');
    HeaderParam(obj, 'prot_title', [mfilename ': ' expmtr ', ' rname], x, y, 'position', [10 figpos(4)-25, 800 20]);

    SMASection(obj, 'init');
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
	   try
           

		   SideSection(obj, 'prepare_next_trial');
		   % Run SessionDefinition *after* SideSection so we know whether the
		   % trial was a violation or not
		   SessionDefinition(obj, 'next_trial');
		   OverallPerformanceSection(obj, 'evaluate');
		   StimulusSection(obj,'prepare_next_trial');
		   %SoundSection(obj, 'prepare_next_trial');
		   SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
		   
		   try send_n_done_trials(obj);
		   end
		   
		   nTrials.value = n_done_trials;
		   
		   [sma, prepare_next_trial_states] = SMASection(obj, 'prepare_next_trial');
		   
		   
		   % Default behavior of following call is that every 20 trials, the data
		   % gets saved, not interactive, no commit to CVS.
		   SavingSection(obj, 'autosave_data');
		   
           if value(Automate_water)==1;
              if n_done_trials==0;
                  minasymp.value = -10;
                  maxasymp.value = 38;
              elseif value(n_done_trials)==80;
                  minasymp.value = -5;
              elseif value(n_done_trials)==150;
                  maxasymp.value = 48;   
              end
           end
           
		   CommentsSection(obj, 'clear_history'); % Make sure we're not storing unnecessary history
		   if n_done_trials==1,  % Auto-append date for convenience.
			   CommentsSection(obj, 'append_date'); CommentsSection(obj, 'append_line', '');
		   end;
		   
		   if n_done_trials==1
			   [expmtr, rname]=SavingSection(obj, 'get_info');
			   prot_title.value=[mfilename ' on rig ' get_hostname ' : ' expmtr ', ' rname  '.  Started at ' datestr(now, 'HH:MM')];
		   end
		   
	   catch ME;
		   if have_i_crashed_yet==0, %#ok<*NODEF>
			   have_i_crashed_yet.value = 1;
			   have_i_crashed_point.value = 'prepare_next_trial'; %#ok<*STRNU>
			   save('../Protocols/@FixedDelayComp/crash_report');
		   end;
	   end;
      
      %% trial_completed
   case 'trial_completed'
	   try
           % Do any updates in the protocol that need doing:
           feval(mfilename, 'update');
           % And PokesPlot needs completing the trial:
           PokesPlotSection(obj, 'trial_completed');
          
           
          if n_done_trials==1,
              HFWaterAdaptorSection(obj, 'set_first_trial_time_stamp');
              CommentsSection(obj, 'append_date');
              CommentsSection(obj, 'append_line', '');
          end
         
           
%            if n_done_trials = 0,
%                hit_history.value=0;
% 			   violation_history.value=0;
% 			   RT_history=0;
% 			   previous_sides.value=0;
% 			   trial.value = 0;
% 			   error_history.value=0;
% 			   %PSI_history.value=0;
% 		   elseif n_done_trials > 0,
% 			   if ~isempty(parsed_events.states.drink_state)
% 				   thishit=1;
% 				   thisviolation=NaN;
% 				   thiserror = NaN;
% 			   elseif ~isempty(parsed_events.states.second_hit_state)
% 				   thishit = 0;
% 				   thisviolation = NaN;
% 				   thiserror = 1;
% 			   elseif ~isempty(parsed_events.states.violation_state)
% 				   thishit=NaN;
% 				   thisviolation = 1;
% 				   thiserror = NaN;
% 			   end
% 			   hit_history.value = [hit_history(:); thishit];
% 			   violation_history.value = [violation_history(:); thisviolation];
% 			   error_history.value = [error_history(:); thiserror];
% 			   %previous_sides.value = [previous_sides(:); value(thisside)];
% 			   trial.value = n_done_trials;
% 			   %PSI_history.value = [PSI_history(:); value(pressure)];
%            end
%            
           side = SideSection(obj, 'get_previous_sides');
           side = side(end);  
           if side == 'l'
               x = 'l';
           elseif side == 'r'
               x = 'r';
           end;
           HFWaterAdaptorSection(obj, 'update_water_volume', x);
		   
           if n_done_trials > 0,
               if ~isempty(parsed_events.states.drink_state)
				   thishit=1;
				   thisviolation=NaN;
				   thiserror = NaN;
			   elseif ~isempty(parsed_events.states.second_hit_state)
				   thishit = 0;
				   thisviolation = NaN;
				   thiserror = 1;
			   elseif ~isempty(parsed_events.states.violation_state)
				   thishit=NaN;
				   thisviolation = 1;
				   thiserror = NaN;
               end
           end
           
           if n_done_trials > 0
               if ~isempty(parsed_events.states.cpslotonly)
                   microswitch_counter.value = value(microswitch_counter)+1;
               else microswitch_counter.value = 0;
               end
               if value(microswitch_counter)>20
                   StepSize.value = 0;
                   WaitStepSize.value = 0.001;
               end
           end
           
		   if use_training_on==1
			   if ~isnan(thishit)
				   trials_in_stage_on.value = value(trials_in_stage_on)+1;
			   end
			   switch value(training_stage)
				   case 1,
					   if strcmp(reward_type, 'Always')
						   if trials_in_stage_on > 1500
							   reward_type.value = 'DelayedReward';
							   secondhit_delay.value = 0;
							   trials_in_stage_on.value=0;
						   end
					   elseif strcmp(reward_type, 'DelayedReward')
						   if trials_in_stage_on > 150 && value(secondhit_delay)==0
							   secondhit_delay.value = 1;
							   trials_in_stage_on.value = 0;
						   elseif trials_in_stage_on > 150 && 0<value(secondhit_delay) && value(secondhit_delay)<9;
							   secondhit_delay.value = value(secondhit_delay)+2;
							   trials_in_stage_on.value = 0;
						   elseif trials_in_stage_on > 150 && value(secondhit_delay)>=9;
							   reward_type.value = 'NoReward';
							   trials_in_stage_on.value = 0;
						   end
					   end
			   end
		   end
		   
		   
		   if value(RandomizePressure)==1
			   if n_done_trials <= 24
				   thispressure.value = 0;
			   elseif n_done_trials > 24 && n_done_trials <= 30
				   thispressure.value = value(pressure);
			   elseif n_done_trials > 30
				   if rand(1) > value(ProbMaxPressure),
					   thispressure.value = value(pressure);
				   else
					   thispressure.value = value(maxpressure);
				   end
			   end
		   elseif value(RandomizePressure)==0
			   thispressure.value = value(pressure);
		   end
		   
		   if ~isempty(parsed_events.waves.step)
			   NosPos.value=value(NosPos)+value(StepSize);
           end
           if value(NosPos)>15000;
               NosPos.value = 14000;
               StepSize.value = 0;
           end
	   catch ME;
		   if have_i_crashed_yet==0, %#ok<*NODEF>
			   have_i_crashed_yet.value = 1;
			   have_i_crashed_point.value = 'trial_completed'; %#ok<*STRNU>
               %warning('The error message was %s', ME.message); 
			   save('../Protocols/@FixedDelayComp/crash_report');
		   end;
	   end;

      %% update
   case 'update'
		try
			PokesPlotSection(obj, 'update');
		catch ME;
			have_i_crashed_yet.value = 1;
			have_i_crashed_point.value = 'update'; %#ok<*STRNU>
			if have_i_crashed_yet==0, %#ok<*NODEF>
				save('../Protocols/@FixedDelayComp/crash_report');
			end;
		end;
      
      
      %% close
   case 'close'
	   try
		   PokesPlotSection(obj, 'close');
		   %PunishmentSection(obj, 'close');
		   SideSection(obj, 'close');
		   StimulusSection(obj,'close');
		   HFWaterAdaptorSection(obj, 'close');
           
		   if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), %#ok<NODEF>
			   delete(value(myfig));
		   end;
		   delete_sphandle('owner', ['^@' class(obj) '$']);
	   
	   catch ME;
			have_i_crashed_yet.value = 1;
			have_i_crashed_point.value = 'close'; %#ok<*STRNU>
			if have_i_crashed_yet==0, %#ok<*NODEF>
				save('../Protocols/@FixedDelayComp/crash_report');
			end;
		end;

      
      %% end_session
   case 'end_session'
      prot_title.value = [value(prot_title) ', Ended at ' datestr(now, 'HH:MM')];
      HFWaterAdaptorSection(obj, 'evaluate_outcome');

      
      %% pre_saving_settings
   case 'pre_saving_settings'
%     if RewardsSection(obj, 'get_poked_trials') >= 60,
%       nsessions_healthy_number_of_pokes.value = nsessions_healthy_number_of_pokes+1; %#ok<NODEF>
%     end;
% 
%     
%     SessionDefinition(obj, 'nongui_change_active_stage', 1);
%     
%     if nsessions_healthy_number_of_pokes >= 4 && ~isempty(post_classical_protocol),
%       code_dir = bSettings('get', 'GENERAL', 'Main_Code_Directory');
%       data_dir = bSettings('get', 'GENERAL', 'Main_Data_Directory');
% 
%        [expname, ratname] = SavingSection(obj, 'get_info'); 
%        settingsfile = [data_dir filesep 'Settings' filesep expname filesep ratname filesep,...
%          value(post_classical_settings_filename)];
%          
%        if exist(settingsfile,'file') == 0
%          settingsfile = [code_dir filesep 'Protocols' filesep '@' value(post_classical_protocol) ...
%            filesep value(post_classical_settings_filename)];
%        end
%        
%        targetfile = [data_dir filesep 'Settings' filesep expname filesep ratname filesep ...
%          'settings_@' value(post_classical_protocol) '_' expname '_' ratname '_' yearmonthday(now+1) 'a.mat'];
%        
%        [success, message] = copyfile(settingsfile, targetfile);
%        if ~success,
%          CommentsSection(obj, 'append_line', ...
%            sprintf('Making %s settings failed-- message was %s', ...
%            value(post_classical_protocol), message));
%        else
%          [errid, errmsg] = add_and_commit(targetfile);
%          if errid~=0,
%            CommentsSection(obj, 'append_line', ...
%              sprintf('Adding and committing %s settings failed-- message was %s', ...
%              value(post_classical_protocol), errmsg));
%          end;
%        end;
%     
%     end;
try
	StimulusSection(obj,'hide');
	SessionDefinition(obj, 'run_eod_logic_without_saving');
	perf    = OverallPerformanceSection(obj, 'evaluate');
	cp_durs = SideSection(obj, 'get_cp_history');
	[classperf tot_perf]= StimulusSection(obj, 'get_class_perform');
	
	CommentsSection(obj, 'append_line', ...
		sprintf(['ntrials = %d, violations = %.2f, timeouts=%.2f, hits = %.2f\n', ...
		'pre-Go cue went from %.3f to %.3f  (delta=%.3f)\n', ...
		'RightLow = %.2f, RightHigh = %.2f, LeftLow = %.2f, LeftHigh = %.2f'], ...
		perf(1), perf(2), perf(3), perf(6), cp_durs(1), cp_durs(end), cp_durs(end)-cp_durs(1), classperf(1),classperf(2),classperf(3),classperf(4)));
	
	
	pd.hits=hit_history(:);
	pd.sides=previous_sides(:);
	pd.viols=violation_history(:);
	pd.errors=error_history(:);
	pd.performance=tot_perf(:);
	pd.cp_durs=cp_durs(:);
    pd.pairs = pair_history(:);
	
	sendsummary(obj,'protocol_data',pd);
catch ME;
	have_i_crashed_yet.value = 1;
	have_i_crashed_point.value = 'pre_saving_settings'; %#ok<*STRNU>
	if have_i_crashed_yet==0, %#ok<*NODEF>
		save('../Protocols/@FixedDelayComp/crash_report');
	end;
end;
      
      %% otherwise
   otherwise,
      warning('Unknown action! "%s"\n', action);
end;

return;


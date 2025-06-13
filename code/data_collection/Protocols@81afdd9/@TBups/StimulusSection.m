% @TBups/StimulusSection.m
% Bing, February 2009

% [x, y] = YOUR_SECTION_NAME(obj, action, varargin)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function [x, y] = StimulusSection(obj, action, varargin)
   
GetSoloFunctionArgs;

switch action
%% init    
  case 'init',
      x = varargin{1};
      y = varargin{2};
      
      % Save the figure and the position in the figure where we are going
      % to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

      NumeditParam(obj, 'nose_in_center', 0.5, x, y, ...
          'labelfraction', 0.5, ...
          'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
      next_row(y);
      SoloParamHandle(obj,'max_nic_previous_day','value',0,'save_with_settings',1); % EDIT HERE
      
      ToggleParam(obj, 'go_sound', 0, x, y, 'position', [x y 100 20], ...
      'OnString', 'go sound ON', 'OffString', 'go sound OFF', ...
      'TooltipString', sprintf(['\nsound that is triggered when reward is available']));
      ToggleParam(obj, 'go_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
        'OnString', 'go showing', 'OffString', ' go hidden', ...
        'TooltipString', sprintf(['\nshow or hide the interface for the go_sound']));
      set_callback(go_sound_show, {mfilename 'go_sound_show'}); %#ok<NODEF>
      next_row(y);   

      %Put up the little figure for the go_sound, set up the SoundUI,
      %then close the figure:
      currfig = double(gcf); cfpos = get(currfig, 'Position');
      SoloParamHandle(obj, 'go_sound_fig', 'value', ...
        double(figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'go_sound', ...
        'CloseRequestFcn', [mfilename '(' class(obj) ', ''go_sound_hide'')'])), ...
        'saveable', 0);
      myx = 10; myy = 10;
      SoundInterface(obj, 'add', 'go_sound', myx, myy);
      SoundInterface(obj, 'set', 'go_sound', 'Style', 'WhiteNoise', 'Vol', 0.001, ...
        'Dur1', 0.2, 'Loop', 0, 'Bal', 0);
      go_sound_show.value = 0;
      set(value(go_sound_fig), 'Visible', 'off');
      
      figure(currfig);

      NumeditParam(obj, 'settling_in_dur',0.15, x, y, 'position', [x y 130 20], ...
          'labelfraction', 0.4, ...
          'TooltipString', sprintf(['\nPeriod after the initial cpoke that rats can nose-out' ...
          'without a violation']));
      next_row(y);

      NumeditParam(obj, 'legal_cbreak', 0.001, x, y,'position', [x y 130 20], ... 
          'labelfraction', 0.4, ...
          'TooltipString', sprintf(['\nGoing out of the center poke and poking back in' ...
          '\nwithin this many seconds means the nose-out is ignored, it is treated' ...
          '\nas if the rat had kept his nose in the center continuously.' ...
          '\n In RT task, this parameter applies only during times in the trial earlier'  ...
          '\n than when the choice is allowed (set by min_rt)']));
      
      ToggleParam(obj, 'require_repoke', 1, x, y, 'position', [x+130 y 70 20], ...
      'OnString', 'require_repoke', 'OffString', 'no_require', ...
      'TooltipString', sprintf(['\nIf On (black, default behavior), the rat must reacquire fixation before the end of' ...
                                '\nthe NIC period to avoid a violation. ' ...
                                '\nIf Off (brown), the rat is allowed to make a choice even if ' ...
                                '\nhe is out of the center port when the NIC period ends' ...
                                '\nso long as he did not exceed the legal_cbreak']));
      next_row(y);
      
      %% NOT CURRENTLY IN STATE MACHINE
      ToggleParam(obj, 'new_trial_on_violation', 0, x, y, 'position', [x y 120 20], ...
          'OnString', 'new trial on viol', 'OffString', 'temp pun on viol', ...
          'TooltipString', sprintf(['\nIf On (black), a new trial is initiated at a nic violation' ...
                                    '\nafter a temp pun of duration reinit_dur' ...
                                    '\nIf Off (brown), a small temp pun occurs, followed by' ...
                                    '\nthe reinitiation of the same trial; note that the nic' ...
                                    '\nmust be successfully completed before moving on to the next trial']));
      NumeditParam(obj, 'reinit_dur', 3, x, y, 'position', [x+120 y 80 20], ...
          'labelfraction', 0.6, ...
          'TooltipString', sprintf(['\nIf new trial on viol, the duration of the temp pun' ...
                                    '\nin seconds, during which the TimeOutPun_OngoingSnd will play']));
      disable(reinit_dur);
      set_callback(new_trial_on_violation, {mfilename 'new_trial_on_violation'});
      next_row(y);
                   
      ToggleParam(obj, 'center_light',1, x, y,'position', [x y 100 20], ...
                    'OnString', 'Center LED on', 'OffString', 'Center LED never on', ...
                    'TooltipString', sprintf(['whether the center LED is on during cpoke req or not' ...
                                                'if on, on from trial available to end of during stim.']));
        ToggleParam(obj, 'cpoke_first', 1, x,y, 'position', [x+100 y 100 20], ...
                    'OnString', 'Cpoke On', 'OffString', 'Cpoke off', ...
                    'TooltipString', sprintf(['whether a cpoke is necessary first for stim and side reward. For training.']))
                                        
      next_row(y);
       ToggleParam(obj, 'use_give' , 0, x, y, 'position', [x y 100 20], ...
          'OnString', 'use give', 'OffString', 'no give', ...
          'TooltipString', sprintf(['\nIf On, the light_give_frac is used to determine if the trial will be light and sound' ...
                                    '\nIf Off, the light_give_frac is ignored and all trials are governed by stim_type set elsewhere']));

        NumeditParam(obj, 'light_give_frac',0, x, y,'position', [x+100 y 100 20], ...
          'labelfraction', 0.6, ...
          'TooltipString', sprintf(['\nFraction of trials that will be Light AND Sound' ...
                                    '\nIf 0, then all trials are Sound only']));

        next_row(y);

        ToggleParam(obj,'replay_stim', 0, x,y, 'position', [x y 100 20], ...
                    'OnString', 'replay on', 'OffString', 'replay off', ...
                    'TooltipString', sprintf(['If on, the same stimulus train plays during hit state for reinforcement'...
                                              '\nIf off, no stim train in reward period']))
        next_row(y);
        ToggleParam(obj,'continue_stim',0, x,y, 'position', [x y 100 20], ...
                    'OnString', 'continue stim', 'OffString', 'stop stim', ...
                    'TooltipString', sprintf(['If on, the stimulus reinits post go sound'...
                                              '\nIf off, the stimulus stops before the go sound']))                                   

        next_row(y);
        MenuParam(obj, 'stim_type', {'Light Only', 'Sound Only', 'Light AND Sound'}, 2, x,y, ...
                    'labelfraction', 0.3, ...
                    'TooltipString', sprintf(['Controls what stimulus indicates correct side.' ...
                                            '\nIf light only, no sounds and correct side LED turns on.'...
                                            '\nIf sound only, only the sound train and no LED.'...
                                            '\nIf light and sound, both.']))

      next_row(y);
        
      NumeditParam(obj, 'fixed_stim_dur', 1, x, y, ...
          'TooltipString', 'Stimulus duration. Set from parameters specified in TBupsSection.');

      next_row(y);
    
      NumeditParam(obj, 'light_on_delay', 0, x, y, ...
          'TooltipString', 'time before give light turns on. used to push back give');      

      next_row(y);

      MenuParam(obj, 'stim_timing', {'Fixed T After Start', 'During Cpoke Only'}, 2, x, y, ...
          'labelfraction', 0.3, ...
          'TooltipString', sprintf(['\n Controls the timing of when the stimulus is on' ...
                                    '\n If Fixed T After Stim Start, stim is stopped after a fixed time' ...
                                    '\n If During Cpoke Only, stim is only ON in one of the cpoke states' ...
                                    '\n In the latter case, a legal cbreak near the end of a trial may cause the stimulus duration to exceed what is specified' ...
                                    '\n In the former case, the stimulus would end in the middle of a similarly timed legal cbreak' ...
                                    '\n Fixed T must be chosen for memory gap functionality']));
      % set_callback(stim_timing,   {mfilename, 'stim_timing'});
      set_callback_on_load(stim_timing, 1);
	  next_row(y);
     
    %   ToggleParam(obj, 'rt_task', 0, x, y, ...
    %         'OffString', 'non-reaction time task', ...
    %         'OnString',  'reaction time task', ...
    %         'TooltipString', sprintf(['\n' ...
    %         'If reaction time task, then rat can indicate choice any time min_rt after stimulus onset.\n' ...
    %         'If non-reaction time task, then stimulus duration is controlled by experimenter.\n']));
    %   set_callback(rt_task,   {mfilename, 'rt_task'});
    %   set_callback_on_load(rt_task, 1);
    %   next_row(y);
      
    %   NumeditParam(obj, 'min_rt', 0, x, y, ...
	% 	  'TooltipString', sprintf(['the stimulus must be on for at least this amount of time before a rat can break NIC and make choice'...
    %       '\n Earlier broken NICs will lead to a violation'...
    %       '\n For non-RT task, automatically set to be nic - stim_start_delay']));
    %   disable(min_rt);
    %   next_row(y);
      
    %   DistribInterface(obj, 'add', 'rt_stim_delay', x, y, 'Style', ...
    %                 'uniform', 'Min', 0, 'Max', 0,...
    %                 'TooltipString', sprintf(['In the RT task, sets the delay to stimulus onset.'...
    %                 '\n Not used in non-RT tasks.']));
                   
      NumeditParam(obj, 'stim_start_delay', 0, x, y, ...
          'TooltipString', sprintf(['The delay (in sec) between cpoke1 and when the stimulus starts playing'...
                    '\n In non-RT tasks, it is set by nic minus memory gap for current trial minus stimulation duration, the last being controlled through TBupSection']));

      next_row(y);          
      [x, y] = TBupsSection(obj, 'init', x, y);
	  SubheaderParam(obj, 'title', 'StimulusSection', x, y);
	  
	  % to store all the relevant info about the stimulus to pass onto
	  % StateMatrix Section
	  specs.sound_id = 0;
	  specs.sound_delay = 0;
	  specs.stim_timing = value(stim_timing);
	  specs.sound_dur = 0;
	  SoloParamHandle(obj, 'StimulusSpecs', 'value', specs); 
      
      SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'legal_cbreak';  'nose_in_center';'go_sound'; ...
          'light_give_frac'; 'center_light'; 'settling_in_dur';...
          'fixed_stim_dur' ; 'stim_start_delay'; ...
          'new_trial_on_violation'; 'reinit_dur';'light_on_delay'; ...
          'require_repoke'; 'cpoke_first'; 'stim_type'; 'replay_stim'; 'continue_stim' ...
          });

      SoloFunctionAddVars('RewardsSection', 'ro_args', {'stim_type','use_give'});
      SoloFunctionAddAllVars(obj, 'TrainingSection', 'rw_args');
      SoloFunctionAddVars('TBupsSection','ro_args',{'nose_in_center'});

      for i = 1:numel(value(active_curricula))
        % Construct the function call with the updated curriculum name
        current_curricula = value(active_curricula{i});
        function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'rw_args');", current_curricula);
        eval(function_call);
      end
      
    %   feval(mfilename, obj, 'side_lights');
	  % feval(mfilename, obj, 'stim_timing');


%% next_trial
  case 'next_trial',      

	  % makes next sound
	  % returns next sound (specifically, an integer ID of the ordinal stimulus strength) and next sample duration
	  
	  if ~isempty(varargin) && ~isempty(varargin{1}),
		  set_side = varargin{1};
	  else
		  set_side = '';
	  end;

    if value(use_give)
      feval(mfilename, obj, 'give_this_trial');
	  end
    
	  [previous_sides, previous_sounds] = SidesSection(obj, 'get_previous_sides_and_sounds');
	  [this_sound, this_T] = TBupsSection(obj, 'next_trial', set_side, previous_sides, previous_sounds,replay_stim,continue_stim);
	  fixed_stim_dur.value = this_T;

    stim_start_delay.value = max(0, nose_in_center - fixed_stim_dur);

	  x = this_sound;
	  y = this_T;
	  
	  % populate the StimulusSpecs cell
      specs.sound_id    = SoundManagerSection(obj, 'get_sound_id', 'TBupsSound');
	  specs.sound_delay = stim_start_delay(1);
	  specs.stim_timing = value(stim_timing);

	  switch value(stim_timing),
		  case 'Fixed T After Start',
			  specs.sound_dur = fixed_stim_dur(1);
		  case 'During Cpoke Only',
			  % if sound stays on for as long as cpoke1, let
			  % StateMatrixSection decide when to turn the sound off
			  specs.sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'TBupsSound');
	  end;
      
      % if not rt_task, then subject is not allowed to respond prematurely
    %   if ~value(rt_task)
          % add 0.1 sec for safety because the min_rt wave is checked one
          % state transition after cpoke_timer wave
      min_rt.value = nose_in_center - stim_start_delay + 0.1; 
    %   end
      
	  StimulusSpecs.value = specs;
	  
  case 'give_this_trial'
    if value(light_give_frac) > rand(1)
      stim_type.value = 'Light AND Sound';
    else
      stim_type.value = 'Sound Only';
    end;
%% get_stimulus_specs
  case 'get_stimulus_specs'
	  x = value(StimulusSpecs);
    % y = TBupsSection(obj, 'get_stimulator_specs');
%% stim_timing
  case 'stim_timing'
      switch value(stim_timing), %#ok<NODEF>
          case 'Fixed T After Start', 
			  enable(memory_gap);
              enable(prob_mem_gap);
          case 'During Cpoke Only', 
              prob_mem_gap.value = 0;
              memory_gap.value = 0;
			  disable(memory_gap);
              disable(prob_mem_gap);
      end;	 
   
    %% go sound figure
    case 'go_sound_show'
        if go_sound_show==1, %#ok<NODEF>
        set(value(go_sound_fig), 'Visible', 'on');
        else
        set(value(go_sound_fig), 'Visible', 'off');
        end;     
        
%% new_trial_on_violation
  case 'new_trial_on_violation'
      if new_trial_on_violation==1,
          enable(reinit_dur);
      else
          disable(reinit_dur);
      end;
      
%% close
  case 'close',
    TBupsSection(obj, 'close');
    delete(value(nic_end_sound_fig));
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);    


%% end_session
  case 'end_session',
        

%% reinit
  case 'reinit',
    currfig = double(gcf);

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); f = my_gui_info(3);

    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    figure(f);
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;

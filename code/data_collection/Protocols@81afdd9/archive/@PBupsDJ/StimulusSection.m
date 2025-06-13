% @PBups/StimulusSection.m
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
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      NumeditParam(obj, 'nose_in_center', 0.5, x, y, ...
          'labelfraction', 0.5, ...
          'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
      next_row(y);
      
      NumeditParam(obj, 'legal_cbreak_rt', 0.000, x, y, ... 
          'labelfraction', 0.5, ...
          'TooltipString', sprintf(['\n Same functionality as legal_cbreak, except that' ...
          '\n in RT task, this parameter applies during times in the trial later'  ...
          '\n than when the choice is allowed (set by min_rt)'...
          '\n In non-RT task, this parameter is not applicable.']));
      disable(legal_cbreak_rt);
      next_row(y);
      
      NumeditParam(obj, 'legal_cbreak', 0.001, x, y, ... 
          'labelfraction', 0.4, ...
          'TooltipString', sprintf(['\nGoing out of the center poke and poking back in' ...
          '\nwithin this many seconds means the nose-out is ignored, it is treated' ...
          '\nas if the rat had kept his nose in the center continuously.' ...
          '\n In RT task, this parameter applies only during times in the trial earlier'  ...
          '\n than when the choice is allowed (set by min_rt)']));
      next_row(y);
      
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
      
      ToggleParam(obj, 'nic_end_sound', 0, x, y, 'position', [x y 100 20], ...
        'OnString', 'end sound ON', 'OffString', 'end sound OFF', ...
        'TooltipString', sprintf(['\nsound that is triggered at start of center_2_side_gap, ' ...
                                  '\nto help the rat realize nose_in_center is over']));
      ToggleParam(obj, 'nic_end_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
        'OnString', 'end sound showing', 'OffString', 'end sound hidden', ...
        'TooltipString', sprintf(['\nshow or hide the interface for the nic_end_sound']));
      set_callback(nic_end_sound_show, {mfilename 'nic_end_sound_show'}); %#ok<NODEF>
      next_row(y);                      

      % Put up the little figure for the nic_end_sound, set up the SoundUI,
      % then close the figure:
      currfig = gcf; cfpos = get(currfig, 'Position');
      SoloParamHandle(obj, 'nic_end_sound_fig', 'value', ...
        figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'nic_end_sound', ...
        'CloseRequestFcn', [mfilename '(' class(obj) ', ''nic_end_sound_hide'')']), ...
        'saveable', 0);
      myx = 10; myy = 10;
      SoundInterface(obj, 'add', 'nic_end_sound', myx, myy);
      SoundInterface(obj, 'set', 'nic_end_sound', 'Style', 'Tone', 'Vol', 0.004, ...
        'Freq1', 6000, 'Dur1', 0.05, 'Loop', 0, 'Bal', 0);
      nic_end_sound_show.value = 0;
      set(value(nic_end_sound_fig), 'Visible', 'off');
      
      figure(currfig);
           
      MenuParam(obj, 'center_light', {'off', 'on', 'off at first cpoke', 'on at first cpoke', 'off when nose in center'}, 2, ...
          x, y, 'labelfraction', 0.4, ...
          'TooltipString', sprintf(['When the center light is kept on.\n' ...
                                    'off: always off \n' ...
                                    'on: on before and during cpokes \n' ...
                                    'off at first cpoke: on before but not during cpokes \n' ...
                                    'on at cpoke: off before, on during cpokes \n' ...
                                    'off when nose in center: on before cpoke, off when center poking, on during legal_cbreak']));
      next_row(y);
      MenuParam(obj, 'side_lights', {'correct side only', 'both sides on', 'both sides off', 'anticorrect side only'}, ...
          1, x, y, ...
          'labelfraction', 0.4, ...
          'TooltipString', 'Which side lights are turned on');
      set_callback(side_lights, {mfilename, 'side_lights'});
      set_callback_on_load(side_lights, 1);
      next_row(y);
      
      NumeditParam(obj, 'C2SGap_2', 0, x, y, 'position', [x+100 y 100 20], ...
          'labelfraction', 0.7, ...
          'TooltipString', 'An additional center-to-side gap that follows C2SGap where there is no punishment for poking anywhere');
      NumeditParam(obj, 'C2SGap', 1, x, y, 'position', [x y 100 20], ...
          'labelfraction', 0.5, ...
          'TooltipString', 'Time (sec) between last center poke and when a side poke is accepted');
      next_row(y);
      NumeditParam(obj, 'LEDRewardTime', 0, x, y, ...
          'TooltipString', sprintf(['\nIf side lights are on, length of time (secs) to keep them' ...
                                    '\non during the reward state']));
      next_row(y);
      
      NumeditParam(obj, 'fixed_stim_dur', 1, x, y, ...
          'TooltipString', 'Stimulus duration. Set from parameters specified in PBupsSection.');
      
      next_row(y);
	  NumeditParam(obj, 'memory_gap', 0, x, y, ...
		  'TooltipString', 'the delay(in sec) between the end of the stimulus and the end of cpoke1. Requires Fixed T stim_timing.');
      next_row(y);
	  NumeditParam(obj, 'prob_mem_gap', 0, x, y, ...
		  'TooltipString', 'probability that a trial will have a memory gap. Requires Fixed T stim_timing.');
      next_row(y);
      MenuParam(obj, 'stim_timing', {'Fixed T After Start', 'During Cpoke Only'}, 2, x, y, ...
          'labelfraction', 0.3, ...
          'TooltipString', sprintf(['\n Controls the timing of when the stimulus is on' ...
                                    '\n If Fixed T After Stim Start, stim is stopped after a fixed time' ...
                                    '\n If During Cpoke Only, stim is only ON in one of the cpoke states' ...
                                    '\n In the latter case, a legal cbreak near the end of a trial may cause the stimulus duration to exceed what is specified' ...
                                    '\n In the former case, the stimulus would end in the middle of a similarly timed legal cbreak' ...
                                    '\n Fixed T must be chosen for memory gap functionality']));
      set_callback(stim_timing,   {mfilename, 'stim_timing'});
      set_callback_on_load(stim_timing, 1);
	  next_row(y);
     
      ToggleParam(obj, 'rt_task', 0, x, y, ...
            'OffString', 'non-reaction time task', ...
            'OnString',  'reaction time task', ...
            'TooltipString', sprintf(['\n' ...
            'If reaction time task, then rat can indicate choice any time min_rt after stimulus onset.\n' ...
            'If non-reaction time task, then stimulus duration is controlled by experimenter.\n']));
      set_callback(rt_task,   {mfilename, 'rt_task'});
      set_callback_on_load(rt_task, 1);
      next_row(y);
      
      NumeditParam(obj, 'min_rt', 0, x, y, ...
		  'TooltipString', sprintf(['the stimulus must be on for at least this amount of time before a rat can break NIC and make choice'...
          '\n Earlier broken NICs will lead to a violation'...
          '\n For non-RT task, automatically set to be nic - stim_start_delay']));
      disable(min_rt);
      next_row(y);
      
      DistribInterface(obj, 'add', 'rt_stim_delay', x, y, 'Style', ...
                    'uniform', 'Min', 0, 'Max', 0,...
                    'TooltipString', sprintf(['In the RT task, sets the delay to stimulus onset.'...
                    '\n Not used in non-RT tasks.']));
                
      
      next_row(y,5.1);          
      NumeditParam(obj, 'stim_start_delay', 0, x, y, ...
          'TooltipString', sprintf(['The delay (in sec) between cpoke1 and when the stimulus starts playing'...
                    '\n In non-RT tasks, it is set by nic minus memory gap for current trial minus stimulation duration, the last being controlled through PBupSection'...
                    '\n In RT tasks, it is set by the random number GUI control below']));

      next_row(y);          
      [x, y] = PBupsSection(obj, 'init', x, y);
	  SubheaderParam(obj, 'title', 'StimulusSection', x, y);
	  
	  % to store all the relevant info about the stimulus to pass onto
	  % StateMatrix Section
	  specs.sound_id = 0;
	  specs.sound_delay = 0;
	  specs.stim_timing = value(stim_timing);
	  specs.sound_dur = 0;
	  SoloParamHandle(obj, 'StimulusSpecs', 'value', specs); 
      
      SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'legal_cbreak'; 'nic_end_sound' ; ...
          'nose_in_center'; ...
          'C2SGap'; 'C2SGap_2'; 'LEDRewardTime' ; ...
          'side_lights'; 'center_light'; ...
          'fixed_stim_dur' ; 'stim_start_delay'; ...
          'legal_cbreak_rt'; 'min_rt';...
          'new_trial_on_violation'; 'reinit_dur'; ...
          });
      
      %   Let SidesSection have read access to the task type
      SoloFunctionAddVars('SidesSection', 'ro_args', {'rt_task'});
      
      feval(mfilename, obj, 'side_lights');
	  feval(mfilename, obj, 'stim_timing');


%% next_trial
  case 'next_trial',      

	  % makes next sound
	  % returns next sound (specifically, an integer ID of the ordinal stimulus strength) and next sample duration
	  
	  if ~isempty(varargin) && ~isempty(varargin{1}),
		  set_side = varargin{1};
	  else
		  set_side = '';
	  end;
	  
	  [previous_sides previous_sounds] = SidesSection(obj, 'get_previous_sides_and_sounds');
	  [this_sound this_T] = PBupsSection(obj, 'next_trial', set_side, previous_sides, previous_sounds);
	  fixed_stim_dur.value = this_T;
      if rand(1) < value(prob_mem_gap) && strcmp(value(stim_timing),'Fixed T After Start')
          this_memory_gap = value(memory_gap);
      else
          this_memory_gap = 0;
      end
      
      % if rt_task, stim_start_delay is specified by random number GUI,
      % else it is specified by a combination of nic, memory gap, and the
      % stimulus duration
      if value(rt_task)
          stim_start_delay.value = DistribInterface(obj, 'get_new_sample', 'rt_stim_delay');
      else
          stim_start_delay.value = max(0, nose_in_center - this_memory_gap - fixed_stim_dur);
      end
      
      % if rt_task, the nic time is not specified by user, but calculated
      % from other parameters
      if value(rt_task), 
          nose_in_center.value = max(0, stim_start_delay + this_T);
      end
      
	  
	  x = this_sound;
	  y = this_T;
	  
	  % populate the StimulusSpecs cell
      specs.sound_id    = SoundManagerSection(obj, 'get_sound_id', 'PBupsSound');
	  specs.sound_delay = stim_start_delay(1);
	  specs.stim_timing = value(stim_timing);
	  switch value(stim_timing),
		  case 'Fixed T After Start',
			  specs.sound_dur = fixed_stim_dur(1);
		  case 'During Cpoke Only',
			  % if sound stays on for as long as cpoke1, let
			  % StateMatrixSection decide when to turn the sound off
			  specs.sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'PBupsSound');
	  end;
      
      % if not rt_task, then subject is not allowed to respond prematurely
      if ~value(rt_task)
          % add 0.1 sec for safety because the min_rt wave is checked one
          % state transition after cpoke_timer wave
          min_rt.value = nose_in_center - stim_start_delay + 0.1; 
      end
      
	  StimulusSpecs.value = specs;
	  

%% get_stimulus_specs
  case 'get_stimulus_specs'
	  x = value(StimulusSpecs);
      y = PBupsSection(obj, 'get_stimulator_specs');


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
      
%% rt_task
  case 'rt_task' 
      if value(rt_task), %#ok<NODEF>
          stim_timing.value = 'During Cpoke Only';
          feval(mfilename, obj, 'stim_timing');
          disable(stim_timing);
          enable(min_rt);
          enable(legal_cbreak_rt);
      else
          enable(stim_timing);
          disable(min_rt);
          disable(legal_cbreak_rt);
      end;	 
      
%% side_lights
   case 'side_lights'
      if strcmp(side_lights, 'both sides off'),
          disable(LEDRewardTime);
      else
          enable(LEDRewardTime);
      end;

        
      
%% nic_end_sound_hide
  case 'nic_end_sound_hide'
    nic_end_sound_show.value = 0;
    set(value(nic_end_sound_fig), 'Visible', 'off');

      
%% nic_end_sound_show
  case 'nic_end_sound_show'
    if nic_end_sound_show==1, %#ok<NODEF>
      set(value(nic_end_sound_fig), 'Visible', 'on');
    else
      set(value(nic_end_sound_fig), 'Visible', 'off');
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
    PBupsSection(obj, 'close');
    delete(value(nic_end_sound_fig));
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);    


%% end_session
  case 'end_session',
        

%% reinit
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); f = my_gui_info(3);

    feval(mfilename, obj, 'close');

    % Reinitialise at the original GUI position and figure:
    figure(f);
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;

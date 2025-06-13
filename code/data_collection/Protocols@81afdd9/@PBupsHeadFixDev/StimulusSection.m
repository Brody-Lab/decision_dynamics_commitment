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
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
      ToggleParam(obj, 'give_hint', 0, x, y, 'position', [x y 100 20], ...
          'OnString', 'give ON', 'OffString', 'give OFF', ...
          'TooltipString', sprintf(['\nif on, give perc of reward is given at the beginning of the stimulus without input from the rat' ...
          '\nif off, full reward is given only after the rat has made a choice']));
      ToggleParam(obj, 'delay_reward', 0, x, y, 'position', [x+101 y 100 20], ...
          'OnString', 'rew delay ON', 'OffString', 'rew delay OFF', ...
          'TooltipString', sprintf(['\nif on, wait until end of stim to deliver reward'])); next_row(y);
      ToggleParam(obj, 'trial_start_sound', 1, x, y, 'position', [x y 100 20], ...
          'OnString', 'start sound ON', 'OffString', 'start sound OFF', ...
          'TooltipString', sprintf(['\nsound that is triggered at start of trial, ' ...
          '\nto help the rat realize drink time is over,' ...
          '\nimportant for when there are ITI penalties']));
      ToggleParam(obj, 'trial_start_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
          'OnString', 'start sound showing', 'OffString', 'start sound hidden', ...
          'TooltipString', sprintf(['\nshow or hide the interface for the trial_start_sound']));
      set_callback(trial_start_sound_show, {mfilename 'trial_start_sound_show'}); %#ok<NODEF>
      next_row(y);

      %Put up the little figure for the trial_start_sound, set up the SoundUI,
      %then close the figure:
      currfig = double(gcf); cfpos = get(currfig, 'Position');
      SoloParamHandle(obj, 'trial_start_sound_fig', 'value', ...
        double(figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'trial_start_sound', ...
        'CloseRequestFcn', [mfilename '(' class(obj) ', ''trial_start_sound_hide'')'])), ...
        'saveable', 0);
      myx = 10; myy = 10;
      SoundInterface(obj, 'add', 'trial_start_sound', myx, myy);
      SoundInterface(obj, 'set', 'trial_start_sound', 'Style', 'ToneSweep', 'Vol', 0.004, ...
        'Freq1', 6000, 'Dur1', 0.05, 'Freq2', 3000, 'Dur2', 0.05,'Loop', 0, 'Bal', 0);
      trial_start_sound_show.value = 0;
      set(value(trial_start_sound_fig), 'Visible', 'off');
      
      figure(currfig);

      ToggleParam(obj, 'stim_start_sound', 1, x, y, 'position', [x y 100 20], ...
        'OnString', 'start stim ON', 'OffString', 'start stim OFF', ...
        'TooltipString', sprintf(['\nsound that is triggered at start of trial, ' ...
                                  '\nto help the rat realize drink time is over,' ...
                                  '\nimportant for when there are ITI penalties']));
      ToggleParam(obj, 'stim_start_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
        'OnString', 'stim start showing', 'OffString', ' stim start hidden', ...
        'TooltipString', sprintf(['\nshow or hide the interface for the stim_start_sound']));
      set_callback(stim_start_sound_show, {mfilename 'stim_start_sound_show'}); %#ok<NODEF>
      next_row(y);                      

      %Put up the little figure for the stim_start_sound, set up the SoundUI,
      %then close the figure:
      currfig = double(gcf); cfpos = get(currfig, 'Position');
      SoloParamHandle(obj, 'stim_start_sound_fig', 'value', ...
        double(figure('Position', [cfpos(1)+487 cfpos(2)+289 218 170], 'Name', 'stim_start_sound', ...
        'CloseRequestFcn', [mfilename '(' class(obj) ', ''stim_start_sound_hide'')'])), ...
        'saveable', 0);
      myx = 10; myy = 10;
      SoundInterface(obj, 'add', 'stim_start_sound', myx, myy);
      SoundInterface(obj, 'set', 'stim_start_sound', 'Style', 'ToneSweep', 'Vol', 0.004, ...
        'Freq1', 3000, 'Dur1', 0.05, 'Freq2', 6000, 'Dur2', 0.05,'Loop', 0, 'Bal', 0);
      stim_start_sound_show.value = 0;
      set(value(stim_start_sound_fig), 'Visible', 'off');
      
      figure(currfig);
      ToggleParam(obj, 'go_sound', 0, x, y, 'position', [x y 100 20], ...
      'OnString', 'go sound ON', 'OffString', 'go sound OFF', ...
      'TooltipString', sprintf(['\nsound that is triggered at start of trial, ' ...
                                '\nto help the rat realize drink time is over,' ...
                                '\nimportant for when there are ITI penalties']));
      ToggleParam(obj, 'go_sound_show', 0, x, y, 'position', [x+101 y 100 20], ...
        'OnString', 'go showing', 'OffString', ' go hidden', ...
        'TooltipString', sprintf(['\nshow or hide the interface for the go_sound']));
      set_callback(go_sound_show, {mfilename 'go_sound_show'}); %#ok<NODEF>
      next_row(y);   

      ToggleParam(obj, 'reinforce_sound', 0, x, y, 'position', [x y 100 20], ...
        'OnString', 'replay stimulus sound during drink time on hit trials', 'OffString', 'no replay (default setting)', ...
        'TooltipString', sprintf(['\nplay stim sound again during drink time on hit trials']));
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
      SoundInterface(obj, 'set', 'go_sound', 'Style', 'SpectrumNoise', 'Vol', 0.004, ...
        'Freq1', 3000, 'Dur1', 0.05, 'Freq2', 6000, 'Sigma',100,'Cntrst',500, 'Loop', 0, 'Bal', 0);
      go_sound_show.value = 0;
      set(value(go_sound_fig), 'Visible', 'off');
      
      figure(currfig);
      ToggleParam(obj,'free_response', 0, x, y, 'position', [x y 100 20], ...
        'OnString', 'free response ON', 'OffString', 'free response OFF', ...
        'TooltipString', sprintf(['\nIf ON, the animal can respond to either side (for shaping pre rule learning)' ...
                                  '\nIf OFF, the animal must follow the sound rule']));
      NumeditParam(obj, 'give_perc', 0.3, x, y, ...
          'TooltipString', sprintf(['\nIf give is ON, this is the percentage of total reward' ...
                                    '\nthat is given to the animal after the go cue. If give is OFF, this is ignored']));
      next_row(y);
      NumeditParam(obj, 'fixed_stim_dur', 1, x, y, ...
          'TooltipString', 'Stimulus duration. Set from parameters specified in PBupsSection.');
      next_row(y);

      ToggleParam(obj, 'stim_delay_type', 0, x, y, 'position', [x y 100 20], ...
          'OnString', 'dyn delay', 'OffString', 'add delay', ...
          'TooltipString', sprintf(['\nif on, stimulus delay is set based on the total stim window'...
                                    '\nif off, stimulus delay is set based on dist and added to stim length']));     
      next_row(y);
      NumeditParam(obj, 'viol_grace_dur', 0, x, y, ...
          'TooltipString', 'time from stimulus onset to when the animal cannot be penalized for licking');

      next_row(y);
      NumeditParam(obj, 'stim_window', 2.0, x, y,...
          'TooltipString', sprintf(['\nif stim delay type is dynamic, this is total stim window'...
                                    '\nif stim delay type is fixed, this isnt used']));     
      next_row(y);   

      DistribInterface(obj, 'add', 'stim_delay', x, y, 'Style', ...
                    'exponential', 'Min', 0.1, 'Max', .2, 'Tau',2, ...
                    'TooltipString', sprintf(['Sets the delay to stimulus onset.']));
                      
      next_row(y,5.1);          
      NumeditParam(obj, 'stim_start_delay', 0.1, x, y, ...
          'TooltipString', sprintf(['If delay type is add, the delay (in sec) between stim start sound and when the stimulus starts playing'...
                    '\n It is set by the random number GUI control below']));

      next_row(y);   

      NumeditParam(obj, 'slick_timeout', 5, x, y, ...
          'TooltipString', sprintf(['The timeout period, where if the animal does not lick, the timeout sound'...
                    '\n is played. This is so the task does not get stuck here. Is very long relative to trial currently.']));
      next_row(y);

      ToggleParam(obj, 'vis_stim_light', 0, x, y, 'position', [x y 100 20], ...
          'OnString', 'light on dur stim', 'OffString', 'light off dur stim', ...
          'TooltipString', sprintf(['\nif on, the vis light (left port) will be on while mouse cant lick'...
                                    '\nif off, no helper light']));

      next_row(y);     
      [x, y] = PBupsSection(obj, 'init', x, y);




	  SubheaderParam(obj, 'title', 'StimulusSection', x, y);
	  
	  % to store all the relevant info about the stimulus min_rtto pass onto
	  % StateMatrix Section
	  specs.sound_id = 0;
	  specs.sound_delay = 0;
	  specs.stim_timing = 'Fixed T After Start';
	  specs.sound_dur = 0;
	  SoloParamHandle(obj, 'StimulusSpecs', 'value', specs); 
      
    SoloFunctionAddVars('StateMatrixSection', 'ro_args', ...
          {'stim_start_sound'; 'trial_start_sound'; 'give_hint'; 'give_perc';...
          'delay_reward';'fixed_stim_dur' ; 'viol_grace_dur';'stim_start_delay'; ...
          'slick_timeout';'go_sound';'reinforce_sound';'vis_stim_light'});
    
    SoloFunctionAddAllVars(obj, 'TrainingSection', 'rw_args');

    for i = 1:numel(value(active_curricula))
      % Construct the function call with the updated curriculum name
      current_curricula = value(active_curricula{i});
      function_call = sprintf("SoloFunctionAddAllVars(obj, 'TS_%s', 'rw_args');", current_curricula);
      eval(function_call);
    end
      
      %   Let SidesSection have read access to the task type
      %SoloFunctionAddVars('SidesSection', 'ro_args', {'rt_task'});
      
    feval(mfilename, obj, 'side_lights');
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

%     if rand(1) < value(prob_mem_gap) && strcmp(value(stim_timing),'Fixed T After Start')
%           this_memory_gap = value(memory_gap);
%     else
          this_memory_gap = 0;
%     end
	  
	  [previous_sides, previous_sounds] = SidesSection(obj, 'get_previous_sides_and_sounds');
	  [this_sound, this_T] = PBupsSection(obj, 'next_trial', set_side, previous_sides, previous_sounds);
	  fixed_stim_dur.value = this_T;

      if this_T > value(stim_window)
          stim_window.value = value(this_T);
      end
      
      % if rt_task, stim_start_delay is specified by random number GUI,
      % else it is specified by a combination of nic, memory gap, and the
      % stimulus duration
      if value(stim_delay_type) == 0
            stim_start_delay.value = DistribInterface(obj, 'get_new_sample', 'stim_delay');
      else
            stim_start_delay.value = max(0, value(stim_window) - value(fixed_stim_dur));
      end
      
      % if rt_task, the nic time is not specified by user, but calculated
      % from other parameters
      %if value(rt_task), 
      %    nose_in_center.value = max(0, stim_start_delay + this_T);
      %end
      
     % sets up the stimulator, uses the other three arguments only if one of the codes are used 
	  PBupsSection(obj, 'next_trial_stimulator', value(stim_start_delay), this_T, this_memory_gap);

	  x = this_sound;
	  y = this_T;
	  
	  % populate the StimulusSpecs cell
      specs.sound_id    = SoundManagerSection(obj, 'get_sound_id', 'PBupsSound');
	  specs.sound_delay = stim_start_delay(1);
	  specs.stim_timing = 'Fixed T After Start';
	  % switch value(stim_timing),
		%   case 'Fixed T After Start',
	  specs.sound_dur = fixed_stim_dur(1);
		  % case 'During Cpoke Only',
			  % if sound stays on for as long as cpoke1, let
			  % StateMatrixSection decide when to turn the sound off
			  % specs.sound_dur = SoundManagerSection(obj, 'get_sound_duration', 'PBupsSound');
	  %end;
      
      % if not rt_task, then subject is not allowed to respond prematurely
      % if ~value(rt_task)
      %     % add 0.1 sec for safety because the min_rt wave is checked one
      %     % state transition after cpoke_timer wave
      %     min_rt.value = nose_in_center - stim_start_delay + 0.1; 
      % end

      StimulusSpecs.value = specs;
      
%% get_stimulus_specs
  case 'get_stimulus_specs',
	x = value(StimulusSpecs);
    y = PBupsSection(obj, 'get_stimulator_specs');
%% stim_timing
  % case 'stim_timing'
  %     switch value(stim_timing), %#ok<NODEF>
  %         case 'Fixed T After Start', 
	% 		  %enable(memory_gap);
  %             %enable(prob_mem_gap);
  %         case 'During Cpoke Only', 
  %             prob_mem_gap.value = 0;
  %             memory_gap.value = 0;
	% 		  disable(memory_gap);
  %             disable(prob_mem_gap);
  %     end;	 
      
%% rt_task
  % case 'rt_task' 
  %     if value(rt_task), %#ok<NODEF>
  %         stim_timing.value = 'During Cpoke Only';
  %         feval(mfilename, obj, 'stim_timing');
  %         disable(stim_timing);
  %         enable(min_rt);
  %         %enable(legal_cbreak_rt);
  %     else
  %         enable(stim_timing);
  %         disable(min_rt);
  %         disable(legal_cbreak_rt);
  %     end;	 
        
      
%% trial_start_sound_hide
  case 'trial_start_sound_hide'
    trial_start_sound_show.value = 0;
    set(value(trial_start_sound_fig), 'Visible', 'off');

      
%% trial_start_sound_show
  case 'trial_start_sound_show'
    if trial_start_sound_show==1, %#ok<NODEF>
      set(value(trial_start_sound_fig), 'Visible', 'on');
    else
      set(value(trial_start_sound_fig), 'Visible', 'off');
    end;

%% trial_start_sound_hide
case 'stim_start_sound_hide'
  stim_start_sound_show.value = 0;
  set(value(stim_start_sound_fig), 'Visible', 'off');

    
%% stim_start_sound_show
case 'stim_start_sound_show'
  if stim_start_sound_show==1, %#ok<NODEF>
    set(value(stim_start_sound_fig), 'Visible', 'on');
  else
    set(value(stim_start_sound_fig), 'Visible', 'off');
  end;
%% trial_start_sound_hide
case 'go_sound_hide'
  go_sound_show.value = 0;
  set(value(go_sound_fig), 'Visible', 'off');

    
%% go_sound_show
case 'go_sound_show'
  if go_sound_show==1, %#ok<NODEF>
    set(value(go_sound_fig), 'Visible', 'on');
  else
    set(value(go_sound_fig), 'Visible', 'off');
  end;     

  case 'close',
    PBupsSection(obj, 'close');
    delete(value(trial_start_sound_fig));
    delete(value(stim_start_sound_fig));
    delete(value(go_sound_fig));
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

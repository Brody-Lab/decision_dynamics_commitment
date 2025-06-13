% @PBups/StateMatrixSection
% BWB, March 2009

% [x, y] = StateMatrixSection(obj, action, x, y)
%
% HELP HERE
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%            'reinit'       Delete all of this section's GUIs and data,
%                           and reinit, at the same position on the same
%                           figure as the original section GUI was placed.
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


function  [] =  StateMatrixSection(obj, action)

GetSoloFunctionArgs;


switch action
  case 'init', 
    
    feval(mfilename, obj, 'next_trial');

%% next_trial
  case 'next_trial',

    sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
    
    min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
    
    left1led           = bSettings('get', 'DIOLINES', 'left1led'); 
    center1led         = bSettings('get', 'DIOLINES', 'center1led');
    right1led          = bSettings('get', 'DIOLINES', 'right1led'); 
    left1water         = bSettings('get', 'DIOLINES', 'left1water'); 
    right1water        = bSettings('get', 'DIOLINES', 'right1water'); 
    
    % set up stimulator channels, if any
    % HACK ALERT: currently works with only one DIO line named LASER
    % if you don't have this in your settings_custom.conf file, then
    % nothing will happen
    stim = bSettings('get', 'DIOLINES', 'LASER');
    mask = bSettings('get', 'DIOLINES', 'MASK');
    if isnan(stim), stim = 0; end;
    if isnan(mask), mask = 0; end;
    
    
%% set up sounds
	% we expect the following fields for StimulusSpecs:
	%	sound_id
	%	sound_delay
	%	sound_dur
	%	stim_timing
    % and the following fields for StimulatorSpecs:
    %   channel
    %   pre
    %   dur
	[StimulusSpecs StimulatorSpecs] = StimulusSection(obj, 'get_stimulus_specs');
    MaskSpecs = PBupsSection(obj, 'get_mask_specs');
	
%% set up reward quantity and timing
    [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times', hit_streak);

%% set up correct responses
thisTrial = SidesSection(obj, 'get_current_side');
    if thisTrial == 'l',
        LeftResponseState = 'left_reward';
        
        if PunishSideChoice == 1, 
            if SideChoicePunishmentType == 1,
                % punishment: temporary white noise
                RightResponseState = 'temporary_punishment';
            else
                % punishment: trial terminates
                RightResponseState = 'error_state1';
            end;
        else
            RightResponseState = 'current_state';
        end;
        
        % set up which side LED to turn on
        switch value(side_lights),
          case 'correct side only',     side_led = left1led;
          case 'both sides on',         side_led = left1led+right1led;
          case 'both sides off',        side_led = 0;
          case 'anticorrect side only', side_led = right1led;
          otherwise
            warning('PBups:UnknownSetting', 'Don''t know what to do with the side_lights setting');
        end;
        correct_side_led   = left1led; %#ok<NASGU>
      
    elseif thisTrial == 'r'
       RightResponseState = 'right_reward';
       
        if PunishSideChoice == 1, 
            if SideChoicePunishmentType == 1,
                % punishment: temporary white noise    
                LeftResponseState = 'temporary_punishment';
            else
                % punishment: trial terminates
                LeftResponseState = 'error_state1';
            end;
        else
            LeftResponseState = 'current_state';
        end;
          
        % set up which side LED to turn on
        switch value(side_lights),
          case 'correct side only',     side_led = right1led;
          case 'both sides on',         side_led = right1led+left1led;
          case 'both sides off',        side_led = 0;
          case 'anticorrect side only', side_led = left1led;
          otherwise
            warning('PBups:UnknownSetting', 'Don''t know what to do with the side_lights setting');
        end;
        correct_side_led   = right1led; %#ok<NASGU>

    else
      % Free Choice 
       switch value(side_lights),
          case 'correct side only',     side_led = right1led+left1led;
          case 'both sides on',         side_led = right1led+left1led;
          case 'both sides off',        side_led = 0;
          case 'anticorrect side only', side_led = 0;
          otherwise
            warning('PBups:UnknownSetting', 'Don''t know what to do with the side_lights setting');
        end;
         LeftResponseState = 'left_reward';
         RightResponseState = 'right_reward';
         correct_side_led   = right1led+left1led; %#ok<NASGU>
      

    end
       right_valvetime = RightWValveTime*right_wtr_mult;
         left_valvetime = LeftWValveTime*left_wtr_mult;

    sma = add_scheduled_wave(sma, 'name', 'direct_left_reward', 'preamble', reward_delay(1), ...
        'sustain', left_valvetime, 'DOut', left1water);

    sma = add_scheduled_wave(sma, 'name', 'direct_right_reward', 'preamble', reward_delay(1), ...
        'sustain', right_valvetime, 'DOut', right1water);

    

%% set up center_pokes
	first_state  = 'wait_for_cpoke1';
	after_cpoke1 = 'cpoke1';

    switch value(center_light),
        case 'off',
            pre_cpoke_led = 0;
            cpoke_led= 0;
            
        case 'on', 
            pre_cpoke_led = center1led;
            cpoke_led= center1led;
            
        case 'off at first cpoke',
            pre_cpoke_led = center1led;
            cpoke_led = 0;
            
        case 'on at first cpoke',
            pre_cpoke_led = 0;
            cpoke_led = center1led;
    end;
    
%% clean up sounds
	snd_list=SoundManagerSection(obj, 'get_sound_id','all');
	sma = add_multi_sounds_state(sma, -1*snd_list,'state_name','clean_sound_state','return_state','iti');
    
%% ITI
    
    if PunishITIPokes == 1, iti_poke_state = 'iti_pun';
    else                    iti_poke_state = 'current_state';
    end;
    
     
    ITI = PenaltySection(obj, 'get_ITI');
    
    sma = add_state(sma, 'name', 'iti', 'self_timer', ITI, ...
        'input_to_statechange', {'Tup', first_state; ...
                                 'Cin', iti_poke_state; ...
                                 'Lin', iti_poke_state; ...
                                 'Rin', iti_poke_state; ...
                                 }); 
                             

    sma = PunishInterface(obj, 'add_sma_states', 'ITIPun', sma, ...
        'name', 'iti_pun', ...
        'exitstate', 'iti');

    
    
%% wait for center poke 1                          
     if PunishCL1BadPokes == 1, poke_state = 'cl1_pun';
     else                       poke_state = 'current_state';
     end;

	 center_poke_state = 'play_stimulus_sound';    
    
     sma = add_state(sma, 'name', 'wait_for_cpoke1', 'self_timer', wait_for_cpoke1_tout, ...
         'output_actions', {'DOut', pre_cpoke_led}, ...
         'input_to_statechange', {'Tup', 'center_2_side_gap' ; ...
                                  'Cin', center_poke_state; ...
                                  'Lin', poke_state; ...
                                  'Rin', poke_state; ...
                                 });

     sma = PunishInterface(obj, 'add_sma_states', 'CenterLightPun', sma, ...
         'name', 'cl1_pun', ...
         'exitstate', 'wait_for_cpoke1');


    

%% set up stimuli: sound and stimulator (for zapping purposes)
    % the stimulator channel to activate, if any
    if StimulatorSpecs.ison > 0, this_stim = stim(1); 
    else                         this_stim = 0;
    end;
    
    if       MaskSpecs.ison > 0, this_mask = mask(1); 
    else                         this_mask = 0;
    end;
    

    % turns on the stim DIO line
    sma = add_scheduled_wave(sma, 'name', 'laser_stim_on', ...
                                  'preamble', StimulatorSpecs.pre, ...
                                  'sustain', StimulatorSpecs.dur, ...
                                  'DOut', this_stim);
                              
    sma = add_scheduled_wave(sma, 'name', 'mask_on', ...
                                  'preamble', MaskSpecs.pre, ...
                                  'sustain', MaskSpecs.dur, ...
                                  'DOut', this_mask);                          

    % plays the sound stimulus                              
	sma = add_scheduled_wave(sma, 'name', 'sound_on', 'preamble', StimulusSpecs.sound_delay, ...
				                  'sustain', StimulusSpecs.sound_dur, ...
							      'sound_trig', StimulusSpecs.sound_id);
    sma = add_scheduled_wave(sma, 'name', 'min_rt_wave', 'preamble', StimulusSpecs.sound_delay + min_rt, ...
                                   'sustain', StimulusSpecs.sound_dur - min_rt);
                               
     sma = add_happening_spec(sma, struct(...
        'name',                 {'min_rt_wave_hi',                  'min_rt_wave_lo'}, ...
        'detectorFunctionName', {'wave_high',                           'wave_low'}, ...
        'inputNumber',          {get_wavenumber(sma, 'min_rt_wave'), get_wavenumber(sma, 'min_rt_wave')}));
                                   
	waves_on  = '+sound_on + min_rt_wave';
	waves_off = '-sound_on - min_rt_wave';
    waves_off_cleanup = '-sound_on - min_rt_wave';
    
    if strcmp(StimulatorSpecs.trigger, 'cpoke1'),
        waves_on = [waves_on '+ laser_stim_on'];
        waves_off_cleanup = [waves_off_cleanup '- laser_stim_on'];
    end;
    
    if strcmp(MaskSpecs.trigger, 'cpoke1'),
        waves_on = [waves_on '+ mask_on'];
        waves_off_cleanup = [waves_off_cleanup '- mask_on'];
    end;
    
    % PLAY_STIMULUS_SOUND: first make sure the stimulus sound and the scheduled waves are off
    sma = add_state(sma, 'name', 'play_stimulus_sound', 'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', waves_off_cleanup}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    
   
   
    % then set all sounds playing by triggering  the scheduled wave,
    % and jump to the state appropriate for immediately after the first
    % cpoke:
    sma = add_state(sma, 'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', waves_on}, ...
        'input_to_statechange', {'Tup', after_cpoke1});

    
%% set up cpokes1
	% set up one cpoke1 state that allows excursions 
	% from the cpoke of duration < legal_cbreak.
	% upon an excursion longer than legal_cbreak, go to this state:
	if new_trial_on_violation==0,
        violation_goto = 'temp_violation';
    else
        violation_goto = 'violation_state';
    end;
    
	if WaitForCenterNoseOut==1, nic_end_goto = 'wait_for_center_nose_out';
	else                        nic_end_goto = 'center_2_side_gap';
	end;

	sma = add_scheduled_wave(sma, 'name', 'cpoke_timer',  'preamble', nose_in_center, 'sustain', legal_cbreak+legal_cbreak_rt+min_time);
    sma = add_happening_spec(sma, struct(...
        'name',                 {'cpoke_timer_hi',                  'cpoke_timer_lo'}, ...
        'detectorFunctionName', {'wave_high',                           'wave_low'}, ...
        'inputNumber',          {get_wavenumber(sma, 'cpoke_timer'), get_wavenumber(sma, 'cpoke_timer')}));
    
    % add cpoke_timer to waves_off
	waves_off = [waves_off '- cpoke_timer'];
    waves_off_cleanup = [waves_off_cleanup '- cpoke_timer'];

	% trigger the start of the timer:
	sma = add_state(sma, 'name', 'cpoke1', 'self_timer', min_time, ...
		'output_actions', {'SchedWaveTrig', 'cpoke_timer'; ...
						   'DOut', cpoke_led;}, ...
		'input_to_statechange', {'Tup', 'current_state+1'});
                            
	% Nose is in:  
	sma = add_state(sma, 'self_timer', 1000, ...
		'output_actions', {'DOut',          cpoke_led}, ...
		'input_to_statechange', {'Cout', 'current_state+1'; ...
								 'cpoke_timer_hi', nic_end_goto});

	% Nose just came out:                           
    % Determine which legal_cbreak to use
    sma = add_state(sma, 'self_timer', 1000, ...
		'output_actions', {'DOut',          cpoke_led}, ...
		'input_to_statechange', {'Cin', 'current_state-1'; ...
                                 'min_rt_wave_lo', 'current_state+1'; ...
								 'min_rt_wave_hi', 'current_state+2'});
    
                             
    % legal_cbreak states
	sma = add_state(sma, 'self_timer', legal_cbreak+min_time, ...
		'output_actions', {'DOut',          cpoke_led}, ...
		'input_to_statechange', {'Cin', 'current_state-2'; ...
								 'Tup', violation_goto});
                             
    sma = add_state(sma, 'self_timer', legal_cbreak_rt+min_time, ...
		'output_actions', {'DOut',          cpoke_led}, ...
		'input_to_statechange', {'Cin', 'current_state-3'; ...
								 'Lin', nic_end_goto; ...
								 'Rin', nic_end_goto; ...
								 'Tup', nic_end_goto});
                             

                             
%% nic_end_goto
   if PunishSidePokesinWFCO==1, side_poke_while_WFCO = 'punish_WFCO';
   else                         side_poke_while_WFCO = 'current_state';
   end;

   
   sma = add_state(sma, 'name', 'WAIT_FOR_CENTER_NOSE_OUT', ...
     'input_to_statechange', {'Clo', 'center_2_side_gap', ...
                              'Lin',  side_poke_while_WFCO, ...
                              'Rin',  side_poke_while_WFCO});

   pwfco_dur = SoundManagerSection(obj, 'get_sound_duration', 'WFCOPun');
   pwfco_id  = SoundManagerSection(obj, 'get_sound_id',       'WFCOPun');

                           
   sma = add_state(sma, 'name', 'PUNISH_WFCO', 'self_timer', pwfco_dur, ...
     'output_actions', {'SoundOut', pwfco_id}, ...
     'input_to_statechange', {'Tup', 'wait_for_center_nose_out', ...
                              'Cout', 'current_state+1'});
                            
   sma = add_state(sma, 'self_timer', pwfco_dur, ...
     'input_to_statechange', {'Tup', 'center_2_side_gap'});
                              
                            
                            

%% temp_violation


	  v_dur = SoundManagerSection(obj, 'get_sound_duration', 'TempPun');
	  v_id  = SoundManagerSection(obj, 'get_sound_id',       'TempPun');
	  sma = add_scheduled_wave(sma, 'name', 'violation', 'preamble', min_time, 'sustain', v_dur, 'sound_trig', v_id);

	  switch(value(TempPunChoice)),
		case 'reinit-able temp pun',
		  % First turn off stimulus sounds and stimulus waves
		  sma = add_state(sma, 'name', 'TEMP_VIOLATION', 'self_timer', min_time, ...
			'output_actions', {'SoundOut', -StimulusSpecs.sound_id ; ...
							   'DOut',    cpoke_led ; ...
							   'SchedWaveTrig', waves_off'}, ...
			'input_to_statechange', {'Tup', 'current_state+1'});                      

		  sma = PunishInterface(obj, 'add_sma_states', 'RTempPun', sma, ...
			'exitstate', 'wait_for_cpoke1');

		case 'non-reinit temp pun',
		  % -- nose OUT:
		  % First turn off stimulus sounds and stimulus waves, and turn on violation wave (which turns on the violation sound):
		  sma = add_state(sma, 'name', 'TEMP_VIOLATION', 'self_timer', min_time, ...
			'output_actions', {'SoundOut', -StimulusSpecs.sound_id ; ...
							   'DOut',    cpoke_led ; ...
							   'SchedWaveTrig', waves_off'}, ...
			'input_to_statechange', {'Tup', 'current_state+1'; ...
									 'Cin', 'current_state+2'});                        
		  % Now turn on violation wave (currently nose is OUT):
		  sma = add_state(sma, 'self_timer', min_time, ...
			'output_actions', {'DOut',    cpoke_led ; ...
							   'SchedWaveTrig', 'violation'}, ...
			'input_to_statechange', {'Tup', 'current_state+2'; ...
									 'Cin', 'current_state+3'});                        
		  % -- parallel states with nose IN:
                    
		  % Now turn on violation wave (currently nose is IN):
		  sma = add_state(sma, 'self_timer', min_time, ...
			'output_actions', {'DOut',    cpoke_led ; ...
							   'SchedWaveTrig', 'violation'}, ...
			'input_to_statechange', {'Tup',  'current_state+2'; ...
									 'Cout', 'current_state+1'});                        

		  % ---

		  % Then just wait to clean go back (currently nose is OUT):
		  sma = add_state(sma, 'output_actions', {'DOut', cpoke_led}, ...
			'input_to_statechange', {'violation_Out', 'wait_for_cpoke1'; ...
									 'Cin',          'current_state+1'});
		  % Then just wait to clean go back (currently nose is IN):
		  sma = add_state(sma, 'output_actions', {'DOut', cpoke_led}, ...
			'input_to_statechange', {'violation_Out', 'play_stimulus_sound'; ...
									 'Cout',         'current_state-1'});

		  % -- END of CASE NON-REINIT TEMP PUN                                   
	 end;
    


%% center to side gap
    % these states are only reached when n_center_pokes == 1
    if PunishC2SCenterPokes == 1, center_poke_state = 'c2s_pun';
    else                          center_poke_state = 'current_state';
    end
    
    if PunishC2SSidePokes == 1, 
        lside_poke_state = 'c2s_pun';
        rside_poke_state = 'c2s_pun';
    else
        lside_poke_state = 'current_state+1';
        rside_poke_state = 'current_state+2';
    end;
    
    if C2SGap_2 == 0, 
        after_c2sgap_state    = 'wait_for_spoke';
        c2sgap_left_response  = LeftResponseState;
        c2sgap_right_response = RightResponseState;
    else
        after_c2sgap_state    = 'center_2_side_gap_2';
        c2sgap_left_response  = 'center_2_side_gap_2+4';
        c2sgap_right_response = 'center_2_side_gap_2+5';
    end
    
    sma = add_scheduled_wave(sma, 'name', 'c2s_gap', 'preamble', max(min_time, C2SGap));
    
    if nic_end_sound==0, nic_end_sound_id = 0; 
    else                 nic_end_sound_id = SoundManagerSection(obj, 'get_sound_id', 'nic_end_sound');
    end;
    
    
    sma = add_state(sma, 'name', 'center_2_side_gap', ...
        'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', '-c2s_gap'; ...
                           'SoundOut',      nic_end_sound_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    if strcmp(StimulusSpecs.stim_timing, 'During Cpoke Only'),  
        % if we want the sounds to be turned off as soon as the center poke states are done,
		% the desired behavior is that the sound is turned off with the
		% scheduled wave, but this does not work on the rigs, so we have
		% turn off the sound manually as well.
        sma = add_state(sma, 'self_timer', min_time, ...
            'output_actions', {'SchedWaveTrig', waves_off; ...
                               'SoundOut', -StimulusSpecs.sound_id;}, ...
            'input_to_statechange', {'Tup', 'current_state+1'});
    end;
    sma = add_state(sma,  ...
        'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', 'c2s_gap'}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma,  ...
        'input_to_statechange', {'c2s_gap_In', after_c2sgap_state; ...
                                 'Cin', center_poke_state; ...
                                 'Lin', lside_poke_state; ...
                                 'Rin', rside_poke_state; ...
                                 });
    sma = add_state(sma, ...  % LEFT
        'input_to_statechange', {'c2s_gap_In', c2sgap_left_response; ...
                                 'Lout', 'current_state-1'; ...
                                 });
    sma = add_state(sma, ...  % RIGHT
        'input_to_statechange', {'c2s_gap_In', c2sgap_right_response; ...
                                 'Rout', 'current_state-2'; ...
                                 });
                             
    % c2s_2, where nothing is punished (or punishable)
    sma = add_scheduled_wave(sma, 'name', 'c2s_gap_2', 'preamble', max(min_time, C2SGap_2));
    
    sma = add_state(sma, 'name', 'center_2_side_gap_2', ...
        'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', '-c2s_gap_2'}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', 'c2s_gap_2'}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, ...
        'input_to_statechange', {'c2s_gap_2_In', 'wait_for_spoke'; ...
                                 'Lin', 'current_state+1'; ...
                                 'Rin', 'current_state+2'});
    sma = add_state(sma, ... % LEFT
        'input_to_statechange', {'c2s_gap_2_In', LeftResponseState; ...
                                 'Lout', 'current_state-1'; ...
                                });
    sma = add_state(sma, ... % RIGHT
        'input_to_statechange', {'c2s_gap_2_In', RightResponseState; ...
                                 'Lout', 'current_state-2'; ...
                                });
        
    % c2s punishment states: first turn off the stimulus sound
    sma = add_state(sma, 'name', 'c2s_pun', ...
        'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id}, ...
        'input_to_statechange', {'Tup', 'c2s_pun2'});
    % then add punishment states

    sma = PunishInterface(obj, 'add_sma_states', 'C2SPun', sma, ...
        'name', 'c2s_pun2', ...
        'exitstate', AfterC2SPunishment);

%% side poke
	if locked_in_sound, locked_snd     = SoundManagerSection(obj, 'get_sound_id', 'locked_in_sound');
		                locked_snd_dur = SoundManagerSection(obj, 'get_sound_duration', 'locked_in_sound');
	else				locked_snd = 0;
						locked_snd_dur = min_time;
	end;
	
    if strcmp(StimulatorSpecs.trigger, 'wait_for_spoke'); wfsp_wave = 'laser_stim_on';
    else                                                  wfsp_wave = '';
    end;
    
    if strcmp(      MaskSpecs.trigger, 'wait_for_spoke'); 
        if isempty(wfsp_wave); wfsp_wave = 'mask_on';
        else                   wfsp_wave = [wfsp_wave,' + mask_on'];
        end
    end;
    
    sma = add_state(sma, 'name', 'wait_for_spoke', ...
        'output_actions', {'DOut', side_led; ...
                           'SchedWaveTrig', wfsp_wave}, ...
        'input_to_statechange', {'Lhi', LeftResponseState; ...
                                 'Rhi', RightResponseState; ...
                                });
                            
%% error states

    sma = add_state(sma, 'name', 'error_state1', ...
        'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id; ...
                           'SchedWaveTrig', waves_off;}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', locked_snd_dur, ...
        'output_actions', {'SoundOut', locked_snd}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
	sma = add_state(sma, 'self_timer', max(min_time, value(error_delay)), ...
		'input_to_statechange', {'Tup', 'error_state'});
    
    sma = PunishInterface(obj, 'add_sma_states', 'ErrorPun', sma, ...
        'name', 'error_state', ...
        'exitstate', 'clean_up_state');

%% temporary_punishment      
    pundur = PunishInterface(obj, 'get', 'TimeOutPun', 'Duration');
    sma = add_scheduled_wave(sma, 'name', 'temporary_punishment_lights_wave', 'preamble', min_time, ...
      'sustain', pundur-min_time, 'DOut', side_led);
    
    if LEDtemp_pun==1,
      sma = add_state(sma, 'name', 'temporary_punishment', 'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', 'temporary_punishment_lights_wave'}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
      
      sma = PunishInterface(obj, 'add_sma_states', 'TimeOutPun', sma, ...
        'name', 'temporary_punishment2', ...
        'exitstate', 'wait_for_spoke');
    else
      sma = PunishInterface(obj, 'add_sma_states', 'TimeOutPun', sma, ...
        'name', 'temporary_punishment', ...
        'exitstate', 'wait_for_spoke');      
    end;
    
%% violation states
    violation_snd_id = SoundManagerSection(obj, 'get_sound_id', 'TimeOutPun_OngoingSnd');
    sma = add_state(sma, 'name', 'violation_state', ...
        'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id; ...
                           'SchedWaveTrig', waves_off_cleanup}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', reinit_dur, ...
        'output_actions', {'SoundOut', violation_snd_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', min_time, ...
        'output_actions', {'SoundOut', -violation_snd_id}, ...
        'input_to_statechange', {'Tup', 'clean_up_state'});
    

%% reward states
    sma = add_scheduled_wave(sma, 'name', 'leds_during_reward', 'preamble', min_time, ...
      'sustain', max(min_time, LEDRewardTime), 'DOut', side_led);
    if LEDRewardTime <= 0, swaves_to_add = '';
    else                   swaves_to_add = '+leds_during_reward';
    end;
    
	% even though we really don't need two of these reward states, they are
	% kept here so it's easy to pick out left/right reward trials in
	% pokesplot
	sma = add_state(sma, 'name', 'left_reward', 'self_timer', locked_snd_dur, ...
		'output_actions', {'SchedWaveTrig', ['direct_left_reward' swaves_to_add]; ...
		                   'SoundOut', locked_snd}, ...
		'input_to_statechange', {'Tup', 'current_state+1'}); 
    
    sma = add_state(sma , 'self_timer',reward_delay,...
        'input_to_statechange', {'Tup', 'hit_state'}); 
    
    
    
	sma = add_state(sma, 'name', 'right_reward', 'self_timer', locked_snd_dur, ...
		'output_actions', {'SchedWaveTrig', ['direct_right_reward' swaves_to_add];
		                   'SoundOut', locked_snd}, ...
		'input_to_statechange', {'Tup', 'current_state+1'});
            
    
    sma = add_state(sma , 'self_timer',reward_delay,...
        'input_to_statechange', {'Tup', 'hit_state'}); 
   

    % JCE, Nov 20, 2013
    % Add extra state so that scheduled_wave delivers water just as
    % entering hit state.  
    
%% hit states
    if SoftDrinkTime == 1, 
      post_hit_state_in  = 'soft_drink_state';
      post_hit_state_out = 'soft_drink_state+1';
    else
      post_hit_state_in  = 'drink_state';
      post_hit_state_out = 'drink_state';
    end;
    
    switch thisTrial,
      case 'l', InAction = 'Lin'; OutAction = 'Lout'; OtherSidePokeIn = 'Rin';
      case 'r', InAction = 'Rin'; OutAction = 'Rout'; OtherSidePokeIn = 'Lin';
      case 'f', 
      post_hit_state_in  = 'drink_state';
      post_hit_state_out = 'drink_state';
      InAction = 'Rin'; OutAction = 'Rout'; OtherSidePokeIn = 'Lin';
     % no soft drink time on Free choice. but need to define actions to
     % prevent things from breaking.
    end;


    sma = add_scheduled_wave(sma, 'name', 'hitstatetimer', 'preamble', DrinkTime);
   
    % allows rat to continue drinking for the time allotted in
    % PenaltySection_DrinkTime
    % First we just trigger the hit_state_timer:
    sma = add_state(sma, 'name', 'HIT_STATE', 'self_timer', min_time, ...
      'output_actions', {'SchedWaveTrig', 'hitstatetimer'}, ...
      'input_to_statechange', {'Tup', 'current_state+2'});
    sma = add_state(sma, 'self_timer', min_time, ...
      'output_actions', {'SchedWaveTrig', 'hitstatetimer'}, ...
      'input_to_statechange', {'Tup', 'current_state+3'});
    % Then we toggle back and forth between being in or out of the drink
    % port:
    sma = add_state(sma, 'input_to_statechange', ...
      {'hitstatetimer_In', post_hit_state_in ; ...
      OutAction, 'current_state+1'});
    sma = add_state(sma, 'input_to_statechange', ...
      {'hitstatetimer_In', post_hit_state_out; ...
      InAction, 'current_state-1'});   
    
                                     
    % timed drinking states:
    if WarnDur > 0,                     post_drink_state = 'warning';
    elseif WarnDur==0 && DangerDur > 0, post_drink_state = 'danger';
    elseif WarnDur==0 && DangerDur==0,  post_drink_state = 'clean_up_state';
    end;
    if DangerDur > 0,                   post_warning_state = 'danger';
    else                                post_warning_state = 'clean_up_state';
    end;   
    
    warn_id   = SoundManagerSection(obj, 'get_sound_id', 'WarningSound');
    danger_id = SoundManagerSection(obj, 'get_sound_id', 'DangerSound');

    sma = add_state(sma, 'name', 'DRINK_STATE', 'self_timer', min_time, ...
        'input_to_statechange', {'Tup', post_drink_state});
    sma = add_state(sma, 'name', 'WARNING', 'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id; ...
                           'SchedWaveTrig', waves_off}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = add_state(sma, 'self_timer', WarnDur, ...
        'input_to_statechange', {'Tup', post_warning_state}, ...
        'output_actions', {'SoundOut', warn_id});
    sma = add_state(sma, 'name', 'DANGER',  'self_timer', DangerDur, ...
        'output_actions', {'SoundOut', danger_id}, ...
        'input_to_statechange', {'Tup', 'clean_up_state', ...
                                 'Lin', 'current_state+1', ...
                                 'Cin', 'current_state+1', ...
                                 'Rin', 'current_state+1'});
    sma = add_state(sma, 'self_timer', min_time, ...
        'output_actions', {'SoundOut', -danger_id}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    sma = PunishInterface(obj, 'add_sma_states', 'PostDrinkPun', sma, 'name', 'mypun', ...
        'exitstate', 'danger');    
    
    
%% soft drink states
    if WD_in_sdt==1, post_softdt = post_drink_state;
    else             post_softdt = 'clean_up_state';
    end;    
    
    
    if SoftDrinkCap > DrinkTime, softdrinktimer = SoftDrinkCap-DrinkTime+min_time;
    else                         softdrinktimer = min_time;
    end;
    
    sma = add_scheduled_wave(sma, 'name', 'softdrinktimer', 'preamble', softdrinktimer);
    sma = add_scheduled_wave(sma, 'name', 'sd_grace',       'preamble', max(SoftDrinkGrace, 3*min_time));

    % Entry to soft_drink_state_in:
    sma = add_state(sma, 'name', 'SOFT_DRINK_STATE', ...
        'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', 'softdrinktimer'}, ...
        'input_to_statechange', {'Tup', 'current_state+2'});

    % Entry to soft_drink_state_out:
    sma = add_state(sma, ...
        'self_timer', min_time, ...
        'output_actions', {'SchedWaveTrig', 'softdrinktimer'}, ...
        'input_to_statechange', {'Tup', 'current_state+2'});

    sma = add_state(sma, 'output_actions', {'SchedWaveTrig', '-sd_grace'}, ...
      'input_to_statechange', {'softdrinktimer_In',      post_softdt, ...
                               OutAction,                'current_state+1', ...
                               'Cin',                    post_softdt, ...
                               OtherSidePokeIn,          post_softdt, ... 
                               });
    sma = add_state(sma, 'self_timer', min_time, 'output_actions', {'SchedWaveTrig', 'sd_grace'}, ...
      'input_to_statechange', {'Tup',                    'current_state+1' ; });     
    sma = add_state(sma, ...
      'input_to_statechange', {'softdrinktimer_In', post_softdt, ...     
                               InAction,            'current_state-2', ...
                               'Cin',               post_softdt, ...
                               OtherSidePokeIn,     post_softdt, ...         
                               'sd_grace_In',       post_softdt});

                             
     
%% clean up                        
      
    % clean up any remaining sounds still playing, then jump to next
    % trial
    sma = add_state(sma, 'name', 'CLEAN_UP_STATE', ...
        'self_timer', min_time, ...
        'output_actions', {'SoundOut', -StimulusSpecs.sound_id; ...
                           'SchedWaveTrig', waves_off_cleanup}, ...
        'input_to_statechange', {'Tup', 'current_state+1'});
    
    sma = add_state(sma,  ...
        'self_timer', min_time, ...
        'output_actions', {'SoundOut', -danger_id}, ...
        'input_to_statechange', {'Tup', 'check_next_trial_ready'});    
                            
    % add states to the 'prepare_next_trial' states:
    dispatcher('send_assembler', sma, {'hit_state', 'error_state', 'violation_state'});
    
%% reinit
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
   
    
end;
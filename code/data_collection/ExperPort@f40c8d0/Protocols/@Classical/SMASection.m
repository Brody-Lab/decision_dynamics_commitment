%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'prepare_next_trial'   Returns a @StateMachineAssembler
%                        object, ready to be sent to dispatcher, and a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
%            'get_state_colors'     Returns a structure where each
%                        fieldname is a state name, and each field content
%                        is a color for that state.
%
%
% RETURNS:
% --------
%
% [sma, prepstates]      When action == 'prepare_next_trial', sma is a
%                        @StateMachineAssembler object, ready to be sent to
%                        dispatcher, and prepstates is a a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
% state_colors           When action == 'get_state_colors', state_colors is
%                        a structure where each fieldname is a state name,
%                        and each field content is a color for that state.
%
%
%
% REQUIRES READ-ONLY SOLOPARAMHANDLES:
% ------------------------------------
%
% PokeMeasureTime, RewardTime, PostCSTime, WaterDelivery, WaterBlock
%



function [varargout] = SMASection(obj, action)
   
GetSoloFunctionArgs(obj);

switch action
    
  case 'prepare_next_trial',
    side = SidesSection(obj, 'get_current_side');
    stim = StimulusSection(obj, 'get_stimulus', side);


    left1led     = bSettings('get', 'DIOLINES', 'left1led');
    center1led   = bSettings('get', 'DIOLINES', 'center1led');
    right1led    = bSettings('get', 'DIOLINES', 'right1led');
    left1water   = bSettings('get', 'DIOLINES', 'left1water');
    right1water  = bSettings('get', 'DIOLINES', 'right1water');

    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');
    
    if isequal(stim.loc, 'anti-loc'), 
      if side == 'l', HitEvent = 'Rin'; HitState = 'RightHit'; WaterTime = RtValve; WaterValve = right1water; PALight = right1led;
      else            HitEvent = 'Lin'; HitState = 'LeftHit';  WaterTime = LtValve; WaterValve = left1water;  PALight = left1led;
      end; 
    else
      if side == 'l', HitEvent = 'Lin'; HitState = 'LeftHit';  WaterTime = LtValve; WaterValve = left1water; PALight = left1led;
      else            HitEvent = 'Rin'; HitState = 'RightHit'; WaterTime = RtValve; WaterValve = right1water; PALight = right1led;
      end; 
    end;
    WaterValve = WaterValve*(1-WaterBlock);
    
    PASound_id = SoundManagerSection(obj,  'get_sound_id',       'PASound');
    PASound_dur = SoundManagerSection(obj, 'get_sound_duration', 'PASound');

    switch stim.type,
      case 'lights',
        SoundOut = 0;
        switch stim.loc,
          case 'surround',  DOut = left1led+center1led+right1led;
          case 'pro-loc',   if side=='l', DOut = left1led;  else DOut = right1led; end;
          case 'anti-loc',  if side=='l', DOut = right1led; else DOut = left1led;  end;
          otherwise,
            error('Don''t know how to handle loc type "%s"\n', stim.loc);
        end;
      case 'sounds'
        DOut = 0;
        SoundOut = stim.id;  % Any localization already done at stim creation time
      otherwise,
            error('Don''t know how to handle stim type "%s"\n', stim.type);
    end;

    sma = StateMachineAssembler('full_trial_structure');

          
    switch WaterDelivery,
      case 'direct',   % ----------------------
        sma = add_state(sma, 'name', 'PRECS', 'self_timer', PokeMeasureTime, ...
          'input_to_statechange', {'Tup', 'direct_cs'});
        sma = add_state(sma, 'name', 'DIRECT_CS', 'self_timer', WaterTime, ...
          'input_to_statechange', {'Tup', 'CS'}, ...
          'output_actions', {'DOut', DOut+WaterValve ; 'SoundOut', SoundOut});
        sma = add_state(sma, 'name', 'CS', 'self_timer', max(stim.duration - WaterTime, 1e-4), ...
          'output_actions', {'DOut', DOut}, 'input_to_statechange', {'Tup', HitState});

        sma = add_state(sma, 'name', 'LEFTHIT', 'self_timer', 1e-4,'input_to_statechange', {'Tup', 'postCS'});
        sma = add_state(sma, 'name', 'RIGHTHIT','self_timer', 1e-4,'input_to_statechange', {'Tup', 'postCS'});
        
        preptime = 3;  firstpart = max(PostCSTime-preptime, 1e-4);
        sma = add_state(sma, 'name', 'POSTCS', 'self_timer', firstpart, ...
          'output_actions', {'SoundOut', -SoundOut}, ...
          'input_to_statechange', {'Tup', 'PrepNextTrial'});
        sma = add_state(sma, 'name', 'PREPNEXTTRIAL', 'self_timer', max(PostCSTime-firstpart, 1e-4), ...
          'input_to_statechange', {'Tup', 'check_next_trial_ready'});

        varargout{2} = {'prepnexttrial' 'check_next_trial_ready'};   
        
        
      case 'on correct poke',   % ----------------------
        sma = add_scheduled_wave(sma, 'name', 'postCSTime', 'preamble', PostCSTime+stim.duration);
        
        sma = add_state(sma, 'name', 'PRECS', 'self_timer', PokeMeasureTime, ...
          'input_to_statechange', {'Tup', 'cs'});
        sma = add_state(sma, 'name', 'CS', 'self_timer', stim.duration, ...
          'input_to_statechange', {HitEvent, HitState; 'Tup', 'preRW_postCS'}, ...
          'output_actions', {'DOut', DOut ; 'SoundOut', SoundOut ; 'SchedWaveTrig', 'postCSTime'});
        sma = add_state(sma, 'name', 'PRERW_POSTCS', ...
          'input_to_statechange', {HitEvent, HitState; 'postCSTime_In', 'clean_up'});
        sma = add_state(sma, 'name', 'POSTCS', ...
          'input_to_statechange', {'postCSTime_In', 'clean_up'});
        sma = add_state(sma, 'name', 'CLEAN_UP', 'self_timer', 1e-4, ...
            'output_actions', {'SoundOut', -SoundOut}, ...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        sma = add_state(sma, 'name', 'LEFTHIT', 'self_timer', WaterTime, ...
          'input_to_statechange', {'Tup', 'hit'; 'postCSTime_In', 'check_next_trial_ready'}, ...
          'output_actions', {'DOut', WaterValve, 'SoundOut', -SoundOut});
        sma = add_state(sma, 'name', 'RIGHTHIT', 'self_timer', WaterTime, ...
          'input_to_statechange', {'Tup', 'hit'; 'postCSTime_In', 'check_next_trial_ready'}, ...
          'output_actions', {'DOut', WaterValve, 'SoundOut', -SoundOut});
        sma = add_state(sma, 'name', 'HIT', 'self_timer', 1e-4, ...
          'input_to_statechange', {'Tup', 'postCS'; 'postCSTime_In', 'check_next_trial_ready'});

        varargout{2} = {'postCS' 'check_next_trial_ready'};
        
      case 'on correctly timed poke',   % ----------------------
        min_time = 1e-4;
        
        warn_id   = SoundManagerSection(obj, 'get_sound_id', 'WarningSound');
        danger_id = SoundManagerSection(obj, 'get_sound_id', 'DangerSound');
        sma = add_scheduled_wave(sma, 'name', 'RewardTime', 'preamble', RewardTime);
        sma = add_scheduled_wave(sma, 'name', 'CSduration', 'preamble', stim.duration, 'sustain', 0.001);
    
        sma = add_state(sma, 'name', 'PRECS', 'self_timer', PokeMeasureTime, ...
          'input_to_statechange', {'Tup', 'rewardable_cs'});
        sma = add_state(sma, 'name', 'REWARDABLE_CS', 'self_timer', stim.duration, ...
          'input_to_statechange', {HitEvent, HitState; 'RewardTime_In', 'nonRewardable_CS'; ...
          'Tup', 'rewardable_postCS'; 'CSduration_In', 'rewardable_postCS'}, ...
          'output_actions', {'DOut', DOut ; 'SoundOut', SoundOut; 'SchedWaveTrig', 'RewardTime + CSduration'});

        sma = add_state(sma, 'name', 'REWARDABLE_POSTCS', ...
          'input_to_statechange', {HitEvent, HitState; 'RewardTime_In', 'postcs'});
        sma = add_state(sma, 'name', 'NONREWARDABLE_CS', ...
          'input_to_statechange', {'CSduration_In', 'postcs'}, ...
          'output_actions', {'DOut', DOut});
	  	
        if Reward_Delay < min_time,
          sma = add_state(sma, 'name', 'LEFTHIT', 'self_timer', WaterTime, ...
            'input_to_statechange', {'Tup', 'hit'}, ...
            'output_actions', {'DOut', WaterValve, 'SoundOut', -SoundOut});
          sma = add_state(sma, 'name', 'RIGHTHIT', 'self_timer', WaterTime, ...
            'input_to_statechange', {'Tup', 'hit'}, ...
            'output_actions', {'DOut', WaterValve, 'SoundOut', -SoundOut});

        else % if there's a delay to reward
		  if PostAnswerSoundSwitch == 0, PASound_id = 0; end;
		  if PostAnswerLightSwitch == 0, PALight = 0; end;
		
          sma = add_scheduled_wave(sma, 'name', 'PostAnswerSound', 'preamble', PostAnswerSoundDelay, ...
			'sustain', max(min_time, value(Reward_Delay)), ...
			'sound_trig', PASound_id);

	      sma = add_state(sma, 'name', 'LEFTHIT', 'self_timer', min_time, ...
            'input_to_statechange', {'Tup', 'current_state+1'}, ...
            'output_actions', {'SoundOut', -SoundOut});
          sma = add_state(sma, 'self_timer', value(Reward_Delay), ...
            'input_to_statechange', {'Tup', 'current_state+1'}, ...
            'output_actions', {'SchedWaveTrig', 'PostAnswerSound'; 'DOut', PALight});
          sma = add_state(sma, 'self_timer', WaterTime, ...
            'input_to_statechange', {'Tup', 'hit'}, ...
            'output_actions', {'DOut', WaterValve, 'SoundOut', -PASound_id});
          
          sma = add_state(sma, 'name', 'RIGHTHIT', 'self_timer', min_time, ...
            'input_to_statechange', {'Tup', 'current_state+1'}, ...
            'output_actions', {'SoundOut', -SoundOut});
          sma = add_state(sma, 'self_timer', value(Reward_Delay), ...
            'input_to_statechange', {'Tup', 'current_state+1'}, ...
            'output_actions', {'SchedWaveTrig', 'PostAnswerSound'; 'DOut', PALight});
          sma = add_state(sma, 'self_timer', WaterTime, ...
            'input_to_statechange', {'Tup', 'hit'}, ...
            'output_actions', {'DOut', WaterValve, 'SoundOut', -PASound_id});          
        end;
        
        sma = add_state(sma, 'name', 'HIT', 'self_timer', 1e-4, ...
          'input_to_statechange', {'Tup', 'drink_time'});
        
        if WarnDur > 0,                     post_drink_state = 'warning';
        elseif WarnDur==0 && DangerDur > 0, post_drink_state = 'danger';
        elseif WarnDur==0 && DangerDur==0,  post_drink_state = 'postcs';
        end;
        if DangerDur > 0,                   post_warning_state = 'danger';
        else                                post_warning_state = 'postcs';
        end;

        
        sma = add_state(sma, 'name', 'DRINK_TIME', 'self_timer', max(DrinkTime, 1e-4), ...
          'input_to_statechange', {'Tup', post_drink_state});
        sma = add_state(sma, 'name', 'WARNING', 'self_timer', WarnDur, ...
          'input_to_statechange', {'Tup', post_warning_state}, 'output_actions', {'SoundOut', warn_id});
        sma = add_state(sma, 'name', 'DANGER',  'self_timer', DangerDur, ...
          'output_actions', {'SoundOut', danger_id}, ...
          'input_to_statechange', {'Tup', 'postcs', 'Lin', 'current_state+1', 'Cin', 'current_state+1', 'Rin', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 1e-4, 'output_actions', {'SoundOut', -danger_id}, ...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = PunishInterface(obj, 'add_sma_states', 'PostDrinkPun', sma, 'name', 'mypun', ...
          'exitstate', 'danger');
        sma = add_state(sma, 'name', 'POSTCS', 'self_timer', 0.0001, ...
          'input_to_statechange', {'Tup', 'current_state+1'}, ...
          'output_actions', {'SoundOut', -SoundOut});
        sma = add_state(sma, 'self_timer', PostCSTime, ...
          'input_to_statechange', {'Tup', 'check_next_trial_ready'}, ...
          'output_actions', {'SoundOut', -danger_id});
        
        varargout{2} = {'postcs' 'check_next_trial_ready'};
    end;
    
    varargout{1} = sma;



    % ----------------------------------------------------------------
    % 
    %       CASE GET_STATE_COLORS
    % 
    % ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'precs',             [0.68  1   0.63], ...
      'direct_cs',         [0.63  1   0.94], ...
      'cs',                [1   0.79  0.63], ...
      'rewardable_cs',     [1   0.79  0.63], ...
      'rewardable_postcs', [0.77 0.60 0.48], ...
      'nonrewardable_cs',  [1    0.54 0.54], ...
      'postcs',            [0.31 0.48 0.30], ...
      'prepnexttrial', 0.8*[0.31 0.48 0.30], ...
      'prerw_postcs',      [0.25 0.45 0.48], ...
      'lefthit',           [0.53 0.78 1.00], ...
      'lefthit_pasound',   [0.53 0.78 1.00]*0.7, ...
      'righthit',          [0.52 1.0  0.60], ...
      'righthit_pasound',  [0.52 1.0  0.60]*0.7, ...
      'drink_time',        [0    1    0],    ...
      'warning',           [0.3  0    0],    ...
      'danger',            [0.5  0.05 0.05], ...
      'hit',               [0    1    0]);
    

    
  case 'reinit',
    currfig = gcf;

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end;



function  [] =  StateMatrixSection(obj, action)

global left1water;
global right1water;

GetSoloFunctionArgs;

switch action,
    
    
  case 'init',
    
    StateMatrixSection(obj, 'next_trial');
    
    
  case 'next_trial',
      
      
    sma = StateMachineAssembler('full_trial_structure');

    LcenterValve = {'DOut', left1water};
    RcenterValve = {'DOut', right1water};
    if strcmp(click_or_sound_onSidePoke, 'NO') && (strcmp(click_or_sound,'CLICK') || strcmp(click_or_sound,'SOUND'))
        LcenterValve = {'DOut', left1water};
        RcenterValve = {'DOut', right1water};
    elseif strcmp(click_or_sound_onSidePoke,'YES') && strcmp(click_or_sound,'CLICK')
        LcenterValve = {'DOut', left1water, ...
     'SchedWaveTrig', 'valve_sw'};
        RcenterValve = {'DOut', right1water, ...
     'SchedWaveTrig', 'valve_sw'};
    elseif strcmp(click_or_sound_onSidePoke,'YES') && strcmp(click_or_sound,'SOUND')
        LcenterValve = {'DOut', left1water, ...
     'SchedWaveTrig', 'sound_sw'};
        RcenterValve = {'DOut', right1water, ...
     'SchedWaveTrig', 'sound_sw'};
    end
    
    
    if strcmp(click_or_sound_onSidePoke,'YES')
        
    end
    if strcmp(click_or_sound_onSidePoke, 'NO')
        
    end
    
%     ---------------------------------------------------------------------
%      Scheduled Waves
%     ---------------------------------------------------------------------
    
%    -----------------REMEMBER TO RESET OUTPUTS FOR REAL RIG!!-------------
% RIG VALUES in green!!
%     sma = add_scheduled_wave(sma, 'name', 'laser_trig_sw', 'preamble', 0.001, ...
%         'sustain', 3600, 'sound_trig', value(laserID));% 
    sma = add_scheduled_wave(sma, 'name', 'valve_sw', 'preamble', 0.001, ...
        'sustain', 0.005, 'dio_line', 0);% null_dio better than centervalve; 1; % 2^0
    
    sma = add_scheduled_wave(sma, 'name', 'sound_sw', 'preamble', 0.001, ...
        'sustain', 0.08, 'sound_trig', value(soundID));
%     ---------------------------------------------------------------------
%      States
%     ---------------------------------------------------------------------    
    sma = add_state(sma, 'name', 'waiting_4_both', ...
        'input_to_statechange', {'Lin', 'l_poke_in', ...
                                'Rin', 'r_poke_in'});
    
    sma = add_state(sma, 'name', 'l_poke_in', 'self_timer', value(lValve), ...
        'output_actions', LcenterValve, ... 
        'input_to_statechange', {'Lout', 'end_state', ...
                                'Tup', 'end_state'});
    
    sma = add_state(sma, 'name', 'r_poke_in', 'self_timer', value(rValve),...
        'output_actions', RcenterValve, ... 
        'input_to_statechange', {'Rout', 'end_state', ...
                                'Tup', 'end_state'});
    
    sma = add_state(sma, 'name', 'end_state', 'self_timer', value(timeOut), ...
        'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    
    dispatcher('send_assembler', sma, {'end_state'});
    
    
 case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action); %#ok<WNTAG>
end;

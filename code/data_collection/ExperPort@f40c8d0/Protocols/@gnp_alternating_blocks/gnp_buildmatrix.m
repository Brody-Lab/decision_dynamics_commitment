function  [] =  gnp_buildmatrix(obj, action)

GetSoloFunctionArgs;
global led
switch action
  case 'init',
      if value(real_stim_period_duration) == value(stim_period_duration),
          term_stim_sw_sustain=value(real_stim_period_duration)-0.02;
      else
          term_stim_sw_sustain=value(real_stim_period_duration);
      end
      SoloParamHandle(obj, 'term_stim_sw_sustain', 'value', term_stim_sw_sustain);
      DeclareGlobals(obj, 'rw_args', {'term_stim_sw_sustain'});
      gnp_buildmatrix(obj, 'next_trial');
    
  case 'next_trial',
    sma = StateMachineAssembler('full_trial_structure');

%     ---------------------------------------------------------------------
%      Scheduled Waves
%     ---------------------------------------------------------------------
    sma = add_scheduled_wave(sma, 'name', 'term_stim_sw', 'preamble', value(term_stim_sw_sustain));
    
%     ---------------------------------------------------------------------
%      Init...
%     ---------------------------------------------------------------------
    
    sma = add_state(sma, 'default_statechange', 'baseline', 'self_timer', 0.001);
    
    sma = add_state(sma, 'name', 'baseline', 'self_timer', value(baseline), ...
        'output_actions', {'SchedWaveTrig', '-term_stim_sw'}, ...
        'input_to_statechange', {'Tup', 'first_stim'});
    
    sma = add_state(sma, 'name', 'first_stim', 'self_timer', value(on_time), ...
        'output_actions', {'SoundOut' value(laserID), ...
                           'SchedWaveTrig', 'term_stim_sw', ...
                           'DOut', led}, ...
        'input_to_statechange', {'Tup', 'stim_off', ...
                                'term_stim_sw_In', 'post_stim'});
        
    sma = add_state(sma, 'name', 'stim_off', 'self_timer', value(off_time), ...
        'input_to_statechange', {'Tup', 'stim_on', ...
                                'term_stim_sw_In', 'post_stim'});
    
    sma = add_state(sma, 'name', 'stim_on', 'self_timer', value(on_time), ...
        'output_actions', {'SoundOut', value(laserID), ...
                           'DOut', led}, ...
        'input_to_statechange', {'Tup', 'stim_off', ...
                                'term_stim_sw_In', 'post_stim'});
    
    sma = add_state(sma, 'name', 'post_stim', 'self_timer', value(post_stimulus_time), ...
        'input_to_statechange', {'Tup', 'baseline'});
    
    dispatcher('send_assembler', sma, {'post_stim'});
    
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

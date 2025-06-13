
function  [] =  SmaSection(obj, action)

GetSoloFunctionArgs;


switch action
    case 'init',
        
        feval(mfilename, obj, 'next_trial');
        
        %% next_trial
    case 'next_trial',
        
        sma = StateMachineAssembler('full_trial_structure', 'use_happenings', 1);
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.
        
        left1led           = bSettings('get', 'DIOLINES', 'left1led');
        center1led         = bSettings('get', 'DIOLINES', 'center1led');
        right1led          = bSettings('get', 'DIOLINES', 'right1led');
        left1water         = bSettings('get', 'DIOLINES', 'left1water');
        right1water        = bSettings('get', 'DIOLINES', 'right1water');
        
        [LeftWValveTime RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        params = ParamsSection(obj,'get_params');
        
        
        
        %% State machine for direct delivery
        
        
        sma = add_state(sma,'name','trial_ready','self_timer',min_time,'input_to_statechange',{'Tup','wait_for_poke'});
        % Light the side-ports, wait for the rat to poke
        sma = add_state(sma,'name','wait_for_poke','output_actions',{'DOut',left1led+right1led}, ...
            'input_to_statechange',{'Rhi','deliver_right','Lhi','deliver_left'});
        
        
        sma = add_scheduled_wave(sma,'name','delivery_wav_left','preamble',min_time,'sustain',LeftWValveTime,'DOut',left1water);
        sma = add_scheduled_wave(sma,'name','delivery_wav_right','preamble',min_time,'sustain',RightWValveTime,'DOut',right1water);
        sma = add_scheduled_wave(sma,'name','drink_timer','preamble',params.drink_time);
        
        sma = add_state(sma,'name','deliver_left','output_actions',{'SchedWaveTrig','delivery_wav_left+drink_timer'},'input_to_statechange',{'drink_timer_In','check_next_trial_ready'});
        sma = add_state(sma,'name','deliver_right','output_actions',{'SchedWaveTrig','delivery_wav_right+drink_timer'},'input_to_statechange',{'drink_timer_In','check_next_trial_ready'});
        
        dispatcher('send_assembler', sma, {'check_next_trial_ready','trial_ready'});
        
        %% reinit
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
    otherwise,
        warning('Unknown action! "%s"\n', action);
end


end
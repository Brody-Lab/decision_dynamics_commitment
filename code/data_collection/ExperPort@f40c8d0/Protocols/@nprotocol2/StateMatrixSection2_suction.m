function  [] =  StateMatrixSection2(obj, action)

GetSoloFunctionArgs;

switch action
  case 'init',
    StateMatrixSection2(obj, 'next_trial');
    
  case 'next_trial',
    sma = StateMachineAssembler('full_trial_structure');
    
% -------------------------------------------------------------------------------  
%     sma = add_scheduled_wave(sma, 'name', 'bla', 'preamble', 0.001, 'sustain', 0.1, 'dio_line', 64);
%     sma = add_state(sma, 'name', 'blahgState', 'output_actions', {'SchedWaveTrig', 'bla', 'DOut', shock},
%               'input_to_statechange', {'bla_out', 'goto state whatever', 'Cin', 'goto state whatever2'});
% ---------------------------------------------------------------------------------    
% Initialize the variables that you will use! Could use
% value(whateverSoloParam) dunno why I decided not to...
    stim_sw_preamble = 0.001;
    stim_sw_sustain = 0.001;
    
    % measure the distance between the error rate of past 10 trials and the
    % target error rate (which is a soloparam).
    % then pick up a value for delta from a gaussian? distribution.
    % LOOK HERE!!!    
    % LOOK HERE!!!    
    % LOOK HERE!!!    
% LOOK HERE!!!    cPokeTime.value = value(cPokeTime) + delta
    % LOOK HERE!!!    
    % LOOK HERE!!!    
    % LOOK HERE!!!    
    % LOOK HERE!!!    
    
    go_sw_preamble = value(cPokeTime);%0.1;
    go_sw_sustain = value(cClickTime);%0.1;
    l_valve_open_sw_preamble = value(lPokePVO);%0.01;
    l_valve_open_sw_sustain = value(leftValve);%0.1;
    r_valve_open_sw_preamble = value(rPokePVO);%0.01;
    r_valve_open_sw_sustain = value(rightValve);%0.1;
    l_suction_sw_preamble = value(leftTimetoSuction);%3;
    l_suction_sw_sustain = value(leftSuctionTime);%0.1;
    r_suction_sw_preamble = value(rightTimetoSuction);%3;
    r_suction_sw_sustain = value(rightSuctionTime);0.1;
    waiting_4_both_tup = value(timeto_lrPoke);%5;
    timeIn = value(timeOut);%3;
    start_laser = value(laserStart_after);
    end_laser = value(laserEnd_after);

% DOuts values should be either names if you declared globals at beginning
% or numbers
    lshock = 0;% 0 in emu and rig
    rshock = 0;% 0 in emu and rig
    lnoise=-value(soundID);
    rnoise=-value(soundID);
%     dio_lines should be the power of 2 that corresponds to the DOut
%     number.
    
% %     ----------RIG SETTINGS----------
%     lwater = 2;% leftwater; 4; % 2^2   %2 in emu
%     rwater = 10;% rightwater; 1024; % 2^10   %7 in emu
%     lsuction = 4;% leftsuction; 16; % 2^4   %4 in emu
%     rsuction = 12;% rightsuction; 4096; % 2^12 %9 in emu
%     null_dio = 22;% null_dio; 4194304; % 2^22   %14 in emu
% %     ----------END OF RIG SETTINGS----------

% %     ----------EMULATOR SETTINGS----------
    lwater = 2;% leftwater; 4; % 2^2   %2 in emu
    rwater = 7;% rightwater; 1024; % 2^10   %7 in emu
    lsuction = 4;% leftsuction; 16; % 2^4   %4 in emu
    rsuction = 9;% rightsuction; 4096; % 2^12 %9 in emu
    null_dio = 14;% null_dio; 4194304; % 2^22   %14 in emu
% %     ----------END OF EMULATOR SETTINGS----------

% %     ----------RIG SETTINGS----------
% if value(probvec_shockLeft(n_done_trials+1)) == 1,
%     lshock = 262144;% shock; 262144; % 2^18 %4096 in emu
%     lnoise = value(soundID);    
% end
% if value(probvec_shockRight(n_done_trials+1)) == 1,
%     rshock = 262144;% shock; 262144; % 2^18 %4096 in emu
%     rnoise = value(soundID);
% end
% if value(probvec_waterLeft(n_done_trials+1)) == 0,
%     lwater = null_dio;% 22 or null_dio; 4194304; % 2^22 %14 in emu
%     lsuction = null_dio;
% end
% if value(probvec_waterRight(n_done_trials+1)) == 0,
%     rwater = null_dio;% 22 or null_dio; 4194304; % 2^22 %14 in emu
%     rsuction=null_dio;
% end;
% 
% if strcmp(Noise_or_Shock, 'White Noise')
%         DOut_SoundOut={'SoundOut'};%, lnoise
%         l_shock_noise=lnoise;
%         r_shock_noise=rnoise;
%         %     r_noise_shock={'SoundOut'};%, rnoise
%     elseif strcmp(Noise_or_Shock, 'Shock')
%         DOut_SoundOut={'DOut'};%, lshock
%         l_shock_noise=lshock;
%         r_shock_noise=rshock;
%         %     r_noise_shock={'DOut'};%, rshock
% end
% %     ----------END OF RIG SETTINGS----------

% %     ----------EMULATOR SETTINGS----------

    if value(probvec_shockLeft(n_done_trials+1)) == 1,
        lshock = 4096;% shock; 262144; % 2^18 %4096 in emu
        lnoise = value(soundID);    
    end
    if value(probvec_shockRight(n_done_trials+1)) == 1,
        rshock = 4096;% shock; 262144; % 2^18 %4096 in emu
        rnoise = value(soundID);
    end

    if value(probvec_waterLeft(n_done_trials+1)) == 0,
        lwater = null_dio;% 22 or null_dio; 4194304; % 2^22 %14 in emu
        lsuction = null_dio;
    end
    if value(probvec_waterRight(n_done_trials+1)) == 0,
        rwater = null_dio;% 22 or null_dio; 4194304; % 2^22 %14 in emu
        rsuction=null_dio;
    end;

    if strcmp(Noise_or_Shock, 'White Noise')
        DOut_SoundOut={'SoundOut'};%, lnoise
        l_shock_noise=lnoise;
        r_shock_noise=rnoise;
        %     r_noise_shock={'SoundOut'};%, rnoise
    elseif strcmp(Noise_or_Shock, 'Shock')
        DOut_SoundOut={'DOut'};%, lshock
        l_shock_noise=lshock;
        r_shock_noise=rshock;
        %     r_noise_shock={'DOut'};%, rshock
    end
% %     ----------END OF EMULATOR SETTINGS----------

% laserVar= {'DOut' '0'}; %'4194304'
laserVar= {'SoundOut' 0};
if start_laser == 0,
%     warndlg('noLASER')
    laserVar= {'DOut' '0'}; %'4194304'
end

if n_done_trials == start_laser && start_laser ~=0,
%     warndlg('start LASER Pulse')
    laserVar= {'SoundOut' value(laserID)};
end

if n_done_trials > start_laser,
%     warndlg('remove SW')
    laserVar= {'DOut' '0'}; %'4194304'
end

if n_done_trials >= end_laser && end_laser~=0,
%      warndlg('remove LASER Pulse')
     laserVar= {'SoundOut' -value(laserID)};
end


    if strcmp(beginner, 'YES')
        cPokeJitter = {'go_center_sw_In', 'c_poke_2' };
        cPokeJitter2 = {'Tup', 'idle', ...
                        'Lin', 'l_poke_in_shock_start', ...
                        'Rin', 'r_poke_in_shock_start'};
        leftBeginnerExpert = {'SchedWaveTrig', 'l_suction_sw+l_valve_open_sw+go_sw', ...
                              DOut_SoundOut, l_shock_noise};
        rightBeginnerExpert = {'SchedWaveTrig', 'r_suction_sw+r_valve_open_sw+go_sw', ...
                              DOut_SoundOut, r_shock_noise};
    elseif strcmp(beginner, 'NO')
        cPokeJitter = {'Cout', 'idle', 'go_center_sw_In', 'c_poke_2' };
        cPokeJitter2 = {'Tup', 'idle', ...
                        'Lin', 'l_poke_in_shock_start', ...
                        'Rin', 'r_poke_in_shock_start', ...
                        'Cin', 'c_poke_in_dummy'};
        leftBeginnerExpert = {'SchedWaveTrig', 'l_suction_sw+l_valve_open_sw', ...
                              DOut_SoundOut, l_shock_noise};
        rightBeginnerExpert = {'SchedWaveTrig', 'r_suction_sw+r_valve_open_sw', ...
                              DOut_SoundOut, r_shock_noise};
    end


%     ---------------------------------------------------------------------
%      Scheduled Waves
%     ---------------------------------------------------------------------
    
%    -----------------REMEMBER TO RESET OUTPUTS FOR REAL RIG!!-------------
% RIG VALUES in green!!
%     sma = add_scheduled_wave(sma, 'name', 'laser_trig_sw', 'preamble', 0.001, ...
%         'sustain', 3600, 'sound_trig', value(laserID));% 
    sma = add_scheduled_wave(sma, 'name', 'stim_sw', 'preamble', stim_sw_preamble, ...
        'sustain', stim_sw_sustain, 'dio_line', null_dio);% null_dio better than centervalve; 1; % 2^0
    if strcmp(value(click_or_sound), 'SOUND')
        sma = add_scheduled_wave(sma, 'name', 'go_center_sw', 'preamble', go_sw_preamble, ...
            'sustain', go_sw_sustain, 'sound_trig', value(go_soundID));
        sma = add_scheduled_wave(sma, 'name', 'go_sw', 'preamble', go_sw_preamble, ...
            'sustain', go_sw_sustain, 'sound_trig', value(go_soundID));% centervalve; 1; % 2^0 -------
    elseif strcmp(value(click_or_sound), 'CLICK')
        sma = add_scheduled_wave(sma, 'name', 'go_center_sw', 'preamble', go_sw_preamble, ...
            'sustain', go_sw_sustain, 'dio_line', 0);
        sma = add_scheduled_wave(sma, 'name', 'go_sw', 'preamble', go_sw_preamble, ...
            'sustain', go_sw_sustain, 'dio_line', 0);% centervalve; 1; % 2^0 -------'sound_trig', go_sound_id
    end
    sma = add_scheduled_wave(sma, 'name', 'l_valve_open_sw', 'preamble', l_valve_open_sw_preamble, ...
        'sustain', l_valve_open_sw_sustain, 'dio_line', lwater);
    sma = add_scheduled_wave(sma, 'name', 'r_valve_open_sw', 'preamble', r_valve_open_sw_preamble, ...
        'sustain', r_valve_open_sw_sustain, 'dio_line', rwater);
    sma = add_scheduled_wave(sma, 'name', 'l_suction_sw', 'preamble', l_suction_sw_preamble, ...
        'sustain', l_suction_sw_sustain, 'dio_line', lsuction);
    sma = add_scheduled_wave(sma, 'name', 'r_suction_sw', 'preamble', r_suction_sw_preamble, ...
        'sustain', r_suction_sw_sustain, 'dio_line', rsuction);
        
%     ---------------------------------------------------------------------
%      Init...
%     ---------------------------------------------------------------------
    
    sma = add_state(sma, 'default_statechange', 'waiting_4_cin', 'self_timer', 0.001);
    
    sma = add_state(sma, 'name', 'waiting_4_cin', ...
        'output_actions', laserVar, ...
        'input_to_statechange', {'Cin', 'c_poke_1', ...
                                'Lin', 'l_poke_in_dummy_two', ...
                                'Rin', 'r_poke_in_dummy_two'});
    
    sma = add_state(sma, 'name', 'c_poke_1', ...
        'output_actions', {'SchedWaveTrig', 'go_center_sw+stim_sw'}, ...
        'input_to_statechange', cPokeJitter);
    
    sma = add_state(sma, 'name', 'c_poke_2', ...
        'input_to_statechange', {'Cout', 'waiting_4_both'});
    
    sma = add_state(sma, 'name', 'l_poke_in_dummy_two', ...
        'input_to_statechange', {'Lout', 'waiting_4_cin'});
    
    sma = add_state(sma, 'name', 'r_poke_in_dummy_two', ...
        'input_to_statechange', {'Rout', 'waiting_4_cin'});
    
%     ---------------------------------------------------------------------
%      waiting_4_both state...
%     ---------------------------------------------------------------------

    sma = add_state(sma, 'name', 'waiting_4_both', 'self_timer', waiting_4_both_tup, ...
        'output_actions', {'SchedWaveTrig', '-stim_sw'}, ...
        'input_to_statechange', cPokeJitter2);

%     ---------------------------------------------------------------------
%       Left Trials
%     ---------------------------------------------------------------------

    sma = add_state(sma, 'name', 'l_poke_in_shock_start', ...
        'output_actions', leftBeginnerExpert, ... 
        'input_to_statechange', {'Lout', 'l_poke_out', ...
                                'l_suction_sw_Out', 'l_poke_in_dummy'});
    
    sma = add_state(sma, 'name', 'l_poke_out', ...
        'input_to_statechange', {'Lin', 'l_poke_in_shock', ...
                                'Cin', 'l_c_poke_in', ...
                                'Rin', 'l_r_poke_in', ...
                                'l_suction_sw_Out', 'idle'});

    sma = add_state(sma, 'name', 'l_poke_in_shock', ...
        'output_actions', {DOut_SoundOut, l_shock_noise}, ... 
        'input_to_statechange', {'Lout', 'l_poke_out', ...
                                 'l_suction_sw_Out', 'l_poke_in_dummy'});
 
    sma = add_state(sma, 'name', 'l_c_poke_in', ...
        'input_to_statechange', {'Cout', 'l_poke_out', ...
                                'l_suction_sw_Out', 'c_poke_in_dummy'});
                            
    sma = add_state(sma, 'name', 'l_r_poke_in', ...
        'input_to_statechange', {'Rout', 'l_poke_out', ...
                                'l_suction_sw_Out', 'r_poke_in_dummy'});

%     ---------------------------------------------------------------------
%       Right Trials
%     ---------------------------------------------------------------------

    sma = add_state(sma, 'name', 'r_poke_in_shock_start', ...
        'output_actions', rightBeginnerExpert, ... 
        'input_to_statechange', {'Rout', 'r_poke_out', ...
                                'r_suction_sw_Out', 'r_poke_in_dummy'});
    
    sma = add_state(sma, 'name', 'r_poke_out', ...
        'input_to_statechange', {'Rin', 'r_poke_in_shock', ...
                                'Cin', 'r_c_poke_in', ...
                                'Lin', 'r_l_poke_in', ...
                                'r_suction_sw_Out', 'idle'});

    sma = add_state(sma, 'name', 'r_poke_in_shock', ...
        'output_actions', {DOut_SoundOut, r_shock_noise}, ... 
        'input_to_statechange', {'Rout', 'r_poke_out', ...
                                 'r_suction_sw_Out', 'r_poke_in_dummy'});
 
    sma = add_state(sma, 'name', 'r_c_poke_in', ...
        'input_to_statechange', {'Cout', 'r_poke_out', ...
                                'r_suction_sw_Out', 'c_poke_in_dummy'});
                            
    sma = add_state(sma, 'name', 'r_l_poke_in', ...
        'input_to_statechange', {'Lout', 'r_poke_out', ...
                                'r_suction_sw_Out', 'l_poke_in_dummy'});
                            
%     ---------------------------------------------------------------------
%       Dummy States and Idle State
%     ---------------------------------------------------------------------
    
    sma = add_state(sma, 'name', 'l_poke_in_dummy', ...
        'input_to_statechange', {'Lout', 'idle'});
    sma = add_state(sma, 'name', 'c_poke_in_dummy', ...
        'input_to_statechange', {'Cout', 'idle'});                        
    sma = add_state(sma, 'name', 'r_poke_in_dummy', ...
        'input_to_statechange', {'Rout', 'idle'});
    
    sma = add_state(sma, 'name', 'idle', 'self_timer', timeIn, ...
        'output_actions', {'SchedWaveTrig', '-stim_sw-go_sw-go_center_sw'}, ...
        'input_to_statechange', {'Tup', 'check_next_trial_ready', ...
                                'Lin', 'l_poke_in_dummy', ...
                                'Cin', 'c_poke_in_dummy', ...
                                'Rin', 'r_poke_in_dummy'});
    
    dispatcher('send_assembler', sma, {'idle'});
x=[value(probvec_shockLeft(n_done_trials+1)), value(probvec_shockRight(n_done_trials+1)), ...
   value(probvec_waterLeft(n_done_trials+1)), value(probvec_waterRight(n_done_trials+1))];
x

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

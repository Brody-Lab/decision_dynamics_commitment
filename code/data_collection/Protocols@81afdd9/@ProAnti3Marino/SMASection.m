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
% 
%



function [varargout] = SMASection(obj, action)
   
GetSoloFunctionArgs(obj);

switch action
    
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',

    left1led     = bSettings('get', 'DIOLINES', 'left1led');
    center1led   = bSettings('get', 'DIOLINES', 'center1led');
    right1led    = bSettings('get', 'DIOLINES', 'right1led'); 
    left1water   = bSettings('get', 'DIOLINES', 'left1water');
    right1water  = bSettings('get', 'DIOLINES', 'right1water');
    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');

    if     CenterCue == 0;     cue = 0;
    elseif TypeCenterCue == 0; cue = left1led + right1led;
    elseif TypeCenterCue == 1; cue = center1led;
    end
    
    if strcmp(ThisTrial_Type,'PRO'); context_sound = 'ProSound';
    else                             context_sound = 'AntiSound';
    end
    
    if CenterSustain == 0; post_cue = 0;
    else                   post_cue = cue;
    end
    
    if CueInOut == 0;          post_cue_in = post_cue;    post_cue_out = post_cue;
    else              cue = 0; post_cue_in = center1led;  post_cue_out = 0;
    end
        
    if     strcmp(ThisTrial_Type,'PRO')  && strcmp(ThisTrial_Side,'LEFT');  stimlight = left1led;  correct = 'Lin'; wrong = 'Rin'; rew_dout = left1water;  rew_t = LtValve;
    elseif strcmp(ThisTrial_Type,'PRO')  && strcmp(ThisTrial_Side,'RIGHT'); stimlight = right1led; correct = 'Rin'; wrong = 'Lin'; rew_dout = right1water; rew_t = RtValve;
    elseif strcmp(ThisTrial_Type,'ANTI') && strcmp(ThisTrial_Side,'LEFT');  stimlight = right1led; correct = 'Lin'; wrong = 'Rin'; rew_dout = left1water;  rew_t = LtValve;
    elseif strcmp(ThisTrial_Type,'ANTI') && strcmp(ThisTrial_Side,'RIGHT'); stimlight = left1led;  correct = 'Rin'; wrong = 'Lin'; rew_dout = right1water; rew_t = RtValve;
    end
        
    if Temperror==1,  on_error = 'temperror';
    else              on_error = 'error_state';
    end;
    
    if CtoSgap   == 0;   CtoSgap   = 0.001; end %#ok<NODEF>
    if StimDur   == Inf; StimDur   = 1e6; end %#ok<NODEF>
    if StimDelay == 0;   StimDelay = 0.002; end %#ok<NODEF>
    if StimTime == 1; do_after_c2sgap = 'stim_on';         do_after_waitcin = 'context';
    else              do_after_c2sgap = 'wait_for_spoke';  do_after_waitcin = 'nicstim';
    end
    
    if strcmp(ThisTrial_Free,'FREE'); do_after_c2sgap = 'free_choice'; end
    
    memoryzap = NICDur - MemoryZap;
    
    sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
    
    sma = add_scheduled_wave(sma, 'name', 'stim_wave',         'preamble',StimDur);
    sma = add_scheduled_wave(sma, 'name', 'rew_wave',          'preamble',rew_t);
    sma = add_scheduled_wave(sma, 'name', 'rew_big_wave',      'preamble',rew_t*GoodNICRewMult);
    sma = add_scheduled_wave(sma, 'name', 'memoryzap_wave',    'preamble', memoryzap);
    sma = add_scheduled_wave(sma, 'name', 'bad_nic_wave',      'preamble',0,       'sustain',1000);
    
    sma = add_scheduled_wave(sma, 'name', 'noseincenter_wave', 'preamble', NICDur, 'sustain',1000);
    sma = add_scheduled_wave(sma, 'name', 'legalcbreak_wave',  'preamble', LegalCBrk);
    sma = add_scheduled_wave(sma, 'name', 'prestim_wave',      'preamble', StimDelay);
    
    sma = add_scheduled_wave(sma, 'name', 'endNIC_wave',       'preamble', endNIC, 'sustain',1000);
    sma = add_scheduled_wave(sma, 'name', 'miniLCB_wave',      'preamble', miniLCB,'sustain',1000);
        
    bnwn = get_wavenumber(sma,'bad_nic_wave');
    enwn = get_wavenumber(sma,'endNIC_wave');
    ncwn = get_wavenumber(sma,'noseincenter_wave');
    mlwn = get_wavenumber(sma,'miniLCB_wave');
    
    sma = add_happening_spec(sma, struct(...
        'name',                 {'bad_nic_wave_hi', 'bad_nic_wave_lo', 'endNIC_wave_hi', 'noseincenter_wave_hi', 'miniLCB_wave_hi', 'Clo',     'Chi'      }, ...
        'detectorFunctionName', {'wave_high',       'wave_low',        'wave_high',      'wave_high',            'wave_high',       'line_low','line_high'}, ...
        'inputNumber',          {bnwn,              bnwn,              enwn,             ncwn,                   mlwn,              1,         1          }));
    
    
    if value(n_center_pokes) == 1
        sma = add_state(sma, 'name', 'wait_for_cin',...
            'output_actions',{'DOut',cue},...
            'input_to_statechange', {'Cin',do_after_waitcin; 'Chi',do_after_waitcin});
    end
        
    if KeepNoseCenter == 0
        if StimTime == 1
            sma = add_state(sma, 'name', 'context', 'self_timer',ContextDur,...
                'output_actions',{'DOut',post_cue_in; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},...
                'input_to_statechange', {'Tup','csgap'});
        else
            if strcmp(ThisTrial_Free,'FREE')
                %Free choice trials have no stim sound
                sma = add_state(sma, 'name', 'nicstim', 'self_timer',0.0001,...
                    'output_actions',{'DOut',post_cue_in},...
                    'input_to_statechange', {'Tup','csgap'});
            else
                %regular trials have a stim sound
                sma = add_state(sma, 'name', 'nicstim', 'self_timer',0.0001,...
                    'output_actions',{'DOut',post_cue_in; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
                    'input_to_statechange', {'Tup','csgap'});
            end
        end
    else 

        if CtoStype == 0; after_nic_comp = 'csgap';
        else              after_nic_comp = 'wait_for_cout';
        end
        
        if AllowLR == 0;  do_on_sidepoke = 'reinit_cpoke';
        else              do_on_sidepoke = 'current_state';
        end 
        
        if StimTime == 1 %stim comes after NIC context period
            sma = add_state(sma, 'name', 'context', 'self_timer', 0.0001,...
              'output_actions', {'DOut',post_cue_in; 'SchedWaveTrig', 'noseincenter_wave'; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},...
              'input_to_statechange', {'Tup', 'current_state+1'});
        else %stim comes during NIC, no context sound
            sma = add_state(sma, 'name', 'nicstim', 'self_timer', 0.0001,...
              'output_actions', {'DOut',post_cue_in; 'SchedWaveTrig', 'noseincenter_wave+prestim_wave'},...
              'input_to_statechange', {'Tup', 'current_state+1'});
        end
        
        sma = add_state(sma, 'self_timer', 0.0001,... %(0) NOSE IN start good NIC period
            'output_actions', {'DOut',post_cue_in; 'SchedWaveTrig', '-endNIC_wave-miniLCB_wave'},...
            'input_to_statechange', {'Tup', 'current_state+1'});
        
        sma = add_state(sma, 'self_timer', 0.0001,... %(A) NOSE IN start good NIC period
            'output_actions', {'DOut',post_cue_in; 'SchedWaveTrig', 'endNIC_wave'},...
            'input_to_statechange', {'Tup', 'current_state+1'});
      
        sma = add_state(sma, ...  %(B) NOSE IN 1
            'output_actions', {'DOut',post_cue_in; 'SchedWaveTrig', '-legalcbreak_wave-miniLCB_wave'} ,...  
            'input_to_statechange', {'noseincenter_wave_hi','current_state+1' ;...
                                     'noseincenter_wave_In','current_state+1' ;...
                                     'Cout',                'current_state+2' ;...
                                     'Clo',                 'current_state+2' ;...
                                     'Lin',                 do_on_sidepoke    ;...
                                     'Rin',                 do_on_sidepoke    ;...
                                     'prestim_wave_In',     'stimon_nosein'  });
        sma = add_state(sma, ... %(C) 
            'output_actions', {'DOut',post_cue_in} ,...  
            'input_to_statechange', {'endNIC_wave_hi',      'current_state+5' ;...
                                     'endNIC_wave_In',      'current_state+5' ;...
                                     'Cout',                'current_state+1' ;...
                                     'Clo',                 'current_state+1' ;...
                                     'Lin',                 do_on_sidepoke    ;...
                                     'Rin',                 do_on_sidepoke    ;...
                                     'prestim_wave_In',     'stimon_nosein'  });                         
                                 

        sma = add_state(sma, ...  %(D) NOSE OUT 1
            'output_actions', {'DOut',post_cue_out; 'SchedWaveTrig', 'legalcbreak_wave+miniLCB_wave'},...
            'input_to_statechange', {'noseincenter_wave_hi','current_state+2' ;...
                                     'noseincenter_wave_In','current_state+2' ;...
                                     'legalcbreak_wave_In', 'reinit_cpoke'    ;...
                                     'miniLCB_wave_In',     'current_state+1' ;...
                                     'miniLCB_wave_hi',     'current_state+1' ;...
                                     'Cin',                 'current_state-2' ;...
                                     'Chi',                 'current_state-2' ;...
                                     'Lin',                 do_on_sidepoke    ;...
                                     'Rin',                 do_on_sidepoke    ;...
                                     'prestim_wave_In',     'stimon_noseout' });     
                               
        sma = add_state(sma, ...  %(E) NOSE OUT 2
            'output_actions', {'DOut',post_cue_out; 'SchedWaveTrig', '-endNIC_wave'},...
            'input_to_statechange', {'noseincenter_wave_hi','current_state+2' ;...
                                     'noseincenter_wave_In','current_state+2' ;...
                                     'legalcbreak_wave_In', 'reinit_cpoke'    ;...
                                     'Cin',                 'current_state-5' ;...
                                     'Chi',                 'current_state-5' ;...
                                     'Lin',                 do_on_sidepoke    ;...
                                     'Rin',                 do_on_sidepoke    ;...
                                     'prestim_wave_In',     'stimon_noseout' }); 
                                  
        if ExitNICTime == 0                       
            sma = add_state(sma, ...  %(F) NOSE OUT, NIC time up, must Cin before legalcbreak
              'output_actions', {'DOut',post_cue_out},...
              'input_to_statechange', {'Cin',                  'current_state-4';...
                                       'Chi',                  'current_state-4';...
                                       'legalcbreak_wave_In',  'reinit_cpoke'   ;...
                                       'miniLCB_wave_In',      'current_state+1';...
                                       'miniLCB_wave_hi',      'current_state+1'});
            sma = add_state(sma, ...  %(G)
              'output_actions', {'DOut',post_cue_out; 'SchedWaveTrig', '-endNIC_wave'},...
              'input_to_statechange', {'Cin',                  'current_state-7';...
                                       'Chi',                  'current_state-7';...
                                       'legalcbreak_wave_In',  'reinit_cpoke'});   
          
        else % NOSE OUT, NIC time up but legalcbreak wave has not gone off, okay to move on
            sma = add_state(sma, 'self_timer',0.0001,...  
              'input_to_statechange', {'Tup',                  'current_state+1'});
            sma = add_state(sma, 'self_timer',0.0001,...  
              'input_to_statechange', {'Tup',                  'csgap'});
        end
        
        %Clean up scheduled waves before leaving NIC period
        sma = add_state(sma, 'self_timer',0.0001,... %(H)
            'output_actions', {'DOut',post_cue_in;... 
                               'SchedWaveTrig', '-noseincenter_wave-endNIC_wave-miniLCB_wave-legalcbreak_wave';...
                               'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)},...
            'input_to_statechange', {'Tup',after_nic_comp});
        
        %Start the sound that plays during the NICstim period
        if strcmp(ThisTrial_Free,'FREE')
            %Free trials have no stim sound
            sma = add_state(sma, 'name', 'stimon_nosein', 'self_timer', 0.0001,...
                'output_actions', {'DOut',     post_cue_in;... 
                                   'SchedWaveTrig', 'memoryzap_wave'},...
                'input_to_statechange', {'Tup', 'current_state-7'});
            sma = add_state(sma, 'name', 'stimon_noseout','self_timer', 0.0001,...
                'output_actions', {'DOut',     post_cue_out;...
                                   'SchedWaveTrig', 'memoryzap_wave'},...
                'input_to_statechange', {'Tup', 'current_state-7'});
        else
            %Regular trials have a stim sound
            sma = add_state(sma, 'name', 'stimon_nosein', 'self_timer', 0.0001,...
                'output_actions', {'DOut',     post_cue_in;... 
                                   'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'StimSound');...
                                   'SchedWaveTrig', 'memoryzap_wave'},...
                'input_to_statechange', {'Tup', 'current_state-7'});
            sma = add_state(sma, 'name', 'stimon_noseout','self_timer', 0.0001,...
                'output_actions', {'DOut',     post_cue_out;...
                                   'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'StimSound');...
                                   'SchedWaveTrig', 'memoryzap_wave'},...
                'input_to_statechange', {'Tup', 'current_state-7'});
        end
        
        %NIC failure, reinit
        sma = add_state(sma, 'name', 'reinit_cpoke', 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue_out; 'SchedWaveTrig', '-noseincenter_wave-memoryzap_wave-endNIC_wave-miniLCB_wave-legalcbreak_wave'} ,...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue_out; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound); 'SchedWaveTrig', 'bad_nic_wave'},...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue_out; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
          'input_to_statechange', {'Tup', 'current_state+1'});
      
        if NICViolation == 0; 
            sma = add_state(sma, 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
                'output_actions', {'DOut',post_cue_out; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
                'input_to_statechange', {'Tup', 'current_state+1'});
            sma = add_state(sma,...
                'output_actions', {'DOut', cue},...  
                'input_to_statechange', {'Cin', do_after_waitcin; 'Chi', do_after_waitcin});
        else
            sma = add_state(sma, 'name','start_new_trial', 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
                'output_actions', {'DOut',post_cue_out; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        end   
    end
    
    if CueInOut == 1
        sma = add_state(sma, 'name', 'wait_for_cout',...
            'output_actions', {'DOut',post_cue_in; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'TemperrorSound')},...
            'input_to_statechange', {'Cout','csgap'});
    else
        sma = add_state(sma, 'name', 'wait_for_cout',...
            'input_to_statechange', {'Cout','csgap'});
    end
    
    sma = add_state(sma, 'name', 'csgap', 'self_timer', CtoSgap,...
        'input_to_statechange', {'Tup',do_after_c2sgap});
    
    %Free choice states
    sma = add_state(sma, 'name', 'free_choice',...
        'input_to_statechange', {'Lin','left_reward';'Rin','right_reward'});
    sma = add_state(sma, 'name', 'left_reward','self_timer',LtValve,...
        'output_actions',       {'DOut', left1water},...
        'input_to_statechange', {'Tup','post_freechoice_wait'});
    sma = add_state(sma, 'name', 'right_reward','self_timer',RtValve,...
        'output_actions',       {'DOut', right1water},...
        'input_to_statechange', {'Tup','post_freechoice_wait'});
    sma = add_state(sma, 'name', 'post_freechoice_wait', 'self_timer',3,...
        'input_to_statechange', {'Tup','warndanger'});
    
    %Regular Rewarded states
    if strcmp(ThisTrial_Stim,'LIGHT')
        sma = add_state(sma, 'name', 'stim_on',...
            'output_actions', {'DOut',stimlight; 'SchedWaveTrig','stim_wave'},...
            'input_to_statechange', {'stim_wave_In','wait_for_spoke'; correct,'son_reward_chooser'; wrong,on_error}); 
    else
        stimlight = 0;
        sma = add_state(sma, 'name', 'stim_on',...
            'output_actions',{'SchedWaveTrig','stim_wave'; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
            'input_to_statechange', {'stim_wave_In','stim_off'; correct,'son_reward_chooser'; wrong,on_error});
        
        sma = add_state(sma, 'name', 'stim_off', 'self_timer', 0.001,...
            'output_actions',{'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
            'input_to_statechange', {'Tup','wait_for_spoke'});
    end
        
    sma = add_state(sma, 'name', 'wait_for_spoke',...
        'input_to_statechange', {correct,'soff_reward_chooser'; wrong,on_error}); 
    
    sma = add_state(sma, 'name', 'son_reward_chooser',...
        'input_to_statechange', {'bad_nic_wave_hi', 'reward_son'; 'bad_nic_wave_lo', 'reward_big_son'});
    sma = add_state(sma, 'name', 'soff_reward_chooser',...
        'input_to_statechange', {'bad_nic_wave_hi', 'reward_soff'; 'bad_nic_wave_lo', 'reward_big_soff'});
    
    
    %Reward states when no NIC violations have occurred
    sma = add_state(sma, 'name', 'reward_big_soff',...
        'output_actions', {'DOut',rew_dout+stimlight; 'SchedWaveTrig','rew_big_wave'; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'rew_big_wave_In','post_reward_off'});
    
    sma = add_state(sma, 'name', 'reward_big_son',...
        'output_actions', {'DOut',rew_dout+stimlight; 'SchedWaveTrig','rew_big_wave'},...
        'input_to_statechange', {'rew_big_wave_In','post_reward_on'; 'stim_wave_In','reward_big_soffwon'});
    
    sma = add_state(sma, 'name', 'reward_big_soffwon',...
        'output_actions', {'DOut',rew_dout; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'rew_big_wave_In','post_reward_off'});
    
    %Reward states when at least 1 NIC violation has occured
    sma = add_state(sma, 'name', 'reward_soff',...
        'output_actions', {'DOut',rew_dout+stimlight; 'SchedWaveTrig','rew_wave'; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'rew_wave_In','post_reward_off'});
    
    sma = add_state(sma, 'name', 'reward_son',...
        'output_actions', {'DOut',rew_dout+stimlight; 'SchedWaveTrig','rew_wave'},...
        'input_to_statechange', {'rew_wave_In','post_reward_on'; 'stim_wave_In','reward_soffwon'});
    
    sma = add_state(sma, 'name', 'reward_soffwon',...
        'output_actions', {'DOut',rew_dout; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'rew_wave_In','post_reward_off'});
    
    
    sma = add_state(sma, 'name', 'post_reward_on', 'self_timer', StimRewardOverlap - rew_t,...
        'output_actions', {'DOut',stimlight'},...
        'input_to_statechange', {'Tup','post_reward_off'});
    
    sma = add_state(sma, 'name', 'post_reward_off', 'self_timer', SoftPokeStayInterface2(obj, 'get', 'soft_drink_time', 'Grace'),...
        'output_actions', {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'Tup','warndanger', correct,'soft_drink_time'});
                
    %sma = add_state(sma, 'name', 'soft_drink_time', 'self_timer', 1, 'input_to_statechange', {'Tup','warndanger'});
    sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_time', sma, ...
      'pokeid', correct(1), 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
        
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger');
        
    sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
      'exitstate', 'check_next_trial_ready');
  
    sma = add_state(sma, 'name', 'temperror', 'self_timer', 0.001,...
        'output_actions', {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
        'input_to_statechange', {'Tup', 'current_state+1'});
    
    sma = add_state(sma, 'self_timer', SoundManagerSection(obj, 'get_sound_duration', 'TemperrorSound'), ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'TemperrorSound')},...
      'input_to_statechange', {'Tup', 'stim_on'});
    
    if NICViolation == 0; 
        sma = add_state(sma, 'name','start_new_trial', 'self_timer',0.001,...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    end
    varargout{1} = sma;
    varargout{2} = {'soft_drink_time', 'error_state', 'reward_soff', 'reward_son', 'warndanger_warning', 'start_new_trial'};    
        
               
 

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
%   case 'get_state_colors',    
%     varargout{1} = struct( ...
%       'wait_for_cin',       [129  77 110]/255, ...  % plum
%       'context',            [255   0 255]/255, ...  % magenta
%       'nicstim',            [200   0 255]/255, ...  % purple
%       'stimon_nosein',      [255 100 200]/255, ...  % pink
%       'stimon_noseout',     [255 100 200]/255, ...  % pink
%       'wait_for_cout',      [200 190 100]/255, ...  % dark mustard
%       'csgap',              [255 236 139]/255, ...  % light goldenrod
%       'stim_on',            [255 161 137]/255, ...  % peach 
%       'stim_off',           [255 161 137]/255, ...  % peach 
%       'wait_for_spoke',     [188  77 110]/255, ...  % fuscia
%       'son_reward_chooser', [  0 255   0]/255, ...  % green
%       'soff_reward_chooser',[  0 255   0]/255, ...  % green
%       'reward_son',         [  0 255   0]/255, ...  % green
%       'reward_soffwon',     [  0 255   0]/255, ...  % green
%       'reward_soff',        [  0 255   0]/255, ...  % green
%       'reward_big_son',     [  0 255   0]/255, ...  % green
%       'reward_big_soffwon', [  0 255   0]/255, ...  % green
%       'reward_big_soff',    [  0 255   0]/255, ...  % green
%       'post_reward_on',     [  0 255   0]/255, ...  % green
%       'post_reward_off',    [  0 255   0]/255, ...  % green
%       'soft_drink_time',    [  0 255   0]/255, ...  % green
%       'warndanger_warning', [0.3  0    0],    ...   % dark maroon
%       'warndanger_danger',  [0.5  0.05 0.05], ...   % lighter maroon
%       'reinit_cpoke',       [180   0   0]/255, ...  % medium red
%       'error_state',        [255   0   0]/255, ...  % red
%       'temperror',          [1   1   0  ],     ...  % yellow
%       'start_new_trial',    [0.5 0.5 0.5],     ...  % dark gray
%       'state_0',            [1   1   1  ],     ...  % white
%       'check_next_trial_ready',     [0.7 0.7 0.7],...% light gray
%       'stim_wave',          [1   1   1  ],     ...
%       'rew_wave',           [1   1   1  ],     ...
%       'rew_big_wave',       [1   1   1  ],     ...
%       'noseincenter_wave',  [1   1   1  ],     ...
%       'legalcbreak_wave',   [1   1   1  ],     ...
%       'prestim_wave',       [1   1   1  ],     ...
%       'memoryzap_wave',     [1   1   1  ],     ...
%       'bad_nic_wave',       [1   1   1  ]);
    
  case 'reinit',
    currfig = double(gcf);

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end;



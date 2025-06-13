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

    
    side = SidesSection(obj, 'get_current_side');
    if side=='l', stimulus_name='left_stimulus';  correct_poke='Lin'; incorrect_poke='Rin'; rew_dout=left1water;  rew_t=LtValve; Reward_Multiply=L_Reward_Multiply;
    else          stimulus_name='right_stimulus'; correct_poke='Rin'; incorrect_poke='Lin'; rew_dout=right1water; rew_t=RtValve; Reward_Multiply=R_Reward_Multiply;
    end;
        
    RA = PsychSection(obj,'get_rewardaround');
    if RA ~= 0
       StimDur = SoundManagerSection(obj, 'get_sound_duration', stimulus_name);
       if     StimDur < RA && side == 'r';        correct_poke='Lin'; incorrect_poke='Rin'; rew_dout=left1water;  rew_t=LtValve; Reward_Multiply=L_Reward_Multiply;
       elseif StimDur > RA && side == 'l';        correct_poke='Rin'; incorrect_poke='Lin'; rew_dout=right1water; rew_t=RtValve; Reward_Multiply=R_Reward_Multiply;
       end
    end
    
    sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);
    
    sma = add_happening_spec(sma, struct(...
        'name',                 {'Clo',     'Chi'      }, ...
        'detectorFunctionName', {'line_low','line_high'}, ...
        'inputNumber',          {1,         1          }));

    if value(Inter_Trial_Interval) > 0
        sma = add_state(sma, 'name', 'iti', 'self_timer', Inter_Trial_Interval,...
            'input_to_statechange', {'Tup', 'current_state+1'});
    end
    
    if value(n_center_pokes) == 0
        if strcmp(side,'l') == 1 
            sma = add_state(sma, 'name', 'wait_for_lin1',...
                'output_actions', {'DOut', left1led},...
                'input_to_statechange', {'Lin', 'var_gap1'});
        else
            sma = add_state(sma, 'name', 'wait_for_rin1',...
                'output_actions', {'DOut', right1led},...
                'input_to_statechange', {'Rin', 'var_gap1'});
        end
    else
        if value(start_on_left) == 0
            sma = add_state(sma, 'name', 'wait_for_cin1', ...
                'output_actions', {'DOut', center1led}, ...
                'input_to_statechange', {'Cin', 'var_gap1','Chi', 'var_gap1'});
        else
            sma = add_state(sma, 'name', 'wait_for_lin1',...
                'output_actions', {'DOut', left1led},...
                'input_to_statechange', {'Lin', 'var_gap1','Lhi', 'var_gap1'});
        end
    end

    if KeepNoseCenter == 0
        sma = add_scheduled_wave(sma, 'name', 'var_gap1_wave', 'preamble', DistribInterface(obj, 'get_current_sample', 'var_gap1'));

        sma = add_state(sma, 'name', 'var_gap1', 'self_timer', 0.0001, ...
          'output_actions', {'SchedWaveTrig', 'var_gap1_wave'} , ...
          'input_to_statechange', {'Tup', 'current_state+1'});

        sma = add_state(sma, ...  % I'm in var_gap_1,  NOSE IN
          'input_to_statechange', ...
          {'var_gap1_wave_In', 'var_gap2' ; ...
          'Cout', 'current_state+1'});

        sma = add_state(sma, ...  % I'm in var_gap_1,  NOSE OUT
          'input_to_statechange', ...
          {'var_gap1_wave_In', 'var_gap2+1' ; ...
          'Cin', 'current_state-1'});

        if     value(n_center_pokes) == 1, 
          after_var_gap2_nose_out = 'vargap2_offset'; 
          after_var_gap2_nose_in  = 'vargap2_offset'; 
        else 
            if value(start_on_left) == 0
                after_var_gap2_nose_out = 'wait_for_cin2';
                after_var_gap2_nose_in  = 'center_flash'; 
            else
                after_var_gap2_nose_out = 'wait_for_lin2';
                after_var_gap2_nose_in  = 'left_flash'; 
            end
        end;

        sma = add_scheduled_wave(sma, 'name', 'var_gap2_wave', 'preamble', DistribInterface(obj, 'get_current_sample', 'var_gap2'));

        sma = add_state(sma, 'name', 'var_gap2', 'self_timer', 0.001, ...  % NOSE IN
          'output_actions', {'SchedWaveTrig', 'var_gap2_wave', ...
          'SoundOut', SoundManagerSection(obj, 'get_sound_id', stimulus_name)} , ...
          'input_to_statechange', {'Tup', 'current_state+2'});

        sma = add_state(sma, 'self_timer', 0.001, ...  % NOSE OUT
          'output_actions', {'SchedWaveTrig', 'var_gap2_wave', ...
          'SoundOut', SoundManagerSection(obj, 'get_sound_id', stimulus_name)} , ...
          'input_to_statechange', {'Tup', 'current_state+2'});


        if value(start_on_left) == 0
            sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE IN CENTER
              'input_to_statechange', ...
              {'var_gap2_wave_In', after_var_gap2_nose_in ; ...
              'Cout', 'current_state+1'});

            sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE OUT OF CENTER
              'input_to_statechange', ...
              {'var_gap2_wave_In', after_var_gap2_nose_out ; ...
              'Cin', 'current_state-1'});
        else
            sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE IN LEFT
              'input_to_statechange', ...
              {'var_gap2_wave_In', after_var_gap2_nose_in ; ...
              'Lout', 'current_state+1'});

            sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE OUT OF LEFT
              'input_to_statechange', ...
              {'var_gap2_wave_In', after_var_gap2_nose_out ; ...
              'Lin', 'current_state-1'});
        end


        sma = add_state(sma, 'name', 'center_flash', 'self_timer', 0.005, ...
          'output_actions', {'DOut', center1led}, ...
          'input_to_statechange', {'Tup', 'vargap2_offset'});

        sma = add_state(sma, 'name', 'left_flash', 'self_timer', 0.005, ...
          'output_actions', {'DOut', left1led}, ...
          'input_to_statechange', {'Tup', 'vargap2_offset'});
    
      
        sma = add_state(sma, 'name', 'wait_for_cin2', ...
          'output_actions', {'DOut', center1led}, ...
          'input_to_statechange', {'Cin', 'vargap2_offset'});

        sma = add_state(sma, 'name', 'wait_for_lin2', ...
          'output_actions', {'DOut', left1led}, ...
          'input_to_statechange', {'Lin', 'vargap2_offset'});
      
    else
        %Rat must keep its nose in the center poke for a specified
        %duration.  The stimulus will start after vargap1.
        
        
        sma = add_scheduled_wave(sma, 'name', 'var_gap1_wave',     'preamble', DistribInterface(obj, 'get_current_sample', 'var_gap1'));
        sma = add_scheduled_wave(sma, 'name', 'noseincenter_wave', 'preamble', NICDur);
        sma = add_scheduled_wave(sma, 'name', 'legalcbreak_wave',  'preamble', LegalCBrk);
        
        if AllowLR == 0; do_on_sidepoke = 'reinit_cpoke';
        else             do_on_sidepoke = 'current_state';
        end 

        sma = add_state(sma, 'name', 'var_gap1', 'self_timer', 0.0001, ...
          'output_actions', {'SchedWaveTrig', 'var_gap1_wave' ; 'DOut', center1led} , ...
          'input_to_statechange', {'Tup', 'current_state+1'});
      
        sma = add_state(sma, 'self_timer', 0.0001, ...
          'output_actions', {'SchedWaveTrig', 'noseincenter_wave' ; 'DOut', center1led} , ...
          'input_to_statechange', {'Tup', 'current_state+1'});
      
        sma = add_state(sma, ...  % I'm in var_gap_1,  NOSE IN
          'output_actions', {'SchedWaveTrig', '-legalcbreak_wave' ; 'DOut', center1led} ,...  
          'input_to_statechange', {'var_gap1_wave_In',    'var_gap2'        ;...
                                   'Cout',                'current_state+1' ;...
                                   'Lin',                 do_on_sidepoke    ;...
                                   'Rin',                 do_on_sidepoke    });

        sma = add_state(sma, ...  % I'm in var_gap_1,  NOSE OUT
          'output_actions', {'SchedWaveTrig', 'legalcbreak_wave' ; 'DOut', center1led} ,...
          'input_to_statechange', {'var_gap1_wave_In',    'current_state+2' ;...
                                   'Cin',                 'current_state-1' ;...
                                   'legalcbreak_wave_In', 'reinit_cpoke'    ;...
                                   'Lin',                 do_on_sidepoke    ;...
                                   'Rin',                 do_on_sidepoke    });
        
        
        sma = add_state(sma, 'name', 'var_gap2', 'self_timer', 0.0001, ... %Start Sound, NOSE IN
          'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', stimulus_name) ; 'DOut', center1led} , ...
          'input_to_statechange', {'Tup', 'current_state+2'});  
      
        sma = add_state(sma, 'self_timer', 0.0001, ... %Start Sound, NOSE OUT
          'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', stimulus_name) ; 'DOut', center1led} , ...
          'input_to_statechange', {'Tup', 'current_state+2'});  
      
        sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE IN
          'output_actions', {'SchedWaveTrig', '-legalcbreak_wave' ; 'DOut', center1led} ,...  
          'input_to_statechange', {'Cout',                 'current_state+1' ;...
                                   'noseincenter_wave_In', 'vargap2_offset'  ;...
                                   'Lin',                  do_on_sidepoke    ;...
                                   'Rin',                  do_on_sidepoke    });

        sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE OUT
          'output_actions', {'SchedWaveTrig', 'legalcbreak_wave' ; 'DOut', center1led} ,...
          'input_to_statechange', {'Cin',                  'current_state-1' ;...
                                   'noseincenter_wave_In', 'current_state+1' ;...
                                   'legalcbreak_wave_In',  'reinit_cpoke'    ;...
                                   'Lin',                  do_on_sidepoke    ;...
                                   'Rin',                  do_on_sidepoke    });
                               
        if ExitNICTime == 0                       
            sma = add_state(sma, ...  % I'm in var_gap_2, NOSE OUT, NIC time up, must Cin before legalcbreak
              'output_actions', {'DOut', center1led},...  
              'input_to_statechange', {'Cin',                  'vargap2_offset' ;...
                                       'legalcbreak_wave_In',  'reinit_cpoke'});
        else % I'm in var_gap_2, NOSE OUT, NIC time up but legalcbreak wave has not gone off, okay to move on
            sma = add_state(sma, 'self_timer',0.0001,...  
              'output_actions', {'DOut', center1led},...  
              'input_to_statechange', {'Tup',                  'vargap2_offset'});
        end
                               
        sma = add_state(sma, 'name', 'reinit_cpoke', 'self_timer', 0.0001,...
          'output_actions', {'SchedWaveTrig', '-noseincenter_wave'} ,...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 0.0001,...
          'output_actions', {'SchedWaveTrig', '-var_gap1_wave'},...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 0.0001,...
          'output_actions', {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', stimulus_name)},...
          'input_to_statechange', {'Tup', 'current_state+1'});
        %sma = add_state(sma, 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
        %  'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
        %  'input_to_statechange', {'Tup', 'current_state+1'});
      
      if ReinitNICFail == 1; 
            sma = add_state(sma, 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
                'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
                'input_to_statechange', {'Tup', 'current_state+1'});
            sma = add_state(sma,...
                'output_actions', {'DOut', center1led},...  
                'input_to_statechange', {'Cin', 'var_gap1'; 'Chi', 'var_gap1'});
        else
            sma = add_state(sma, 'name','start_new_trial', 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
                'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        end  
      
        %sma = add_state(sma,...
        %  'output_actions', {'DOut', center1led},...  
        %  'input_to_statechange', {'Cin', 'var_gap1'});
        
    end
  
    if value(Locked_VarGap2_Offset) == 0; vg2_offset = 0.01;
    else                                  vg2_offset = value(Locked_VarGap2_Offset);
    end
        
    if Temperror==1,  on_error = 'temperror';
    else              on_error = 'error_state';
    end;
    
    sma = add_state(sma, 'name', 'vargap2_offset', 'self_timer', vg2_offset,...
        'input_to_statechange', {'Tup', 'wait_for_spoke'});
    
    if value(Probe_Trials) == 1 && PsychSection(obj,'get_trialtype') ~= 1 && PsychSection(obj,'get_trialtype') ~= 10
        %This is an intermediate probe trial
        if     strcmp(value(Probe_Reward),'None') == 1
            %Give no reward
            sma = add_state(sma, 'name', 'wait_for_spoke',...
                'input_to_statechange', {'Lin', 'no_reward' ; 'Rin', 'no_reward'});
        elseif strcmp(value(Probe_Reward),'Random') == 1
            %Randomly assign reward and punishment to left and right poke
            if rand(1) < 0.5
                sma = add_state(sma, 'name', 'wait_for_spoke',...
                    'input_to_statechange', {'Lin', on_error ; 'Rin', 'prereward'});
                rew_dout=right1water;  rew_t=RtValve;
            else
                sma = add_state(sma, 'name', 'wait_for_spoke',...
                    'input_to_statechange', {'Lin', 'prereward' ; 'Rin', on_error});
                rew_dout=left1water;  rew_t=LtValve;
            end
        elseif strcmp(value(Probe_Reward),'Always') == 1
            %Give reward on any side poke
            sma = add_state(sma, 'name', 'wait_for_spoke',...
                'input_to_statechange', {'Lin', 'prereward' ; 'Rin', 'prereward'});
            rew_dout=left1water+right1water;  rew_t=mean([LtValve RtValve]);
        else
            %Reward is given normally only on "correct" side poke
            sma = add_state(sma, 'name', 'wait_for_spoke', ...
                'input_to_statechange', {correct_poke, 'prereward'; incorrect_poke, on_error});
        end
        
    else
        sma = add_state(sma, 'name', 'wait_for_spoke', ...
            'input_to_statechange', {correct_poke, 'prereward'; incorrect_poke, on_error});
    end
    
    sma = add_state(sma, 'name', 'temperror', 'self_timer', SoundManagerSection(obj, 'get_sound_duration', 'TemperrorSound'), ...
      'input_to_statechange', {'Tup', 'wait_for_spoke'}, ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'TemperrorSound')});
    
    
    if Reward_Multiply > 1
        sma = add_state(sma, 'name', 'prereward', 'self_timer', rew_t, ...
            'output_actions', {'DOut',rew_dout},...
            'input_to_statechange', {'Tup','current_state+1'});
            
        if round(Reward_Multiply) > 2
            for R = 2:round(Reward_Multiply - 1)
                sma = add_state(sma, 'self_timer', 0.15, ...
                    'input_to_statechange', {'Tup','current_state+1'});
                sma = add_state(sma, 'self_timer', rew_t, ...
                    'output_actions', {'DOut',rew_dout},...
                    'input_to_statechange', {'Tup','current_state+1'});
            end
        end

        sma = add_state(sma, 'self_timer', 0.15, ...
            'input_to_statechange', {'Tup','soft_drink_time'});
    else
        sma = add_state(sma, 'name', 'prereward', 'self_timer', 0.01, ...
            'input_to_statechange', {'Tup','soft_drink_time'});
    end
  

    sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_time', sma, ...
      'pokeid', correct_poke(1), 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
      'Sound1TrigTime', SoundRewardOverlap, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', stimulus_name), ...
      'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
    
 
    sma = add_state(sma, 'name', 'no_reward', 'self_timer', 4, ...
        'input_to_statechange', {'Tup','warndanger'});
  
  
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger');
        
    sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
      'exitstate', 'check_next_trial_ready');
  
    
    varargout{1} = sma;
    varargout{2} = {'soft_drink_time', 'error_state', 'no_reward', 'start_new_trial'};
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'iti',               [  0   0   0]/255, ...  % black  
      'wait_for_cin1',     [129  77 110]/255, ...  % plum
      'wait_for_lin1',     [129  77 110]/255, ...  % plum
      'wait_for_rin1',     [129  77 110]/255, ...  % plum
      'var_gap1',          [255 236 139]/255, ...  % light goldenrod
      'var_gap2',          [255 161 137]/255, ...  % peach 
      'wait_for_cin2',     [188  77 110]/255, ...  % fuscia
      'wait_for_lin2',     [188  77 110]/255, ...  % fuscia
      'center_flash',      [188  77 110]/255, ...  % fuscia
      'left_flash',        [188  77 110]/255, ...  % fuscia
      'vargap2_offset',    [106 129 110]/255, ...  % dark sage
      'wait_for_spoke',    [132 161 137]/255, ...  % sage
      'temperror',         [61  131 157]/255, ...  % aqua teal
      'prereward',         [50  255  50]/255, ...  % green
      'soft_drink_time',   [50  255  50]/255, ...  % green
      'warndanger_warning',[0.3  0    0],    ...   % dark maroon
      'warndanger_danger', [0.5  0.05 0.05], ...   % lighter maroon
      'reinit_cpoke',      [180   0   0]/255, ...  % medium red
      'error_state',       [255   0   0]/255, ...  % red
      'no_reward',         [1   1   0  ],     ...  % yellow
      'state_0',           [1   1   1  ],  ...
      'check_next_trial_ready',     [0.7 0.7 0.7]);


    
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



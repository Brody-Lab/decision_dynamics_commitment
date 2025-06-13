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
        
    if     strcmp(ThisTrial_Type,'PRO')  && strcmp(ThisTrial_Side,'LEFT');  stimlight = left1led;  correct = 'Lin'; wrong = 'Rin'; rew_dout = left1water;  rew_t = LtValve;
    elseif strcmp(ThisTrial_Type,'PRO')  && strcmp(ThisTrial_Side,'RIGHT'); stimlight = right1led; correct = 'Rin'; wrong = 'Lin'; rew_dout = right1water; rew_t = RtValve;
    elseif strcmp(ThisTrial_Type,'ANTI') && strcmp(ThisTrial_Side,'LEFT');  stimlight = right1led; correct = 'Lin'; wrong = 'Rin'; rew_dout = left1water;  rew_t = LtValve;
    elseif strcmp(ThisTrial_Type,'ANTI') && strcmp(ThisTrial_Side,'RIGHT'); stimlight = left1led;  correct = 'Rin'; wrong = 'Lin'; rew_dout = right1water; rew_t = RtValve;
    end
        
    if Temperror==1,  on_error = 'temperror';
    else              on_error = 'error_state';
    end;
    
    if CtoSgap == 0; CtoSgap = 0.001; end %#ok<NODEF>
    if StimDur == Inf; StimDur = 1e6; end %#ok<NODEF>
    
    sma = StateMachineAssembler('full_trial_structure');
    
    sma = add_scheduled_wave(sma, 'name', 'stim_wave', 'preamble',StimDur);
    sma = add_scheduled_wave(sma, 'name', 'rew_wave',  'preamble',rew_t);
    
    if value(n_center_pokes) == 1
        sma = add_state(sma, 'name', 'wait_for_cin',...
            'output_actions',{'DOut',cue},...
            'input_to_statechange', {'Cin','context'});
    end
        
    if KeepNoseCenter == 0

        sma = add_state(sma, 'name', 'context', 'self_timer',ContextDur,...
            'output_actions',{'DOut',post_cue; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},...
            'input_to_statechange', {'Tup','csgap'});
    else 

        sma = add_scheduled_wave(sma, 'name', 'noseincenter_wave', 'preamble', NICDur);
        sma = add_scheduled_wave(sma, 'name', 'legalcbreak_wave',  'preamble', LegalCBrk);
        
        if AllowLR == 0; do_on_sidepoke = 'reinit_cpoke';
        else             do_on_sidepoke = 'current_state';
        end 

        sma = add_state(sma, 'name', 'context', 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue; 'SchedWaveTrig', 'noseincenter_wave' },...
          'input_to_statechange', {'Tup', 'current_state+1'});
      
        sma = add_state(sma, 'self_timer', 0.0001, ...
          'output_actions', {'DOut',post_cue; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', context_sound)},...
          'input_to_statechange', {'Tup', 'current_state+1'});
      
        sma = add_state(sma, ...  % NOSE IN
          'output_actions', {'DOut',post_cue; 'SchedWaveTrig', '-legalcbreak_wave'} ,...  
          'input_to_statechange', {'noseincenter_wave_In','csgap'           ;...
                                   'Cout',                'current_state+1' ;...
                                   'Lin',                 do_on_sidepoke    ;...
                                   'Rin',                 do_on_sidepoke    });

        sma = add_state(sma, ...  % NOSE OUT
          'output_actions', {'DOut',post_cue; 'SchedWaveTrig', 'legalcbreak_wave'},...
          'input_to_statechange', {'noseincenter_wave_In','current_state+1' ;...
                                   'legalcbreak_wave_In', 'reinit_cpoke'    ;...
                                   'Cin',                 'current_state-1' ;...
                                   'Lin',                 do_on_sidepoke    ;...
                                   'Rin',                 do_on_sidepoke    });
                                  
        if ExitNICTime == 0                       
            sma = add_state(sma, ...  % NOSE OUT, NIC time up, must Cin before legalcbreak
              'output_actions', {'DOut',post_cue},...
              'input_to_statechange', {'Cin',                  'csgap' ;...
                                       'legalcbreak_wave_In',  'reinit_cpoke'});
        else % NOSE OUT, NIC time up but legalcbreak wave has not gone off, okay to move on
            sma = add_state(sma, 'self_timer',0.0001,...  
              'input_to_statechange', {'Tup',                  'csgap'});
        end
                               
        sma = add_state(sma, 'name', 'reinit_cpoke', 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue; 'SchedWaveTrig', '-noseincenter_wave'} ,...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', 0.0001,...
          'output_actions', {'DOut',post_cue; 'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)},...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma, 'self_timer', SoundInterface(obj,'get','Reinit','Dur1'),...
          'output_actions', {'DOut',post_cue; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'Reinit')},...
          'input_to_statechange', {'Tup', 'current_state+1'});
        sma = add_state(sma,...
          'output_actions', {'DOut', cue},...  
          'input_to_statechange', {'Cin', 'context'});
        
    end
        
    sma = add_state(sma, 'name', 'csgap', 'self_timer', CtoSgap,...
        'output_actions', {'SoundOut', -SoundManagerSection(obj, 'get_sound_id', context_sound)},...
        'input_to_statechange', {'Tup','stim_on'});
    
    if strcmp(ThisTrial_Stim,'LIGHT')
        sma = add_state(sma, 'name', 'stim_on',...
            'output_actions', {'DOut',stimlight; 'SchedWaveTrig','stim_wave'},...
            'input_to_statechange', {'stim_wave_In','wait_for_spoke'; correct,'reward_son'; wrong,on_error}); 
    else
        stimlight = 0;
        sma = add_state(sma, 'name', 'stim_on',...
            'output_actions',{'SchedWaveTrig','stim_wave'; 'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
            'input_to_statechange', {'stim_wave_In','stim_off'; correct,'reward_son'; wrong,on_error});
        
        sma = add_state(sma, 'name', 'stim_off', 'self_timer', 0.001,...
            'output_actions',{'SoundOut', -SoundManagerSection(obj, 'get_sound_id', 'StimSound')},...
            'input_to_statechange', {'Tup','wait_for_spoke'});
    end
        
    sma = add_state(sma, 'name', 'wait_for_spoke',...
        'input_to_statechange', {correct,'reward_soff'; wrong,on_error}); 
    
    sma = add_state(sma, 'name', 'reward_soff',...
        'output_actions', {'SchedWaveTrig','rew_wave'},...
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
  
    
    varargout{1} = sma;
    varargout{2} = {'soft_drink_time', 'error_state', 'reward_soff', 'reward_son', 'warndanger_warning'};    
        
               
 

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'wait_for_cin',      [129  77 110]/255, ...  % plum
      'context',           [255   0 255]/255, ...  % magenta
      'csgap',             [255 236 139]/255, ...  % light goldenrod
      'stim_on',           [255 161 137]/255, ...  % peach 
      'stim_off',          [255 161 137]/255, ...  % peach 
      'wait_for_spoke',    [188  77 110]/255, ...  % fuscia
      'reward_son',        [  0 255   0]/255, ...  % green
      'reward_soffwon',    [  0 255   0]/255, ...  % green
      'reward_soff',       [  0 255   0]/255, ...  % green
      'post_reward_on',    [  0 255   0]/255, ...  % green
      'post_reward_off',   [  0 255   0]/255, ...  % green
      'soft_drink_time',   [  0 255   0]/255, ...  % green
      'warndanger_warning',[0.3  0    0],    ...   % dark maroon
      'warndanger_danger', [0.5  0.05 0.05], ...   % lighter maroon
      'reinit_cpoke',      [180   0   0]/255, ...  % medium red
      'error_state',       [255   0   0]/255, ...  % red
      'temperror',         [1   1   0  ],     ...  % yellow
      'state_0',           [1   1   1  ],     ...  % white
      'check_next_trial_ready',     [0.7 0.7 0.7]);% gray


    
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



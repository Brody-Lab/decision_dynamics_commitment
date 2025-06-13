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

    % left1led     = bSettings('get', 'DIOLINES', 'left1led');
    center1led   = bSettings('get', 'DIOLINES', 'center1led');
    % right1led    = bSettings('get', 'DIOLINES', 'right1led');
    left1water   = bSettings('get', 'DIOLINES', 'left1water');
    right1water  = bSettings('get', 'DIOLINES', 'right1water');
    [LtValve, RtValve] = WaterValvesSection(obj, 'get_water_times');

    
    side = SidesSection(obj, 'get_current_side');
    if side=='l', stimulus_name = 'left_stimulus';  correct_poke = 'Lin'; incorrect_poke = 'Rin'; rew_dout = left1water;  rew_t = LtValve;
    else          stimulus_name = 'right_stimulus'; correct_poke = 'Rin'; incorrect_poke = 'Lin'; rew_dout = right1water; rew_t = RtValve;
    end;
        
    sma = StateMachineAssembler('full_trial_structure');
    
    sma = add_state(sma, 'name', 'wait_for_cin1', ...
      'output_actions', {'DOut', center1led}, ...
      'input_to_statechange', {'Cin', 'var_gap1'});

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
        
    if n_center_pokes==1, 
      after_var_gap2_nose_out = 'wait_for_spoke'; 
      after_var_gap2_nose_in  = 'wait_for_spoke'; 
    else
      after_var_gap2_nose_out = 'wait_for_cin2';
      after_var_gap2_nose_in  = 'center_flash'; 
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

    sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE IN CENTER
      'input_to_statechange', ...
      {'var_gap2_wave_In', after_var_gap2_nose_in ; ...
      'Cout', 'current_state+1'});
    
    sma = add_state(sma, ...  % I'm in var_gap_2,  NOSE OUT OF CENTER
      'input_to_statechange', ...
      {'var_gap2_wave_In', after_var_gap2_nose_out ; ...
      'Cin', 'current_state-1'});

  
    sma = add_state(sma, 'name', 'center_flash', 'self_timer', 0.005, ...
      'output_actions', {'DOut', center1led}, ...
      'input_to_statechange', {'Tup', 'wait_for_spoke'});
    
    
    
    sma = add_state(sma, 'name', 'wait_for_cin2', ...
      'output_actions', {'DOut', center1led}, ...
      'input_to_statechange', {'Cin', 'wait_for_spoke'});
      
    if Temperror==1,  on_error = 'temperror';
    else              on_error = 'error_state';
    end;
    
    sma = add_state(sma, 'name', 'wait_for_spoke', ...
      'input_to_statechange', {correct_poke, 'soft_drink_time', incorrect_poke, on_error});
    
    sma = add_state(sma, 'name', 'temperror', 'self_timer', SoundManagerSection(obj, 'get_sound_duration', 'TemperrorSound'), ...
      'input_to_statechange', {'Tup', 'wait_for_spoke'}, ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'TemperrorSound')});
    
    sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_time', sma, ...
      'pokeid', correct_poke(1), 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
      'Sound1TrigTime', SoundRewardOverlap, 'Sound1Id', -SoundManagerSection(obj, 'get_sound_id', stimulus_name), ...
      'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
    
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger');
        
    sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
      'exitstate', 'check_next_trial_ready');
    
    varargout{1} = sma;
    varargout{2} = {'soft_drink_time', 'error_state'};
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'wait_for_cin1',     [129  77 110]/255, ...  % plum
      'var_gap1',          [255 236 139]/255, ...  % light goldenrod
      'var_gap2',          [255 161 137]/255, ...  % peach 
      'wait_for_cin2',     [188  77 110]/255, ...  % fuscia
      'center_flash',      [188  77 110]/255, ...  % fuscia
      'wait_for_spoke',    [132 161 137]/255, ...  % sage
      'temperror',         [61  131 157]/255, ...  % aqua teal
      'soft_drink_time',   [50  255  50]/255, ...  % green
      'warndanger_warning',[0.3  0    0],    ...   % dark maroon
      'warndanger_danger', [0.5  0.05 0.05], ...   % lighter maroon
      'error_state',       [255   0   0]/255, ...  % red
      'state_0',           [1   1   1  ],  ...
      'check_next_trial_ready',     [0.7 0.7 0.7]);


    
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



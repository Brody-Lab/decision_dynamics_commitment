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

    
    side = Sides3waySection(obj, 'get_current_side');
    if anti == 0    %NORMAL LIGHTCHASING   
        if      side=='l'
                    led_name = left1led;
                    correct_poke = 'Lin';
                    incorrect_poke1 = 'Cin';
                    incorrect_poke2 = 'Rin';
                    rew_dout = left1water;
                    rew_t = LtValve;
        else if  side=='r'
                    led_name = right1led;
                    correct_poke = 'Rin';
                    incorrect_poke1 = 'Cin';
                    incorrect_poke2 = 'Lin';
                    rew_dout = right1water;
                    rew_t = RtValve;
            else
                    led_name = center1led;
                    correct_poke= 'Cin';
                    incorrect_poke1 = 'Lin';
                    incorrect_poke2 = 'Rin';
            end;
        end;
    else            %ANTI LIGHTCHASING
        if      side=='l'
                    led_name = right1led;
                    correct_poke = 'Lin';
                    incorrect_poke1 = 'Cin';
                    incorrect_poke2 = 'Rin';
                    rew_dout = left1water;
                    rew_t = LtValve;
        else if side=='r'
                    led_name = left1led;
                    correct_poke = 'Rin';
                    incorrect_poke1 = 'Cin';
                    incorrect_poke2 = 'Lin';
                    rew_dout = right1water;
                    rew_t = RtValve;
             else error('Anti requires left and right only trials');
            end;
        end;
    end;
    
    sma = StateMachineAssembler('full_trial_structure');

    if n_center_pokes == 0, ...
        action_state = 'light_on';
    else if n_center_pokes == 1, ...
            action_state  = 'wait_centerpoke1'; ...
            second_action = 'light_on';
        else %number center pokes is 2
            action_state  = 'wait_centerpoke1'; ...
            second_action = 'wait_centerpoke2';
        end;
    end;
    
    sma = add_state(sma, 'name', 'wait_for_light', ...
      'self_timer', DistribInterface(obj, 'get_current_sample', 'var_gap'), ...
      'input_to_statechange', {'Tup', action_state, ...
                               'Cin', 'early_punish', ...
                               'Lin', 'early_punish', ...                                % Way to do any poke?
                               'Rin', 'early_punish'});
    if n_center_pokes == 1, ...
             sma = add_state(sma, 'name', 'wait_centerpoke1', ...
             'input_to_statechange', {'Cin', second_action,});
    end;

    if n_center_pokes == 2, ...
             sma = add_state(sma, 'name', 'wait_centerpoke2', ...
             'input_to_statechange', {'Cin', 'light_on',});
    end;

 if ((nowrong==0) && (nolate ==0))
    sma = add_state(sma, 'name', 'light_on', ...
      'self_timer', DistribInterface(obj, 'get_current_sample', 'light_time'), ...
      'output_actions', {'DOut', led_name}, ...
      'input_to_statechange', {'Tup', 'late_punish', ...
                               correct_poke, 'reward', ...
                               incorrect_poke1, 'wrong_punish', ...
                               incorrect_poke2, 'wrong_punish'});
 else if (nolate==0)
         sma = add_state(sma, 'name', 'light_on', ...
      'self_timer', DistribInterface(obj, 'get_current_sample', 'light_time'), ...
      'output_actions', {'DOut', led_name}, ...
      'input_to_statechange', {'Tup', 'late_punish', ...
                               correct_poke, 'reward'});
    else if (nowrong==0)
      sma = add_state(sma, 'name', 'light_on', ...
      'self_timer', DistribInterface(obj, 'get_current_sample', 'light_time'), ...
      'output_actions', {'DOut', led_name}, ...
      'input_to_statechange', {'Tup', 'warndanger', ...
                               correct_poke, 'reward', ...
                               incorrect_poke1, 'wrong_punish', ...
                               incorrect_poke2, 'wrong_punish'});

        else
      sma = add_state(sma, 'name', 'light_on', ...
      'self_timer', DistribInterface(obj, 'get_current_sample', 'light_time'), ...
      'output_actions', {'DOut', led_name}, ...
      'input_to_statechange', {'Tup', 'warndanger', ...
                               correct_poke, 'reward'});
        end
     end
 end
 
if noearly == 0
    sma = PunishInterface(obj, 'add_sma_states', 'early_punish', sma, ...
      'exitstate', 'wait_for_light');                                                       
else
    sma = WarnDangerInterface(obj, 'add_sma_states', 'early_punish', sma, ...
      'exitstate', 'wait_for_light', 'on_poke_when_danger_state', 'warndanger');
end;

    sma = PunishInterface(obj, 'add_sma_states', 'wrong_punish', sma, ...
      'exitstate', 'check_next_trial_ready');  

    sma = PunishInterface(obj, 'add_sma_states', 'late_punish', sma, ...
      'exitstate', 'check_next_trial_ready');

if side == 'c', ...
    sma = add_state(sma, 'name', 'reward', ...
        'self_timer', center_time, ...
        'input_to_statechange', {'Tup', 'warndanger'});
        %Point was if Rat stayed in center, would give extra time, not
        %count as early poke if started next trial.
        %Instead can I use COut for the input to change state, accomplish
        %same end?
else
    sma = SoftPokeStayInterface(obj, 'add_sma_states', 'reward', sma, ...
      'pokeid', correct_poke(1), 'DOut', rew_dout, 'DOutStartTime', 0, 'DOutOnTime', rew_t, ...
      'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
end;
                           
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger');
    
    varargout{1} = sma;
    varargout{2} = {'warndanger', 'wrong_punish', 'late_punish'};                                 %What is varargout(2) for?
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',
      
    varargout{1} = struct( ...
      'wait_for_light',             [129  77 110]/255, ...  % plum
      'wait_centerpoke1',           [132 161 137]/255, ...  % sage
      'wait_centerpoke2',           [61  131 157]/255, ...  % aqua teal
      'light_on',                   [255 236 139]/255, ...  % light goldenrod
      'early_punish',               [255 161 137]/255, ...  % peach 
      'late_punish',                [255   0   0]/255, ...  % red
      'wrong_punish',               [188  77 110]/255, ...  % fuscia
      'reward',                     [50  255  50]/255, ...  % green
      'warndanger_warning',         [0.3   0   0],    ...   % dark maroon
      'warndanger_danger',          [0.5 .05 .05], ...   % lighter maroon
      'state_0',                    [1    1    1],    ...
      'check_next_trial_ready',     [0.7 0.7 0.7]);

%      'wait_for_spoke',             [132 161 137]/255, ...  % sage
%      'temperror',                  [61  131 157]/255, ...  % aqua teal


%% reinit

% ----------------------------------------------------------------
%
%       CASE REINIT
%
% ----------------------------------------------------------------

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



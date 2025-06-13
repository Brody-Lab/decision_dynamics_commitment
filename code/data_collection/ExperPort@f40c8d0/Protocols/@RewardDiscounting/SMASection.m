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
    type = SidesSection(obj, 'get_trial_type');

    l_gap = DistribInterface(obj, 'get_current_sample', 'left_gap');
    r_gap = DistribInterface(obj, 'get_current_sample', 'right_gap');
    
    sdl = 0;
    sdr = 0;
    
    if l_gap == 0; l_gap = 0.01; end
    if r_gap == 0; r_gap = 0.01; end
    
    if strcmp(type,'Forced')
        if side=='l';     first_gap=l_gap; second_gap=0.001; early_choice='Lin'; late_choice='Lin'; r1='reward_left';  r2='reward_left';  led=left1led;  early_wait='left_wait_before';  late_wait='left_wait_before'; 
        elseif side=='r'; first_gap=r_gap; second_gap=0.001; early_choice='Rin'; late_choice='Rin'; r1='reward_right'; r2='reward_right'; led=right1led; early_wait='right_wait_before'; late_wait='right_wait_before'; 
        else  disp('Free side on a Forces Trial!');
        end;
    else
        if     l_gap < r_gap; first_gap = l_gap; second_gap = r_gap - l_gap; early_choice = 'Lin'; late_choice = 'Rin'; r1='reward_left';  r2='reward_right'; early_wait='left_wait_before';  late_wait='right_wait_before'; 
        elseif l_gap > r_gap; first_gap = r_gap; second_gap = l_gap - r_gap; early_choice = 'Rin'; late_choice = 'Lin'; r1='reward_right'; r2='reward_left';  early_wait='right_wait_before'; late_wait='left_wait_before';
        else                  first_gap = l_gap; second_gap = 0.01;          early_choice = 'Lin'; late_choice = 'Rin'; r1='reward_left';  r2='reward_right'; early_wait='left_wait_before';  late_wait='right_wait_before';
        end
        led=left1led + right1led;
    end
        
    sma = StateMachineAssembler('full_trial_structure');
    
    if value(Inter_Trial_Interval) > 0 && Fix_Trial_Length == 0
        sma = add_state(sma, 'name', 'iti', 'self_timer', Inter_Trial_Interval,...
            'input_to_statechange', {'Tup', 'current_state+1'});
    end
    
    if Start_on_Left == 1
        sma = add_state(sma, 'name', 'wait_for_lin1', ...
            'output_actions', {'DOut', left1led}, ...
            'input_to_statechange', {'Lin', 'current_state+1'});
    elseif n_center_pokes == 1
        sma = add_state(sma, 'name', 'wait_for_cin1', ...
            'output_actions', {'DOut', center1led}, ...
            'input_to_statechange', {'Cin', 'current_state+1'});
    end
    
    if Decision_Time == 1
        sma = add_state(sma, 'name', 'wait_for_spoke',...
            'output_actions', {'DOut', led},...
            'input_to_statechange', {early_choice,early_wait;late_choice,late_wait});
        
        sma = add_state(sma, 'name', 'left_wait_before','self_timer',l_gap,...
            'output_actions', {'DOut', left1led},...
            'input_to_statechange', {'Tup','wait_for_lpoke'});
        
        sma = add_state(sma, 'name', 'wait_for_lpoke',...
            'output_actions', {'DOut',left1led},...
            'input_to_statechange', {'Lin','reward_left'});
        
        sma = add_state(sma, 'name', 'right_wait_before','self_timer',r_gap,...
            'output_actions', {'DOut', right1led},...
            'input_to_statechange', {'Tup','wait_for_rpoke'});
        
        sma = add_state(sma, 'name', 'wait_for_rpoke',...
            'output_actions', {'DOut',right1led},...
            'input_to_statechange', {'Rin','reward_right'});
    else
    
        sma = add_state(sma, 'name', 'wait_for_firstup', 'self_timer',first_gap, ...
            'output_actions', {'DOut', led}, ...
            'input_to_statechange', {'Tup', 'wait_for_secondup'});
    
        sma = add_state(sma, 'name', 'wait_for_secondup', 'self_timer',second_gap, ...
            'output_actions', {'DOut', led}, ...
            'input_to_statechange', {'Tup', 'wait_for_spoke'; early_choice, r1});

        sma = add_state(sma, 'name', 'wait_for_spoke', ...
            'output_actions', {'DOut', led}, ...
            'input_to_statechange', {early_choice, r1; late_choice, r2});
    end
    
    if      Fix_Trial_Length    == 0     ||...
            Inter_Trial_Interval < l_gap ||...
            Inter_Trial_Interval < r_gap
        
        if rand(1) <= L_Reward_Probability
            sma = add_state(sma, 'name', 'reward_left', 'self_timer', LtValve, ...
                'output_actions', {'DOut',left1water},...
                'input_to_statechange', {'Tup','current_state+1'});
            if round(L_Reward_Multiply) > 1
                for R = 2:round(L_Reward_Multiply)
                    sma = add_state(sma, 'self_timer', 0.15, ...
                        'input_to_statechange', {'Tup','current_state+1'});
                    sma = add_state(sma, 'self_timer', LtValve, ...
                        'output_actions', {'DOut',left1water},...
                        'input_to_statechange', {'Tup','current_state+1'});
                end
            end
            
            sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_left', sma, ...
                'pokeid', 'L', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
            sdl = 1;
        else
            sma = add_state(sma, 'name', 'reward_left','self_timer',0.01, ...
                'input_to_statechange', {'Tup','no_reward_wait'});
        end
        
        if rand(1) <= R_Reward_Probability
            sma = add_state(sma, 'name', 'reward_right', 'self_timer', RtValve, ...
                'output_actions', {'DOut',right1water},...
                'input_to_statechange', {'Tup','current_state+1'});
            if round(R_Reward_Multiply) > 1
                for R = 2:round(R_Reward_Multiply)
                    sma = add_state(sma, 'self_timer', 0.15, ...
                        'input_to_statechange', {'Tup','current_state+1'});
                    sma = add_state(sma, 'self_timer', RtValve, ...
                        'output_actions', {'DOut',right1water},...
                        'input_to_statechange', {'Tup','current_state+1'});
                end
            end
            
            sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_right', sma, ...
              'pokeid', 'R', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
            sdr = 1;
        else
            sma = add_state(sma, 'name', 'reward_right','self_timer',0.01, ...
                'input_to_statechange', {'Tup','no_reward_wait'});
        end
        
        sma = add_state(sma, 'name', 'no_reward_wait','self_timer',No_Reward_Wait,...
            'input_to_statechange', {'Tup','warndanger'});
        
    else
        waittime = 0.01;
        if rand(1) <= L_Reward_Probability
            sma = add_state(sma, 'name', 'reward_left', 'self_timer', LtValve, ...
                'output_actions', {'DOut',left1water},...
                'input_to_statechange', {'Tup','current_state+1'});
            if round(L_Reward_Multiply) > 1
                for R = 2:round(L_Reward_Multiply)
                    sma = add_state(sma, 'self_timer', 0.15, ...
                        'input_to_statechange', {'Tup','current_state+1'});
                    sma = add_state(sma, 'self_timer', LtValve, ...
                        'output_actions', {'DOut',left1water},...
                        'input_to_statechange', {'Tup','current_state+1'});
                end
            end
        
            sma = add_state(sma, 'name', 'left_wait_after', 'self_timer', Inter_Trial_Interval-l_gap, ...
                'input_to_statechange', {'Tup','warndanger'});
        else
            sma = add_state(sma, 'name', 'reward_left','self_timer',0.01, ...
                'input_to_statechange', {'Tup','no_reward_wait_l'});
            sma = add_state(sma, 'name', 'no_reward_wait_l','self_timer',Inter_Trial_Interval-l_gap,...
                'input_to_statechange', {'Tup','warndanger'});
        end
        
        if rand(1) <= R_Reward_Probability
            sma = add_state(sma, 'name', 'reward_right', 'self_timer', RtValve, ...
                'output_actions', {'DOut',right1water},...
                'input_to_statechange', {'Tup','current_state+1'});
            if round(R_Reward_Multiply) > 1
                for R = 2:round(R_Reward_Multiply)
                    sma = add_state(sma, 'self_timer', 0.15, ...
                        'input_to_statechange', {'Tup','current_state+1'});
                    sma = add_state(sma, 'self_timer', RtValve, ...
                        'output_actions', {'DOut',right1water},...
                        'input_to_statechange', {'Tup','current_state+1'});
                end
            end
        
            sma = add_state(sma, 'name', 'right_wait_after', 'self_timer', Inter_Trial_Interval-r_gap, ...
                'input_to_statechange', {'Tup','warndanger'});
        else
            sma = add_state(sma, 'name', 'reward_right','self_timer',0.01, ...
                'input_to_statechange', {'Tup','no_reward_wait_r'});
            sma = add_state(sma, 'name', 'no_reward_wait_r','self_timer',Inter_Trial_Interval-r_gap,...
                'input_to_statechange', {'Tup','warndanger'});
        end
                
    end
        
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger', 'triggertime', 0.01);
        
    sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
      'exitstate', 'check_next_trial_ready');
  
    if sdl == 0
        sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_left', sma, ...
            'pokeid', 'L', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
    end
    if sdr == 0
        sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_right', sma, ...
            'pokeid', 'R', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
    end
    varargout{1} = sma;
    varargout{2} = {'reward_left','reward_right', 'error_state'};
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'iti',               [ 10  10  10]/255, ...  % black
      'wait_for_cin1',     [129  77 110]/255, ...  % plum
      'wait_for_lin1',     [129  77 110]/255, ...  % plum
      'wait_for_firstup',  [255 236 139]/255, ...  % light goldenrod
      'left_wait_before',  [255 236 139]/255, ...  % light goldenrod
      'wait_for_lpoke',    [128 118  70]/255, ...  % dark goldenrod    
      'wait_for_secondup', [255 161 137]/255, ...  % peach 
      'right_wait_before', [255 161 137]/255, ...  % peach 
      'wait_for_rpoke',    [128  81  69]/255, ...  % dark peach      
      'wait_for_spoke',    [132 161 137]/255, ...  % sage
      'reward_left',       [1  150  250]/255, ...  % carribbean blue
      'soft_drink_left',   [1  150  250]/255, ...  % carribbean blue
      'left_wait_after',   [1  150  250]/255, ...  % carribbean blue
      'reward_right',      [50  255  50]/255, ...  % green
      'soft_drink_right',  [50  255  50]/255, ...  % green
      'right_wait_after',  [50  255  50]/255, ...  % green
      'no_reward_wait',    [250   0 250]/255, ...  % magenta
      'no_reward_wait_l',  [250   0 250]/255, ...  % magenta
      'no_reward_wait_r',  [250   0 250]/255, ...  % magenta
      'warndanger_warning',[0.3  0    0],     ...  % dark maroon
      'warndanger_danger', [0.5  0.05 0.05],  ...  % lighter maroon
      'error_state',       [255   0   0]/255, ...  % red
      'state_0',           [1   1   1  ],     ...
      'check_next_trial_ready', [0.7 0.7 0.7]);


    
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



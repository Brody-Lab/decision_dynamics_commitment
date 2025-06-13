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
    
    if l_gap == 0; l_gap = 0.01; end
    if r_gap == 0; r_gap = 0.01; end
    if l_gap == r_gap; r_gap = r_gap + 0.01; end

    if strcmp(type,'Forced')
        if     side=='l'; leave_wait_for_spoke = { 'left_wave_In', 'leftup'}; led = left1led; 
        elseif side=='r'; leave_wait_for_spoke = {'right_wave_In', 'rightup'}; led = right1led;
        else disp('Free side on a Forces Trial!');
        end
        leave_Lup = {'Lin','left_reward'}; 
        leave_Rup = {'Rin','right_reward'};
    else
        if Decision_Time == 1
            leave_wait_for_spoke = {'Lin','waitforlup'; 'Rin','waitforrup'; 'left_wave_In', 'leftup'; 'right_wave_In', 'rightup'};
            leave_Lup            = {'Lin','left_reward'; 'right_wave_In','bothup'; 'Rin','waitforrup'};
            leave_Rup            = {'Rin','right_reward'; 'left_wave_In','bothup'; 'Lin','waitforlup'};
        else
            leave_wait_for_spoke = {'left_wave_In', 'leftup'; 'right_wave_In', 'rightup'};
            leave_Lup            = {'Lin','left_reward'; 'right_wave_In','bothup'};
            leave_Rup            = {'Rin','right_reward'; 'left_wave_In','bothup'};
        end 
        led = left1led + right1led; 
    end
    
    if  Fix_Trial_Length    == 0 || Inter_Trial_Interval < l_gap || Inter_Trial_Interval < r_gap
        %Trial length is NOT fixed
        NRWtimeL = No_Reward_Wait;
        NRWtimeR = No_Reward_Wait;
        leave_after_Lreward = 'soft_drink_left';
        leave_after_Rreward = 'soft_drink_right';
    
    else
        %Now the trial length IS fixed
        NRWtimeL = Inter_Trial_Interval - l_gap;
        NRWtimeR = Inter_Trial_Interval - r_gap;
        leave_after_Lreward = 'left_wait_after';
        leave_after_Rreward = 'right_wait_after';
    end
        
    sma = StateMachineAssembler('full_trial_structure');
    
    sma = add_scheduled_wave(sma, 'name',  'left_wave', 'preamble', l_gap); 
    sma = add_scheduled_wave(sma, 'name', 'right_wave', 'preamble', r_gap);
    
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
    
    sma = add_state(sma, 'self_timer', 0.001,...
        'output_actions', {'DOut', led; 'SchedWaveTrig', 'left_wave+right_wave'},...
        'input_to_statechange', {'Tup','current_state+1'});

    sma = add_state(sma, 'name', 'wait_for_spoke',...
        'output_actions', {'DOut', led},...
        'input_to_statechange', leave_wait_for_spoke);

    sma = add_state(sma, 'name', 'waitforlup',...
        'output_actions', {'DOut', left1led},...
        'input_to_statechange', {'left_wave_In', 'forcel'});

    sma = add_state(sma, 'name', 'waitforrup',...
        'output_actions', {'DOut', right1led},...
        'input_to_statechange', {'right_wave_In', 'forcer'});

    sma = add_state(sma, 'name', 'leftup',...
        'output_actions', {'DOut', led},...
        'input_to_statechange', leave_Lup);

    sma = add_state(sma, 'name', 'rightup',...
        'output_actions', {'DOut', led},...
        'input_to_statechange', leave_Rup);
    
    sma = add_state(sma, 'name', 'bothup',...
        'output_actions', {'DOut', led},...
        'input_to_statechange', {'Lin','left_reward'; 'Rin','right_reward'});

    sma = add_state(sma, 'name', 'forcel',...
        'output_actions', {'DOut',left1led},...
        'input_to_statechange', {'Lin','left_reward'});

    sma = add_state(sma, 'name', 'forcer',...
        'output_actions', {'DOut',right1led},...
        'input_to_statechange', {'Rin','right_reward'});
        
    
    if rand(1) <= L_Reward_Probability
        sma = add_state(sma, 'name', 'left_reward', 'self_timer', LtValve, ...
            'output_actions', {'DOut',left1water+left1led},...
            'input_to_statechange', {'Tup','current_state+1'});
        if round(L_Reward_Multiply) > 1
            for R = 2:round(L_Reward_Multiply)
                sma = add_state(sma, 'self_timer', 0.15, ...
                    'output_actions', {'DOut',left1led},...
                    'input_to_statechange', {'Tup','current_state+1'});
                sma = add_state(sma, 'self_timer', LtValve, ...
                    'output_actions', {'DOut',left1water+left1led},...
                    'input_to_statechange', {'Tup','current_state+1'});
            end
        end

        sma = add_state(sma, 'name', 'after_lreward', 'self_timer',0.01,...
            'output_actions', {'DOut',left1led},...
            'input_to_statechange', {'Tup', leave_after_Lreward});

    else
        sma = add_state(sma, 'name', 'left_reward','self_timer',0.01, ...
            'output_actions', {'DOut',left1led},...
            'input_to_statechange', {'Tup','no_reward_wait_ll'});
    end
    
    if rand(1) <= R_Reward_Probability
        sma = add_state(sma, 'name', 'right_reward', 'self_timer', RtValve, ...
            'output_actions', {'DOut',right1water+right1led},...
            'input_to_statechange', {'Tup','current_state+1'});
        if round(R_Reward_Multiply) > 1
            for R = 2:round(R_Reward_Multiply)
                sma = add_state(sma, 'self_timer', 0.15, ...
                    'output_actions', {'DOut',right1led},...
                    'input_to_statechange', {'Tup','current_state+1'});
                sma = add_state(sma, 'self_timer', RtValve, ...
                    'output_actions', {'DOut',right1water+right1led},...
                    'input_to_statechange', {'Tup','current_state+1'});
            end
        end

        sma = add_state(sma, 'name', 'after_rreward', 'self_timer',0.01,...
            'output_actions', {'DOut',right1led},...
            'input_to_statechange', {'Tup', leave_after_Rreward});

    else
        sma = add_state(sma, 'name', 'right_reward','self_timer',0.01, ...
            'output_actions', {'DOut',right1led},...
            'input_to_statechange', {'Tup','no_reward_wait_rr'});
    end
    
    
    sma = add_state(sma, 'name', 'no_reward_wait_ll','self_timer',NRWtimeL,...
        'output_actions', {'DOut',left1led},...
        'input_to_statechange', {'Tup','warndanger'});

    sma = add_state(sma, 'name', 'no_reward_wait_rr','self_timer',NRWtimeR,...
        'output_actions', {'DOut',right1led},...
        'input_to_statechange', {'Tup','warndanger'});
    
    sma = add_state(sma, 'name', 'left_wait_after','self_timer',NRWtimeL,...
        'output_actions', {'DOut',left1led},...
        'input_to_statechange', {'Tup','warndanger'});
    
    sma = add_state(sma, 'name', 'right_wait_after','self_timer',NRWtimeR,...
        'output_actions', {'DOut',right1led},...
        'input_to_statechange', {'Tup','warndanger'});
    
  
    sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_left', sma,'DOut',left1led,'DOutStartTime',0.1,'DOutOnTime',10000, ...
        'pokeid', 'L', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');

    sma = SoftPokeStayInterface2(obj, 'add_sma_states', 'soft_drink_right', sma,'DOut',right1led,'DOutStartTime',0.1,'DOutOnTime',10000, ...
        'pokeid', 'R', 'triggertime', 0.01, 'success_exitstate_name', 'warndanger', 'abort_exitstate_name', 'warndanger');
    
        
    sma = WarnDangerInterface(obj, 'add_sma_states', 'warndanger', sma, ...
      'exitstate', 'check_next_trial_ready', 'on_poke_when_danger_state', 'warndanger', 'triggertime', 0.01);
        
    sma = PunishInterface(obj, 'add_sma_states', 'error_state', sma, ...
      'exitstate', 'check_next_trial_ready');
  

    varargout{1} = sma;
    varargout{2} = {'left_reward','right_reward', 'error_state'};
    
    
    

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
        'wait_for_spoke',    [255 255 255]/255, ...  % white
        'rightup',           [255 236 139]/255, ...  % light goldenrod
        'waitforlup',        [255 236 139]/255, ...  % light goldenrod
        'forcel',            [204 189 111]/255, ...  % dark goldenrod
        'leftup',            [255 161 137]/255, ...  % peach
        'waitforrup',        [255 161 137]/255, ...  % peach
        'forcer',            [204 129 110]/255, ...  % dark peach
        'bothup',            [255 200 138]/255, ...  % peachy goldenrod
        'left_reward',       [1  150  250]/255, ...  % carribbean blue
        'after_lreward',     [1  150  250]/255, ...  % carribbean blue
        'soft_drink_left',   [1  150  250]/255, ...  % carribbean blue 
        'left_wait_after',   [1  150  250]/255, ...  % carribbean blue
        'right_reward',      [50  255  50]/255, ...  % green
        'after_rreward',     [50  255  50]/255, ...  % green
        'soft_drink_right',  [50  255  50]/255, ...  % green
        'right_wait_after',  [50  255  50]/255, ...  % green
        'no_reward_wait_ll', [250   0 250]/255, ...  % magenta
        'no_reward_wait_rr', [250   0 250]/255, ...  % magenta
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



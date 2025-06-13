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
    stim1        = bSettings('get', 'DIOLINES', 'stim1');

    if strcmp(value(Valve_Side),'Right or Left')
      side_coin = rand(1); if side_coin < 0.5; wave_out = 'pulse_wave_right'; else wave_out = 'pulse_wave_left'; end;
    end
    
    if      strcmp(value(Valve_Side),'Right Only')    == 1; wave_out = 'pulse_wave_right'; side_led = right1led;
    elseif  strcmp(value(Valve_Side),'Left Only')    == 1; wave_out = 'pulse_wave_left'; side_led = left1led;
    end  

%     if      strcmp(value(Output),'Light Only')    == 1; do_out = side_led;
%     elseif  strcmp(value(Output),'Water Only')    == 1; do_out = side_out;
%     elseif  strcmp(value(Output),'Light & Water') == 1; do_out = side_out + side_led;
%     end
    
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1);
    
    sma = add_scheduled_wave(sma, 'name',     'pulse_wave_right',...
                                  'preamble', InterPulseInterval,...
                                  'sustain',  Valve_Open_Time,...
                                  'DOut',     right1water,...
                                  'loop',     Number_Pulses-1);
    sma = add_scheduled_wave(sma, 'name',     'pulse_wave_left',...
                                  'preamble', InterPulseInterval,...
                                  'sustain',  Valve_Open_Time,...
                                  'DOut',     left1water,...
                                  'loop',     Number_Pulses-1);    
    sma = add_state(sma, 'name', 'wait_for_anyin',...
        'input_to_statechange', {'Lin', 'pulsingL'; 'Rin', 'pulsingR'});
        
    sma = add_state(sma, 'name', 'pulsingL', 'self_timer', Number_Pulses*(InterPulseInterval + Valve_Open_Time),...
        'output_actions', {'SchedWaveTrig', 'pulse_wave_left'},...
        'input_to_statechange', {'Tup','wait'});

    sma = add_state(sma, 'name', 'pulsingR', 'self_timer', Number_Pulses*(InterPulseInterval + Valve_Open_Time),...
        'output_actions', {'SchedWaveTrig', 'pulse_wave_right'},...
        'input_to_statechange', {'Tup','wait'});

    sma = add_state(sma, 'name', 'wait','self_timer', InterOutTime,...
        'input_to_statechange', {'Tup','current_state+1'});            
%     sma = add_state(sma, 'name', 'pulsing','self_timer',0.01,...
%                 'output_actions', {'DOut', right1led},...
%                 'input_to_statechange', {'Tup', 'current_state+1'});
%             
%     for n = 1:Number_Pulses
%         if Duty_Cycle == 0
%             sma = add_state(sma,'self_timer',Valve_Open_Time-0.00001,...
%                     'output_actions', {'DOut', do_out},...
%                     'input_to_statechange', {'Tup', 'current_state+1'});
% 
%             sma = add_state(sma,'self_timer',InterPulseInterval-0.00001,...
%                     'input_to_statechange', {'Tup', 'current_state+1'});
%         else
%             sma = add_state(sma,'self_timer',Up_Duration-0.00001,...
%                     'output_actions', {'DOut', do_out},...
%                     'input_to_statechange', {'Tup', 'current_state+1'});
% 
%             sma = add_state(sma,'self_timer',Duty_Cycle-Up_Duration-0.00001,...
%                     'input_to_statechange', {'Tup', 'current_state+1'});
%         end
%     end
  
    sma = add_state(sma,'name','trial_complete','self_timer',1,...
                'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'trial_complete'};
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'wait_for_cin',           [  0   0   0], ...  % black  
      'pulsing',                [  0   1   0], ...  % green
      'trial_complete',         [  0   0   1], ...  % black
      'state_0',                [  1   1   1], ...
      'check_next_trial_ready', [0.7 0.7 0.7]);


    
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



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
    
    sma = StateMachineAssembler('full_trial_structure');
    
    stimline1 = bSettings('get','DIOLINES',value(Line_1));  
    stimline2 = bSettings('get','DIOLINES',value(Line_2));  
    
    if     isnan(stimline1) == 0 && isnan(stimline2) == 0; wt = 'delay_wave_1+delay_wave_2';
    elseif isnan(stimline1) == 0 && isnan(stimline2) == 1; wt = 'delay_wave_1';
    elseif isnan(stimline1) == 1 && isnan(stimline2) == 0; wt = 'delay_wave_2';
    else                                                   wt = '';
    end
    
    if strcmp(stimline1,'none') == 0
        sma = add_scheduled_wave(sma,...
            'name',          'delay_wave_1',...
            'preamble',      value(Delay_1)/1000,...
            'sustain' ,      0.001,...
            'trigger_on_up', 'stim_wave_1');
        sma = add_scheduled_wave(sma,...
            'name',          'stim_wave_1',...
            'preamble',      (1/value(Frequency_1))-(value(Duration_1)/1000),...
            'sustain' ,      value(Duration_1)/1000,...
            'DOut',          stimline1,...
            'loop',          value(NumPulses_1)-1,...
            'no_wave_events',0);
    end
    
    if strcmp(stimline2,'none') == 0
        sma = add_scheduled_wave(sma,...
            'name',          'delay_wave_2',...
            'preamble',      value(Delay_2)/1000,...
            'sustain' ,      0.001,...
            'trigger_on_up', 'stim_wave_2');
        sma = add_scheduled_wave(sma,...
            'name',          'stim_wave_2',...
            'preamble',      (1/value(Frequency_2))-(value(Duration_2)/1000),...
            'sustain' ,      value(Duration_2)/1000,...
            'DOut',          stimline2,...
            'loop',          value(NumPulses_2)-1,...
            'no_wave_events',0);
    end
    
    if strcmp(value(EndTrial),'C_poke'); afterstim = 'wait_for_cin2'; else afterstim = 'ITI'; end
    
    if strcmp(value(StartTrial),'C_poke')
        sma = add_state(sma, 'name', 'wait_for_cin1', 'input_to_statechange', {'Cin','stim'});
    end
    
    if ~isempty(wt)
        sma = add_state(sma, 'name', 'stim', 'self_timer',value(Trial_Length),...
                'output_actions', {'SchedWaveTrig', wt},...
                'input_to_statechange', {'Tup', afterstim});
    else
        sma = add_state(sma, 'name', 'stim', 'self_timer',value(Trial_Length),...
                'input_to_statechange', {'Tup', afterstim});
    end
    
    sma = add_state(sma, 'name', 'wait_for_cin2',       'input_to_statechange', {'Cin', 'ITI'});            
    sma = add_state(sma, 'name', 'ITI','self_timer',0.1,'input_to_statechange', {'Tup', 'check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'ITI'};
    
    
    

%% get_state_colors
% ----------------------------------------------------------------
%
%       CASE GET_STATE_COLORS
%
% ----------------------------------------------------------------
  
  case 'get_state_colors',    
    varargout{1} = struct( ...
      'wait_for_cin1',          [129  77 110]/255, ...  % plum
      'stim',                   [  1   0   0], ...      % red  
      'wait_for_cin2',          [129  77 110]/255, ...  % plum
      'ITI',                    [  0   0   0], ...      % black
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



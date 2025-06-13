% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function  [] =  StateMatrixSection(obj, action)

global left1water;
global right1water;


GetSoloFunctionArgs;
%'rw_args': 
%
%'ro_args': ValveRight, ValveLeft, DelayToRewardLeft, DelayToRewardRight,
%           RewardAvailPeriod, CPokeNecessary

CPOKE_NECESSARY = value(CPokeNecessary);
REWARD_AVAIL_PERIOD = value(RewardAvailPeriod);
DELAY_TO_REWARD_LEFT = value(DelayToRewardLeft);
DELAY_TO_REWARD_RIGHT = value(DelayToRewardRight);
LEFT_REWARD = value( ValveLeft);
RIGHT_REWARD = value(ValveRight);

switch action
  case 'init',
    StateMatrixSection(obj, 'prepare_next_trial');    
    
  case 'prepare_next_trial',
      
    sma = StateMachineAssembler('full_trial_structure');

%%%%%%%%%%%Waiting for rat's entering waiting port%%%%%%%%%%%%%%%%%    
%         'wait_for_cpoke'
    switch CPOKE_NECESSARY
        case 'No',
        sma = add_state(sma, 'name', 'wait_for_cpoke', ...
            'self_timer', 0.0001, ...
            'input_to_statechange', {'Tup','wait_for_apoke'});
        case 'Yes',
        sma = add_state(sma, 'name', 'wait_for_cpoke', ...
            'input_to_statechange', {'Cin','wait_for_apoke'});
        otherwise,
            error('don''t know this CPOKE_NECESSARY param, %s', ...
                   CPOKE_NECESSARY);
    end;
        
%%%%%%%%%%% waiting for reward poke %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %wait_for_apoke
    sma = add_state(sma, 'name', 'wait_for_apoke', ...
        'self_timer', REWARD_AVAIL_PERIOD, ...
        'input_to_statechange',  {'Lin', 'pre_left_reward', ...
                                  'Rin', 'pre_right_reward', ...
                                  'Tup', 'check_next_trial_ready'});
    
%%%%%%%%%%%%%Pre-reward state and reward delivery state%%%%%%%%%%%%
%         'pre_left_reward'
    sma = add_state(sma, 'name', 'pre_left_reward', ...
      'self_timer', DELAY_TO_REWARD_LEFT, ...
      'input_to_statechange', {'Tup','left_reward'});
  
%         'left_small_reward'
    sma = add_state(sma, 'name', 'left_reward', ...
      'self_timer', LEFT_REWARD, ...
      'output_actions', {'DOut',left1water}, ...
      'input_to_statechange', {'Tup','check_next_trial_ready'});

%         'pre_right_reward'
    sma = add_state(sma, 'name', 'pre_right_reward', ...
      'self_timer', DELAY_TO_REWARD_RIGHT, ...
      'input_to_statechange', {'Tup','right_reward'});
  
%         'right_reward'
    sma = add_state(sma, 'name', 'right_reward', ...
      'self_timer', RIGHT_REWARD, ...
      'output_actions', {'DOut',right1water}, ...
      'input_to_statechange', {'Tup','check_next_trial_ready'});

%%%%%%%%%%%%%Pre-reward state and reward delivery state%%%%%%%%%%%%
  
%         'final_state'
%         'check_next_trial_ready'
    
%   dispatcher('send_assembler', sma, ...
%   optional cell_array of strings specifying the prepare_next_trial states);   
    dispatcher('send_assembler', sma, 'check_next_trial_ready');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

   
      
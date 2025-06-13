% @util_compare/StateMatrixSection
%
% Stephanie Chow 
% Time-stamp: <2007-11-06 14:10:47 chow>
%
% adapted from @Multipokes3/StateMatrixSection by
% Bing Wen, June 2007
%
% [x, y] = StateMatrixSection(obj, action, x, y)
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'         To initialise the section
%
%            'next_trial'   To set up the state matrix for the next trial
%
%%%%% ?needed?            'reinit'       Delete all of this section's GUIs and data,
%                           and reinit, at the same position on the same
%                           figure as the original section GUI was placed.
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

global left1led;
global center1led;
global right1led;
global left1water;
global right1water;

% temporary variables --- redo as soloparamhandles?
CENTRE_TIMEOUT = 120; % seconds, I think.
SIDE_TIMEOUT = 120;

GetSoloFunctionArgs;

switch action
 case 'init',
  
  feval(mfilename, obj, 'next_trial');
  
 case 'next_trial',
  sma = StateMachineAssembler('full_trial_structure');
  
  % start with single stimulus
  
  % pre-sma requirements:
  % stimulus value (side + frequency)
  % associated water probability
  % instantiation of above (coinflip outcome)
  
  % start with centre poke?
  % want centrepoke to start each trial? otherwise skip to next state
  
  % add sounds!!!
  % trial start signal
  % left and right sounds
  
  % add error state with signal/aversive sound

  % add lights !!!
  
  % add sound?
  
  
  
  % trial type
  if strcmp(TrialType, 'TWOSIDED')
    if strcmp(ThisTrial, 'LEFT')
      sma = add_state(sma, 'name', 'start_2L_trial', 'self_timer', 0.1, ...
                      'input_to_statechange', {'Tup', 'wait_for_cpoke'});
    else % TWO-SIDED, RIGHT
      sma = add_state(sma, 'name', 'start_2R_trial', 'self_timer', 0.1, ...
                      'input_to_statechange', {'Tup', 'wait_for_cpoke'});
    end
  else % ONESIDED
    if strcmp(ThisTrial, 'LEFT')
      sma = add_state(sma, 'name', 'start_1L_trial', 'self_timer', 0.1, ...
                      0.1, 'input_to_statechange', {'Tup', 'wait_for_cpoke'});
    else % RIGHT
      sma = add_state(sma, 'name', 'start_1R_trial', 'self_timer', 0.1, ...
                      0.1, 'input_to_statechange', {'Tup', 'wait_for_cpoke'});
    end
  end
  
  % centre poke
  sma = add_state(sma, 'name', 'wait_for_cpoke', 'self_timer', CENTRE_TIMEOUT, ...
                  'output_actions', {'Dout', center1led}, ...
                  'input_to_statechange', {'Cin', 'sound_on', 'Tup', ...
                      'error_state'});
  
  left_sound_id = ['left_sound' int2str(stim_choices(1))];
  right_sound_id = ['right_sound' int2str(stim_choices(2))];
  
  % side poke
  if strcmp(TrialType, 'TWOSIDED')
    % allow poking during sound
    %%%%% sound needs to be fixed to be able to get combos of left/right
    % sounds
    
    lsound_id = SoundManagerSection(obj, 'get_sound_id', left_sound_id);
    rsound_id = SoundManagerSection(obj, 'get_sound_id', right_sound_id);

    % sounds on
    sma = add_state(sma, 'name', 'lsound_on', 'self_timer', 0.1, ...
                    'output_actions', {'SoundOut', lsound_id}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
    
    sma = add_state(sma, 'name', 'rsound_on', 'self_timer', 0.1, ...
                    'output_actions', {'SoundOut', rsound_id}, ...
                    'input_to_statechange', {'Tup', 'current_state+1'});
    
    % lights on, wait for poke
    sma = add_state(sma, 'name', 'wait_for_spoke', 'self_timer', SIDE_TIMEOUT', ...
                    'output_actions', {'Dout', -center1led+left1led+right1led}, ...
                    'input_to_statechange', {'Lin', 'lpoke', 'Rin', 'rpoke', ...
                        'Cin', 'cpoke', 'Tup', 'error_state'});
    
  else % ONESIDED trial
    if strcmp(ThisTrial, 'LEFT')
      sound_id = SoundManagerSection(obj, 'get_sound_id', left_sound_id); ...
      % !
      % turn sound off?
      % note, can only turn off sounds one at a time (per statement)    
      
      sma = add_state(sma, 'name', 'wait_for_lpoke', 'self_timer', ...
                      SIDE_TIMEOUT', 'output_actions', {'SoundOut', ...
                          sound_id, 'Dout', -center1led+left1led}, ...
                      'input_to_statechange', {'Lin', 'lpoke', 'Rin', ...
                          'rpoke', 'Cin', 'cpoke', 'Tup', 'error_state'});
      
    else % RIGHT trial
      sound_id = SoundManagerSection(obj, 'get_sound_id', left_sound_id); ...
      
      sma = add_state(sma, 'name', 'wait_for_rpoke', 'self_timer', ...
                      SIDE_TIMEOUT', 'output_actions', {'SoundOut', ...
                          sound_id, 'Dout', -center1led+left1led}, ...
                      'input_to_statechange', {'Lin', 'lpoke', 'Rin', ...
                          'rpoke', 'Cin', 'cpoke', 'Tup', 'error_state'});
      
    end
  end
  
  % error sound? correct sound?
  if water_flags(1) % left water on
    sma = add_state(sma, 'name', 'lpoke', 'self_timer', 0.1, ...
                    'input_to_statechange', {'Tup', 'lwater_on'});
  else
    sma = add_state(sma, 'name', 'lpoke', 'self_timer', 0.1, ...
                    'input_to_statechange', {'Tup', 'no_lwater'});
  end
  
  if water_flags(2) % right water on
    sma = add_state(sma, 'name', 'rpoke', 'self_timer', 0.1, ...
                    'input_to_statechange', {'Tup', 'rwater_on'});
  else
    sma = add_state(sma, 'name', 'rpoke', 'self_timer', 0.1, ...
                    'input_to_statechange', {'Tup', 'no_rwater'});
  end

  % water delivery time?
  sma = add_state(sma, 'name', 'lwater_on', 'self_timer', 0.1, 'output_actions', ...
                  {'DOut', +left1water}, 'input_to_statechange', {'Tup', ...
                      'final_state'}); 
  
  sma = add_state(sma, 'name', 'rwater_on', 'self_timer', 0.1, 'output_actions', ...
                  {'DOut', +right1water}, 'input_to_statechange', {'Tup', ...
                      'final_state'}); 
  
  sma = add_state(sma, 'name', 'no_water', 'self_timer', 0.1, ...
                  'input_to_statechange', {'Tup', 'final_state'}); 
  
  % need this? what about "doing ok so far" state?
  sound_id = SoundManagerSection(obj, 'get_sound_id', 'badboy_both'); %
  sma = add_state(sma, 'name', 'error_state', 'self_timer', 1, 'output_actions', ...
                  {'SoundOut', sound_id}, 'input_to_statechange', {'Tup', ...
                      'final_state'});
  
  % lights off, water off
  
  % water off
  sma = add_state(sma, 'name', 'final_state', 'self_timer', 0.1, {'DOut', ...
                      -left1water-right1water}, 'input_to_statechange', ...
                  {'Tup', 'current_state+1'});

  % lights off
  sma = add_state(sma, 'name', 'lights_off', 'self_timer', 0.1, {'DOut', ...
                      -centre1led-left1led-right1led}, 'input_to_statechange', ...
                  {'Tup', 'current_state+1'});

  % sound1 off, sound
  sma = add_state(sma, 'name', 'left_sound_off', 'self_timer', 0.1, ...
                  {'SoundOut', -leftsound}, 'input_to_statechange', {'Tup', ...
                      'current_state+1'});

  sma = add_state(sma, 'name', 'right_sound_off', 'self_timer', 0.1, ...
                  {'SoundOut', -rightsound}, 'input_to_statechange', {'Tup', ...
                      'check_next_trial_ready'});
  % 'check_next_trial_ready'});
  
  
  %%%%% fix...
  dispatcher('send_assembler', sma, {'error_state', 'final_state', ...
                      'off_lwater', 'off_rwater', 'no_water'});
  
 case 'reinit',
  
  % Delete all SoloParamHandles who belong to this object and whose
  % fullname starts with the name of this mfile:
  delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename]);
  
  % Reinitialise at the original GUI position and figure:
  feval(mfilename, obj, 'init');
  
end

% return;
   
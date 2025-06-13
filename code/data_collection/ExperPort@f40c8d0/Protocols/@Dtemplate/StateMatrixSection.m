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

global left1led;
global center1led;
global right1led;
global left1water;
global right1water;


GetSoloFunctionArgs;


switch action
  case 'init',
    srate = SoundManagerSection(obj, 'get_sample_rate');
    left_sound   = MakeBupperSwoop(srate, 10, 15, 15, 500, 500, 0, 1);
    left_sound   = [left_sound(:)' ; zeros(1, length(left_sound))];
    right_sound  = MakeBupperSwoop(srate, 10, 100, 100, 500, 500, 0, 1);
    right_sound  = [zeros(1, length(right_sound)) ; right_sound(:)'];
    t = 0:(1/srate):1; center_sound = 0.3*sin(2*pi*400*t);
        
    SoundManagerSection(obj, 'declare_new_sound', 'left_sound',   left_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'center_sound', center_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'right_sound',  right_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'error_sound',  0.1*(rand(1, srate)-0.5));
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');  
    
    sma = StateMachineAssembler('no_dead_time_technology');
    
    sma = add_state(sma, 'name', 'LEFT_LIGHT', ...
      'output_actions', {'DOut', left1led}, ...
      'input_to_statechange', {'Lin', 'left_sound'});
    sma = add_state(sma, 'name', 'LEFT_SOUND', ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'left_sound')}, ...
      'self_timer', 0.0001, 'default_statechange', 'center_light');
    
    sma = add_state(sma, 'name', 'CENTER_LIGHT', ...
      'output_actions', {'DOut', center1led}, ...
      'input_to_statechange', {'Cin', 'center_sound'});
    sma = add_state(sma, 'name', 'CENTER_SOUND', ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'center_sound')}, ...
      'self_timer', 0.0001, 'default_statechange', 'right_light');
    
    sma = add_state(sma, 'name', 'RIGHT_LIGHT', ...
      'output_actions', {'DOut', right1led}, ...
      'input_to_statechange', {'Rin', 'right_sound'});
    sma = add_state(sma, 'name', 'RIGHT_SOUND', ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'right_sound')}, ...
      'self_timer', 0.0001, 'default_statechange', 'state35');
    
      
    dispatcher('send_assembler', sma);


    
  case 'next_trial',

    sma = StateMachineAssembler('no_dead_time_technology');

    if SidesSection(obj, 'get_current_side') == 'l',
      sound     = 'left_sound';
      left_act  = 'left_reward';
      right_act = 'error_state';
    else
      sound     = 'right_sound';
      left_act  = 'error_state';
      right_act = 'right_reward';
    end;
    
    sma = add_state(sma, 'name', 'CENTER_LIGHT', ...
      'output_actions', {'DOut', center1led}, ...
      'input_to_statechange', {'Cin', 'play_sound'});
    sma = add_state(sma, 'name', 'PLAY_SOUND', ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', sound)}, ...
      'input_to_statechange', ...
      {'Lin'   left_act ; ...
      'Rin'    right_act});
    sma = add_state(sma, 'name', 'LEFT_REWARD', ...
      'output_actions', {'DOut', left1water}, ...
      'self_timer', 0.1, 'default_statechange', 'hit_state');
    sma = add_state(sma, 'name', 'RIGHT_REWARD', ...
      'output_actions', {'DOut', right1water}, ...
      'self_timer', 0.1, 'default_statechange', 'hit_state');
    sma = add_state(sma, 'name', 'hit_state', 'self_timer', 0.0001, ...
      'default_statechange', 'state35');
    
    sma = add_state(sma, 'name', 'error_state', ...
      'output_actions', {'SoundOut', SoundManagerSection(obj, 'get_sound_id', 'error_sound')}, ...
      'self_timer', 1, 'default_statechange', 'state35');
    
    dispatcher('send_assembler', sma);
    
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
end;

   
      
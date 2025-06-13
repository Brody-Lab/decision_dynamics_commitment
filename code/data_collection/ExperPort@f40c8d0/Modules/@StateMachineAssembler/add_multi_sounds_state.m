

function sma = add_multi_sounds_state(sma, snd_ids , varargin)

% sma = add_multi_sounds_state(sma, snd_ids ,varargin)
% pairs={'self_timer' min_time;...
%        'return_state' 'current_state+1';...
%        'state_name'   ''};
%
% This function is a shortcut that allows protocol writers to turn on or
% off many sounds almost simultaneously.  Each state takes 1/5 ms to
% execute, so 5 SoundOut commands will execute in 1 ms.  
% The only required parameters are a state machine object 'sma' and a list
% of sound ids which can be positive or negative, depending on the desired
% action.  
%
% Options
%
% 'self_timer'   if this is left out, all the states will execute as
%                quickly as possible and transition to the 'return_state'.
%                If it is passed in then the SoundOut actions will execute as
%                quickly as possible, but the 'return_state' will occur after the
%                time in 'self_timer' has elapsed.
%
% 'return_state' The default is to transition to 'current_state+1', but
%                this parameters allows to transition to a named state after 
%                executing all of the SoundOut commands.
%
% 'state_name'   The default is for all of the states to be unamed (see
%                add_states.m for details), but the initial state in the
%                sequence can be named with this parameter.
   


min_time=1E-4;  % If given a time smaller than possible the FSM will do the best it can.
next_state='current_state+1';

pairs={'self_timer' min_time;...
       'return_state' 'current_state+1';...
       'state_name'   '';};
   
parseargs(varargin, pairs);

if numel(snd_ids)==1
    min_time=self_timer;
    next_state=return_state;
end

sma = add_state(sma, 'name',state_name,...
    'self_timer', min_time,...
    'output_actions',{'SoundOut', snd_ids(1)},...
    'input_to_statechange', {'Tup', next_state});

if numel(snd_ids)==1
    return;
end
   



for xi=2:(numel(snd_ids)-1)
    sma = add_state(sma, ...
        'self_timer', min_time,...
        'output_actions',{'SoundOut', snd_ids(xi)},...
        'input_to_statechange', {'Tup', next_state});
end

final_time=max(min_time, self_timer-(min_time*numel(snd_ids)));

sma = add_state(sma, ...
    'self_timer', final_time,...
    'output_actions',{'SoundOut', snd_ids(end)},...
    'input_to_statechange', {'Tup', return_state});

return;



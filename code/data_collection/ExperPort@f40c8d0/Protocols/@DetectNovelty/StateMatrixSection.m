% Create and send state matrix.
%
% Santiago Jaramillo - 2008.07.10

function sma = StateMatrixSection(obj, action)

GetSoloFunctionArgs;


global right1water;
global center1led;
center1led         = bSettings('get', 'DIOLINES', 'center1led');
switch action
case 'update',

% -- Get index for 
Sound_A = SoundManagerSection(obj, 'get_sound_id', 'Sound_A');
Sound_B = SoundManagerSection(obj, 'get_sound_id', 'Sound_B');
Sound_C = SoundManagerSection(obj, 'get_sound_id', 'Sound_C');
Sound_D = SoundManagerSection(obj, 'get_sound_id', 'Sound_D');
Sound_E = SoundManagerSection(obj, 'get_sound_id', 'Sound_E');
Sound_F = SoundManagerSection(obj, 'get_sound_id', 'Sound_F');
Sound_G = SoundManagerSection(obj, 'get_sound_id', 'Sound_G');
error_sound = SoundManagerSection(obj, 'get_sound_id', 'error_sound');

% -- Reward parameters --
[ValveDurationL,ValveDurationR] = WaterValvesSection(obj,'get_water_times');

% -- Define state matrix --



sma = StateMachineAssembler('full_trial_structure');


% First Trial Variables:
% 
% InitialDelay (a random delay between 0 and 1 seconds)

InitialDelay = 0;
DrinkIdleTimer = 1;
% 
% CueDuration (a fixed stimulus duration, changeable as a SOLOPARAM from the GUI)

CueDuration = value(SoundDuration);


% InterstimDelay (a random delay between 2 and 3 seconds. . . long enough that A1's input to downstream areas should be roughly the same code for two instantiations of a 'match' stimulus, requiring working        memory. . . if the sounds are too close together, based upon Hiro's work in Anaesthetized rat, A1 outputs a different code for the second sound and no working memory component is required to solve)


% !!! USE THIS!!!  Makes 100 element random array called 'x' from interval 1-10. x = 1 + (10-1).*rand(100,1);

InterStimDelay = value(InterStimDelayLo) + (value(InterStimDelayHi)-value(InterStimDelayLo)).*rand;

% Match_Action1 and Match_Action2: These take on the values "punishment_iti" or "reward", decribing which state to go to next depending on trial type. If the animal licks before the state timer is up on a "match" trial, it gets rewarded. If it waits for the state timer to expire on a "mismatch" trial, water is automatically delivered. If it does the wrong thing in either case it goes to punishment_iti.

% CueDuration2 (a fixed stimulus duration and subsequent "awaiting response" delay period, changeable as a SOLOPARAM from the GUI. Total time = 2-3 seconds)

CueDuration2 = value(SoundDuration);
Response_Delay = value (DelayTillResponse);
Response_Window = value(TimeForResponse);
% 
% ExtraTimeForError (The duration of "time-out" punishment)


ExtraTimeForError = value(Error_ITI);
ExtraTimeImpatient = value(Impatient_ITI);

if  (strcmp(value(Task_Phase),'Lick4Sound'))
ModeDirect = 'Deliver_Stim7';
elseif (strcmp(value(Task_Phase),'Lick4Second'))
ModeDirect = 'Deliver_Stim6';
else 
ModeDirect = 'Deliver_Stim1';
end
% 
% PunishNoise: (an array variable containing aversive white noise as 200,000hz-sampled audio data. This can be used for training and phased out so that correlates on error are due to internal representation of error and not simply coding for sound)



%     ----- Set Trial Sound IDs ------
First_Snd = value(First_Sound);
Second_Snd = value(Second_Sound);
Third_Snd = value(Third_Sound);
Fourth_Snd = value(Fourth_Sound);
Fifth_Snd = value(Fifth_Sound);
Sixth_Snd = value(Sixth_Sound);
Seventh_Snd = value(Seventh_Sound);

if n_done_trials > 1
First_Snd = First_Snd.value;
Second_Snd = Second_Snd.value;
Third_Snd = Third_Snd.value;
Fourth_Snd = Fourth_Snd.value;
Fifth_Snd = Fifth_Snd.value;
Sixth_Snd = Sixth_Snd.value;
Seventh_Snd = Seventh_Snd.value;
end
% if  (strcmp(value(Task_Phase),'LickOnSnd2'))
% 
%     if strcmp(First_Snd, 'Sound_A') == 1
%      First_Snd = Sound_A;
%     else
%      First_Snd = Sound_B;
%     end
% 
%     Second_Snd = Squeak;
% 
% 
% else
    
    if strcmp(First_Snd, 'Sound_A') == 1
     First_Snd = Sound_A;
    elseif strcmp(First_Snd, 'Sound_B') == 1
     First_Snd = Sound_B;
    elseif strcmp(First_Snd, 'Sound_C') == 1
     First_Snd = Sound_C;
    elseif strcmp(First_Snd, 'Sound_D') == 1
     First_Snd = Sound_D;
    elseif strcmp(First_Snd, 'Sound_E') == 1
     First_Snd = Sound_E;
    elseif strcmp(First_Snd, 'Sound_F') == 1
     First_Snd = Sound_F;
    else
     First_Snd = Sound_G;       
    end
    
    if strcmp(Second_Snd, 'Sound_A') == 1
    Second_Snd = Sound_A;
    elseif strcmp(Second_Snd, 'Sound_B') == 1
    Second_Snd = Sound_B;
    elseif strcmp(Second_Snd, 'Sound_C') == 1
    Second_Snd = Sound_C;
    elseif strcmp(Second_Snd, 'Sound_D') == 1
    Second_Snd = Sound_D;
    elseif strcmp(Second_Snd, 'Sound_E') == 1
    Second_Snd = Sound_E;
    elseif strcmp(Second_Snd, 'Sound_F') == 1
    Second_Snd = Sound_F;
    else
    Second_Snd = Sound_G;
    end
    
    if strcmp(Third_Snd, 'Sound_A') == 1
    Third_Snd = Sound_A;
    elseif strcmp(Third_Snd, 'Sound_B') == 1
    Third_Snd = Sound_B;
    elseif strcmp(Third_Snd, 'Sound_C') == 1
    Third_Snd = Sound_C;
    elseif strcmp(Third_Snd, 'Sound_D') == 1
    Third_Snd = Sound_D;
    elseif strcmp(Third_Snd, 'Sound_E') == 1
    Third_Snd = Sound_E;
    elseif strcmp(Third_Snd, 'Sound_F') == 1
    Third_Snd = Sound_F;
    else
    Third_Snd = Sound_G;
    end
    
    if strcmp(Fourth_Snd, 'Sound_A') == 1
    Fourth_Snd = Sound_A;
    elseif strcmp(Fourth_Snd, 'Sound_B') == 1
    Fourth_Snd = Sound_B;
    elseif strcmp(Fourth_Snd, 'Sound_C') == 1
    Fourth_Snd = Sound_C;
    elseif strcmp(Fourth_Snd, 'Sound_D') == 1
    Fourth_Snd = Sound_D;
    elseif strcmp(Fourth_Snd, 'Sound_E') == 1
    Fourth_Snd = Sound_E;
    elseif strcmp(Fourth_Snd, 'Sound_F') == 1
    Fourth_Snd = Sound_F;
    else
    Fourth_Snd = Sound_G;
    end
    
    if strcmp(Fifth_Snd, 'Sound_A') == 1
    Fifth_Snd = Sound_A;
    elseif strcmp(Fifth_Snd, 'Sound_B') == 1
    Fifth_Snd = Sound_B;
    elseif strcmp(Fifth_Snd, 'Sound_C') == 1
    Fifth_Snd = Sound_C;
    elseif strcmp(Fifth_Snd, 'Sound_D') == 1
    Fifth_Snd = Sound_D;
    elseif strcmp(Fifth_Snd, 'Sound_E') == 1
    Fifth_Snd = Sound_E;
    elseif strcmp(Fifth_Snd, 'Sound_F') == 1
    Fifth_Snd = Sound_F;
    else
    Fifth_Snd = Sound_G;
    end
    
    if strcmp(Sixth_Snd, 'Sound_A') == 1
    Sixth_Snd = Sound_A;
    elseif strcmp(Sixth_Snd, 'Sound_B') == 1
    Sixth_Snd = Sound_B;
    elseif strcmp(Sixth_Snd, 'Sound_C') == 1
    Sixth_Snd = Sound_C;
    elseif strcmp(Sixth_Snd, 'Sound_D') == 1
    Sixth_Snd = Sound_D;
    elseif strcmp(Sixth_Snd, 'Sound_E') == 1
    Sixth_Snd = Sound_E;
    elseif strcmp(Sixth_Snd, 'Sound_F') == 1
    Sixth_Snd = Sound_F;
    else
    Sixth_Snd = Sound_G;
    end
    
    if strcmp(Seventh_Snd, 'Sound_A') == 1
    Seventh_Snd = Sound_A;
    elseif strcmp(Seventh_Snd, 'Sound_B') == 1
    Seventh_Snd = Sound_B;
    elseif strcmp(Seventh_Snd, 'Sound_C') == 1
    Seventh_Snd = Sound_C;
    elseif strcmp(Seventh_Snd, 'Sound_D') == 1
    Seventh_Snd = Sound_D;
    elseif strcmp(Seventh_Snd, 'Sound_E') == 1
    Seventh_Snd = Sound_E;
    elseif strcmp(Seventh_Snd, 'Sound_F') == 1
    Seventh_Snd = Sound_F;
    else
    Seventh_Snd = Sound_G;
    end
% end
    
%   ------ Set Trial Correct Action -----
MatchAct1 = value(Match_Action1);
MatchAct2 = value(Match_Action2);
MatchAct3 = value(Match_Action3);
MatchAct4 = value(Match_Action4);
MatchAct5 = value(Match_Action5);


%   ------ Make State Matrix --------

sma = StateMachineAssembler('full_trial_structure');
        sma = add_state(sma, 'name', 'initial_delay', ...
                        'self_timer', InitialDelay,...
                        'input_to_statechange', ...
                        {'Tup', ModeDirect},...
                        'output_actions', {} ); ...
        sma = add_state(sma, 'name', 'Deliver_Stim1', ...
                        'self_timer', CueDuration,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay', 'Cin', 'impatient_iti'},...
                        'output_actions', {'SoundOut', First_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim2', 'Cin', 'impatient_iti'},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim2', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay2', 'Cin', 'impatient_iti'},...
                        'output_actions', {'SoundOut', Second_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay2', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim3', 'Cin', 'impatient_iti'},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim3', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay3', 'Cin', MatchAct1},...
                        'output_actions', {'SoundOut', Third_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay3', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim4', 'Cin', MatchAct1},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim4', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay4', 'Cin', MatchAct2},...
                        'output_actions', {'SoundOut', Fourth_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay4', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim5', 'Cin', MatchAct2},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim5', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay5', 'Cin', MatchAct3},...
                        'output_actions', {'SoundOut', Fifth_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay5', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim6', 'Cin', MatchAct3},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim6', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay6', 'Cin', MatchAct4},...
                        'output_actions', {'SoundOut', Sixth_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay6', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'Deliver_Stim7', 'Cin', MatchAct4},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'Deliver_Stim7', ...
                        'self_timer', CueDuration2,...
                        'input_to_statechange', ...
                        {'Tup', 'Inter_Stim_Delay7', 'Cin', MatchAct5},...
                        'output_actions', {'SoundOut', Seventh_Snd,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'Inter_Stim_Delay7', ...
                        'self_timer', InterStimDelay,...
                        'input_to_statechange', ...
                        {'Tup', 'iti', 'Cin', MatchAct5},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'reward', ...
                        'self_timer', ValveDurationR,...
                        'input_to_statechange', {'Tup', 'Drinking'},...
                        'output_actions', {'DOut', right1water});            
        sma = add_state(sma, 'name', 'Drinking', ...
                        'self_timer', DrinkIdleTimer,...
                        'input_to_statechange', {'Cin', 'StillDrinking', 'Cout', 'StillDrinking', 'Tup', 'final_state'},...
                        'output_actions', {});
        sma = add_state(sma, 'name', 'StillDrinking', ...
                        'self_timer', 0.1,...
                        'input_to_statechange', {'Cin', 'Drinking', 'Cout', 'Drinking', 'Tup', 'Drinking'},...
                        'output_actions', {});
        sma = add_state(sma, 'name', 'punishment_iti', ...
                        'self_timer', ExtraTimeForError,...
                        'input_to_statechange', {'Tup', 'final_state'},...
                        'output_actions', {'SoundOut', error_sound,'DOut', 0}); ...
        sma = add_state(sma, 'name', 'impatient_iti', ...
                        'self_timer', ExtraTimeImpatient,...
                        'input_to_statechange', {'Tup', 'final_state'},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'iti', ...
                        'self_timer', 1,...
                        'input_to_statechange', {'Tup', 'final_state'},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'mismatch_iti', ...
                        'self_timer', .01,...
                        'input_to_statechange', {'Tup', 'final_state'},...
                        'output_actions',{}); ...
        sma = add_state(sma, 'name', 'final_state', ...
                        'self_timer', .01,... 
                        'input_to_statechange',...
                        {'Tup', 'check_next_trial_ready'});
                    
                    
                   

dispatcher('send_assembler', sma, {'final_state'});

end %%% SWITCH action

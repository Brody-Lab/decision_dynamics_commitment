
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Growing nose in center time

% --- VAR NAMES: --- (do not edit this line)
% Maximum duration of center poke (including Go cue), in secs:
max_total_cp    6.2 	forceinit=1
% Standard Go cue duration
target_go_cue_duration  0.2
% Standard A1 duration
target_a1_duration  0.05
% Standard A2 duration
target_a2_duration  0.05
% CP_duration reached at the end of the last session
last_session_total_cp  0
% Fractional increment in center poke duration every time there is a non-cp-violation trial:
cp_fraction           0.001
% Minimum increment (in secs) in center poke duration every time there is a non-cp-violation trial:
cp_minimum_increment  0.001
% Maximum Delay interval 
del_max   4
% Del_time reached at the end of the last session
last_session_del_time 0


% Initial startup trials over which to gradually grow cp duration
% Only do the initial startup stuff if cp_duration is longer than:
cp_duration_threshold_for_initial_trials  1.5
% Number of initial trials over which to gradually grow cp duration:
n_initial_trials                          10
% Minimum duration for Auditory stimuli during warmup phase. 
minimum_aud_dur                           0.01
% Starting delay duration:
starting_del_time                         0.5
% Starting total center poke duration:
starting_total_cp                         0.5

% Minimum CP_duration at which a settling_in legal_cbreak is different to
% the regular legal_cbreak:
start_settling_in_at      1000
% Once we've reached CP_duration > start_settling_in_at, the parameters of
% the settling in:
settling_in_time          0
settling_in_legal_cbreak  0.05




% --- TRAINING STRING: --- (do not edit this line)
% If warmup flag is on, then during the first n_initial_trials Del_time
% starts to grow. If stimuli_on is on as well, the duration of A1_time and
% A2_time will be kept at minimum_aud_stimul.

% Check to see whether we're doing the initial startup stuff. Assumes that
% we're NOT changing the Go cue duration.
if SideSection_Total_CP_duration+0.0001 < last_session_total_cp & SideSection_warmup_on ==1
	% Check to see whether we're done with initial stuff within numerical
	% rounding error:
    
	if abs(last_session_del_time - SideSection_Del_time) < 0.0001,
		SideSection_Del_time.value = last_session_del_time;
    % during warmup phase, increment happens only for Del_time    
	elseif ~violation_history(end),
		increment = (last_session_del_time - starting_del_time)/(n_initial_trials - 1);
		SideSection_Del_time.value = SideSection_Del_time + increment;
	end;
    SideSection_A1_time.value = value(minimum_aud_dur);
    SideSection_A2_time.value = value(minimum_aud_dur);
    
elseif ~violation_history(end) & SideSection_Total_CP_duration < max_total_cp,
    
    if n_done_trials ==n_initial_trials
    SideSection_A1_time.value=value(a1_time_reg);
    SideSection_A2_time.value=value(a2_time_reg);
    end
    
	% We're in regular increasing territory
	increment = SideSection_Total_CP_duration*cp_fraction;
	if increment < cp_minimum_increment,
		increment = value(cp_minimum_increment);
	end;
	% If we're growing the CP duration, grow the Go cue duration first
	% until it reaches its target; after that, grow CP_duration, the
	% pre-Go cue time.
	if SideSection_time_go_cue < target_go_cue_duration,
		SideSection_time_go_cue.value = SideSection_time_go_cue + increment;
    elseif SideSection_A1_time < target_a1_duration || SideSection_A2_time < target_a2_duration
        if SideSection_A1_time < target_a1_duration
        SideSection_A1_time.value = SideSection_A1_time + increment;
        end
        if SideSection_A2_time < target_a2_duration
        SideSection_A2_time.value = SideSection_A2_time + increment;
        end
    else
		SideSection_Del_time.value = SideSection_Del_time + increment;
	end;
end;

% make sure the total reflects all the changes:

SideSection_CP_duration = SideSection_Del_time.value + SideSection_PreStim_time + SideSection_A1_time + SideSection_A2_time + SideSection_time_bet_aud2_gocue;
callback(SideSection_CP_duration);
callback(SideSection_Del_time);
callback(SideSection_A1_time);
callback(SideSection_A2_time);


% Double-check that we don't go over the desired max value:
if SideSection_Total_CP_duration > max_total_cp,
	SideSection_CP_duration.value = max_total_cp - SideSection_time_go_cue;
    SideSection_Del_time.value = SideSection_Cp_duration - SideSection_PreStim_time - SideSection_A1_time - SideSection_A2_time - SideSection_time_bet_aud2_gocue;
	% once again, make sure the total reflects any the changes:
	callback(SideSection_CP_duration);
    callback(SideSection_Del_time);
end;

% Settling in code:
if SideSection_CP_duration >= start_settling_in_at
	SideSection_SettlingIn_time.value       = value(settling_in_time);
	SideSection_settling_legal_cbreak.value = value(settling_in_legal_cbreak);
else
	SideSection_SettlingIn_time.value       = 0;
	SideSection_settling_legal_cbreak.value = value(SideSection_legal_cbreak);
end;




% --- END-OF-DAY LOGIC: -- (do not edit this line)


    % Store the value of the total cp duration reached:
    last_session_total_cp.value = value(SideSection_Total_CP_duration);
    last_session_del_time.value = value(SideSection_Total_CP_duration) - SideSection_time_go_cue - SideSection_PreStim_time - SideSection_A1_time - SideSection_A2_time - SideSection_time_bet_aud2_gocue;
    % Check whether we're going to do the initial startup trials on the next
    % day:
if SideSection_warmup_on ==1
    if SideSection_Total_CP_duration > cp_duration_threshold_for_initial_trials,
        % Yup, doing initial startup.  Set CP_duration to the necessary duration:
        SideSection_init_CP_duration.value = starting_total_cp - SideSection_time_go_cue;
        SideSection_Del_time.value = value(starting_del_time);
        % Error check, make sure we don't set it to something nonsensical:
        if SideSection_init_CP_duration < 0.001,
            SideSection_init_CP_duration = 0.001;
        end;
        if SideSection_Del_time < 0.001,
            SideSection_Del_time = 0.001;
        end;        
        %%%Callback to make sure the calculation initial values for
        %%%CP_duration and Del_time is made
        callback(SideSection_init_CP_duration);
        callback(SideSection_Del_time);
    end;
end







% --- COMPLETION STRING: --- (do not edit this line)
0






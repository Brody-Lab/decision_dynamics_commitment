
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
1 Side blocks of 10, then random

% --- VAR NAMES: --- (do not edit this line)
block
counter
blk_len 10
days
blk0_lprob 1




% --- TRAINING STRING: --- (do not edit this line)
gamma_0 = 5;
sample = 10;

blk1_lprob = 1-blk0_lprob;
rand_lprob = 0.5;

goto_trial_terminates_at = 8*blk_len;
goto_random_at = 6*blk_len;

random_max_same = 7;
random_beta = 4;

StimulusSection_stim_timing.value = 1;
StimulusSection_nose_in_center.value = 0.001;

if n_done_trials == 1,
	blk0_lprob.value = round(rand(1));
	blk1_lprob = 1-blk0_lprob;

    counter.value = 0;
    block.value = 0;

	PBupsSection_L_pprobs.value = blk0_lprob(1);
	PBupsSection_R_pprobs.value = 1-blk0_lprob;

    PenaltySection_PunishSideChoice.value = 0;
    PenaltySection_SideChoicePunishmentType.value = 0;

    SidesSection_MaxSame.value = Inf;
    SidesSection_LR_Beta.value = 0;

	PBupsSection_easiest.value = gamma_0;
	PBupsSection_N.value_callback = 1;

	PBupsSection_T_min.value = sample;
	PBupsSection_T_max.value = sample;
	PBupsSection_p_probe.value = 0;

	StimulusSection_stim_timing.value = 2;
end;

counter.value = counter+1;

if counter > blk_len,
  if block == 1,
	counter.value = 0;
    block.value = 0;
    PBupsSection_L_pprobs.value_callback = blk0_lprob(1);
	PBupsSection_R_pprobs.value_callback = 1-blk0_lprob;
  else
	counter.value = 0;
    block.value = 1;
    PBupsSection_L_pprobs.value_callback = blk1_lprob(1);
	PBupsSection_R_pprobs.value_callback = 1-blk1_lprob;
  end;
end;

if n_done_trials > goto_trial_terminates_at,
  PenaltySection_PunishSideChoice.value = 1;
end;

if n_done_trials > goto_random_at,
    PBupsSection_L_pprobs.value_callback = rand_lprob(1);
	PBupsSection_R_pprobs.value_callback = 1-rand_lprob;

    SidesSection_MaxSame.value = random_max_same;
    SidesSection_LR_Beta.value = random_beta;
end;




% --- END-OF-DAY LOGIC: -- (do not edit this line)
counter.value = 0;
block.value = 0;




% --- COMPLETION STRING: --- (do not edit this line)
n_done_trials > 80 && value(RewardsSection_last60_hitfrac) > 0.5;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
2 Random with temperror

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
gamma_0 = 5;
sample = 10;

goto_trial_terminates_at = 50;

random_max_same = 7;
random_beta = 4;

StimulusSection_stim_timing.value = 1;
StimulusSection_nose_in_center.value = 0.001;

if n_done_trials == 1,
	blk0_lprob.value = round(rand(1));
	blk1_lprob = 1-blk0_lprob;

    counter.value = 0;
    block.value = 0;

	PBupsSection_L_pprobs.value = 0.5;
	PBupsSection_R_pprobs.value = 0.5;

    PenaltySection_PunishSideChoice.value = 0;
    PenaltySection_SideChoicePunishmentType.value = 0;

	PBupsSection_easiest.value = gamma_0;
	PBupsSection_N.value_callback = 1;

	PBupsSection_T_min.value = sample;
	PBupsSection_T_max.value = sample;
	PBupsSection_p_probe.value = 0;

	StimulusSection_stim_timing.value = 2;
end;

if n_done_trials > goto_trial_terminates_at,
  PenaltySection_PunishSideChoice.value = 1;
end;




% --- END-OF-DAY LOGIC: -- (do not edit this line)




% --- COMPLETION STRING: --- (do not edit this line)
n_done_trials > 120 && value(RewardsSection_last60_hitfrac) > 0.7;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
3 grow nose in center

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
max_nose_in = 2.5;
sample = 3;


if value(StimulusSection_nose_in_center) <= max_nose_in && rows(parsed_events.states.cpoke1) < 2,
	StimulusSection_nose_in_center.value = value(StimulusSection_nose_in_center) + 0.001;
end;

StimulusSection_stim_timing.value = 1;
PBupsSection_L_pprobs.value_callback = 0.5;
PBupsSection_R_pprobs.value_callback = 0.5;

PenaltySection_SideChoicePunishmentType.value = 0;
PenaltySection_PunishSideChoice.value = 1;

SidesSection_MaxSame.value = 7;
SidesSection_LR_Beta.value = 4;

PBupsSection_T_min.value = sample;
PBupsSection_T_max.value = sample;



% --- END-OF-DAY LOGIC: -- (do not edit this line)




% --- COMPLETION STRING: --- (do not edit this line)
value(StimulusSection_nose_in_center) >= 2.5;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
4 wait for good endpoints

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
StimulusSection_stim_timing.value = 2;




% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 120 && RewardsSection_mean_hitfrac > 0.75;
    SessionDefinition_eod_jumper.value_callback = 5;
end;





% --- COMPLETION STRING: --- (do not edit this line)
0;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
6 retreat violation sound

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
StimulusSection_new_trial_on_violation.value = 1;
StimulusSection_reinit_dur.value = 1;
if isfield(parsed_events.states, 'violation_state') && rows(parsed_events.states.violation_state) > 0,
    RewardsSection_error_delay.value = value(RewardsSection_error_delay) + 0.005;
end;



% --- END-OF-DAY LOGIC: -- (do not edit this line)



% --- COMPLETION STRING: --- (do not edit this line)
value(RewardsSection_error_delay) >= 0.5;








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
5 add psychometrics 1

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
PBupsSection_N.value = 2;
PBupsSection_hardest.value = 5;
PBupsSection_T_min.value = 2.5;
PBupsSection_T_max.value = 2.5;
RewardsSection_error_delay = 0.5;



% --- END-OF-DAY LOGIC: -- (do not edit this line)



% --- COMPLETION STRING: --- (do not edit this line)
1;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
6 increase psych difficulty

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
PBupsSection_N.value = 2;




% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 120 && value(RewardsSection_mean_hitfrac) > 0.7;
    if value(PBupsSection_hardest) <= 3,
        PBupsSection_T_min.value = 2.5;
        PBupsSection_T_max.value = 2.5;
        SessionDefinition_eod_jumper.value_callback = 7;
    else
        PBupsSection_hardest.value = value(PBupsSection_hardest) - 1;
    end;
end;




% --- COMPLETION STRING: --- (do not edit this line)
0;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
7 decrease durations

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
PBupsSection_T_max.value = 2.5;




% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 120 && value(RewardsSection_mean_hitfrac) > 0.7;
    if value(PBupsSection_T_min) <= 0.5,
        PBupsSection_T_max.value = 2.5;
        PBupsSection_T_min.value = 0.5;
        SessionDefinition_eod_jumper.value_callback = 8;
    else
        if value(PBupsSection_T_max) > 2.5;
            PBupsSection_T_max.value = value(PBupsSection_T_max) - 0.1;
        end;
        if value(PBupsSection_T_min) > 0.5;
            PBupsSection_T_min.value = value(PBupsSection_T_min) - 0.2;
        end;
    end;
end;




% --- COMPLETION STRING: --- (do not edit this line)
0;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
8 add psychometrics 2

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
PBupsSection_N.value = 4;
PBupsSection_hardest.value = 2;



% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 150 && value(RewardsSection_mean_hitfrac) > 0.7;
    SessionDefinition_eod_jumper.value_callback = 9;
end;




% --- COMPLETION STRING: --- (do not edit this line)
0;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
9 sharpen psychometrics

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)



% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 120 && value(RewardsSection_mean_hitfrac) > 0.7;
    if value(PBupsSection_hardest) > 1;
        PBupsSection_hardest.value = value(PBupsSection_hardest) - 0.1;
    end;
    if value(PBupsSection_easiest) > 4;
        PBupsSection_easiest.value = value(PBupsSection_easiest) - 0.1;
    end;

    if value(PBupsSection_hardest) <= 1 && value(PBupsSection_easiest) <= 4;
        PBupsSection_hardest.value = 1;
        PBupsSection_easiest.value = 4;
        SessionDefinition_eod_jumper.value_callback = 10;
    end;
end;



% --- COMPLETION STRING: --- (do not edit this line)
0;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
11 sharpen psychometrics 2

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)



% --- END-OF-DAY LOGIC: -- (do not edit this line)
if n_done_trials > 150 && value(RewardsSection_mean_hitfrac) > 0.7;
    if value(PBupsSection_hardest) > 0.5;
        PBupsSection_hardest.value = value(PBupsSection_hardest) - 0.1;
    end;
    if value(PBupsSection_easiest) > 3.5;
        PBupsSection_easiest.value = value(PBupsSection_easiest) - 0.1;
    end;
    if value(PBupsSection_hardest) <= 0.5 && value(PBupsSection_easiest) <= 3.5;
        PBupsSection_easiest.value = 3.5;
        PBupsSection_hardest.value = 0.5;
        SessionDefinition_eod_jumper.value_callback = 12;
    end;
end;



% --- COMPLETION STRING: --- (do not edit this line)
0;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
12 final

% --- VAR NAMES: --- (do not edit this line)


% --- TRAINING STRING: --- (do not edit this line)



% --- END-OF-DAY LOGIC: -- (do not edit this line)



% --- COMPLETION STRING: --- (do not edit this line)
0



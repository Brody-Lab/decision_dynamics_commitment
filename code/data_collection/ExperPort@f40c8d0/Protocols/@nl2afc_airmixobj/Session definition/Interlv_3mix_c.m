
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Baseline_1_start

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 3;
OdorSection_mix_ID.value_callback = 2;
SessionDefinition_blk_cnt.value = 0;


% --- COMPLETION STRING: --- (do not edit this line)
1






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Baseline_1

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
if BlockControl_trial_count >= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;




% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_blk_cnt >= 5






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Baseline_2_start

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 3;
OdorSection_mix_ID.value_callback = 3;
SessionDefinition_blk_cnt.value = 0;


% --- COMPLETION STRING: --- (do not edit this line)
1






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Baseline_2

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
if BlockControl_trial_count >= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;




% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_blk_cnt >= 5







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Interlv_start

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value_callback = 4;
BlockControl_mixid_rept.value = 1;             BlockControl_repts.value_callback = 180;
BlockControl_mixid_rept.value = 2;             BlockControl_repts.value_callback = 60;
BlockControl_mixid_rept.value = 3;             BlockControl_repts.value_callback = 60;



% --- COMPLETION STRING: --- (do not edit this line)
1






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Interlv

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)




% --- COMPLETION STRING: --- (do not edit this line)
BlockControl_n_interlv_trials_left <= 1;







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Recov_tg1

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 3;
OdorSection_mix_ID.value_callback = 2;
SessionDefinition_blk_cnt.value = 0;



% --- COMPLETION STRING: --- (do not edit this line)
1






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Recov_tg1_cont

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
if BlockControl_trial_count >= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;



% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_blk_cnt >= 2







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Recov_tg2

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 3;
OdorSection_mix_ID.value_callback = 3;
SessionDefinition_blk_cnt.value = 0;



% --- COMPLETION STRING: --- (do not edit this line)
1






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Recov_tg2_cont

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
if BlockControl_trial_count >= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;



% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_blk_cnt >= 2






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
End_of_session

% --- VAR NAMES: --- (do not edit this line)



% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 1;



% --- COMPLETION STRING: --- (do not edit this line)
0



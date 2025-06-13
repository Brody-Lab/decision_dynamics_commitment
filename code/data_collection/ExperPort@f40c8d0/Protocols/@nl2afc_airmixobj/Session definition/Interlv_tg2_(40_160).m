
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
if (BlockControl_trial_count>= BlockControl_block_size) && (BlockControl_blk_scr(value(BlockControl_block_count)-1) >= 80)
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
Interlv_1_start

% --- VAR NAMES: --- (do not edit this line)

% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value_callback = 4;
BlockControl_mixid_rept.value = 1;             BlockControl_repts.value_callback = 160;
BlockControl_mixid_rept.value = 2;             BlockControl_repts.value_callback = 40;

% --- COMPLETION STRING: --- (do not edit this line)
1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Interlv_1

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
Baseline_2_start

% --- VAR NAMES: --- (do not edit this line)

% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value = 3;
OdorSection_mix_ID.value_callback = 1;
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
if (BlockControl_trial_count>= BlockControl_block_size)&& (BlockControl_blk_scr(value(BlockControl_block_count)-1) >= 80)
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
Interlv_2_start

% --- VAR NAMES: --- (do not edit this line)

% --- TRAINING STRING: --- (do not edit this line)
BlockControl_block_update.value_callback = 4;
BlockControl_mixid_rept.value = 1;             BlockControl_repts.value_callback = 40;
BlockControl_mixid_rept.value = 2;             BlockControl_repts.value_callback = 160;

% --- COMPLETION STRING: --- (do not edit this line)
1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Interlv_2

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
End of Session

% --- VAR NAMES: --- (do not edit this line)

% --- TRAINING STRING: --- (do not edit this line)
  BlockControl_block_update.value = 2;

% --- COMPLETION STRING: --- (do not edit this line)
0


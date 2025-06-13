
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix1_start

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
OdorSection_mix1.value = 1;
OdorSection_mix2.value = 3;
OdorSection_mix3.value = 2;
OdorSection_mix_ID.value_callback = 1;
BlockControl_block_update.value = 3;
SessionDefinition_blk_cnt.value = 0;
SessionDefinition_score_cnt.value = 0;



% --- COMPLETION STRING: --- (do not edit this line)
1




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix1

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
if (BlockControl_trial_count>= BlockControl_block_size) && (BlockControl_blk_scr(value(BlockControl_block_count)-1) >= 80)
    SessionDefinition_score_cnt.value = SessionDefinition_score_cnt + 1;
end;
if BlockControl_trial_count>= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;




% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_score_cnt >= 3




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix2_start

% --- VAR NAMES: --- (do not edit this line)


% --- TRAINING STRING: --- (do not edit this line)
OdorSection_mix_ID.value_callback = 2;
BlockControl_block_update.value = 3;
SessionDefinition_blk_cnt.value = 0;
SessionDefinition_score_cnt.value = 0;




% --- COMPLETION STRING: --- (do not edit this line)
1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix2

% --- VAR NAMES: --- (do not edit this line)


% --- TRAINING STRING: --- (do not edit this line)
if (BlockControl_trial_count>= BlockControl_block_size) && (BlockControl_blk_scr(value(BlockControl_block_count)-1) >= 80)
    SessionDefinition_score_cnt.value = SessionDefinition_score_cnt + 1;
end;
if BlockControl_trial_count>= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;




% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_score_cnt >= 3




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix3_start

% --- VAR NAMES: --- (do not edit this line)


% --- TRAINING STRING: --- (do not edit this line)
OdorSection_mix_ID.value_callback = 3;
BlockControl_block_update.value = 3;
SessionDefinition_blk_cnt.value = 0;
SessionDefinition_score_cnt.value = 0;


% --- COMPLETION STRING: --- (do not edit this line)
1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
Mix3

% --- VAR NAMES: --- (do not edit this line)


% --- TRAINING STRING: --- (do not edit this line)
if (BlockControl_trial_count>= BlockControl_block_size) && (BlockControl_blk_scr(value(BlockControl_block_count)-1) >= 80)
    SessionDefinition_score_cnt.value = SessionDefinition_score_cnt + 1;
end;
if BlockControl_trial_count>= BlockControl_block_size
    SessionDefinition_blk_cnt.value = SessionDefinition_blk_cnt + 1;
end;


% --- COMPLETION STRING: --- (do not edit this line)
SessionDefinition_score_cnt >= 3



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ------------ STAGE SEPARATOR ------- (do not edit this line)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- STAGE NAME: --- (do not edit this line)
End_of_Session

% --- VAR NAMES: --- (do not edit this line)




% --- TRAINING STRING: --- (do not edit this line)
  BlockControl_block_update.value = 1;



% --- COMPLETION STRING: --- (do not edit this line)
0





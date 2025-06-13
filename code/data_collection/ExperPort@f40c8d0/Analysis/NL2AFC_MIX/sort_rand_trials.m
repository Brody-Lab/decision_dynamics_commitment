function [saved, saved_history, events] = sort_rand_trials(saved, saved_history, events, rand_trial)
% sort data from randomly interleaved trials
[tmp, idx] = sort(cell2mat(saved_history.OdorSection_mix_ID(rand_trial)));
% trial_id = data_sorting(trial_id, rand_trial, idx);
saved_history.OdorSection_mix_ID = data_sorting(saved_history.OdorSection_mix_ID, rand_trial, idx);
saved.RewardsSection_LeftRewards = data_sorting(saved.RewardsSection_LeftRewards, rand_trial, idx);
saved.RewardsSection_RightRewards = data_sorting(saved.RewardsSection_RightRewards,rand_trial, idx);
saved.SidesSection_side_list = data_sorting(saved.SidesSection_side_list,rand_trial, idx);
events = data_sorting(events,rand_trial, idx);
saved_history.OdorSection_mix_name = data_sorting(saved_history.OdorSection_mix_name,rand_trial, idx);
saved_history.SidesSection_WaterDelivery = data_sorting(saved_history.SidesSection_WaterDelivery,rand_trial,idx);

function [data_sorted] = data_sorting(rand_data, rand_trial, idx)
tmp = rand_data(rand_trial);
tmp = tmp(idx);
rand_data(rand_trial) = tmp;
data_sorted = rand_data;
return;
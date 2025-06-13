function [] = rand_bg_plot(ratname, taskname, date_ses)
% input ratname, e.g., xu1_2, taskname, e.g., 'nl2afc', session name, e.g.,
% '060927a'. 
% You can input more than one session. 
% Here is an example:
%    rat_over_ses('xu1_2', 'nl2afc', '060926a', 060927a')
% it will sort randomly permutated bgrds, and calculate the block score for
% each bgrds. 

cd('C:\Home\RatExper\ExperPort\');
close all;
taskname_l = ['@' taskname 'obj'];
scrsz = get(0, 'ScreenSize');
lft = 1; btm = scrsz(4)/2; wd = scrsz(3)/round(1/2); ht = scrsz(4)/2;
figure('Position', [lft btm wd ht]); hold on;
load_datafile(ratname, taskname_l, date_ses);
Title = [ratname ' ' taskname ' ' date_ses saved.OdorSection_target_frac];
title(Title, 'FontSize', 20);
% Next to sort the randomized trials if there are some
if ismember('random_bg', saved_history.BlockControl_block_update)
    rand_trial = find(strcmpi(saved_history.BlockControl_block_update, 'random_bg'));
    if rand_trial(end)> saved.RewardsSection_TrialTracker
        x = rand_trial(end) - saved.RewardsSection_TrialTracker;
        rand_trial = rand_trial(1:end-x);
    end;
    [tmp, idx] = sort(cell2mat(saved_history.OdorSection_bgrd_ID(rand_trial)));
    
    saved_history.OdorSection_bgrd_ID = sort_rand_trials(saved_history.OdorSection_bgrd_ID, rand_trial, idx);
    saved.RewardsSection_LeftRewards = sort_rand_trials(saved.RewardsSection_LeftRewards, rand_trial, idx);
    saved.RewardsSection_RightRewards = sort_rand_trials(saved.RewardsSection_RightRewards,rand_trial, idx);
    saved.SidesSection_side_list = sort_rand_trials(saved.SidesSection_side_list,rand_trial, idx);
    saved_history.odorsegm2obj_LastTrialEvents = sort_rand_trials(saved_history.odorsegm2obj_LastTrialEvents,rand_trial, idx);
    saved_history.OdorSection_bgrd_name = sort_rand_trials(saved_history.OdorSection_bgrd_name,rand_trial, idx);

    [L_Score, R_Score, Score, score_blk] = rat_perform(saved,saved_history,taskname,0,...
        rand_trial(1), rand_trial(end));
    set(gca,'YGrid','on')
    save_dir = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep ratname filesep 'analyse'];
    if ~exist(save_dir)
        mkdir(save_dir);
    end
    save_result_file = [save_dir filesep date_ses];
    save(save_result_file, 'L_Score', 'R_Score', 'Score','score_blk');
    saveas(gcf, save_result_file, 'tif');
end

function [data_sorted] = sort_rand_trials(saved_data, rand_trial, idx)
tmp = saved_data(rand_trial);
tmp = tmp(idx);
saved_data(rand_trial) = tmp;
data_sorted = saved_data;
return;

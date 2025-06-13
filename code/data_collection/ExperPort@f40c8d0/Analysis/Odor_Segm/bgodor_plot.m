function [L_Score, R_Score, Score, score_blk] = bgodor_plot(ratname, taskname, date_ses)
% This is a function to pick out trials of random and non_random odor presentation.
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
lft = 1; btm = scrsz(4)/2; wd = scrsz(3); ht = scrsz(4)/2-50;
fig1 = figure('Position', [lft btm wd ht]); hold on;

load_datafile(ratname, taskname_l, date_ses);
Title = [ratname ' ' taskname ' ' date_ses saved.OdorSection_target_frac];
save_dir = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep ratname filesep 'analyse'];
    if ~exist(save_dir)
        mkdir(save_dir);
    end
save_path = [save_dir filesep date_ses];
% Next to sort the randomized trials if there are any
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
    saved_history.SidesSection_WaterDelivery = sort_rand_trials(saved_history.SidesSection_WaterDelivery,rand_trial,idx);
end
[L_Score, R_Score, Score, score_blk] = rat_perform(saved,saved_history,taskname,0);
figure(fig1);
set(gca,'YGrid','on')
title(Title, 'FontSize', 20);
save(save_path, 'L_Score', 'R_Score', 'Score','score_blk');
saveas(gcf, save_path, 'tif');

figure('Position', [lft 30 wd ht-50]); 
plot(cell2mat(score_blk(:,2)), cell2mat(score_blk(:,7)),'-o'); % plot odor sampling time in a separate figure
set(gca, 'YGrid','on', 'XGrid', 'off');
set(get(gca,'XLabel'),'String','Trials','FontSize',18);
set(get(gca,'YLabel'),'String','Odor Sampling Time (s)','FontSize',18);

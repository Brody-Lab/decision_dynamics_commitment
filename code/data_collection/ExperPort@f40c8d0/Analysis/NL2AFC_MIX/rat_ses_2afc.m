function [L_Score, R_Score, Score, score_blk] = rat_ses_2afc (ratname, taskname, mannual_input, varargin)
% input ratname, e.g., xu1_2, taskname, e.g., 'nl2afc', session name, e.g.,
% '060927a'. 
% You can input more than one session. 
% Here is an example:
%    rat_over_ses('xu1_2', 'nl2afc', '060926a', 060927a')
% it will plot the results of the two sessions of this rat, with moving
% average. The block size is 20 trials. 

close all;
taskname_l = ['@' taskname 'obj'];
date_ses = varargin;
n = length(date_ses);
scrsz = get(0, 'ScreenSize');
lft = 1; btm = scrsz(4)/2; wd = scrsz(3)/round(n/2); ht = scrsz(4)/2;
for i = 1: n,
    if i<= round(n/2),
        lft = (i-1)*wd +1;
    else
        lft = (i-round(n/2)-1)*wd + 1;
        btm = scrsz(2);
    end
    figure('Position', [lft btm wd ht]); hold on;
    load_datafile(ratname, taskname_l, date_ses{i});
    events = eval(['saved_history.' taskname 'obj_LastTrialEvents']);
    Title = [ratname ' ' taskname ' ' date_ses{i}];% ' ' saved.OdorSection_left_target '/' saved.OdorSection_right_target];
    title(Title, 'FontSize', 20);
    trial_id = (1:saved.RewardsSection_TrialTracker); % to track varialbes trial ID.
    if ismember('interlv', saved_history.BlockControl_block_update) % if there are rand interleaved trials
        % determine the ids of the randomly interleaved trials
        if mannual_input, % mannual input the ranges of rand trials
            % there could be many epochs of interleaved trials
            rand_trials = input('Input interleaved trial IDs: {(a:b), (c:d),...}');
        else
            rand_trial = find(strcmpi(saved_history.BlockControl_block_update, 'interlv'));
            if rand_trial(end)> saved.RewardsSection_TrialTracker
                x = rand_trial(end) - saved.RewardsSection_TrialTracker;
                rand_trial = rand_trial(1:end-x);
            end;
            rand_trials = {rand_trial};
        end;
        for j = 1:length(rand_trials),
            % Sort rand trials independently in each epoch
            [saved, saved_history, events] = sort_rand_trials(saved, saved_history, events, rand_trials{j});
        end;
    end;

    [L_Score, R_Score, Score, score_blk] = data_plot_2afc(saved,saved_history,taskname,events,0);
    save_dir = [pwd filesep '..' filesep 'SoloData' filesep 'data' filesep 'NL_Analysis' filesep taskname];
    if ~exist(save_dir)
        mkdir(save_dir);
    end;
    save_result_file = [save_dir filesep ratname '_' date_ses{i}];
    save(save_result_file, 'L_Score', 'R_Score', 'Score','score_blk');
    saveas(gcf, save_result_file, 'tif');
end
   
figure('Position', [lft 30 wd ht-50]); 
plot(cell2mat(score_blk(2:end,2)), cell2mat(score_blk(2:end,7)),'-o'); % plot odor sampling time in a separate figure
set(gca, 'YGrid','on', 'XGrid', 'off');
set(get(gca,'XLabel'),'String','Trials','FontSize',18);
set(get(gca,'YLabel'),'String','Odor Sampling Time (s)','FontSize',18);

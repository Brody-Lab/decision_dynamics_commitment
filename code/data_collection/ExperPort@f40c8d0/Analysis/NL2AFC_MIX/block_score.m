function [block_scr] = block_score(taskname, saved, saved_history, start_trial, end_trial)

block_size = 20;
% extract information from saved Solo variables.
Trials = saved.RewardsSection_TrialTracker;
side_list = saved.SidesSection_side_list(1:Trials);
events = eval(['saved_history.' taskname 'obj_LastTrialEvents']);

% to eliminate the trials in which rats did not response...
wfapk = saved.make_and_upload_state_matrix_RealTimeStates.wait_for_apoke;
dummy_trials = [];
% to find the dummy trials....
for i = 1: length(events),
    temp = events{i};
    a = temp(temp(:,1) == wfapk, 2);
    if ~isempty(a)
        if a(end) == 7
            dummy_trials = [dummy_trials i];
        end
    else
        dummy_trials = [dummy_trials i];
    end
end
% now eliminate the dummy trials...
Trials = Trials - length(dummy_trials);
side_list(dummy_trials) = [];

L_Rew = saved.RewardsSection_LeftRewards;
%L_Rew(dummy_trials) = [];
R_Rew = saved.RewardsSection_RightRewards;
%R_Rew(dummy_trials) = [];
Rew = L_Rew+R_Rew;
% Now calculate the blcok score
n_block = round((end_trial - start_trial +1)/block_size);
if n_block > 0
    for i = 1: n_block
        if i == n_block
            trial_n = (start_trial+(i-1)*block_size: end_trial);
            trial_n(ismember(trial_n, dummy_trials)) = [];
        else
            trial_n = (start_trial+(i-1)*block_size: start_trial + i*block_size-1);
            trial_n(ismember(trial_n, dummy_trials)) = [];
        end
        block_scr(i) = sum(Rew(trial_n))/length(trial_n)*100;
    end
end

        
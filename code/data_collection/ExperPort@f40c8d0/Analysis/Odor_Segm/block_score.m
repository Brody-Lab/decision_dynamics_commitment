function [block_scr, block_st] = block_score(taskname, saved, saved_history, start_trial, end_trial)
% Calculate block score and block averaged odor sampling time, in specified
% trial range.
% If data contain randomly interleaved trials, they will be sorted first.
block_size = 20;
% extract information from saved Solo variables.
Trials = saved.RewardsSection_TrialTracker;
side_list = saved.SidesSection_side_list(1:Trials);
events = eval(['saved_history.' taskname 'obj_LastTrialEvents']);
wfapk = saved.make_and_upload_state_matrix_RealTimeStates.wait_for_apoke;
L_Rew = saved.RewardsSection_LeftRewards;
R_Rew = saved.RewardsSection_RightRewards;

%Next if there is randomly interleaved trials, sort those trials.
if isfield(saved_history, 'BlockControl_block_update'),
    if ismember('random_bg', saved_history.BlockControl_block_update)
        rand_trial = find(strcmpi(saved_history.BlockControl_block_update, 'random_bg'));
        if rand_trial(end)> saved.RewardsSection_TrialTracker % in case there is one empty trial in the end
            x = rand_trial(end) - saved.RewardsSection_TrialTracker;
            rand_trial = rand_trial(1:end-x);
        end;
        [tmp, idx] = sort(cell2mat(saved_history.OdorSection_bgrd_ID(rand_trial)));
        side_list = sort_rand_trials(side_list, rand_trial, idx);
        events = sort_rand_trials(events, rand_trial, idx);
        L_Rew = sort_rand_trials(L_Rew, rand_trial, idx);
        R_Rew = sort_rand_trials(R_Rew, rand_trial, idx);
    end;
end;

% to eliminate the trials in which rats did not response...
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

Rew = L_Rew+R_Rew;
% Now calculate the blcok score
n_block = round((end_trial - start_trial +1)/block_size);
if n_block > 0
    % next loop through all the blocks
    for i = 1: n_block
        % next find the trial ids (trial_n) of this block
        if i == n_block % if reach the last block
            trial_n = (start_trial+(i-1)*block_size: end_trial);
            trial_n(ismember(trial_n, dummy_trials)) = []; % eliminate the dummy trials
        else
            trial_n = (start_trial+(i-1)*block_size: start_trial + i*block_size-1);
            trial_n(ismember(trial_n, dummy_trials)) = [];
        end
        block_scr(i) = sum(Rew(trial_n))/length(trial_n)*100;
        % next calculate the average odor sampling time of this block
        st = [];
        for j = trial_n,
            t = SamplingTime(events{j}); % sampling time of this trial 
            if t~=0, st = [st t]; end;
        end;
        block_st(i) = mean(st);
    end
end

        
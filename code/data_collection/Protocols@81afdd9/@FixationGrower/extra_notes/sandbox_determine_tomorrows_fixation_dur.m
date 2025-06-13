
% Return if stimuli are on- pre,stim,post durs are not yet accounted for
% here
if value(stimuli_on) 
    warning("***Stimuli are on, case is not currently written for this scenario");
    return
end


%% Access SoloParamHandles 
valid_trials = value(~violation_history);
cpoke_dur_handle = get_sphandle('fullname', 'HistorySection_cpoke_dur'); % theres also a wf_cpoke_dur so we are explicit here
cooke_durs =value(cpoke_dur_handle{1}); % unpack from SPH struct


%% Toggle variables based on if settling in determines fixation
%
% violation penalty is off- this means settling_in_dur is what is being
% primarily being used fixation_dur such that
%   pre_go_dur = 0.001 to keep SMA happy
%   fixation_dur = settling_in_dur + pre_do_dur
%
% A trial is only counted here if the cpoke was completed. The only
% possible way to violate is if the animal side pokes during the
% pre_go_dur window (so it's effectively impossible). So, in general
% n_done_trials ~= n_valid trials.
%
%
% failed pokes for a trial are summarized by avg_settling_in_durs which
% is the average of all the failed pokes that were below the
% fixation_dur threshold for a trial
if value(settling_in_determines_fixation)
    task_var = 'settling_in_dur';
    task_var_value = value(settling_in_dur);
         
    % Failed cpoke dur
    avg_settling_in_dur_handle = getsphandle('fullname', 'HistorySection_avg_settling_in_dur');
    avg_settling_in_durs = value(avg_settling_in_dur_handle{1}); % unpack from SPH struct
    avg_failed_cpoke_dur = mean(avg_settling_in_durs, 'omitnan');

else  
% violation penaty is on- this means that fixation_dur is parameterized
% by settling_in_dur and delay_dur such that pre go dur is the time
% during fication where violations are possible. And if an animal makes
% it through settling_in, this counts to their overal fixation goal for
% the trail
%   pre_go_dur = max(0.001, delay_dur - settling_in_dur) 
%   fixation_dur = settling_in_dur + pre_go_dur
%
% A trial is counted here whether or not cpokes are completed.
% Therefore, n_valid indicates the number of non-violation trials
%
% To find the valid cpoke_durs we must filter for valid trials only
%
% To find the violation cpoke_durs we must filter for nonvalid or
% violation trials only.

    task_var = 'delay_dur';
    task_var_value = value(delay_dur);

    % Failed cpoke dur
    violation_cpokes     = cpoke_durs(~valid_trials);
    failed_cpoke_durs    = value(cpoke_durs(~valid_trials)); 
    avg_failed_cpoke_dur = mean(failed_cpoke_durs, 'omitnan');

end

%% compute shared metrics between settling in dets fix on/off conditions
fixation_dur = value(fixation_dur);
was_bad_day = value(n_valid) <= 20; % between 5 and 15 due to logic
was_good_day = value(n_valid) >= 50;
not_enough_data = n_done_trials < 5;

if task_dur_value <= value(initial_fixation_dur)
    havent_started_growing = 1;
else
    havent_started_growing = 0;
end

valid_cpoke_durs     = value(cpoke_durs(valid_trials));
avg_valid_cpoke_dur  = mean(valid_cpoke_durs, 'omitnan');

%% Update Fixation Dur- Overnight Growth

growth_type = value(eval([task_var '_growth']));
switch growth_type
    
    case 'overnight_growth'
        % animal hasn't grasped fixation yet ~or~ we don't have enough data to
        % make an informed decision about what to do, so we will drop the
        % fixation dur by the adjustment value (usually 50 ms)
        if (havent_started_growing && today_was_bad) || not_enough_data

            adjusted_fixation_dur = fixation_dur - value(fixation_adjustment);
            new_fixation_dur = max(value(settling_in_min), adjusted_fixation_dur);

        % animal  hasn't grown to full target yet. If it was a good day, let's grow
        % to the average valid cpoke. If it was a bad day we will decrease the
        % requirement a bit. If it was inbetween (20-50 trials) don't do anything.
        elseif ~value(has_reached_fixation_target)
            if was_good_day
                new_fixation_dur = avg_valid_cpoke_dur;
                if new_fixation_dur > value(target_fixation_dur)
                    has_reached_fixation_target = 1;
                end

            elseif was_bad_day
                % if we have enough data on bad poking (5-20 trials), set fixation
                % to halfway between average failed and today's requirement

                diff = max(0.001, fixation_dur - avg_failed_cpoke_dur);
                new_fixation_dur = fixation_dur - (0.5 * diff);
            end
        else %do nothing- just keep things as is!
            new_fixation_dur = fixation_dur;
        end

        % animal has reached the target as of today and we will now switch to
        % overnight sampled
        if has_reached_fixation_target 
           eval([task_var '_growth.value = overnight_sampled;']); 
           new_fixation_dur = DistribInterface(obj, 'get_new_sample', 'exp_sample');
        end

        eval([task_var '.value = new_fixation_dur;']);
    
    case 'overnight_sampled'
        new_fixation_dur = DistribInterface(obj, 'get_new_sample', 'exp_sample');
        eval([task_var '.value = new_fixation_dur;']);
    
    case 'fixed'
        % TODO- need to check this logic
        if havent_started_growing && today_was_bad
            adjusted_fixation_dur = fixation_dur - value(fixation_adjustment);
            new_fixation_dur = max(value(settling_in_min), adjusted_fixation_dur);
            eval([task_var '.value = new_fixation_dur;']);
            eval([task_var '_prev_session.value = new_fixation_dur;']);
        end
        
        if has_reached_fixation_target
            sampled_dur = DistribInterface(obj, 'get_new_sample', 'exp_sample');
            eval([task_var '_prev_session.value = sampled_dur;']);
        else
            % do nothing! this is taken care of in ShapingSection warm up 
            % and fixed_growth cases
            disp('');
        end
end % switch growth type
%%



























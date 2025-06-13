%% TS_JB_r_classic_rule_experiments
% Training Section; Jess Breda; Rats ; Classic Rule Experiments
%
% This curriculum builds off of JB_r_classic and is specific to pro-anti rule
% learning. It is assumed when an animal is swtiched to this curriculum
% that the following has happened
%
% 1. they are center poking with 2 discrete sounds play and fixation end
% triggered by a go cue
% 2. they are capable of an sb dependent rule indicating they can use the
% sounds (as of 2023-10-26, this may change)
%
% 
% Pro-anti style (full set) [prioritized]
% 12 Add in other sb rule pair in blocks style (e.g. anti) with give on 
%   100% for anti trials. block logic is always starting w/ pro and then 
%   after minimum 30 trials and 70% threshold, swtich to anti
% 13 Reduce give frac on anti trials
% 14 randomly interleave pro-anti (full cross)
% 
function varargout = TS_JB_r_classic_pro_anti(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values 
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1 Not in use',...
            '2 Not in use',...
            '3 Not in use',...
            '4 Not in use',...
            '5 Not in use',...
            '6 Not in use',...
            '7 Not in use',...
            '8 Not in use',...
            '9 Not in use',...
            '10 Not in use',...
            '11 Not in use',...
            '12 Pro only',...
            '13 Anti only',...
            '14 Add in anti blocked, give',...
            '15 Add in anti blocked, adaptive give delay',...
            '16 Add in anti blocked, no guide ',...
            '17 Add in anti blocked -> random ',...
        };

    %---------------------------------------------------------------%
    %          get_update                                           %
    %---------------------------------------------------------------%

    % If this curriculum is selected, this is called during init and on
    % each trial to determine the settings for the given trial in Training
    % Section `get_curriculum_update`.

    % This is this case that is synonyms to a SessionDefinition. End of 
    % stage logic occurs within the case for the stage number, end of day 
    % logic occurs in the `get_eod_logic` case.
    
    case 'get_update'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        
        case {1,2,3,4,5,6,7,8,9,10,11}
            
            stage_description.value = 'Init vars & switch to stg 12';
            
            % timing
            settling_in_dur.value = 0.25;
            pre_dur.value = 0.25; % will be filled by settling in
            stimulus_dur.value = 0.4;
            delay_dur.value = 0.14;
            post_dur.value = 0.40;
            
            % shaping
            replay_on.value = 1;
            fixation_required.value = 1;
            temp_error_penalty.value = 0;
            viol_off_growth.value = 'match_pre_go';
            Beta.value = 3;
            betaRampup.value = 1;
            
            % errors have time out penalty
            error_dur.value = 2;
            violation_dur.value = 1;

            % iti
            inter_trial_dur_type.value = 'sampled'; % gaussain
            inter_trial_min.value = 0.25; % seconds
            inter_trial_sample_mean.value = 1; 
            inter_trial_max.value = 5; 
            inter_trial_sample_std.value = 0.5; 
            
            % switch to next stage
            TrainingSection(obj, 'increment_stage', 12);
            
    case 12
            %%
            stage_description.value = 'pro only';

            %%% init
            % session init
            if value(n_trials_stage) == 0
                
                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'pro';
                presets.value = value(pro_preset);
                StimulusSection(obj, 'set_preset');
                

                 % stage init
                if value(n_days_stage) <= 1 % stage init 
                    % give should be off- but allowing for flexibility by
                    % only setting it to off on first day in stage
                    give_type_set.value = 'none'; % pro trials get no give

                    % set up distribui for exp delay for overnight sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);

                end
            end

            %%% Stage Algorithim- nothing is happening here animal is just
            %%% doing trials with "pro" stimulus set
            
            %%% EOD logic- currently none animals are being manually
            %%% switched once pro-only performance is abouve ~85% for 5 or
            %%% so days, trial numbers are 250+ and violations are low
            %%% - ~15% or less for most animals
            
            
    case 13
            %%
            stage_description.value = 'anti only' ;

            %%% init
            % session init
            if value(n_trials_stage) == 0
                
                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'anti';
                presets.value = value(anti_preset);
                StimulusSection(obj, 'set_preset');
                

                 % stage init
                if value(n_days_stage) <= 1 % stage init 
                    % give should be off- but allowing for flexibility by
                    % only setting it to off on first day in stage
                    give_type_set.value = 'none'; 
                end
            end

            %%% Stage Algorithim- nothing is happening here animal is just
            %%% doing trials with "anti" stimulus set
            
            %%% EOD logic- currently none animals are being manually
            %%% switched once anti-only performance is abouve ~85% for 5 or
            %%% so days, trial numbers are 250+ and violations are low
            %%% - ~15% or less for most animals
            
        case 14
            %%
            stage_description.value = 'pro-anti blocks with anti-give';

            %%% init
            % session init
            if value(n_trials_stage) == 0
                
                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'pro';
                presets.value = value(pro_preset);
                StimulusSection(obj, 'set_preset');
                give_type_set.value = 'none'; % pro trials get no give
                

                 % stage init
                if value(n_days_stage) <= 1 % stage init 
                    % when give is not none, make sure it's always given
                    give_frac.value = 1;
                    anti_give_type.value = 'light'; % anti get light give

                    % minimum number of trials to complete a block
                    % note pro-anti paper used 15
                    % can also sample from a gaussian for additional
                    % randomness
                    block_size.value = 15;
                    block_switch_type.value = 'static';
                    
                    % perf rate on last 10 trials that needs to be met
                    % start this at a low value so switches happen
                    % frequently to start
                    pro_anti_hit_threshold.value = 0.70;
                    pro_anti_viol_threshold.value = 0.30;
                end
            end

            %%% Stage Algorithim
            % check for block switch
            if value(n_trials_in_block) > value(block_size) && ...
                    value(Last10TrialPerf) > value(pro_anti_hit_threshold) && ...
                    value(Last10TrialViol) < value(pro_anti_viol_threshold)
                
                % implement block switch
                n_blocks.value = value(n_blocks) + 1;
                n_trials_in_block.value = 0;
                was_block_switch.value = 1;
                
                % if block size is set to sampled, get a new one
                if strcmp(value(block_switch_type), 'sampled')
                    randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                    block_size.value = round(randvalue);
                end
                
                if strcmp(value(pro_anti_block_type), 'pro') % pro -> anti
                    pro_anti_block_type.value = 'anti';
                    presets.value = value(anti_preset);
                    StimulusSection(obj, 'set_preset');
                    give_type_set.value = value(anti_give_type); % anti trials get give
                    give_type_implemented.value = value(anti_give_type); % turns it on for trial 1 in block
                    
                    
                else % anti -> pro
                    pro_anti_block_type.value = 'pro';
                    presets.value = value(pro_preset);
                    StimulusSection(obj, 'set_preset');
                    give_type_set.value = 'none'; % pro trials get no give                   
                end
            else
                if value(n_trials_stage) >= 1
                    n_trials_in_block.value = value(n_trials_in_block) + 1;
                    was_block_switch.value = 0;
                end
            end
            
            %%% EOD logic
            % No EOD logic- stay here for now!
%             if value(n_blocks) >= 7 && ...
%                     value(frac_correct_pro) > 0.75 &&...
%                     value(frac_correct_anti) > 0.75 &&...
%                     value(frac_violations) < 0.25
%                 TrainingSection(obj, 'increment_stage', 14);
%             end
        
        case 15 
            %%
            stage_description.value = 'pro-anti blocks with adaptive give delay';

            %%% init

            % session init
            if value(n_trials_stage) == 0
                
                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'pro';
                presets.value = value(pro_preset);
                StimulusSection(obj, 'set_preset');
                give_type_set.value = 'none'; % pro trials get no give
                give_del_growth.value = 'adaptive';
                
                % rest give delay dur to min if warming up
                if value(give_del_warm_up)
                    give_del_dur.value = value(give_del_min);
                end
                
                
                 % stage init
                if value(n_days_stage) <= 1 % stage init
                    
                    % init give delay dur params
                    give_del_dur.value = 0.001;
                    give_del_growth_trial_subset.value = 'anti';
                    give_delay_strict_mode.value = 1; % no incorrect answers allowed during delay
                    n_warm_up_trials.value = 30; % if warm up is turned on for an animal
                    
                    % set up distribui for exp delay for overnight sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);

                    % minimum number of trials to complete a block
                    % note pro-anti paper used 15, but I want to give
                    % animals more of a warm up to keep motivation higher
                    % can also sample from a gaussian for additional
                    % randomness
                    block_size.value = 15;
                    block_switch_type.value = 'static';
                    
                end
            end

            %%% Stage Algorithim
            % check for block switch
            if value(n_trials_in_block) > value(block_size) && ...
                    value(Last10TrialPerf) > value(pro_anti_hit_threshold) && ...
                    value(Last10TrialViol) < value(pro_anti_viol_threshold)
                   
                % implement block switch
                n_blocks.value = value(n_blocks) + 1;
                n_trials_in_block.value = 0;
                was_block_switch.value = 1;
                
                % if block size is set to sampled, get a new one
                if strcmp(value(block_switch_type), 'sampled')
                    randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                    block_size.value = round(randvalue);
                end
                
                if strcmp(value(pro_anti_block_type), 'pro') % pro -> anti
                    pro_anti_block_type.value = 'anti';
                    presets.value = value(anti_preset);
                    StimulusSection(obj, 'set_preset');
                    give_type_set.value = value(anti_give_type); % anti trials get give
                    give_type_implemented.value = value(anti_give_type); % turns it on for trial 1 in block

                    
                    % if block size is set to sampled, get a new one
                    if strcmp(value(block_switch_type), 'sampled')
                        randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                        block_size.value = randvalue;
                    end
                    
                    
                else % anti -> pro
                    pro_anti_block_type.value = 'pro';
                    presets.value = value(pro_preset);
                    StimulusSection(obj, 'set_preset');
                    give_type_set.value = 'none'; % pro trials get no give   
                    
                end
            else
                if value(n_trials_stage) >= 1
                    n_trials_in_block.value = value(n_trials_in_block) + 1;
                    was_block_switch.value = 0;
                end
            end
            
            %%% EOD logic-
%             if value(n_blocks) >= 7 && ...
%                     value(frac_correct_pro) > 0.75 &&...
%                     value(frac_correct_anti) > 0.75 &&...
%                     value(frac_violations) < 0.25
%                 TrainingSection(obj, 'increment_stage');
%             end
%              

        case 16
            %%
            stage_description.value = 'pro-anti blocks no guide';
            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'pro';
                presets.value = value(pro_preset);
                StimulusSection(obj, 'set_preset');


                if value(n_days_stage) <= 1 % stage init 
                    
                    % all guides off
                    give_type_set.value = 'none';
                    temp_error_penalty.value = 0;

                    % set up distribui for exp delay for sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);
                    
                    block_size.value = 20; 
                end
            end
                    
            %%% Stage Algorithim
            % check for block switch
            if value(n_trials_in_block) > value(block_size) && ...
                    value(Last10TrialPerf) > value(pro_anti_hit_threshold) && ...
                    value(Last10TrialViol) < value(pro_anti_viol_threshold)
                   
                % implement block switch
                n_blocks.value = value(n_blocks) + 1;
                n_trials_in_block.value = 0;
                was_block_switch.value = 1;
                
                % if block size is set to sampled, get a new one
                if strcmp(value(block_switch_type), 'sampled')
                    randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                    block_size.value = round(randvalue);
                end
                
                if strcmp(value(pro_anti_block_type), 'pro') % pro -> anti
                    pro_anti_block_type.value = 'anti';
                    presets.value = value(anti_preset);
                    StimulusSection(obj, 'set_preset');
                    
                    
                else % anti -> pro
                    pro_anti_block_type.value = 'pro';
                    presets.value = value(pro_preset);
                    StimulusSection(obj, 'set_preset');
                    
                end
            else
                if value(n_trials_stage) >= 1
                    n_trials_in_block.value = value(n_trials_in_block) + 1;
                    was_block_switch.value = 0;
                end
            end
        case 17
            %%
            stage_description.value = 'pro-anti blocks -> interleved';
            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
                
                % initialize in a pro block
                pro_anti_on.value = 1;
                pro_anti_block_type.value = 'pro';
                presets.value = value(pro_preset);
                StimulusSection(obj, 'set_preset');
                
                % initialize with a sampled block switch
                block_switch_type.value = 'sampled';
                randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                block_size.value = round(randvalue);
                
                % blocked trials have longer iti than random due to setting
                % stim preset being a bit slow and happening on every trial
                % in the random setting
                inter_trial_dur_type.value = 'sampled'; % gaussain
                inter_trial_min.value = 0.25; % seconds
                inter_trial_sample_mean.value = 1; 
                inter_trial_max.value = 5; 
                inter_trial_sample_std.value = 0.5; 

                if value(n_days_stage) <= 1 % stage init 
                    
                    % all guides off
                    give_type_set.value = 'none';
                    temp_error_penalty.value = 0;

                    % set up distribui for exp delay for sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);
                    
                    % initialize block sampling
                    DistribInterface(obj, 'set', 'blk_size_gaus', 'Min', 10);
                    DistribInterface(obj, 'set', 'blk_size_gaus', 'Max', 25);
                    DistribInterface(obj, 'set', 'blk_size_gaus', 'Mu',  15);
                    DistribInterface(obj, 'set', 'blk_size_gaus', 'Sd',  2); 
                   
                    % how many blocks until random and slight bias to pro
                    % in random to start
                    max_blocks.value = 7;
                    pro_prob.value = 0.6;
                end
            end
                    
            %%% Stage Algorithim
            %% Blocked
            if value(n_blocks) < value(max_blocks)
                % check for block switch
                if value(n_trials_in_block) > value(block_size) && ...
                        value(Last10TrialPerf) > value(pro_anti_hit_threshold) && ...
                        value(Last10TrialViol) < value(pro_anti_viol_threshold)

                    % implement block switch
                    n_blocks.value = value(n_blocks) + 1;
                    n_trials_in_block.value = 0;
                    was_block_switch.value = 1;

                    % if block size is set to sampled, get a new one
                    if strcmp(value(block_switch_type), 'sampled')
                        randvalue = DistribInterface(obj, 'get_new_sample', 'blk_size_gaus');
                        block_size.value = round(randvalue);
                    end

                    if strcmp(value(pro_anti_block_type), 'pro') % pro -> anti
                        pro_anti_block_type.value = 'anti';
                        presets.value = value(anti_preset);
                        StimulusSection(obj, 'set_preset');


                    else % anti -> pro
                        pro_anti_block_type.value = 'pro';
                        presets.value = value(pro_preset);
                        StimulusSection(obj, 'set_preset');

                    end
                else
                    if value(n_trials_stage) >= 1
                        n_trials_in_block.value = value(n_trials_in_block) + 1;
                        was_block_switch.value = 0;
                    end
                end
                
            %% Random
            else
                block_switch_type.value = 'none';
                
                % make iti shorter because setting presets is a little slow
                inter_trial_min.value = 0.05; % seconds
                inter_trial_sample_mean.value = 0.3; 
                inter_trial_max.value = 1.5; %DB 30
                inter_trial_sample_std.value = 0.25;
                
                % get random sample and set type based on th at
                p = rand(1);
                if p < value(pro_prob)
                    
                    pro_anti_block_type.value = 'pro';
                    presets.value = value(pro_preset);
                    StimulusSection(obj, 'set_preset');
                else
                    pro_anti_block_type.value = 'anti';
                    presets.value = value(anti_preset);
                    StimulusSection(obj, 'set_preset');
                end
                
            end
            
            %% EOS

        end %stage number

       
    %---------------------------------------------------------------%
    %          get_eod_logic                                        %
    %---------------------------------------------------------------%
    % If this curriculum is selected, this is run during the `end_session`
    % case from TrainingSection. This is where you put stage specific end
    % of day logic.
    %
    % For example, if you want an animal to move to a stage only at the end
    % of the day, rather than within a session, you would put that here.
    %
    case 'get_eod_logic'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        case 10
            % if animal does above chance on no-give trials, decrease the
            % number of no-give trials
            if value(give_frac) == 1 % first day in stage
                give_frac.value = value(inital_give_frac);
            elseif value(frac_correct_no_give) > value(no_give_perf_threshold)
                give_frac.value = value(give_frac) - value(give_frac_decrease_rate);
            end
            
            % select a new delay value for tomorrow given params 
            if strcmp(value(delay_growth), 'overnight_sampled')
                randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
                delay_dur.value = randvalue;
            end
            
            
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function


%% TS_JB_m_classic
% Training Section; Jess Breda; Mice; Classic
% 
% This curriculum starts with light & water guided side poking with a go 
% cue where each day is a single side. Then it moves into random side 
% poking after L/R blocks to ensure light chasing is happening. 
% Once that is established, it moves into C -> S motor learning with a
% longer than expected fixation length to start. These trials are blocked
% then blocked -> random, then fully random. Once performance is stable and
% above chance, the center fixation will start to grow. Once grown ~1.4
% seconds, sounds will start to play and there will be a transition to the
% sound rule.
% 
%
% Stage 1: Poke Left
%   In left side port, go cue plays, light turns on and fraction of water 
%   reward idelivered. Animals have to answer within wait_for_spoke_tup, 
%   otherwise will move to next trial. ITIs are very long so that animal
%   learns the association between go -> light/water -> reward. There is 
%   control to make sure no more water is given until animal drinks from 
%   the port. If an animal answers incorrectly, it will be recorded, but
%   there is no penalty.
% 
% Stage 2: Poke right
%   Same thing as stage 1, but for the right side. Stage 1 and stage 2
%   alternate days until they are both completed (e.g. an animal can
%   complete stage 2 before they complete stage 1). 
% 
% Stage 3: Poke Left/Right Blocks
%   Same trial structure as stage 1 and 2, but rather than having L/R be
%   switching over sessions, they will be in blocks of a specified size.
%   The ITI is also slightly shorter here (~25 seconds). If an animal
%   answers incorrectly here, the trial will clean up (but they can drink
%   the give water).
%   
% Stage 4: Poke Left/Right Blocks -> Random
%   Same trial structure as stage 3 but after a specified number of trials,
%   the blocks will end and it becomes random L/R. The ITI will be
%   slightly shorter here (~20 seconds).
%  
% Stage 5: Center to side, blocked
%   Now the animal know to follow light and water guides, we introduce the
%   primary motor patter. A light comes on in the center port to indicate 
%   trial availibility. The settling in dur for this stage will be quite
%   long (~300 ms), so an animal needs to learn to hold their nose in the
%   port in order to get the go sound -> light guide. The center light does
%   not turn off until the go sound plays (ie is not grocked to the
%   animal's movements). TBD on reward structure. Blocks of ~20 L/R trials
%
% Stage 6: Center to side, blocked -> random
%   Same as stage 4, but the blocks will only be for the first ~50-60
%   trials before switching to random. Sa/sb replay turns on here.
%
% Stage 7: Center to side, random
%   Same as stage 4 & 5, but the L/R are drawn at random
%
% Stage 8: Grow nose poke
%   In this stage, the settling in dur starts to increase on each valid
%   trial. If an animal pokes out early (violates), nothing happens. The
%   light stays on until they should have stayed and no go cue plays. In
%   other words, if they poke out where the c led is still on/the go cue
%   hasn't get played, they get no reward. The rate of growth will vary
%   from animal to animal. Animals will start at half of the previous days
%   growth value. Growth can be stopped within this stage if needed (it's 
%   only initated on day 0). Temp error is off.
%
%
% Stage 9: Introduce sounds
%   In this stage, sa and sb with a delay between and after will start to
%   play. The rough timing is 0.25-0.2-0.2-0.2-0.4 for pre-sa-del-sb-post
%   All features from previous stages are still in use.
%
% Stage 10: Remove light give (in progress)
%   In this stage, we will remove the light give so that animal will rely 
%   on the subtler water give, and/or the sounds. This can be done in two
%   ways (1) reduce the fraction of trials where light give is happening,
%   or (2) delay the light give over time. Reward structure is TBD 
%
% Stage 11: Remove water give (in progress)
%   Same as above, but with water.
%
% Stage 12: Require sounds (in progress)
%   Same as 10, but give is now really off and the animals are punished for
%   incorrect answers
%

function varargout = TS_JB_m_classic(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values 
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1: L poke',...
            '2: R poke',...
            '3: Spoke block',...
            '4: Spoke block to rand',...
            '5: C -> Spoke block',...
            '6: C -> Spoke block to rand',...
            '7: C -> Spoke rand',...
            '8: C -> Spoke w/ Viol',...
            '9: Introduce sa,sb',...
            '10: Remove light give',...
            '11: Remove water give',...
            '12: Require sounds',...
            '13: TBD' 
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
        case 1
            %%
            stage_description.value = 'gc,light, water, left poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 1;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init
                    replay_on.value = 0;
    
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 40; 
                    inter_trial_max.value = 60; %DB 60
                    inter_trial_sample_std.value = 5;
                    
                    % document incorrect pokes, but no penalty. animal can
                    % retry untill correct answer or Tup
                    temp_error_penalty.value = 1;
                    retry_type.value = 'multi';
                    temp_error_dur.value = 0.001;          
                end
            end

            %%% EOS logic
            % DB 3 -> 40
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.15
                left_poke_stage_complete.value = 1;
                
                if right_poke_stage_complete
                    TrainingSection(obj, 'increment_stage', 3);
                else
                    TrainingSection(obj, 'increment_stage', 2);
                end
            end 
            
        case 2
            %%
            stage_description.value = 'gs, light, water, right poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 0;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;

                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 40; 
                    inter_trial_max.value = 60; %DB 60
                    inter_trial_sample_std.value = 5;
                    
                    % document incorrect pokes, but no penalty. animal can
                    % retry untill correct answer or Tup
                    temp_error_penalty.value = 1;
                    retry_type.value = 'multi';
                    temp_error_dur.value = 0.001; 
                end
            end

            %%% EOS logic
            %DB -> 40
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.15

                right_poke_stage_complete.value = 1;
                
                if left_poke_stage_complete
                    TrainingSection(obj, 'increment_stage', 3);
                else
                    TrainingSection(obj, 'increment_stage', 1);
                end
            end

        case 3
            %%
            stage_description.value = 'r/l blocks, iti less long';
           
            %%% init
            if value(n_trials_stage) == 0 % session init
                
                %%% dont want them to learn rapid L/R strategy so turnining 
                %%% water give off. <- this is too harsh from the start. will
                %%% turn if off later
                %give_type_set.value = 'light'; 
                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init
                    give_type_set.value = 'light';
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 7; % seconds
                    inter_trial_sample_mean.value = 12; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 1.5;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                end
            end
            
            %%% Stage Algorithim - blocks of L/R trials
            % initialize session in a L or R block
            if value(n_trials_stage) == 0 
                p = rand(1);
                if p < 0.5
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                else 
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                end
            
            % check to see if time for block switch
            elseif rem(value(n_trials_stage), value(block_size)) == 0
                was_block_switch.value = 1;
                if value(in_left_block) % switch to right
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                elseif value(in_right_block) % switch to left
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                end
            else
                was_block_switch.value = 0;
            end

            %%% EOS logic- TODO!
            % DB trials_end
            trials_end = min(value(block_size) * 6, 100);
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.9 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end
            
        case 4
            %%
            stage_description.value = 'r/l blocks -> random';
           
            %%% init
            if value(n_trials_stage) == 0 % session init

                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;       
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 6; % seconds
                    inter_trial_sample_mean.value = 9; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 1.5;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % make sure antibias is on when in random and that beta
                    % ramps up from 0 to 3 over tau trials
                    Beta.value = 3;
                    betaRampup.value = 1;
                    
                end
            end
            
            %%% Stage Algorithim - blocks of L/R trials
            % initialize session in a L or R block
            if value(n_trials_stage) == 0 
                coin_flip = rand(1);
                if coin_flip < 0.5
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                else 
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                end
            
            % check to see if we need to move from blocks to random
            elseif value(n_trials_stage) >= value(blocks_end)
                    was_block_switch.value = 0;
                    in_left_block.value = 0;
                    in_right_block.value = 0;
                    LeftProb.value = 0.5;
            
            % if still in blocks, check to see if time for block switch
            elseif rem(value(n_trials_stage), value(block_size)) == 0
                was_block_switch.value = 1;
                if value(in_left_block) % switch to right
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                elseif value(in_right_block) % switch to left
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                end
            else
                was_block_switch.value = 0;
            end


            %%% EOS logic- TODO!
            % DB trials_end -> 10
            trials_end = min(value(blocks_end) + 50, 150);
            % ! could switch from frac_correct to last 50 trials?
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.8 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end

        case 5
            %%
            stage_description.value = 'c->s blocks';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;
                fixation_required.value = 1;

                if value(n_days_stage) <= 1 % stage init 

                    % set these incase coming back from a higher stage
                    replay_on.value = 0;
                     
                    % trial timing
                    % in this set of stages, settling_in_dur is how long 
                    % the animal needs to poke to trigger go cue. If they 
                    % don't poke for this duration, nothing happens. Failed
                    % poke metrics are tracked in History Section
                    settling_in_dur.value = 0.4; 
                    pre_dur.value = 0.001;
                    stimulus_dur.value = 0.001;
                    delay_dur.value = 0.001;
                    post_dur.value = 0.001;
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 3; % seconds
                    inter_trial_sample_mean.value = 6; 
                    inter_trial_max.value = 15; %DB 15
                    inter_trial_sample_std.value = 1; 

                    % incorrect pokes get no full reward
                    temp_error_penalty.value = 0;


                    % update delay overnight to match the animals cpoke
                    % duration
                    delay_growth.value = 'overnight_growth';
                    % set up distribui for exp delay for overnight sample
                    % if animal has reached max fixation reqs.
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.8);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   2);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   1.3);

                end
            end

            %%% Stage Algorithim - blocks of L/R trials
            % initialize session in a L or R block
            if value(n_trials_stage) == 0 
                p = rand(1);
                if p < 0.5
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                else 
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                end
            
            % check to see if time for block switch
            elseif rem(value(n_trials_stage), value(block_size)) == 0
                was_block_switch.value = 1;
                if value(in_left_block) % switch to right
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                elseif value(in_right_block) % switch to left
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                end
            else
                was_block_switch.value = 0;
            end
            
            %%% EOS logic %DB 100 -> 10
            if value(n_trials_stage) > 100 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.75
                TrainingSection(obj, 'increment_stage');
            end
        
        case 6
            %%
            stage_description.value = 'c->s blocks -> random';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0; 

                if value(n_days_stage) <= 1 % stage init 
                    
                    replay_on.value = 1; % replay on here for the first time

                    % trial timing
                    % in this set of stages, settling_in_dur is how long 
                    % the animal needs to poke to trigger go cue. If they 
                    % don't poke for this duration, nothing happens. Failed
                    % poke metrics are tracked in History Section
                    pre_dur.value = 0.001;
                    stimulus_dur.value = 0.001;
                    delay_dur.value = 0.001;
                    post_dur.value = 0.001;
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 3; % seconds
                    inter_trial_sample_mean.value = 6; 
                    inter_trial_max.value = 15; %DB 15
                    inter_trial_sample_std.value = 1; 

                    % incorrect pokes get no full reward
                    temp_error_penalty.value = 0;
                    
                end
            end

            %%% Stage Algorithim - blocks of L/R trials
            % initialize session in a L or R block
            if value(n_trials_stage) == 0 
                coin_flip = rand(1);
                if coin_flip < 0.5
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                else 
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                end
            
            % check to see if we need to move from blocks to random
            elseif value(n_trials_stage) >= value(blocks_end)
                    was_block_switch.value = 0;
                    in_left_block.value = 0;
                    in_right_block.value = 0;
                    LeftProb.value = 0.5;
            
            % if still in blocks, check to see if time for block switch
            elseif rem(value(n_trials_stage), value(block_size)) == 0
                was_block_switch.value = 1;
                if value(in_left_block) % switch to right
                    in_left_block.value = 0;
                    in_right_block.value = 1;
                    LeftProb.value = 0;
                elseif value(in_right_block) % switch to left
                    in_left_block.value = 1;
                    in_right_block.value = 0;
                    LeftProb.value = 1;
                end
            else
                was_block_switch.value = 0;
            end


            %%% EOS logic- TODO!
            % DB trials_end -> 10
            trials_end = min(value(blocks_end) + 60, 120);
            % ! could switch from frac_correct to last 50 trials?
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.85 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end

        case 7
            %%
            stage_description.value = 'c->s random';
            
            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 

                    % trial timing
                    % in this set of stages, settling_in_dur is how long 
                    % the animal needs to poke to trigger go cue. If they 
                    % don't poke for this duration, nothing happens. Failed
                    % poke metrics are tracked in History Section
                    pre_dur.value = 0.001;
                    stimulus_dur.value = 0.001;
                    delay_dur.value = 0.001;
                    post_dur.value = 0.001;
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 3; % seconds
                    inter_trial_sample_mean.value = 6; 
                    inter_trial_max.value = 15; %DB 15
                    inter_trial_sample_std.value = 1; 

                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % make sure blocks are off
                    in_left_block.value = 0;
                    in_right_block.value = 0;
                    LeftProb.value = 0.5;
                    was_block_switch.value = 0;
                end
            end

            %%% Stage Algorithim -
            % nothign happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inherited from previous stage,
            % replay is on. 
            
            %%% EOS logic
            if value(n_trials_stage) > 110 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                
                % set they delay dur for the next stage based on the
                % current avg cpoke length
                cpoke_durs = get_sphandle('name', 'cpoke_dur_history');
                delay_dur.value = mean(value(cpoke_durs{1}), 'omitnan') - 0.25;
                TrainingSection(obj, 'increment_stage');
            end 
            
        case 8
            %%
            stage_description.value = 'c->s w/ viol';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 

                    % trial timing- now violations are a thing
                    if value(delay_dur) == 0.001 % if manually moved here
                        delay_dur.value = value(settling_in_dur) - 0.25; % add to rats
                    end
                    
                    settling_in_dur.value = 0.25;
                    pre_dur.value = 0.001;
                    adjusted_pre_dur.value = 0.001;
                    stimulus_dur.value = 0.001;
                    post_dur.value = 0.001;
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 1; % seconds
                    inter_trial_sample_mean.value = 2; 
                    inter_trial_max.value = 5; %DB 12
                    inter_trial_sample_std.value = 0.5; 

                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;

                end
            end

            %%% Stage Algorithim -
            % nothign happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inherited from previous stage,
            % replay is on and delay dur is set by the EOS logic.
            
            %%% EOS logic
            if value(n_trials_stage) > 150 && value(frac_violations) < 0.20 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
            end 

        case 9
            %%
            stage_description.value = 'turn sound on & up';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;
          

                if value(n_days_stage) <= 1 % stage init 
                    % volume multiplier
                    % in this stage,sounds begin to play. we will play them
                    % softly to start (so they don't trigger an animal to
                    % move thinking it's the go cue)
                    volume_multiplier.value = 0.4;
                    
                    % trial timing, now sound will play
                    stimulus_min.value = 0.03;
                    stimulus_dur.value = value(stimulus_min);
                    stimulus_max.value = 0.3; % 0.4 for rats
                    settling_in_dur.value = 0.25;
                    pre_dur.value = 0.25; % settling in will count for pre_dur
                    post_dur.value = 0.45;
                    
                    % growth- the sounds are slowly going to grow from
                    % trial 1 -> session end. As they become longer, the
                    % delay dur will be shorter to keep a stable fixation
                    % length.
                    stimulus_growth.value = 'fill_delay';
                    stimulus_fixed_growth_rate.value = 0.002;
                    stimulus_fixed_growth_unit.value = 's';
                    stimulus_warm_up.value = 0;
                    delay_dur.value = max(value(delay_dur), 0.8);
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 0.25; % seconds
                    inter_trial_sample_mean.value = 1; 
                    inter_trial_max.value = 5; 
                    inter_trial_sample_std.value = 0.5; 

                    % incorrect pokes don't get full reward & errors have a
                    % timeout penalty
                    temp_error_penalty.value = 0;
                    error_dur.value = 2;
                    
                    % water and light should be the give type if wanting to
                    % wean animals to water only
                    give_type_set.value = 'water_and_light';
                    
                    % set up distribui for exp delay for overnight sample
                    % knowing that sounds are now included in fixation
                    delay_growth.value = 'overnight_sampled';
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.8);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   1.2);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   1);
                end
                
                % each session, restart the growth., note that stimulus_min
                % can grow overnight if performance is good
                stimulus_dur.value = value(stimulus_min); 
                
            end
            
            %%% Stage Algorithim -
            % nothign happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inherited from previous stage,
            % replay is on and sound volume/duration is set on a trial by
            % trial basis for growth and overnight
            
            %%% EOD logic
            if (value(frac_violations) < 0.30) && (value(frac_correct) > 0.85) && ...
                    (value(volume_multiplier) == 1) && (value(stimulus_dur) == 0.3)
                TrainingSection(obj, 'increment_stage');
            end
        case 10
            %%
            stage_description.value = 'timings stable, decrease give';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 
                    
                    % modify stimulus growth and timing from previous stage
                    % where the sounds were growing in duration & volume
                    % volume multiplier ensure full
                    volume_multiplier.value = 1;
                    stimulus_dur.value = 0.3;
                    stimulus_min.value = 0.2;
                    stimulus_growth.value = 'none';
                    
                    % initialize give frac (probabilistic) at full value
                    give_type_set.value = 'water_and_light';
                    give_frac.value = 1;
                    inital_give_frac.value = 0.60; % after day 1, what will the give frac drop to from 1
                    give_frac_decrease_rate.value = 0.15; % what will inital give frac decreae by
                    no_give_perf_threshold.value = 0.70; % threshold to decrease give frac                     
                    
                    % set up distribui for exp delay for overnight sample
                    % if it is selected, but defualt is a stable, short delay
                    delay_growth.value = 'none';
                    delay_dur.value = 0.15;
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.6);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.2);
                    
                    % errors have time out penalty
                    error_dur.value = 4;
                    
                end    
            end
            
            %%% Stage Algorithim -
            % nothing happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inited to water, repaly is on.
            % delay between sounds is short & stable on init. can be
            % switched to jitter overnight. give frac will change overnight
            % is performance on non-give trials is good enough. After day 1
            % the give rate dops to the init value (%60)
            
            %%% EOD logic
            if value(n_trials_stage) > 50 && value(give_frac) < 0.25 &&...
                    value(frac_correct_no_give) > value(no_give_perf_threshold) &&...
                    value(frac_violations) < 0.3
                TrainingSection(obj, 'increment_stage');
            end
            

        case 11
            %%
            % TBD- stimulus may need to be modified in previous stage to be
            % a smaller subset
            stage_description.value = 'give off';
            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;
                LeftProb.value = 0.5;

                if value(n_days_stage) <= 1 % stage init 
                    
                    give_type_set.value = 'none';
                end    
            end
            
 
            
                
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
    % TODO what happens if the stage number you called isn't here?
    case 'get_eod_logic'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        case 1
            % Can only get here if you did not complete the stage and
            % transition within the session. Let's check if we can move to
            % stage 2 to balance the sides R/L across days. If it's already
            % complete, we will stay in stage 1 until it's completed.
            if ~right_poke_stage_complete
                TrainingSection(obj, 'increment_stage', 2);
            end
                
        case 2
            % Same as stage 1, but reversed.
            if ~left_poke_stage_complete
                TrainingSection(obj, 'increment_stage', 1);
            end
        case {5, 6, 7}

            % don't need animals fixating more than 2s and over-growing
            % themselves
            cpoke_durs = get_sphandle('name', 'cpoke_dur_history');
            avg_cpoke_dur = mean(value(cpoke_durs{1}), 'omitnan');
            if avg_cpoke_dur > 2.15 && ~strcmp(value(delay_growth), 'none')
                delay_growth.value = 'overnight_sampled';
            end
            
            if value(n_trials_stage) > 40 && strcmp(value(delay_growth), 'overnight_growth')
                % If animal is engaged (measured by trial rate), set the
                % requirements of tomorrow's cpoke fixation based on thier
                % average poke duration today.
                settling_in_dur.value = avg_cpoke_dur;
            elseif strcmp(value(delay_growth), 'overnight_sampled')
                randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
                settling_in_dur.value = randvalue;
            end
        
        case 8
            % If an animal has low violations, set the requirements of
            % tomorrow's cpoke fixation based on their average poke
            % duration today. TODO: update this to filter for valid pokes
            % first.
            if value(frac_violations) < 0.4
                % don't need animals fixating more than 2s and over-growing
                % themselves
                cpoke_durs = get_sphandle('name', 'cpoke_dur_history');
                avg_cpoke_dur = mean(value(cpoke_durs{1}), 'omitnan');
                if avg_cpoke_dur > 2.15 && ~strcmp(value(delay_growth), 'none')
                    delay_growth.value = 'overnight_sampled';
                end
                if strcmp(value(delay_growth), 'overnight_growth')
                    delay_dur.value = max(0.25, avg_cpoke_dur - value(settling_in_dur));
                elseif strcmp(value(delay_growth), 'overnight_sampled')
                    randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
                    delay_dur.value = randvalue;
                end
            end
            
        case 9
            % if animal did pretty well, increase the starting length of
            % the sounds, once those are full, increase the volume
            % NOTE this assumes desired stim length is 0.3 s and growth by
            % 0.15 overnight is good
            if value(frac_violations) < 0.4 
               if value(stimulus_min) < 0.3
                   stimulus_min.value = min(0.3, (value(stimulus_min) + 0.15)); % TODO make this an SPH
               else
                   volume_multiplier.value = min(1, (value(volume_multiplier) + 0.25)); 
               end
            end
            
            % select a new delay value for tomorrow given params 
            if strcmp(value(delay_growth), 'overnight_sampled')
                randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
                delay_dur.value = randvalue;
            end

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


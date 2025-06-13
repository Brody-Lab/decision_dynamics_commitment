%% TS_JB_r_goguide
% Training Section; Jess Breda; Rats ; Go Guide
% 
% This curriculum starts with light & water guided side poking with a 
% directional go cue where each day is a single side. As soon as an animal 
% appears engaged. The light guide goes away and it's only sound & water
% guide. Once it's clear go sound guide is being used, spoking switch to
% blocks of L & R trials, eventually moving into a blocks -> random.
% Once that is established, it moves into C -> S motor learning with a
% longer than expected fixation length to start. These trials are blocked
% then blocked -> random, then fully random. During this period, fixation
% is growing overnight to the duration of the average cpoke from they day
% before. Once an animal has made it to random L/R in this regime,
% violations are turned on (prev just settling in). Then, sounds will start
% to play. Finally there is a transition to the sound rule.
%
% NOTE this is very similar to JB_r_classic, but it has extra things
% happening in the spoke stages for go sound guidance and a slightly
% different transition to the sound rule.
%
% Stage 1: Poke Left (light + sound + water)
%   In left side port, go cue plays, light turns on and fraction of water 
%   reward idelivered. Animals have to answer within wait_for_spoke_tup, 
%   otherwise will move to next trial. ITIs are very long so that animal
%   learns the association between go -> light/water -> reward. There is 
%   control to make sure no more water is given until animal drinks from 
%   the port. If an animal answers incorrectly, it will be recorded, but
%   there is no penalty.
% 
% Stage 2: Poke right (light + sound + water)
%   Same thing as stage 1, but for the right side. Stage 1 and stage 2
%   alternate days until animal is answering on half the trials, then the
%   light guide is turned off to ensure animal is learning go cue guide in
%   stage 3/4.
%
% Stage 3: Poke left (sound + water)
%   Same as stage 1, but without light guide. Animal moves to stage 5 once
%   3 and 4 are completed.
%
% Stage 4: Poke right (sound + water)
%   Same as stage 2, but without light guide.Animal moves to stage 5 once
%   3 and 4 are completed.
%
% Stage 5: Poke Left/Right Blocks
%   Same trial structure as stage 3 and 4, but rather than having L/R be
%   switching over sessions, they will be in blocks of a specified size.
%   The ITI is also slightly shorter here (~20 seconds). If an animal
%   answers incorrectly here, the trial will clean up. Give water also
%   turns off here (TBD if this is the right call)
%   
% Stage 6: Poke Left/Right Blocks -> Random
%   Same trial structure as stage 5 but after a specified number of trials,
%   the blocks will end and it becomes random L/R. The ITI will be
%   shorter here (~10 seconds). 
%  
% Stage 7: Center to side, blocked
%   Now the animal know to follow sound and water guides, we introduce the
%   primary motor patter. A light comes on in the center port to indicate 
%   trial availibility. The settling in dur for this stage will be quite
%   long (~400 ms), so an animal needs to learn to hold their nose in the
%   port in order to get the go sound -> light guide. The center light does
%   not turn off until the go sound plays (ie is not grocked to the
%   animal's movements).Blocks of ~20 L/R trials. Settling in dur grows
%   over night grocked to avg cpoke dur. Sa/sb replay also turns on here.
%
% Stage 8: Center to side, blocked -> random
%   Same as stage 7, but the blocks will only be for the first ~50-60
%   trials before switching to random.
%
% Stage 9: Center to side, random
%   Same as stage 7 & 8, but the L/R are drawn at random. 
%
% Stage 10: Center to side, random with violations
%   Same as stage 9, but settling in dur is now shorter (~25 ms) and
%   fixation time is replaced with delay period. Violations are now a thing
%   so if an animal pokes out early, the trial cleans up.
%
%
% Stage 11: Introduce sounds
%   In this stage, sa and sb with a delay between and after will start to
%   play. The rough timing is 0.25-0.4-0.2-0.4-0.45 for pre-sa-del-sb-post
%   All features from previous stages are still in use. The sounds will
%   start at 30 ms and grow to ~400 ms within a session. The volume of the
%   sa/sb sounds will grow overnight. Growth is dependent on violation
%   rate.
%
% Stage 12 +: Remove go sound guide and switch to requiring sa/sb

function varargout = TS_JB_r_goguide(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values 
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1: L poke l+s+w',...
            '2: R poke l+s+w',...
            '3: L poke s+w'...
            '4: R poke s+w',...
            '5: Spoke block',...
            '6: Spoke block to rand',...
            '7: C -> Spoke block',...
            '8: C -> Spoke block to rand',...
            '9: C -> Spoke rand',...
            '10: C -> Spoke w/ Viol',...
            '11: Introduce sa,sb',...
            '12: Decrease sound give',...
            '11: TBD',...
            '12: TBD',...
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
            stage_description.value = 'loc gs, light, water, left poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 1;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init
                    replay_on.value = 0;
    
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds %DB 10
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
            % DB 40
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.5
                spoke_motivated_stage_complete.value = 1;
                TrainingSection(obj, 'increment_stage', 3);
            end
            
        case 2
            %%
            stage_description.value = 'loc gs, light, water, right poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 0;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
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
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.5
                spoke_motivated_stage_complete.value = 1;
                TrainingSection(obj, 'increment_stage', 4);
            end
        case 3
            %%
            stage_description.value = 'loc gs, water, left poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 1;
                give_type_set.value = 'water';
                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;

                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 30; 
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
            %DB -> 60
            if value(n_trials_stage) >= 60 && value(frac_no_answer) < 0.15

                left_poke_stage_complete.value = 1;
                
                if value(right_poke_stage_complete)
                    TrainingSection(obj, 'increment_stage', 5);
                else
                    TrainingSection(obj, 'increment_stage', 4);
                end
            end
    
        case 4
            %%
            stage_description.value = 'loc gs, water, right poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 0;
                give_type_set.value = 'water';
                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;

                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 30; 
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
            %DB -> 60
            if value(n_trials_stage) >= 60 && value(frac_no_answer) < 0.15

                right_poke_stage_complete.value = 1;
                
                if value(left_poke_stage_complete)
                    TrainingSection(obj, 'increment_stage', 5);
                else
                    TrainingSection(obj, 'increment_stage', 3);
                end
            end

        case 5
            %%
            stage_description.value = 'r/l blocks, iti less long';
           
            %%% init
            if value(n_trials_stage) == 0 % session init
                
                % dont want them to learn rapid L/R strategy so turnining 
                % water give off <- this is too harsh, relaxing it for now
                % give_type_set.value = 'light'; 
                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init 
                    give_type_set.value = 'none';
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 20; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 2;
                    
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

            %%% EOS logic!
            % DB trials_end
            trials_end = min(value(block_size) * 10, 200);
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.9 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end
            
        case 6
            %%
            stage_description.value = 'r/l blocks -> random';
           
            %%% init
            if value(n_trials_stage) == 0 % session init

                SMA_set.value = 'spoke';
                go_type.value = 'sound_localized';
                stimuli_on.value = 0;       
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 6; % seconds
                    inter_trial_sample_mean.value = 10; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 2;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % make sure antibias is on when in random
                    Beta.value = 3;
                    
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


            %%% EOS logic
            % DB trials_end
            trials_end = min(value(blocks_end) + 75, 250);
            % ! could switch from frac_correct to last 50 trials?
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.8 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end

        case 7
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
                    replay_on.value = 1; % replay on here for the first time
                     
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
                    inter_trial_min.value = 5; % seconds
                    inter_trial_sample_mean.value = 10; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 2;

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
            
            %%% EOS logic %DB 250
            if value(n_trials_stage) > 250 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.9
                TrainingSection(obj, 'increment_stage');
            end
        case 8
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
                    inter_trial_sample_mean.value = 8; 
                    inter_trial_max.value = 15; %DB 15
                    inter_trial_sample_std.value = 1; 

                    % incorrect pokes get no reward
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
            trials_end = min(value(blocks_end) + 150, 300);
            % ! could switch from frac_correct to last 50 trials?
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.9 && ...
                    value(frac_no_answer) < 0.1
                TrainingSection(obj, 'increment_stage')
            end

        case 9
            %%
            stage_description.value = 'c->s random';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;

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
                    inter_trial_sample_mean.value = 5; 
                    inter_trial_max.value = 10; %DB 10
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
            % DB 300
            if value(n_trials_stage) > 300 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.9

                % set they delay dur for the next stage based on the
                % current avg cpoke length
                cpoke_durs = get_sphandle('name', 'cpoke_dur_history');
                delay_dur.value = mean(value(cpoke_durs{1}), 'omitnan') - 0.25;
                TrainingSection(obj, 'increment_stage');
            end
        case 10
            %%
            stage_description.value = 'c->s w/ viol';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;

                if value(n_days_stage) <= 1 % stage init 

                    % trial timing- now violations are a thing
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
                    inter_trial_max.value = 5; %DB 5
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
            % DB 350
            if value(n_trials_stage) > 350 && value(frac_violations) < 0.20 && ...
                    value(frac_correct) > 0.9
                TrainingSection(obj, 'increment_stage');
            end 
            % this stage assumes that delay will change overnight
            % next stage, sounds will be introduced

        case 11
            stage_description.value = 'turn sound on & up';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 1;

                if value(n_days_stage) <= 1 % stage init 
                    % volume multiplier
                    % in this stage,sounds begin to play. we will play them
                    % softly to start (so they don't trigger an animal to
                    % move thinking it's the go cue)
                    volume_multiplier.value = 0.4;
                    
                    % trial timing, now sound will play
                    stimulus_min.value = 0.03;
                    stimulus_dur.value = value(stimulus_min);
                    stimulus_max.value = 0.4; % maybe set to 0.3?
                    settling_in_dur.value = 0.25;
                    pre_dur.value = 0.25; % settling in will count for pre_dur
                    post_dur.value = 0.45;
                    
                    % growth- the sounds are slowly going to grow from
                    % trial 1 -> session end. As they become longer, the
                    % delay dur will be shorter to keep a stable fixation
                    % length.
                    stimulus_growth.value = 'fill_delay';
                    stimulus_fixed_growth_rate.value = 0.0015;
                    stimulus_fixed_growth_unit.value = 's';
                    stimulus_warm_up.value = 0;
                    delay_dur.value = max(value(delay_dur), 1);
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 1; % seconds
                    inter_trial_sample_mean.value = 2; 
                    inter_trial_max.value = 5; %DB 5
                    inter_trial_sample_std.value = 0.5; 

                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % set up distribui for exp delay for overnight sample
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   1);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   2);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   1.25);
                end
                
                % each session, restart the growth
                stimulus_dur.value = value(stimulus_min);
                
            end
            
            %%% Stage Algorithim -
            % nothign happening here that isn't controlled by the GUI/SMA.
            % L/R trials are random, give is inherited from previous stage,
            % replay is on and sound volume/duration is set on a trial by
            % trial basis for growth and overnight
            
            %%% EOD logic (todo)
            if (value(frac_violations) < 0.30) && (value(frac_correct) > 0.85) && ...
                    (value(volume_multiplier) == 1) && (value(stimulus_dur) > 0.3)
                TrainingSection(obj, 'increment_stage');
            end
        case 12
            
            
            
            % next stage: start to remove the light, delay changes
            % overnight, stimulus dur is stable
             
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
        
        % until animal is motivated, switch back and forth between left and
        % right until they move into stage 3
        case 1
            if ~value(spoke_motivated_stage_complete)
                TrainingSection(obj, 'increment_stage', 2);
            end
                
        case 2
            if ~value(spoke_motivated_stage_complete)
                TrainingSection(obj, 'increment_stage', 1);
            end
            
        % Can only get here if you did not complete the stage and
        % transition within the session. Let's check if we can move to
        % stage 4 to balance the sides R/L across days. If it's already
        % complete, we will stay in stage 3 until it's completed.
        case 3
            if ~value(right_poke_stage_complete)
                TrainingSection(obj, 'increment_stage', 4);
            end
        case 4
            % Same as stage 3, but reversed.
            if ~value(left_poke_stage_complete)
                TrainingSection(obj, 'increment_stage', 3);
            end
        
        % TODO end of seeion logic for cpoke stages 6 -> 10
        case 11
            % if animal did pretty well, increase the volume of the sounds
            if value(frac_violations) < 0.4 
               volume_multiplier.value = min(1, (value(volume_multiplier) + 0.2));           
            end
            
            % select a new delay value for tomorrow given params 
            %(params inited to min 1, max 2, tau 1.25)
            randvalue = DistribInterface(obj, 'get_new_sample', 'exp_delay');
            delay_dur.value = randvalue;
            
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function


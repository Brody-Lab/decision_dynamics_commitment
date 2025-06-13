%% TS_JB_r_spoke_starter
% Training Section; Jess Breda; Rats ; Spoke Starter

% This curriculum is for gettng animals habiutated and used to the side
% ports prior to center port stages. These stages are nearly identical to
% the first 4 spokes stages in JB_r_classic, however they are just in thier
% own file now.
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

function varargout = TS_JB_r_spoke_starter(obj, action, varargin)


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
            '5: Not in use',...
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
                % TODO turn on waptor
                WaterValvesSection(obj, 'set_water_amounts', 60, 60);
                
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
            % DB 60
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
            %DB -> 60
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
                
                % dont want them to learn rapid L/R strategy so turnining 
                % water give off <- this is too harsh, relaxing it for now
                % give_type_set.value = 'light'; 
                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;
                
                if value(n_days_stage) <= 1 % stage init 
                    give_type_set.value = 'light';
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 25; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 3;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % block size of 15 trials
                    block_size.value = 15;
                    
                    WaterValvesSection(obj, 'set_water_amounts', 45, 45);
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

            %%% EOS logic- none see EOD
            
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
                    inter_trial_min.value = 5; % seconds
                    inter_trial_sample_mean.value = 15; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 3;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % blocks end at 70 trials
                    blocks_end.value = 70;
                    
                    % make sure antibias is on when in random and that beta
                    % ramps up from 0 to 3 over tau trials
                    Beta.value = 3;
                    betaRampup.value = 1;
                    
                    WaterValvesSection(obj, 'set_water_amounts', 30, 30);
                    
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

            %%% EOS logic- none see EOD
        
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
            
        case 3
            % DB trials_end
            trials_end = min(value(block_size) * 6, 140);
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.87 && ...
                    value(frac_no_answer) < 0.20
                TrainingSection(obj, 'increment_stage')
            end
            
                
        case 4
            trials_end = min(value(blocks_end) + 75, 175);
            % ! could switch from frac_correct to last 50 trials?
            if value(n_trials_stage) > trials_end && value(frac_correct) > 0.8 && ...
                    value(frac_no_answer) < 0.20
                
                % Determine next stage number (same pattern across all
                % curricula)
                if value(auto_advance_spoke_to_cpoke)
                    next_stage = 5; % cpoke stages start at 5
                else
                    next_stage = 4; % copy of spoke stage in new curriculum
                end
                
                % Determine next curriculum file
                switch value(fixation_experiment_condition)
                    case 'none'
                        cpoke_curr = 'JB_cpoke_test';
                    case 'V1'
                        cpoke_curr = 'JB_V1_SL_GT_VE';
                    case 'V2'
                        cpoke_curr = 'JB_V2_SH_GO_VL';
                end
                        
                % Switch
                curriculum.value = cpoke_curr;
                TrainingSection(obj, 'get_curriculum_stage_list', value(x_stage_name), value(y_stage_name));
                TrainingSection(obj, 'increment_stage', next_stage);
                
            end
   
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function


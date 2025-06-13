%% TS_JB_V1_SL_GT_VE
% Training Section; Jess Breda; 
% Version 1 Start Low, Grow Trials, Vioaltions Early
% Documentation written: 2024-07-24
%
%% CONTEXT
% This is the curriculum associated with the 'V1' fixation experiment
% condition. It is meant to mimic the orginial way of growing fixation in
% the Brody lab (and other related labs), specifically with respect to the
% Akrami et al. 2018 publication. Many of these specifics were not in the
% publication/readme but were determined from analyzing the fromt the
% animals included in the publication during the Grow Nose Poke stage.
%
%
% Start Low (SL) : 
%   this means the initial fixation period starts very, very small.
%   Specifically it is 0.010 seconds as done in Akrami et al. To implement
%   this, 'delay_dur' is set to 0.010 and this then sets the
%   'initial_fixation_dur'.
%
% Grow Trials (GT) : 
%   this means the fixation grows after each valid, non-violation trial by
%   a specificed amount. Specifically, this is set to max(0.001 s, 0.1%)
%   with a 20 trial warm up to yesterdays fixation value as done in Akrami
%   et al. 2018. To implement this, 'delay_growth' is set to 'fixed' with
%   the specified 'delay_fixed_growth_rate'.
%
%   if the target fixation dur has been reached. The warm up target is
%   sampled from an exponetial with min = 1 s, max = target and tau = 120%
%   of min. (1 seconds, 1.2 second, 2 second currently)
%
% Violations Early (VE): 
%   this means that the violation penalty is on from the beginning. The
%   settling_in_dur is the amount of fixation time animals get for "free".
%   They must complete it to start a trial, but if they do not there is no
%   penalty. Here, this is set to 0.001 as done in Akrami et al. 2018.
%   Moreover, 'settling_in_determines_fixation' is false and this is the
%   variable that modulates the SMA.
%
%% STAGES
% Stage 1-3: Empty stages
%  These keep the stage list happy so it's a clean transition from
%  curricula
%   
% Stage 4: Poke Left/Right Blocks -> Random
%   Starts with blocks of L/R spokes, then, after a specified number of
%   trials, the blocks will end and it becomes random L/R. The ITI will be
%   slightly shorter here (~20 seconds). This is the exact same as stage 4
%   in JB_spoke_starter.
%  
% Stage 5: Cpoke Left/Right Blocks
%   A light comes on in the center port to indicate trial availibility. The
%   animal will start fixating at the initial_fixation_dur (0.010 s) until
%   a go sound plays followed by a light guide in L or R port to indicate
%   reward location. Blocks of 15 trials for L/R. The center light does not
%   turn off until the go sound plays (ie is not grocked to the animal's
%   movements). The settling_in_dur does not determine fixation (delay_dur
%   does) and this will grow on each valid trial by the
%   delayed_fixed_growth_rate. Advancment from this stage is based off of
%   trial count, hit rate and no answer rate and occurs only overnight.
%
% Stage 6: Cpoke Left/Right Blocks -> Random
%   The trial structure and growth logic is identical to stage 5 except
%   that now after 'blocks_end' trials the trials become random L/R light
%   chasing. Blocks end is typically 75 trials. Antibiasing is on.
%   Advancment from this stage is based off of trial count, hit rate and no
%   answer rate and occurs only overnight.
%
% Stage 7: Cpoke Left/Right Random
%   Same as stages 5 and 6, but block structure is removed and L/R trials
%   are always drawn from random. Advancment from this stage is based off
%   of trial count, hit rate and no answer rate and if the animal has
%   reached the target fixation value. Animals will advance to the probe
%   curriculum directly from here (stages 9 and 10)

function varargout = TS_JB_V1_SL_GT_VE(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values 
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1: Not in use',...
            '2: Not in use',...
            '3: Not in use',...
            '4: Spoke block to rand',...
            '5: C to S block',...
            '6: C to S block to rand',...
            '7: C to S rand',...
            '8: Not in use',...
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
        case {1,2,3}
            %%
            stage_description.value = 'Switch to correct stage';
           
            
            if auto_advance_spoke_to_cpoke
                TrainingSection(obj, 'increment_stage', 5);
            else
                TrainingSection(obj, 'increment_stage', 4);
            end
            
            
        case 4
            %% Note: identical to stage 4 in spoke_starter
            stage_description.value = 'r/l blocks -> random';
           
            %%% init
            if value(n_trials_stage) == 0 % session init

                SMA_set.value = 'spoke';
                go_type.value = 'sound';
                stimuli_on.value = 0;
                give_type_set.value = 'light';
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 5; % seconds
                    inter_trial_sample_mean.value = 15; 
                    inter_trial_max.value = 30; %DB 30
                    inter_trial_sample_std.value = 3;
                    
                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % 15 trial blocks ending at 70 triaks
                    block_size.value = 15;
                    blocks_end.value = 70;
                    
                    % taking water & antibias values from GUI
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


            %%% No EOS/EOD logic, must manually advance!!
                
        case 5
        %%
        stage_description.value = 'V1: c to s blocks';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            
            % settling determines fixation is off, and since stimuli
            % are also off, fixation_dur = settling_in_dur + pre_go_dur.
            % where pre_go_dur is delay_dur - settling_in_dur.
            % violations are now possible if pre_go_dur is large enough
            settling_in_determines_fixation.value = 0;
            % violation penalty has a timeout
            % note that default settings have no penalty sound
            violation_dur.value = 2;


            if value(n_days_stage) <= 1 % stage init 

                %% TRIAL TIMING
                target_fixation_dur.value = 2;

                % settling in dur is how long animal has to fixate for
                % before officially starting the trial. Until delay_dur > 
                % settling in dur violations are effectively impossible
                settling_in_min.value = 0.001;
                settling_in_dur.value = value(settling_in_min); 
                delay_min.value = 0.01;
                delay_dur.value = value(delay_min);
                delay_max.value = value(target_fixation_dur) * 1.25;
                
                if value(delay_dur) >= value(settling_in_dur)
                    initial_fixation_dur.value = value(delay_dur);
                else
                    initial_fixation_dur.value = value(settling_in_dur);
                end

                % center light stays on for duration of fixation_dur
                % (ie not grocked to animals movements but what they
                % were supposed to do)
                cled_mapped_to_fixation_dur.value = 1;

                % fixation growth happens each trial with a 20 trial warm
                % up to yesterdays value
                delay_growth.value = 'fixed';
                delay_fixed_growth_rate.value = 0.001; % will grow max(1%, 1ms)
                delay_fixed_growth_unit.value = '%';
                delay_warm_up.value = 0; % warm up not needed until > settling in

                % inter trial dur is around 5 seconds
                inter_trial_dur_type.value = 'sampled'; % gaussain
                inter_trial_min.value = 2; % seconds
                inter_trial_sample_mean.value = 5; 
                inter_trial_max.value = 15; %DB 15
                inter_trial_sample_std.value = 1; 

                % incorrect pokes get no reward
                temp_error_penalty.value = 0;

                % Set up DistribUI incase target is reached and we are
                % sample tomorrows warm up growth target
                target = value(target_fixation_dur);
                sample_min = target * 0.5; 
                sample_tau = sample_min * 1.2;
                
                DistribInterface(obj, 'set', 'exp_sample', 'Min', sample_min);
                DistribInterface(obj, 'set', 'exp_sample', 'Max', target);
                DistribInterface(obj, 'set', 'exp_sample','Tau', sample_tau);
                
                % blocks
                block_size.value = 15;
                
            elseif value(delay_dur) > value(initial_fixation_dur) &&...
                value(n_days_stage) < 5 && ~value(delay_warm_up)
                % one delay dur has started to grow, turn warm up on
                delay_warm_up.value = 1; %warm up implemented via ShapingSection
                n_warm_up_trails.value = 20;
            end % n_days_stage
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        end % n_trials_stage == 0
        

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
        
        % No EOS logic- only EOD!
       
        case 6
        %%
        stage_description.value = 'V1: c to s blocks to random';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            settling_in_determines_fixation.value = 0;

            if value(n_days_stage) <= 1 % stage init 
                % block params
                blocks_end.value = 70;
                
                % antibiasing
                Beta.value = 3;
                betaRampup.value = 1; % ramp from 0 to beta over tau trials
               
                % assumed from stage 5
                % - delay dur growth
                % - target fixation
                % - cled mapped to go
                % - iti parameters
                % - block size 
                % - violation timeout
                % - distrib UI for exp sample
            end

            if value(delay_dur) > value(initial_fixation_dur) &&...
                value(n_days_stage) < 4 && ~value(delay_warm_up)
                % one delay dur has started to grow, turn warm up on
                delay_warm_up.value = 1; %warm up implemented via ShapingSection
                n_warm_up_trails.value = 20;
            end
            
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        end % n_trials_stage == 0
        

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
        % check to see if we need to move from blocks to random     
        elseif value(n_trials_stage) >= value(blocks_end)
                was_block_switch.value = 0;
                in_left_block.value = 0;
                in_right_block.value = 0;
                LeftProb.value = 0.5;

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
        
        % No EOS logic- only EOD!
        
        case 7
        %%
        stage_description.value = 'V1: c to s random';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            settling_in_determines_fixation.value = 0;

            if value(n_days_stage) <= 1 % stage init 
                % make sure blocks are off
                in_left_block.value = 0;
                in_right_block.value = 0;
                LeftProb.value = 0.5;
                was_block_switch.value = 0;
                
                
                % assumed from stage 5
                % - delay dur growth
                % - target fixation
                % - cled mapped to go
                % - iti parameters
                % - violation timeout
                % - distrib UI for exp sample
            
                % assumed from stage 6
                % - warm up is on for delay_dur
                % - anti biasing
                

            end % n_days_stage
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        
        end % n_trials_stage == 0
        

        %%% Stage Algorithim - nothing to implement here, L/R are drawn at
        %%% random, delay dur is growing on valid trials
        
        % No EOS logic- only EOD!             

    end %stage number

       
    %---------------------------------------------------------------%
    %          get_eod_logic                                        %
    %---------------------------------------------------------------%
    % If this curriculum is selected, this is run during the `end_session`
    % case from TrainingSection. This is where you put stage specific end
    % of day logic.
    %
    % Note, this is the last end_session call, so the variables saved to
    % protocol data do not reflect this update
    %
    % For example, if you want an animal to move to a stage only at the end
    % of the day, rather than within a session, you would put that here.
    %
    case 'get_eod_logic'
        curriculum_stage_number = value(varargin{1});
        switch curriculum_stage_number
        case 5
            if value(n_trials_stage) > 200 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
                CommentsSection(obj, 'append_line', 'Stg5 COMPLETE');
            end        
        case 6
            if value(n_trials_stage) > 250 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
                CommentsSection(obj, 'append_line', 'Stg6 COMPLETE');
            end    
        case 7
            if value(n_trials_stage) > 200 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85 && value(has_reached_fixation_target)
                CommentsSection(obj, 'append_line', 'Stg7 COMPLETE'); 

                curriculum.value = 'JB_alpha_fix_experiment';
                TrainingSection(obj, 'get_curriculum_stage_list', value(x_stage_name), value(y_stage_name));
                TrainingSection(obj, 'increment_stage', 9);
            end 
        end % switch get_eod_logic curriculum_stage_number
       

    end % switch action

end % function



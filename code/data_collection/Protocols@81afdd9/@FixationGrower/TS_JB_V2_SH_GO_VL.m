%% TS_JB_V2_SH_GO_VL
% Training Section; Jess Breda; 
% Version 2 Start High, Grow Overnight, Vioaltions Late
% Documentation written: 2024-07-24
%
%% CONTEXT
% This is the curriculum associated with the 'V2' fixation experiment
% condition. It is meant to mimic the new way that I (Jess Breda) started
% to grow fixation with mice and rats in late 2023, early 2024 in the
% Delayed Match to Sample Protocol
%
% Start High (SH) : 
%   this means the initial fixation period starts quite high. Specifically,
%   it set to 0.400 seconds here (like DMS2). To implement this
%   'settling_in_dur' is set to 0.400 and this then sets the
%   'initial_fixation_dur'.
%
% Grow Overnight (GO) : 
%   this means the fixation is stable during a sessions and grows overnight
%   to the animals mean center poke. There is no warm up and this is
%   implemented by the 'determine_tomorrows_fixation' case in
%   ShapingSection.
%
%   if the target fixation dur has been reached, then tomorrows value is
%   sampled from an exponetial with min = 1 s, max = target and tau = 120%
%   of min. (1 seconds, 1.2 second, 2 second currently)
%
% Violations Late (VL): 
%   this means that the violation penalty is off until a specific stage (8)
%   where it turns on. This is why settling_in sets the initial fixation as
%   opposed to delay_dur and this is controled by 
%   'settling_in_determines_fixation'. Trials cannot be started when there
%   are concurrent side pokes. However, if an animal leaves the cport early
%   they can immediately retry. A trial does not complete until they fixate
%   until the go cue plays.
%
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
%   animal will start fixating at the initial_fixation_dur (0.4 s) until
%   a go sound plays followed by a light guide in L or R port to indicate
%   reward location. Blocks of 15 trials for L/R. The center light does not
%   turn off until the go sound plays (ie is not grocked to the animal's
%   movements). The settling_in_dur does determine fixation so violations
%   are not possible and fixation growth happens overnight to mean center
%   pooke. Advancment from this stage is based off of trial count, hit rate
%   and no answer rate and occurs only overnight.
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
%   reached the target fixation value. 
% 
% Stage 8: Violation Penalty On
%   Same exact structure as stage 7 except now
%   'settling_in_determines_fixation' is False and the 'delay_dur'
%   paramterizes the fixation period such that violations are possible. As
%   of 7/24/2024 exact advancement criteria from this stage has not been
%   determined. Animals will advance to the probe curriculum directly from
%   here (stages 9 and 10)

function varargout = TS_JB_V2_SH_GO_VL(obj, action, varargin)


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
            '8: Violations On',...
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
        stage_description.value = 'V2: c to s blocks';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            
            % settling in determines fixation means no penalty for
            % leaving center before go cue- animal must retry until
            % go cue plays and trial is complete
            settling_in_determines_fixation.value = 1;

            if value(n_days_stage) <= 1 % stage init 

                %% TRIAL TIMING
                target_fixation_dur.value = 2;

                % duration of fixation is set by settling in dur and
                % fixation_dur = settling_in_dur + pre_go_dur where
                % pre_go_dur is fixed to 0.001 when settling in
                % determines fixation is true. 
                settling_in_dur.value = 0.400;
                initial_fixation_dur.value = value(settling_in_dur);
                settling_in_min.value = 0.150;
                settling_in_max.value = value(target_fixation_dur) * 1.25; % can't go more than 25% above target
            
                % if animal is having trouble starting with high
                % fixation rate, will decrease overnight by this amount
                fixation_adjustment.value = 0.05;

                % center light stays on for duration of fixation_dur
                % (ie not grocked to animals movements but what they
                % were supposed to do)
                cled_mapped_to_fixation_dur.value = 1;

                % fixation growth is overnight to animals mean cpoke
                % and this is taken care of by
                % determine_tomorrows_fixation
                settling_in_growth.value = 'overnight_growth';

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
        stage_description.value = 'V2: c to s blocks to random';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            settling_in_determines_fixation.value = 1;

            if value(n_days_stage) <= 1 % stage init 
                % block params
                blocks_end.value = 70;
                
                % antibiasing
                Beta.value = 3;
                betaRampup.value = 1; % ramp from 0 to beta over tau trials
               
                % assumed from stage 5
                % - settling in growth
                % - target fixation
                % - cled mapped to go
                % - iti parameters
                % - block size 
                % - distrib UI for exp sample
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
        stage_description.value = 'V2: c to s random';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            settling_in_determines_fixation.value = 1;

            if value(n_days_stage) <= 1 % stage init 
                % make sure blocks are off
                in_left_block.value = 0;
                in_right_block.value = 0;
                LeftProb.value = 0.5;
                was_block_switch.value = 0;
                
                
                % assumed from stage 5
                % - settling in dur growth
                % - target fixation
                % - cled mapped to go
                % - iti parameters
                % - distrib UI for exp sample
            
                % assumed from stage 6
                % - anti biasing
                

            end % n_days_stage
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        
        end % n_trials_stage == 0
        

        %%% Stage Algorithim - nothing to implement here, L/R are drawn at
        %%% random
        
        % No EOS logic- only EOD!   
        case 8
        %%
        stage_description.value = 'V2: Turn on violations';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA and set stimulus to off 
            % because cpoke sma will send stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';
            
            % violation penalty on and has a timeout (note there are no
            % penalty sounds by default)
            settling_in_determines_fixation.value = 0; 
            settling_in_growth.value = 'none';
            violation_dur.value = 2;

            if value(n_days_stage) <= 1 % stage init 
                
                % now delay dur is paramaterizing the fixation period and
                % settling in dur is set to 150 ms. If animal made it here
                % they can fixate for the target length so we will sample
                % tomorrows value from and exponential.
                if value(settling_in_dur) > 0.150
                    delay_dur.value = value(settling_in_dur);
                    delay_growth.value = 'overnight_sampled';
                    settling_in_dur.value = 0.150;
                end

                % assumed from stage 5
                % - settling in dur growth
                % - target fixation
                % - cled mapped to go
                % - iti parameters
                % - distrib UI for exp sample
            
                % assumed from stage 6
                % - anti biasing
               
                % assumed from stage 7
                % - blocks are off
                
            end % n_days_stage
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        
        end % n_trials_stage == 0
        

        %%% Stage Algorithim - nothing to implement here, L/R are drawn at
        %%% random
        
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
            %DB 200
            if value(n_trials_stage) > 200 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
                CommentsSection(obj, 'append_line', 'Stg5 COMPLETE');
            end        
        case 6
            %DB 250
            if value(n_trials_stage) > 250 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
                CommentsSection(obj, 'append_line', 'Stg6 COMPLETE');
            end    
        case 7
            if value(n_trials_stage) > 200 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85 && value(has_reached_fixation_target)
                TrainingSection(obj, 'increment_stage');
                CommentsSection(obj, 'append_line', 'Stg7 COMPLETE'); 
            end
        case 8
            % advance after 1 session!
            CommentsSection(obj, 'append_line', 'Stg8 COMPLETE');  

            curriculum.value = 'JB_alpha_fix_experiment';
            TrainingSection(obj, 'get_curriculum_stage_list', value(x_stage_name), value(y_stage_name));
            TrainingSection(obj, 'increment_stage', 9);

        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function



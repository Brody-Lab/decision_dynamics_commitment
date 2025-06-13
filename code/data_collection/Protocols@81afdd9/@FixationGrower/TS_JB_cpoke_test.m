%% TS_JB_r_cpoke_test
% Training Section; Jess Breda; Cpoke Test

% This is curriculum used for testing the logic of spoke to cpoke
% curriculum transitions. It is not meant to be used with animals, but will
% likely be copied and put to use.
%
% Stage 1-3: Empty stages
%   If auto_advance_spoke_to_cpoke is on, these stages will move you
%   directly into stage 5 (cpoke L/R blocks). If it is off, these stages
%   will move you into stage 4 (Poke L/R Blocks -> Random) which is
%   identical to the stage 4 in spoke starter.
%   
% Stage 4: Poke Left/Right Blocks -> Random
%   Starts with blocks of L/R spokes, then, after a specified number of
%   trials, the blocks will end and it becomes random L/R. The ITI will be
%   slightly shorter here (~20 seconds).
%  
% Stage 5: Cpoke Left/Right Blocks
%   A light comes on in the center port to indicate trial availibility. The
%   settling in dur for this stage will be quite long (~300 ms), so an
%   animal needs to learn to hold their nose in the port in order to get
%   the go sound -> light guide. The center light does not turn off until
%   the go sound plays (ie is not grocked to the animal's movements). TBD
%   on reward structure. Blocks of ~15 L/R trials
%
%


function varargout = TS_JB_cpoke_test(obj, action, varargin)


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
            '5: C -> S block, V1',...
            '6: C -> S block, V0',...
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
            stage_description.value = 'V1: c->s blocks';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;
                give_type_set.value = 'light';

                if value(n_days_stage) <= 1 % stage init 
                    
                    %% TRIAL TIMING
                    % settling in determines fixation means no penalty for
                    % leaving center before go cue- animal must retry until
                    % go cue plays and trial is complete
                    settling_in_determines_fixation.value = 1;
                    target_fixation_dur.value = 2;
  
                    % duration of fixation is set by settling in dur and
                    % fixation_dur = settling_in_dur + pre_go_dur where
                    % pre_go_dur is fixed to 0.001 when settling in
                    % determines fixation is true. 
                    initial_fixation_dur.value = 0.350;
                    settling_in_dur.value = value(initial_fixation_dur);
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
                    % sample tomorrows settling in dur
                    target = value(target_fixation_dur);
                    sample_min = target * 0.5; 
                    sample_tau = sample_min * 1.2;

                    DistribInterface(obj, 'set', 'exp_sample', 'Min', sample_min);
                    DistribInterface(obj, 'set', 'exp_sample', 'Max', target);
                    DistribInterface(obj, 'set', 'exp_sample','Tau', sample_tau);
                end
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
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
            
        case 6
        %%
        stage_description.value = 'V0: c->s blocks';

        %%% init
        if value(n_trials_stage) == 0 % session init

            % Trial Structure- move to cpoke SMA 
            % and set stimulus to off because cpoke sma will send 
            % stimuli if on
            SMA_set.value = 'cpoke';
            stimuli_on.value = 0;
            give_type_set.value = 'light';

            if value(n_days_stage) <= 1 % stage init 

                %% TRIAL TIMING
                % settling determines fixation is off, and since stimuli
                % are also off, fixation_dur = settling_in_dur + pre_go_dur.
                % where pre_go_dur is delay_dur - settling_in_dur.
                % violations are now possible if pre_go_dur is large enough
                settling_in_determines_fixation.value = 0;
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
%         switch curriculum_stage_number
%         case 5
%             %% Implement overnight growth to avg valid cpoke dur
%             %DEBUG 5 -> 50
%             if value(n_trials_stage) > 50 && strcmp(value(settling_in_growth), 'overnight_growth')
%                 
%                 % grab the cpoke durs we calculate in History section and
%                 % note theres also a wf_cpoke_dur so we are explicit here
%                 cpoke_dur_handle = get_sphandle('fullname', 'HistorySection_cpoke_dur'); 
%                 cpoke_durs =value(cpoke_dur_handle{1}); % unpack from SPH struct
%                 
%                 % filter for non-violation trials (only possible here if
%                 % spoked during cpoke)
%                 valid_trials = value(~violation_history);
%                 valid_cpokes = cpoke_durs(valid_trials);
%                 
%                 avg_valid_cpoke = mean(cpoke_durs(valid_trials), 'omitnan');
%                 settling_in_dur.value = avg_valid_cpoke;
%             end
% 
%         end % switch get_eod_logic curriculum_stage_number
       

    end % switch action

end % function


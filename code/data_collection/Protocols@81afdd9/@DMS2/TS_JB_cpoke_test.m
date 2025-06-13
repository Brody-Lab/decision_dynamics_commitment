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
            '5: C -> S block, high start',...
            '6: Not yet written',...
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
                    inter_trial_max.value = 1; %DB 30
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
                    settling_in_dur.value = 0.3; 
                    pre_dur.value = 0.001;
                    stimulus_dur.value = 0.001;
                    delay_dur.value = 0.001;
                    post_dur.value = 0.001;
                    viol_off_growth.value = 'match_pre_go';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 2; % seconds
                    inter_trial_sample_mean.value = 5; 
                    inter_trial_max.value = 15; %DB 15
                    inter_trial_sample_std.value = 1; 

                    % incorrect pokes get no reward
                    temp_error_penalty.value = 0;
                    
                    % update delay overnight to match the animals cpoke
                    % duration
                    delay_growth.value = 'overnight_growth';
                    % set up distribui for exp delay for overnight sample
                    % if animal has reached max fixation reqs.
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.8);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   1.5);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   1);
                    
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
            
        case 6
            %%
            stage_description.value = 'HOLDING HERE';
        
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
        case 5
            disp('********************************')
            %%% EOS logic %DB 250 -> 10
            if value(n_trials_stage) > 10 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.85
                TrainingSection(obj, 'increment_stage');
            end
   
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function


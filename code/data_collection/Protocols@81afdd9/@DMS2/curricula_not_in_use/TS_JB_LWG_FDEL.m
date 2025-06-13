%% TS_JB_LWG_FDEL
% Training Section; Jess Breda; Light & Water Give (LWG); Full Delay (FDel)
% 
% This curriculum starts with light & water guided side poking, then it 
% moves into center -> side poking (still with guides and sa/sb sounds). 
% Once the delay between centered and side is the desired length (measured 
% by parameters of the exponential it's being sampled from) sounds are added
% and a sound rule is enforced by sequentially removing light and water
% guides.
%
% Stage 1: Poke Left
%   In left side port, light turns on and fraction of water reward is
%   delivered. Animals have to answer within wait_for_spoke_tup, otherwise
%   will move to next trial. ITIs are very long so that animal learns the
%   association between light/water 'give' and reward. There is control to
%   make sure no more water is given until animal drinks from the port.
%
% Stage 2: Poke right
%   Same thing as stage 1, but for the right side. Stage 1 and stage 2
%   alternate days until they are both completed (e.g. an animal can
%   complete stage 2 before they complete stage 1)
%
% Stage 3: Center to side with short, random delay
%   Now the animal know to follow light and water guides, we introduce the
%   primary motor patter. A light comes on in the center port to indicate 
%   trial availibility, followed by a light & water delivery in either the 
%   L or R side port. The delay between center poke and light/water give is
%   drawn from an exponential distribution with a mean of 400 ms. There are
%   no violations or sounds during this stage, and the ITI is back to
%   "normal" lengths of ~3 seconds. The possibly out comes are correct or
%   no answer. Poking in the incorrect (unlit) port is tracked as a
%   temporary error (also called "forgivness" or "always" in other 
%   protocols), but there is no feedback to the animal until the poke
%   correctly.
%
% Modification to stage 3 on 4/22 to see if a center L/R block structure
% might help an issue we are seeing with some animals not doing light
% guiding very well upon learning the cpoke. Similar to the rats, blocks of
% 20 L/R light guided trials. Once they are good at that, then the L/R will
% be random. Additionally turning on violations after the first (or
% second?) day depending on how n_days_stage is evaluated. This is kind of
% a blend of stage 3 and 4. If it works, will need to make things a bit
% cleaner.
%   
% Stage 4: Introduce violations & sa/sb during drink
%   Now the animal understands the basic C -> S motor program, we will
%   introduce a violation penalty if the animal pokes before the side
%   light/water give. This will play a sound for a timeout and the animal
%   recives no reward. If the animal does not violate, and they answer
%   correctly (either on the first try or after incorrect answers), they
%   will hear a "replay" of sa/sb sounds that match that side during the
%   drink period. The third possible outcome is "no answer" and can be used
%   to measure engagement.
%
% Stage 5: Grow delay
%   In this stage, we will grow the distribtuion the delay is being sampled
%   from to make space for sa/sb sounds. The min, tau (mean) and max of the
%   distribtuion will grow if the animal did not violate. The target growth
%   is min : 1, tau : 1.6, max: 5.3. All features from previous stages 
%   (violation penaly, drink "replay", temporory error, light and water 
%   give) are still in use.
%
% Stage 6: Introduce sounds
%   In this stage, sa and sb with a delay between and after will start to
%   play. The delay between the sounds will be sampled from an exponential,
%   but the min, max and tau will be adjusted to account for the length of
%   the sounds + post sound delay. All features from previous stages are
%   still in use.
%
% Stage 7: Remove light give (in progress)
%   In this stage, we will remove the light give so that animal will rely 
%   on the subtler water give, and/or the sounds. This can be done in two
%   ways (1) reduce the fraction of trials where light give is happening,
%   or (2) delay the light give over time. Reward structure is TBD 
%
% Stage 8: Remove water give (in progress)
%   Same as above, but with water.
%
% Stage 9: Require sounds (in progress)
%   Same as 8, but give is now really off and the animals are punished for
%   incorrect answers
%

function varargout = TS_JB_LWG_FDEL(obj, action, varargin)


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
            '3: C -> Spoke',...
            '4: Add violation & drink sa/sb',...
            '5: Grow C -> S delay',...
            '6: Introduce sa,sb',...
            '7: Remove light give',...
            '8: Remove water give',...
            '9: Require sounds',...
            '10: TBD' 
            % if want more than 10 need to adjust TrainingSection.m
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
            stage_description.value = 'light, water, left poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 1;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                
                if value(n_days_stage) <= 1 % stage init
                    replay_on.value = 0;

                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 40; 
                    inter_trial_max.value = 60;
                    inter_trial_sample_std.value = 5; 
                end
            end

            %%% EOS logic
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.15
                stage_1_spoke_completed.value = 1;
                
                if stage_2_spoke_completed
                    TrainingSection(obj, 'increment_stage', 3);
                else
                    TrainingSection(obj, 'increment_stage', 2);
                end
            end 
            
        case 2
            stage_description.value = 'light, water, right poke, long iti';

            %%% init
            if value(n_trials_stage) == 0 % session init

                LeftProb.value = 0;
                give_type_set.value = 'water_and_light';
                SMA_set.value = 'spoke';
                
                if value(n_days_stage) <= 1 % stage init 
                    replay_on.value = 0;

                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 10; % seconds
                    inter_trial_sample_mean.value = 40; 
                    inter_trial_max.value = 60;
                    inter_trial_sample_std.value = 5; 
                end
            end

            %%% EOS logic
            if value(n_trials_stage) >= 40 && value(frac_no_answer) < 0.15

                stage_2_spoke_completed.value = 1;
                
                if stage_1_spoke_completed
                    TrainingSection(obj, 'increment_stage', 3);
                else
                    TrainingSection(obj, 'increment_stage', 1);
                end
            end

        case 3
            stage_description.value = 'c -> s, small delay from exp dist';

            %%% init
            if value(n_trials_stage) == 0 % session init

                % Trial Structure- move to cpoke SMA 
                % and set stimulus to off because cpoke sma will send 
                % stimuli if on (spoke sma does not)
                SMA_set.value = 'cpoke';
                stimuli_on.value = 0;

                % Trial timing- turning most things to zero and letting exp
                % sampled delay dur time between center and side
                pre_dur.value = 0.001; 
                stimulus_dur.value = 0.001;
                post_dur.value = 0.001;
%                 delay_growth.value = 'exp';

                if value(n_days_stage) <= 1 % stage init 
                    % start in a blocked L/R structure
                    stage_3_blocks.value = 1;

                    % set these incase coming back from a higher stage
                    replay_on.value = 0;
                    wait_for_spoke_dur.value = 8;
                    
                    % intializse give
                    give_type_set.value = 'light';

                    % inter trial dur is smaller in stage 3 than 1 and 2
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 3; % seconds
                    inter_trial_sample_mean.value = 5; 
                    inter_trial_max.value = 10;
                    inter_trial_sample_std.value = 1; 

                    % Trial Timing set inital parameters for exponential 
                    % delay sampling
                    DistribInterface(obj, 'set', 'exp_delay', 'Min',   0.2);
                    DistribInterface(obj, 'set', 'exp_delay', 'Max',   0.7);
                    DistribInterface(obj, 'set', 'exp_delay', 'Tau',   0.3);

                    % Penalty- Document early pokes, but do not penalize them 
                    % by going into violation penalty stae state
                    viol_off_dur.value = 0.001; % pokes after 1ms are valid
                    SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0); % 0.001 default
                    violation_dur.value = 0.1;

                    % Penalty- Incorrect answer noted, but no noticible penalty. 
                    % Animal must answer correctly to finish trial (ie no error
                    % state)
                    temp_error_penalty.value = 1;
                    SoundInterface(obj, 'set', 'TempErrorSound', 'Vol', 0); % 0.005 default
                    retry_type.value = 'multi';
                    temp_error_dur.value = 0.1;
                    SoundInterface(obj, 'set', 'ErrorSound', 'Vol', 0);

                elseif value(n_days_stage) == 2 
                    % Penalty - turn on violations penalty after the first 
                    % day so now a sound plays and the trial cleans up
                    % after an early poke
                    viol_off_growth.value = 'match_pre_go';
                    stage_4_viol_off_grown.value = 1;
                    SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0.001);
                    violation_dur.value = 0.3;
                    
                    % turn on replay after the first day
                    replay_on.value = 1;
                end
            end

            %%% Stage algorithim
            if stage_3_blocks
                if value(n_trials_stage) == 0
                    stage_3_left_block.value = 1;
                    LeftProb.value = 1;
                    stage_3_right_block.value = 0;
                % check to see if 20 trial block is compelte
                elseif rem(value(n_trials_stage), 20) == 0
                    if stage_3_left_block
                        LeftProb.value = 0;
                        stage_3_right_block.value = 1;
                        stage_3_left_block.value = 0;
                    elseif stage_3_right_block
                        LeftProb.value = 1;
                        stage_3_left_block.value = 1;
                        stage_3_right_block.value = 0;
                    end
                end
            else
                LeftProb.value = 0.5;
                stage_3_left_block.value = 0;
                stage_3_right_block.value = 0;
            end

            %%% this is effectively an EOS logic, but I'm being hacky right
            %%% now and don't want to make a new stage. So we're kinda
            %%% doing two in one
            if value(n_trials_stage) > 70 && value(frac_correct) > 0.9 && ...
                    value(frac_violations) < 0.2 && value(stage_3_blocks)
                stage_3_blocks.value = 0;

            end

            %%% EOS logic
            if value(n_trials_stage) > 120 && value(frac_no_answer) < 0.1 && ...
                    value(frac_correct) > 0.8 && ~value(stage_3_blocks)
                TrainingSection(obj, 'increment_stage');
            end

        case 4
            stage_description.value = 'c -> s like stage 3 + viol & replay';
            %%% init
            if value(n_trials_stage) == 0 % session init
                
                % Violation Penalty- turn it on. From center poke to
                % viol_off is the duration of time in the trial an animal
                % can violate. After volf_off and pre pre_go, early spokes 
                % are documented, but not penalized. Here, we are growing
                % the viol_off window until it matches that of pre_go
                % see cpoke_SMA for more info.
                SoundInterface(obj, 'set', 'ViolationSound', 'Vol', 0.001);
                if ~stage_4_viol_off_grown
                    viol_off_growth.value = 'fixed'; % in case animal is reset
                end

                % replay isn't the best name here since the stimuli are
                % off, but play sa/sb during the drink period a specified 
                % number of times. Replay Params subwindow has more info
                replay_on.value = 1;

                if value(n_days_stage) <= 1 % stage init 
                    % Violation Penalty- duration and growth rate
                    violation_dur.value = 0.3;
                    viol_off_fixed_growth_rate.value = 0.0025; 
                end
            end

            %%% Stage Algorithim
            % once viol_off is close to the maximum delay, we can turn the
            % growth off and match it to pre_go. Once this happens and poke
            % before side lights come on is a violation. 
            max_delay = DistribInterface(obj, 'get', 'exp_delay', 'Max') - 0.05;
            if value(viol_off_dur) >= max_delay && ~stage_4_viol_off_grown
                viol_off_growth.value = 'match_pre_go';
                stage_4_viol_off_grown.value = 1;
            end

            
            %%% EOS logic
            if value(n_trials_stage) > 5 && value(frac_correct) > 0.75 && ...
                    value(frac_violations) < 0.2 && ...
                    strcmp(value(viol_off_growth) , 'match_pre_go')
                
                TrainingSection(obj, 'increment_stage');
            end

        case 5
            stage_description.value = 'c -> s with growing delay duration';
            %%% init
            if value(n_trials_stage) == 0 % session init
                disp('')
                if value(n_days_stage) <= 1 % stage init
                    disp('')
                end
               
            end

            %%% EOS logic

        
        end % switch get_curriculum curriculum_stage_number
       
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
            if ~stage_2_spoke_completed
                TrainingSection(obj, 'increment_stage', 2);
            end
                
        case 2
            % Same as stage 1, but reversed.
            if ~stage_1_spoke_completed
                TrainingSection(obj, 'increment_stage', 1);
            end
        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function


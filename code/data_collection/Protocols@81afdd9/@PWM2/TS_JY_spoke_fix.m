% Curriculum inspired by Halassa style training.
% We start by playing Sa - Sb - Go in sequence, and delivering reward to the
% corresponding port automatically. This habituates the animal to the stimulus
% set, as well as to receiving water from the sideports. Trials are separated
% by randomized ITI lengths.
% 
% Stage 2 is the same, but now requires the animal to poke into the correct
% side port in order to receive the reward. There is no penalty for incorrect
% pokes.
% 
% Stage 3 adds the requirement that the animal poke into the center port in
% order to begin the sound sequence. We still require the animal to sidepoke
% correctly in order to receive reward. Incorrect pokes are not punished.
% 
% Stage 4 is about growing fixation. We begin requiring longer and longer
% fixation periods, up to about a second (the necessary space for an Sa, Sb,
% delay, and Go sound of 0.2 seconds in length to fit). Early cpoke out
% causes sounds to stop playing and a violation sound to play.
% 
% Stage 5 is the beginning of rule learning. We begin to delay the reward
% delivery for incorrect pokes.
% 
% Stage 6 imposes no reward for incorrect pokes. At the end of this stage,
% animals are performing the task well.
% 
% Stage 7 grows the delay between Sa and Sb.
% 
% Stage 8 introduces a discrete set of delay lengths (1.5, 2, 2.5 seconds).
% 
function varargout = TS_JY_spoke_fix(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: all snds give',...
            '2: all snds poke',...
            '3: center snds poke',...
            '4: gnp 0.4s all snds poke',...
            '5: gnp 0.5s (grow stim) cpoke_fix',...
            '6: gnp 0.7s (grow pre) all snds',...
            '7: gnp 0.9s (grow delay) all snds',...
            '8: gnp 1s (grow post) all snds',...
        };


    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
    	stage_num = value(varargin{1});
    	switch stage_num
        case 1
            stage_description.value= 'center to side no sounds';
            %%% updated only on the first trial
            if n_trials_stage == 0
                %%% task parameters
                reward_type.value = 'give';
                init_poke_type.value = 'cpoke_nofix';
                stimuli_on.value = false;
                wait_spoke_Tup_forgiveness.value = true;
                temp_error_penalty.value = true;
                

                if value(n_days_stage) > 2
                    retry_type.value = 'single';
                else
                    retry_type.value = 'multi';
                end

                inter_trial_perf_multiplier.value = false;
            end
            %%% EOS logic
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end


        case 2
            stage_description.value = 'center to side, gnp with go cue and give reward';
            if value(n_trials_stage) == 0
                %%% task parameters
                reward_type.value = 'give';
                init_poke_type.value = 'cpoke_fix';
                stimuli_on.value = true;
                spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = true;

                if value(n_days_stage) > 2
                    retry_type.value = 'single';
                else
                    retry_type.value = 'multi';
                end

                inter_trial_perf_multiplier.value = false;

                %%% sound parameters
                SoundInterface_SaSound_Vol.value = 0;
                SoundInterface_SbSound_Vol.value = 0;

                %%% duration & growth inits 
                pre_min.value = 0.1;
                pre_dur.value = value(pre_min);
                pre_growth.value = true;
                pre_growth_type.value = 'fixed';
                pre_fixed_growth_unit.value = 's';
                pre_warm_up.value = true;
                %! if you change pre_fixed_growth_rate will it be maintained 
                % into the next session?
                 
                delay_dur.value = 0.001;
                delay_growth.value = false;
                stimulus_dur.value = 0.001;
                stimulus_growth.value = false;
                post_dur.value = 0.001;
                post_growth.value = false;
            end
            %%% algorithm: grow pre_dur
            if value(pre_dur) >= 1.0
                TrainingSection(obj, 'increment_stage');
            end


        case 3
            stage_description.value = 'center to side, play stimuli and give reward'; 

            if(value(n_trials_stage)==0) || strcmp(value(in_helper_block), 'TRUE')
                %%% task parameters
                reward_type.value = 'give';
                init_poke_type.value = 'cpoke_fix';
                stimuli_on.value = true;
                wait_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = true;
                retry_type.value = 'single';
                inter_trial_perf_multiplier.value = false;

                %%% sound parameters'
                % TODO: change these to be correct when ready
                SoundInterface_SaSound_Vol.value = 0.1;
                SoundInterface_SbSound_Vol.value = 0.1;

                %%% duration and growth inits
                % TODO: make stimulus_dur and soundUI interact
                pre_dur.value = 0.2;
                pre_growth.value = false;
                delay_dur.value = 0.2;
                delay_growth.value = false;
                stimulus_dur.value = 0.2;
                stimulus_growth.value = false;
                post_dur.value = 0.2;
                post_growth.value = false;
                
                StimulusSection(obj, 'set_pairs', [3000 6000 ; 6000 3000 ; 6000 12000 ; 12000 6000]);
            end
            %%% algorithm
            if strcmp(in_helper_block, 'TRUE')
                if ~exists('var', 'ctr')
                    ctr = value(helper_trials_give);
                end
                ctr = ctr - 1;
                if ctr == 0
                    in_helper_block.value = 'FALSE';
                    stage_number.value = 4;
                    clear ctr;
                end
            end
            if value(n_trials_stage) >= 100 && value(last100trialperf) > .7 && ...
               value(violation_rate) < .5 && strcmp(in_helper_block, 'FALSE')
                TrainingSection(obj, 'increment_stage');
            end


        case 4
            stage_description.value = 'center to side, play stimuli required rule (temperror)';
            if value(n_trials_stage) == 0
                %%% task parameters
                reward_type.value = 'poke';
                init_poke_type.value = 'cpoke_fix';
                stimuli_on.value = true;
                wait_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = true;
                retry_type.value = 'single';
                inter_trial_perf_multiplier.value = true;

                %%% duration and growth inits
                % TODO: make stimulus_dur and soundUI interact
                pre_dur.value = 0.2;
                pre_growth.value = false;
                delay_dur.value = 0.2;
                delay_growth.value = false;
                stimulus_dur.value = 0.2;
                stimulus_growth.value = false;
                post_dur.value = 0.2;
                post_growth.value = false;

                if value(n_days_stage) > 3
                    helper.value = false;
                else
                    helper.value = true;
                end

                % TODO: Set which stimuli you want to use?
                %StimulusSection(obj, 'set_preset', 'Cross (4 pairs)');
                % OR
                %StimulusSection(obj, 'set_pairs', [3000 6000 ; 6000 12000 ; ...]);
            end
            %%% algorithm
            if value(n_trials_stage) >= 150 && value(last150trialperf) > .7 && value(violation_rate) < .3
                TrainingSection(obj, 'increment_stage');
            elseif value(helper)
                % TODO
                %if perf_over_helper_window < threshold
                %    in_helper_block.value = 'TRUE';
                %    stage_number.value = 'Stage 3';
                %end
            end
            

        case 5
            stage_description.value = 'center to side, play stimuli required rule (temp error off)';
            if value(n_trials_stage) == 0
                %%% task parameters
                reward_type.value = 'poke';
                init_poke_type.value = 'cpoke_fix';
                stimuli_on.value = true;
                wait_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = false;
                retry_type = 'N/A';
                inter_trial_perf_multiplier.value = true;

                %%% duration and growth inits
                % TODO: make stimulus_dur and soundUI interact
                pre_dur.value = 0.2;
                pre_growth.value = false;
                delay_dur.value = 0.2;
                delay_growth.value = false;
                stimulus_dur.value = 0.2;
                stimulus_growth.value = false;
                post_dur.value = 0.2;
                post_growth.value = false;
            end
            
            %%% algorithm
            if value(n_trials_stage) >= 150 && value(last150trialperf) > .7 && value(violation_rate) < .3
                TrainingSection(obj, 'increment_stage');
            end 

        case 6
            stage_description.value = 'growth of delay btwn stimuli';
            if value(n_trials_stage) == 0
                %%% task parameters
                reward_type.value = 'poke';
                init_poke_type.value = 'cpoke_fix';
                stimuli_on.value = true;
                wait_spoke_Tup_forgiveness.value = false;
                temp_error_penalty.value = false;
                retry_type = 'N/A';
                inter_trial_perf_multiplier.value = true;

                %%% duration and growth inits
                % TODO: make stimulus_dur and soundUI interact
                pre_dur.value = 0.2;
                pre_growth.value = false;
                stimulus_dur.value = 0.2;
                stimulus_growth.value = false;
                post_dur.value = 0.2;
                post_growth.value = false;

                delay_min.value = 0.2;
                delay_dur.value = value(delay_min);
                delay_growth.value = true;
                delay_warm_up.value = true;
            end
            %%% algorithm
            if value(delay_dur) >= value(delay_max) && value(violation_rate) < 0.3 && value(last100trialperf) > 0.7
                TrainingSection(obj, 'increment_stage');
            end 

        case 7
            stage_description.value = 'delay with discrete values';

        case 8
            stage_description.value = 'add stimuli';

        end
    end
end

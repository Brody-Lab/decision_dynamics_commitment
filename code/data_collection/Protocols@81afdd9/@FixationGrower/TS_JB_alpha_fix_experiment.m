%% TS_JB_alpha_fix_experiment
% Training Section; Jess Breda; 
% Alpha fixation Experiment
% Documentation written: 2024-08-02
%
%% CONTEXT
% This is the fixation testing (or "probe") stages for the alpha cohort of
% animals that went throuhg the V1_SL_GT_VE or V2_SH_GO_VL curricula. This
% curriculum consists of two stages for testing and all animals pass
% through both. End of stage logic is determined by the number of days (5
% test days for each stage).
%
%
%% STAGES
% Stage 9: Stable Fixation Dur
%   In this stage, the delay will be fixed to a single value- the target
%   delay value. In this experiment that is 2 seconds. Animals will recieve
%   random R/L trials (adjusted by antibias as needed). The trial structure
%   is the same as before with a cpoke -> go cue -> light guided L/R poke.
%   The stage will last for 5 days and will test performance on a stable
%   delay for both V1/V2 conditions.
%
% Stage 10: Random Fixation Dur
%   In this stage, the delay will be randomly sampled each trial. This
%   sample will come from an exponential with min = 1s, max = 2s and tau =
%   1.2s. Animals will recieve random R/L trials (adjusted by antibias as
%   needed). The trial structure is the same as before with a cpoke -> go
%   cue -> light guided L/R poke. The stage will last for 5 days and will
%   test performance on a random delay for both V1/V2 conditions.
%
% Stage 11: Probe complete
%   This stage is simply a placeholder to indicate the experiment has
%   ended. It turns the delay into an overnight sample. This will likely be
%   adjusted to swtich to other curricula (e.g. adding sounds) once
%   written.

function varargout = TS_JB_alpha_fix_experiment(obj, action, varargin)


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
            '4: Not in use',...
            '5: Not in use',...
            '6: Not in use',...
            '7: Not in use',...
            '8: Not in use',...
            '9: Probe Target Delay',...
            '10: Probe Sampled Delay',...
            '11: Probe Complete'
        };

        %% STOPPED HERE!!

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
        case {1,2,3,4,5,6,7,8}
            %%
            stage_description.value = 'Switch to correct stage';
            
            TrainingSection(obj, 'increment_stage', 9);

            
            
        case 9
            %% Note: identical to stage 4 in spoke_starter
            stage_description.value = 'probe stage- fixed delay';
           
            %%% init
            if value(n_trials_stage) == 0 % session init
                SMA_set.value = 'cpoke';
                go_type.value = 'sound';
                go_dur.value = 0.2;
                stimuli_on.value = 0;
                give_type_set.value = 'light';

                % trial structure
                target_fixation_dur.value = 2;
                settling_in_determines_fixation.value = 0;
                settling_in_dur.value = 0.150;
                delay_dur.value = value(target_fixation_dur);
                cled_mapped_to_fixation_dur.value = 1;

                % no growth
                settling_in_growth.value = 'none';
                delay_growth.value = 'none';
                delay_warm_up.value = 0;

                % penalties
                violation_dur.value = 2;
                temp_error_penalty.value = 0;

                % ensure antibias ramps on
                betaRampup.value = 1;
                
                if value(n_days_stage) <= 1 % stage init

                    % inter trial dur is around 4 seconds
                    inter_trial_dur_type.value = 'sampled'; % gaussain
                    inter_trial_min.value = 1; % seconds
                    inter_trial_sample_mean.value = 4; 
                    inter_trial_max.value = 9; %DB 8
                    inter_trial_sample_std.value = 1; 

                end % N days == 0
                ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
            end % N trials == 0

            % EOS -> Advance after 5 days
        
        case 10
        %%
        stage_description.value = 'probe stage- random delay';

        %%% init
        if value(n_trials_stage) == 0 % session init
            SMA_set.value = 'cpoke';
            go_type.value = 'sound';
            go_dur.value = 0.2;
            stimuli_on.value = 0;
            give_type_set.value = 'light';

            % trial structure
            target_fixation_dur.value = 2;
            settling_in_determines_fixation.value = 0;
            settling_in_dur.value = 0.150;
            cled_mapped_to_fixation_dur.value = 1;

            % Randomly sample delay
            settling_in_growth.value = 'none';
            delay_growth.value = 'exp';
            delay_warm_up.value = 0;
            
            % Random Sample from Exp
            target = value(target_fixation_dur);
            sample_min = target * 0.5; 
            sample_tau = sample_min * 1.2;
            
            DistribInterface(obj, 'set', 'exp_sample', 'Min', sample_min);
            DistribInterface(obj, 'set', 'exp_sample', 'Max', target);
            DistribInterface(obj, 'set', 'exp_sample','Tau', sample_tau);
            DistribInterface(obj, 'get_new_sample', 'exp_sample');

            % penalties
            violation_dur.value = 2;
            temp_error_penalty.value = 0;

            % ensure antibias ramps on
            betaRampup.value = 1;
            
            if value(n_days_stage) <= 1 % stage init

                % inter trial dur is around 4 seconds
                inter_trial_dur_type.value = 'sampled'; % gaussain
                inter_trial_min.value = 1; % seconds
                inter_trial_sample_mean.value = 4; 
                inter_trial_max.value = 9; %DB 8
                inter_trial_sample_std.value = 1; 

            end % N days == 0
            ShapingSection(obj, 'calculate_fixation_and_pre_go_durs')
        end % N trials == 0

        % EOS -> Advance after 5 days
        
        case 11
        %%
        stage_description.value = 'probe stages complete!';

        % set back to stable delay for all animals
        if value(n_trials_stage) == 0 % session init
            delay_growth.value = 'overnight_sampled';
        end

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
        case 9
            if value(n_days_stage) > 5
                TrainingSection(obj, 'increment_stage');
            end        
        case 10
            if value(n_days_stage) > 5
                TrainingSection(obj, 'increment_stage');
            end      

        end % switch get_eod_logic curriculum_stage_number

    end % switch action

end % function



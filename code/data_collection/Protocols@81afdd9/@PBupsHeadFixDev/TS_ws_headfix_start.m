%% TS_ws_headfix_start
%

%
%
% Stage 1: Poke Left

%

function varargout = TS_ws_headfix_start(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1: Lick for Reward',...
            '2: Simple Rule' ,...
            '3: Decrease durs 1', ...
            '4: Req Wait for Stim End', ...
            '5: Punish early stim licks', ...
            '6: Decrease Durs', ...      
            '7: Add psychometrics', ...
            '8: Add more psychometrics', ...
            '9: end state' ...
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
                stage_description.value = 'no puns, lick Correct spout anytime for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    % turn off all licking punishments
                    PunishSideChoice.value = 0;
                    PunishITIPokes.value = 0;
                    PunishStimLicks.value = 0;
                    StimRewardWait.value = 0;

                    slick_timeout.value = 20;
                    % edit stim vars to be as easy as possible
                    T_min.value = 20; %make equal to slick_timeout so that stim is always on
                    T_max.value = 20;
                    easiest.value = 99;
                    hardest.value = 99;
                    N.value = 1;

                    % set ITI values to be relatively long
                    ITI_style.value = 'gaussian';
                    ITI_mu.value = 2;
                    ITI_Sd.value = 1;
                    ITI_min.value = 0;
                    ITI_max.value = 5;

                    go_sound.value = 0; %go sound doesn't make sense at this stage
                    give_hint.value = 1; %give hint at end of stim if animal hasn't licked
                    delay_reward.value = 0; %delay reward is off
                end
                if value(nRewarded) == 60
                    give_hint.value = 0;
                end
            case 2
                stage_description.value = 'lick cor spout first for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    PunishSideChoice.value = 1;
                    give_hint.value = 0;
                    go_sound.value = 0; %go sound doesn't make sense at this stage
                    delay_reward.value = 0; %delay reward is off
                    stim_start_sound.value = 1; %turn on sounds to help shape animal when to lick
                    trial_start_sound.value = 1;
                end

            case 3
                stage_description.value = 'decrease stims so we can shape timing, animal can still lick whenever. reward delay also turns on';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    delay_reward.value = 1;
                    T_min.value = 0.2;
                    T_max.value = 0.5;
                end
            case 4
                stage_description.value = 'lick cor spout after stim ends for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    StimRewardWait.value = 1; % animal now has to wait for stim to end before getting reward (during stim state goes on)
                end
            case 5
                stage_description.value = 'punish early licks';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    PunishStimLicks.value = 1; % animal now has to wait for stim to end before getting reward (during stim state goes on)
                end
            case 6
                stage_description.value = 'increase stim duration to 1-2 slowly';
    
            case 7             
                stage_description.value = 'add psych, step down to 4 and 2';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    T_min.value = 1;
                    T_max.value = 2;

                    easiest.value = 5;
                    hardest.value = 3;
                    N.value = 2;
                end

            case 8
                stage_description.value = 'add more psych (to N =4) and make harder';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    N.value = 4;
                end
            case 9
                stage_description.value = 'end stage';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    hardest.value = 0.5;
                    easiest.value = 3.5;
                end
        end


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
                if value(nRewarded) > 120
                    TrainingSection(obj, 'increment_stage');
                end
            case 2
                if value(nRewarded) > 120 && value(n_days_stage) > 3 && value(mean_hitfrac) > 0.8 
                    TrainingSection(obj, 'increment_stage');
                end
            case 3
                if value(nRewarded) > 120 && value(mean_hitfrac) > 0.8
                    TrainingSection(obj, 'increment_stage');
                end
            case 4
                if value(nRewarded) > 120 && value(mean_hitfrac) > 0.8
                    TrainingSection(obj, 'increment_stage');
                end
            case 5
                if value(nRewarded) > 120 && value(mean_hitfrac) > 0.8 
                    TrainingSection(obj, 'increment_stage');
                end
            case 6 
                if value(nRewarded) > 120 && value(mean_hitfrac) > 0.75 %if daily trials is high and hitfrac is high, make harder
                    if round(value(T_min),1) < 1 
                        T_min.value = value(T_min) + .1;
                    end
                    if round(value(T_max),1) < 2
                        T_max.value = value(T_max) + .1;
                    end
                    if value(T_min) >= 1 && value(T_max) >= 1.5
                        T_min.value = 0.5; % put back T_min to caprture broader range of stim times
                        TrainingSection(obj, 'increment_stage');
                        
                    end
                end
            case 7
                if value(nRewarded) > 150 && value(mean_hitfrac) > 0.75 %if daily trials is high and hitfrac is high, make harder
                    if value(hardest) <= 1 && value(easiest) <= 4
                        TrainingSection(obj, 'increment_stage');
                    end
                    if value(hardest) > 1
                        hardest.value = value(hardest) - .25;
                    end
                    if value(easiest) > 4
                        easiest.value = value(easiest) - .25;
                    end
                end
            case 8
                if value(nRewarded) > 150 && value(mean_hitfrac) > 0.75 %if daily trials is high and hitfrac is high, make harder 
                    if value(hardest) > 0.5
                        hardest.value = value(hardest) - .1;
                    end
                    if value(easiest) > 3.5
                        easiest.value = value(easiest) - .1;
                    end
                    if value(hardest) <= 0.5 && value(easiest) <= 3.5
                        hardest.value = 0.5;
                        easiest.value = 3.5;
                        TrainingSection(obj, 'increment_stage');
                    end
                end
        end
end % switch action

end % function


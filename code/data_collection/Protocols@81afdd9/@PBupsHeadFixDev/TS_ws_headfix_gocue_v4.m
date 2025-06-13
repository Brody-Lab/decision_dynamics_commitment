%% TS_ws_headfix_gocue_first
%
% Stage 1: Go Sound then Lick, Reward. At this stage, the go cue is the only sound on. Reward will only dispense
% if/when the mouse licks in the 20s after the sound, then a trial will restart if the mouse has not. There is 
% no punishment for licking at any point. Reward is only available at one spout, and this is random to the mouse. 
% The mouse must get > 120 rewards to move on. 
%
% Stage 2: Punish Pre-go lick. Now, the sound that starts the stimulus period turns on, and if the mouse licks between
% the stimulus on and go sound (a uniformly drawn time between .2 and .5s), there is a punishment sound and timeout for 
% the mouse. The mouse must get > 120 rewards and violate less than 20% of trials to move on. 
%
% Stage 3: Intro Stim. Turns on the stimulus sound. Mouse isn't yet punished, but still needs to get >120 rewards and 
% violate less than 20% of trials.
%
% Stage 4: Require correct response. Mouse now must lick the correct spout based on the stimulus sound the first time
% to get reward. The stimulus has no distractors in it. To move on, the mouse must get >120 rewards, get >80% correct, and 
% violate less than 20% of trials.
%
% Stage 5: Increase Stim Length. Grow the stimulus length, growing the amount of time the mouse must withhold licking.
% At the end of each day, if the mouse has get >75% correct, and  violate less than 20% of trials, the min and max times
% grow .1 seconds until the max time is 1.5 s.
%
% Stage 6: Add psychometrics. Add 2 gammas (5 and 3), and if mouse is rewarded 150 trials and hitfrac is >75% at end of session,  
% step down .25 until the values are 1 and 4.
% 
% Stage 7: Add more psychometrics. Add 2 more gammas (1, 2, 3, 4), and if mouse is rewarded 150 trials and hitfrac is >75% at end of session,  
% step down .1 until the values are 0.5 and 3.5. 



function varargout = TS_ws_headfix_gocue_v4(obj, action, varargin)


GetSoloFunctionArgs(obj);

switch action,

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    % Called by `create_stage_list` in `TrainingSection.m and these values
    % are used to create the stage name menu param in the GUI

    case 'get_stage_list'
        varargout{1} = {...
            '1: Go Sound then Lick, Reward' , ...
            '2: Punish Pre-go lick', ...
            '3: Intro Stim', ...
            '4: Give hint with Correct response', ...
            '5: Require Correct response', ...
            '6: Increase Stim Length', ...
            '7: Add psychometrics', ...
            '8: Finish viols shaping', ...
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
                stage_description.value = 'no puns, lick correct spout after go cue for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    % turn off all licking punishments
                    PunishSideChoice.value = 0; % animal can lick either side
                    PunishITIPokes.value = 0;
                    PunishStimLicks.value = 0;

                    StimRewardWait.value = 1; % animal can never get reward for lick during stim

                    slick_timeout.value = 5;

                    stim_window.value = 0.3;
                    T_min.value = 0.5; %use T values to control stim on->go sound length
                    T_max.value = 1;


                    vol_on.value = 0; %turn off stim
                    easiest.value = 99;
                    hardest.value = 99;
                    N.value = 1;

                    % set ITI values to be relatively long
                    ITI_style.value = 'gaussian';
                    ITI_mu.value = 2;
                    ITI_Sd.value = 1;
                    ITI_min.value = 2;
                    ITI_max.value = 5;

                    % set up which sounds are on
                    go_sound.value = 1;                     
                    stim_start_sound.value = 1; 
                    trial_start_sound.value = 0; 

                    % set trial light to on
                    vis_stim_light.value = 1;

                    stim_delay_type.value = 0;
                    stim_delay_Min.value = 0;
                    stim_delay_Max.value = 0;
                    % set up reward timing places
                    give_hint.value = 0; %give hint off
                    delay_reward.value = 0; %delay reward is off
                end
                if value(nRewarded) < 10 % animals get 50% give for first 10 trials the collect reward
                    give_hint.value = 1; %give hint on for first 10 trials
                    give_perc.value = 0.5;
                elseif value(nRewarded) == 10
                    give_hint.value = 0; %give hint off after 10 trials
                end

            case 2
                stage_description.value = 'lick cor spout after go cue for reward, punish pre-go licks';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    PunishStimLicks.value = 1; % punish pre go licks
                    PunishSideChoice.value = 0; % no cues so no punishments

                    go_sound.value = 1; 
                    delay_reward.value = 0; %delay reward is off
                    miss_iti.value = 5; % longer ITI if animal licks pre go cue

                    stim_delay_type.value = 1;

                    T_min.value = 0.3;
                    T_max.value = 0.3;
                    stim_window.value = 0.3;

                end

            case 3
                stage_description.value = 'turn on stim, no puns, lick cor spout after stim ends for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    vol_on.value = 1; %turn on stim
                    reinforce_sound.value = 1; % turn on reinforcement to start associating sound with reward
                end
                
            case 4
                stage_description.value = 'give off punish incorrect responses,lick cor spout after stim ends for reward';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    PunishSideChoice.value = 1; % punish incorrect responses
                    vol_on.value = 1; %turn on stim
                    give_hint.value = 0; %give hint off
                end
            case 5                
                stage_description.value = 'increase stim dur slowly';

            case 6
                stage_description.value = 'add psychometrics';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    N.value = 2; 
                    easiest.value = 5;
                    hardest.value = 3;                   
                end
            case 7
                stage_description.value = 'add more psych (to N =4) and make harder';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    N.value = 4;
                end
            case 8
                stage_description.value = 'end stage';
                if value(n_trials_stage) < 2 & value(n_days_stage) == 1
                    hardest.value = 0.5;
                    easiest.value = 3.5;
                end
            case 9
                stage_description.value = 'end stage';
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
                if value(nRewarded) > 100
                    TrainingSection(obj, 'increment_stage');
                end
            case 2
                if value(nRewarded) > 120 && value(nViolation)/value(nTrials) < 0.3 %animal must be successfully waiting to lick until go cue 
                    if value(stim_window) >= 0.5
                        T_min.value = 0.3; % put back T_min to caprture broader range of stim times
                        TrainingSection(obj, 'increment_stage');                      
                    end
                    if round(value(stim_window),1) < 0.5 % If we made the task easier, we need to then grow times again for subsequent stage
                        stim_window.value = value(stim_window) + .1;
                    end
                end
            case 3
                if value(nRewarded) > 120 && value(nViolation)/value(nTrials) < 0.3 % same req with sound on (new sounds may induce early licking)
                    TrainingSection(obj, 'increment_stage');
                end
            case 4
                if value(nRewarded) > 120 && mean(value(LtHits)) > 0.7 && mean(value(RtHits)) > 0.7 && value(nViolation)/value(nTrials) < 0.3% EDIT THIS TO BE 120 && value(n_days_stage) > 3 % animal must successfully use rule for 3 days
                    reinforce_sound.value = 0; % turn off reinforcement before next stage  
                    TrainingSection(obj, 'increment_stage');
                end
                if value(mean_hitfrac) < 0.65 && value(n_days_stage) > 5
                    reinforce_sound.value = 1; % if animal is not performing well for multiple days, turn on sound replay for reinfocement
                end

            case 5
                if value(nRewarded) > 120 && mean(value(LtHits)) > 0.7 && mean(value(RtHits)) > 0.7 && value(nViolation)/value(nTrials) < 0.3 %if daily trials is high and hitfrac is high, make harder 
                    if value(T_min) >= 0.5 && value(T_max) >= 1.5
                        T_min.value = 0.5; % put back T_min to caprture broader range of stim times
                        stim_window.value = value(T_max)+.1;
                        TrainingSection(obj, 'increment_stage');                      
                    end
                    if round(value(T_max),1) < 1.5
                        T_max.value = value(T_max) + .1;
                        stim_window.value = value(T_max)+.1;
                    end
                    if round(value(T_min),1) < 0.5
                        T_min.value = value(T_min) + .1;
                    end
                end
            case 6
                if value(nRewarded) > 120 && mean(value(LtHits)) > 0.7 && mean(value(RtHits)) > 0.7  && value(nViolation)/value(nTrials) < 0.3 %if daily trials is high and hitfrac is high, make harder
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
            case 7
                if value(nRewarded) > 120 && mean(value(LtHits)) > 0.7 && mean(value(RtHits)) > 0.7  && value(nViolation)/value(nTrials) < 0.3 %if daily trials is high and hitfrac is high, make harder 
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
            case 8
                if value(nRewarded) > 120 && mean(value(LtHits)) > 0.7 && mean(value(RtHits)) > 0.7  && value(nViolation)/value(nTrials) < 0.3  %if daily trials is high and hitfrac is high, make harder 
                    if value(T_min) >= 0.5 && value(T_max) >= 1.5 && value(viol_grace_dur) == 0 && n_days_stage > 5
                        L_pprobs.value = [.1 .1 .1 .2];
                        R_pprobs.value = [.1 .1 .1 .2];
                        TrainingSection(obj, 'increment_stage');
                    end
                    if value(T_max) >= 1.5 
                        if value(viol_grace_dur) <= 0.1
                            viol_grace_dur.value = max(0,round(value(viol_grace_dur)-.025,4));
                        if value(viol_grace_dur) > 0.1
                            viol_grace_dur.value = max(0,round(value(viol_grace_dur)-.1,4));
                        end
                    end
                    end
                    if value(T_max) < 1.5
                        T_max.value = value(T_max) + .1;
                        stim_window.value = value(T_max);
                    end

                end
        end
end % switch action

end % function


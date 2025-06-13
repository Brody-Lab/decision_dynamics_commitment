%% TS_ws_headfix_start
%

%
%
% Stage 1: Poke Left

%

function varargout = TS_fixtorule_cont_stim_wean(obj, action, varargin)


    GetSoloFunctionArgs(obj);
    
    switch action,
    
        %---------------------------------------------------------------%
        %          get_stage_list                                       %
        %---------------------------------------------------------------%
        % Called by `create_stage_list` in `TrainingSection.m and these values
        % are used to create the stage name menu param in the GUI
    
        case 'get_stage_list'
            varargout{1} = {...
                '1: Lights Only',...
                '2: Increase Vol' ,...
                '3: Stochastic Lights', ...
                '4: No Lights, Test Rule, Continue Stim', ...
                '5: No Lights, Test Rule, decrease vol', ...
                '6: Decrease Times', ...
                '7: End of Stage Temp'
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
                    stage_description.value = 'no sounds, lights and fixate only';
                    if  value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        stim_type.value = 'Light Only';
                        vol.value = 0;
                        nose_in_center.value = 1.5;
                        settling_in_dur.value = .15;
                        legal_cbreak.value = .05;
                        probe_frac.value = 0;
                    end

                case 2
                    stage_description.value = 'turn on and slowly increase vol';
                    vol_on.value = 1;
                    if value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        stim_type.value = 'Light AND Sound';
                        vol.value = 0.05;
                        use_give.value = 0;
                        
                    end
                    
                case 3
                    stage_description.value = 'wean rats off lights and onto sound rule';
                    if value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        stim_type.value = 'Light AND Sound';
                        vol.value = 0.2;
                        use_give.value = 1;
                        light_give_frac.value = 0.6;
                    end

                case 4
                    stage_description.value = 'no lights, test rule';
                    if value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        stim_type.value = 'Sound Only';
                        vol.value = 0.2;
                        use_give.value = 0;
                        light_give_frac.value = 0;
                        probe_frac.value = 0;
                    end
                case 5
                    stage_description.value = 'no lights, test rule, decrease cont vol';
                    if value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        stim_type.value = 'Sound Only';
                        use_give.value = 0;
                        light_give_frac.value = 0;
                        probe_frac.value = 0;

                        continue_stim.value = 1;
                        continue_vol_mult.value = 1;
                    end
                case 6
                    stage_description.value = 'decrease min click train times';
                    if value(n_trials_stage) < 2 && value(n_days_stage) == 1
                        T_min.value = 1.5;
                        T_max.value = 1.5;

                    end
                case 7
                    stage_description.value = 'temp stage, no changes pre probe';
                    
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
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) 
                        TrainingSection(obj, 'increment_stage', 2);
                    end
                case 2
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) 
                        if value(vol) >= .2
                            TrainingSection(obj, 'increment_stage', 3);
                        else
                            vol.value = value(vol) + .05;
                        end
                    end
                case 3
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) && nanmean(no_give_hit_history) > 0.75
                        if value(light_give_frac) > 0
                            light_give_frac.value = value(light_give_frac) - 0.15;
                        else
                            TrainingSection(obj, 'increment_stage', 4);
                        end
                    end
                case 4
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) && nanmean(hit_history) > 0.75 && value(n_days_stage) > 4
                        TrainingSection(obj, 'increment_stage', 5);
                    end

                case 5
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) && nanmean(hit_history) > 0.75
                        if value(continue_vol_mult) > 0.05
                            continue_vol_mult.value = value(continue_vol_mult) * 0.5;
                        else
                            TrainingSection(obj, 'increment_stage', 6);
                        end
                    end
                case 6
                    if value(n_done_trials) >= 100 && value(mean(violation_history) < 0.2) && nanmean(hit_history) > 0.75
                        if value(T_min) > 0.5
                            T_min.value = value(T_min) - 0.1;
                            if value(T_max) > 1
                                T_max.value = value(T_max) - 0.1;
                            end
                        else
                            TrainingSection(obj, 'increment_stage', 7);
                        end
                    end
            end
    end % switch action
    
    end % function
    
    
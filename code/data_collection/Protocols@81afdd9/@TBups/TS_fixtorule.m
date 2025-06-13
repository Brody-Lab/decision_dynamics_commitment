%% TS_ws_headfix_start
%

%
%
% Stage 1: Poke Left

%

function varargout = TS_fixtorule(obj, action, varargin)


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
                '4: Reg/Irreg Endpoints'
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

            end
    end % switch action
    
    end % function
    
    
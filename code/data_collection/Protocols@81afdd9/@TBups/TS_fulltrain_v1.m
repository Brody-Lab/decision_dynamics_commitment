%% TS_ws_headfix_start
%

%
%
% Stage 1: Poke Left

%

function varargout = TS_fulltrain_v1(obj, action, varargin)


    GetSoloFunctionArgs(obj);
    
    switch action,
    
        %---------------------------------------------------------------%
        %          get_stage_list                                       %
        %---------------------------------------------------------------%
        % Called by `create_stage_list` in `TrainingSection.m and these values
        % are used to create the stage name menu param in the GUI
    
        case 'get_stage_list'
            varargout{1} = {...
                '1: L Poke for reward',...
                '2: R poke for reward' ,...
                '3: Block poke for reward', ...
                '4: C->side poke in blocks', ...
                '5: C->side poke random', ...
                '6: '
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
                    stage_description.value = 'no c poke, gocue, light on, poke left for reward';
                    if value(n_done_trials) < 2 || value(n_trials_stage) < 2
                        stim_type.value = 'Light Only';
                        use_give.value = 0;
                        vol.value = 0;
                        cpoke_first.value = 0;
                        go_sound.value = 1;
                        nose_in_center.value = 0;
                        probe_frac.value = 0;

                        PunishSideChoice.value = 0;

                        in_left_block.value = 1;
                        in_right_block.value = 0;
                    end

                    if value(n_trials_stage) >= 80 && value(mean(tup_history)) < 0.2
                        left_poke_stage_complete.value = 1;
                        TrainingSection(obj, 'increment_stage', 2);
                    end

                case 2
                    stage_description.value = 'no c poke, gocue, light on, poke right for reward';
                    if value(n_done_trials) < 2 || value(n_trials_stage) < 2
                        stim_type.value = 'Light Only';
                        vol.value = 0;
                        cpoke_first.value = 0;
                        go_sound.value = 1;
                        nose_in_center.value = 0;
                        probe_frac.value = 0;

                        PunishSideChoice.value = 0;

                        in_left_block.value = 0;
                        in_right_block.value = 1;
                    end
                    if value(n_trials_stage) >= 80 && value(mean(tup_history)) < 0.2
                        right_poke_stage_complete.value = 1;
                        TrainingSection(obj, 'increment_stage', 3);
                    end                   
                case 3
                    stage_description.value = 'move rats to block side pokes';
                    if value(n_trials_stage) < 2
                        block_size.value = 20;
                        p = rand(1);
                        if p < 0.5
                            in_left_block.value = 1;
                            in_right_block.value = 0;

                        else 
                            in_left_block.value = 0;
                            in_right_block.value = 1;

                        end
                    
                    % check to see if time for block switch
                    elseif rem(value(n_trials_stage), value(block_size)) == 0
                        was_block_switch.value = 1;
                        if value(in_left_block) % switch to right
                            in_left_block.value = 0;
                            in_right_block.value = 1;

                        elseif value(in_right_block) % switch to left
                            in_left_block.value = 1;
                            in_right_block.value = 0;

                        end
                    else
                        was_block_switch.value = 0;
                    end

                case 4
                    stage_description.value = 'rand side pokes';
                    if value(n_done_trials) < 2 || value(n_trials_stage) < 2
                        in_left_block.value = 0;
                        in_right_block.value = 0;
                        cpoke_first.value = 0;
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
                    if value(n_done_trials) >= 80 && value(mean(tup_history)) < 0.2
                        TrainingSection(obj, 'increment_stage', 2);
                    end
                case 2
                    if value(n_done_trials) >= 80 && value(mean(tup_history)) < 0.2
                        TrainingSection(obj, 'increment_stage', 3);
                    end
                case 3
                    if value(n_done_trials) >= 80 && value(mean(tup_history)) < 0.2
                        TrainingSection(obj, 'increment_stage', 2);
                    end

                case 4

            end
    end % switch action
    
    end % function
    
    
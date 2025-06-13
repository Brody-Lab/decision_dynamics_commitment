%% TS_light_guide_no_fix
%
% Curriculum writtten by JRB 
%
% Inspired by light guided shaping that has previously worked
% well for rats
%

function varargout = TS_JB_light_guide_no_fix(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action

    %---------------------------------------------------------------%
    %          get_stage_list                                       %
    %---------------------------------------------------------------%
    case 'get_stage_list'
        varargout{1} = {...
            '1: left poking',...
            '2: right poking',...
            '3: center to side',...
            '4: center to side w/ growth',...
            '5: introduce sounds',...
            '6: remove light guide',...
            '7: remove water guide',...
            '8: TBD3',...
        };
    
    % want to think about:
    % * introducing mulitiple growing delays- are those separate
    % * stages?

    % * if stage 1 and 2 should really be separate or there 
    % * is just a ShapingSection case that determines L or R
    % * side for the day and then keeps track of n_good days
    % * when switching turns off

    % * if there is any helper logic 


    %---------------------------------------------------------------%
    %          get_curriculum_update                                %
    %---------------------------------------------------------------%
    case 'get_curriculum_update'
        stage_num = value(varargin{1});
        
        switch stage_num
        
        case 1
            stage_description.value= 'learn to poke in left port';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end

        case 2
            stage_description.value= 'learn to poke in right port';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end

        case 3
            stage_description.value= 'c -> s w/ small delay + guides';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end
        
        case 4
            stage_description.value= 'c -> s grow delay + guides';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end
        
        case 5
            stage_description.value= 'introduce sounds + guides';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end
        
        case 6
            stage_description.value= 'remove light guide';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end
        
        case 7
            stage_description.value= 'remove water guide';
            % settings on protocol init
            if n_trials_stage == 0

                % settings on first day in stage
                if n_days_stage > 1
                    disp('');
                else
                    disp('');
                end

            % settings for every trial
            else
                disp('');
            end

            % EOS
            if value(n_done_trials) >= 70 && value(percent_correct) > .7
                TrainingSection(obj, 'increment_stage');
            end
        end % stage_num switch
    end % get_curriculum_update switch
end 

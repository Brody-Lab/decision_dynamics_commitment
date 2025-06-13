
function [x, y] = HitSection(obj, action, x, y)

GetSoloFunctionArgs(obj);

switch action
    
    %% prepare_next_trial
    % -----------------------------------------------------------------------
    %
    %         PREPARE_NEXT_TRIAL
    %
    % -----------------------------------------------------------------------
    
    case 'prepare_next_trial'
        
        if n_done_trials > 0
            
            % Get last time of "correct" response
            right_correct = get_last_state(parsed_events.states, 'right_correct');
            left_correct = get_last_state(parsed_events.states, 'left_correct');
            
            max_correct = max([right_correct, left_correct]);
            
            %Get last time of "wrong" response
            right_wrong = get_last_state(parsed_events.states, 'right_wrong');
            left_wrong = get_last_state(parsed_events.states, 'left_wrong');
            
            max_wrong = max([right_wrong, left_wrong]);
            
            %Count consecutive hits
            %If the correct response was later, it was a hit, else was a
            %miss
            % hit_history 2x1 vector consecutive (hits, misses)
            hit_ac = value(hit_history);
            %Correct trial
            if max_correct > max_wrong
                hit_ac(1) = hit_ac(1) + 1;
                hit_ac(2) = 0;
                % If we got three hits in a row, it gets more difficult
                if hit_ac(1) == 3
                    SoundSection(obj, 'sounds_more_difficult')
                    hit_ac(1) = 0;
                end
            % Miss trial
            else
                hit_ac(2) = hit_ac(2) + 1;
                hit_ac(1) = 0;
                if hit_ac(2) == 3
                    SoundSection(obj, 'sounds_more_easy')
                    hit_ac(2) = 0;
                end
            end
            hit_history.value = hit_ac;
            value(hit_history)
            
        end
        
end

%Get last time state with "statename" was executed
function time =  get_last_state(states, statename)

% If state doesn't exist, it was not present in this trial
if isempty(states.(statename))
    time = -Inf;        
else
    %Get the end time of the state
    time = states.(statename)(end);
end

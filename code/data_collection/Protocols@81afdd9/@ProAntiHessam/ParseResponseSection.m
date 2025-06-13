function [x, y] = ParseResponseSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);

switch action
      
     
   %% case parse_just_finished_trial      
    case 'parse_just_finished_trial'
        if n_done_trials < 1,
            return;
        end;
        
        if isempty(parsed_events) || ~isstruct(parsed_events) || ...
                ~isfield(parsed_events, 'states'),
            return;
        end;
        
        completed_cfix.value = ~isempty(parsed_events.states.delay_period);
        
        if(~isempty(parsed_events.states.correct_spoke))
            prev_correct.value = true;
        elseif(~isempty(parsed_events.states.wrong_spoke))
            prev_correct.value = false;
        else
            prev_correct.value = nan;
        end

        
        prev_side.value = TrialSection(obj, 'get_side');
        
        cfix_history.value = [value(cfix_history), value(completed_cfix)];
        correct_history.value = [value(correct_history), value(prev_correct)];
        side_history.value = [value(side_history), value(prev_side)];
        
        fprintf('completed_cfix = %d\n', value(completed_cfix));
        
end;


%% -----------------  function parse_specific_trial

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
        
        completed_cfix.value = isempty(parsed_events.states.cbreak);
        
        if(~isempty(parsed_events.states.double_poke))
            prev_correct.value = nan;
        elseif(~isempty(parsed_events.states.correct_spoke))
            prev_correct.value = true;
        elseif(~isempty(parsed_events.states.wrong_spoke))
            prev_correct.value = false;
        else
            prev_correct.value = nan;
        end

        
        prev_target.value = TrialSection(obj, 'get_target');
        prev_context.value = TrialSection(obj, 'get_context');
        
        cfix_history.value = [value(cfix_history), value(completed_cfix)]; %#ok<NODEF>
        correct_history.value = [value(correct_history), value(prev_correct)]; %#ok<NODEF>
        target_history.value = [value(target_history), value(prev_target)]; %#ok<NODEF>
        context_history.value = [value(context_history), value(prev_context)]; %#ok<NODEF>
        
        fprintf('completed_cfix = %d\n', value(completed_cfix));
        
end;


%% -----------------  function parse_specific_trial

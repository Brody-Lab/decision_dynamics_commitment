% [obj] = compute_next_trial(obj, {'eval_EOD', 0}, {'old_style_parsing_flag', 1})
%
% This is the function used by SessionModel to evaluate the active training
% stage, whenever it is called (presumably, at the end of each trial in the
% session).
% If there are no more training strings to be evaluated, no values are
% changed.
% However, if there is an active training string, the following steps get
% taken:
% 1. The statement (active training string) is evaluated, and associated
% callbacks are called.
% 2. The string to test for training stage completion is evaluated. If it
% evaluates to FALSE, the training stage is retained as the active training
% stage and is evaluated again at the time of the next call to
% compute_next_trial. However, if it evaluates to TRUE, the current
% training stage is flagged as being complete, and SessionModel sets the
% next training stage (in order of registration) as being the active
% training stage.
%
% If there is an error on evaluation of the training string, and the
% calling object has @comments as a plugin, a line reporting the error is
% appended to the comments.
%
%
% OPTIONAL PARAMS:
% ----------------
%
% eval_EOD    By default 0. If 0, then the current training stage is
%             evaluated, followed by the completion string and a step to
%             the next stage is performed if necessary. In contrast, if
%             eval_EOD is 1, then the end_of_day_logic string is evaluated,
%             and the completion string is not used.
%
% old_style_parsing_flag  By default 1. If this is 0, then each line in training
%            string, completion string, or end-of-day logic string is
%            treated as a separate line. As in Matlab, lines that start
%            with % as treated as comments and are ignored, and to continue
%            a statement across a line break, you must end the line with
%            "..."
%


function [obj] = compute_next_trial(obj, varargin)

pairs = { ...
    'eval_EOD'         0   ; ...
    'old_style_parsing_flag'   1   ; ... 
    };
parse_knownargs(varargin,pairs);

GetSoloFunctionArgs('func_owner', get_owner(obj), 'func_name', 'SessionModel');    % should now have access to all variables owned by its owner

% struct('training_stages', {{}}, ...
%    'current_train_stage', 1, ...
%    'train_string_COL', 1, ...
%    'completion_test_COL', 2, ...
%    'is_complete_COL', 3, ...
%    'name_COL', 4, ...
%    'vars_COL', 5, ...
%    'param_owner', '' );


curr = obj.current_train_stage;
ts = get_training_stages(obj);

mycol = obj.train_string_COL;
if eval_EOD > 0,
    mycol = obj.EOD_logic_COL;
end;

if curr <= rows(ts) && ~ts{curr, obj.is_complete_COL}
    eval_stmt = ts{obj.current_train_stage, mycol};
    try
      dummy = get_string(eval_stmt, old_style_parsing_flag);
      eval(dummy);
    catch %#ok<CTCH>
        fprintf(1, ['Unable to evaluate training stage string! Error was:' ...
          lasterr '\n']); %#ok<LERR>
        try % we'll try to append a line to CommentsSection of this protocol, reporting the error
          owner_obj = eval(obj.param_owner(2:end));
          if isa(owner_obj, 'comments'),
            CommentsSection(owner_obj, 'append_line', 'Unable to evaluate training stage string!');
            CommentsSection(owner_obj, 'append_line', sprintf(['Error was:' lasterr])); %#ok<LERR>
          end;
        catch %#ok<CTCH>
        end;
    end;

    new_curr = get_current_training_stage(value(SessionDefinition_my_session_model));
    if new_curr ~= curr % some jumping has been going on
        % sync the two objects
        obj = value(SessionDefinition_my_session_model);
        return;
    end;


    if eval_EOD < 1
        test_complete = ts{curr, obj.completion_test_COL};
        try
          dummy = get_string(test_complete, old_style_parsing_flag);
          eval(['done = ' dummy ';']);
        catch %#ok<CTCH>
          private_came_through_ok = 0;
          lerr = lasterror; %#ok<LERR>
          if strcmp(lerr.identifier, 'MATLAB:m_invalid_lhs_of_assignment'),
            try
              eval(dummy);
              if exist('this_trial', 'var'), 
                done = this_trial;
                private_came_through_ok = 1;
              end;
            catch %#ok<CTCH>
              lerr = lasterror; %#ok<LERR>
            end;
          end;
          
          if private_came_through_ok == 0,
            fprintf(1, ['Unable to test completion of current training stage! ' ...
              'Error was:' lerr.message]);
            try % we'll try to append a line to CommentsSection of this protocol, reporting the error
              owner_obj = eval(obj.param_owner(2:end));
              if isa(owner_obj, 'comments'),
                CommentsSection(owner_obj, 'append_line', ...
                  sprintf(['Unable to test completion of current training stage! ' ...
                  'Error was:' lasterr])); %#ok<LERR>
              end;
            catch %#ok<CTCH>
            end;

            done = 0;
          end;
        end;
        
        if done,
            obj = mark_as_complete(obj, curr);
            obj = set_current_training_stage_unchecked(obj, curr+1);
        end;
    end;
else
    return; % do nothing
end;


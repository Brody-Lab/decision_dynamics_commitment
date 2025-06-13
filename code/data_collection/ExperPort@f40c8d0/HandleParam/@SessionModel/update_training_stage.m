function [obj] = update_training_stage(obj, idx, new_ts, varargin)

% Updates a training string indexed by its registered position
% This function will update either the train_string or the
% completion_string
% string of a specified training stage.
%
% Example of usage:
% update_training_stage(obj, 3, 'value(mySoloFunction_myParam) == 24',
% 'utype', 'completion_string')
% will update the completion_string of registered training stage #3 to
% 'value(mySoloFunction_myParam) == 24'.
%
% "utype" may be one of the following:
% a) 'train_string': updating a train_string (the main string that contains
% update rules of a training stage),
% b) 'completion_string': updating a completion string (which determines
% till when a train_string is active and when a training stage is
% complete), or
% c) 'name': a name for the training stage, or
% d) 'vars': a string of whitespace-separated varnames
% e) 'eod': a string that evaluates if part of the active training stage at
% the end of a session
%

   
pairs = { ...
    'utype', 'train_string' };
parse_knownargs(varargin, pairs);

if strcmpi(utype, 'train_string'),
    col = obj.train_string_COL;
elseif strcmpi(utype, 'completion_string'),
    col = obj.completion_test_COL;
elseif strcmpi(utype, 'name'),
    col = obj.name_COL;
elseif strcmpi(utype, 'vars'),
    col = obj.vars_COL;
    if isstr(new_ts), new_ts = cellize_tokens(new_ts); end;
elseif strcmpi(utype, 'eod'),
    col = obj.EOD_logic_COL;
else
    error('Error while updating training stage: ''utype'' should be either ''train_string'', ''completion_string'', ''name'', ''vars'' or ''eod''!');
end;

ts = get_training_stages(obj);
if idx > rows(ts) | idx < 0,
    error('Error while updating training stage: Invalid index!');
end;

if strcmpi(utype,'name') & ~isstr(new_ts)
    error('Name should be a string!');
elseif isnumeric(new_ts),
    if strcmp(utype, 'completion_string'),
        if new_ts == 1 | new_ts == 0
            new_ts = num2str(new_ts);
        else
            error('Use only ''1'' and ''0'' to indicate ''true'' and ''false'' respectively');
        end;
    else
        error('Sorry, this field cannot be numeric');
    end;
end;

if idx == get_current_training_stage(obj) && strcmpi(utype, 'vars'),
  old_handlenames = get_helper_vars(obj, idx);
  ts{idx, col} = new_ts;
  obj.training_stages = ts; 
  new_handlenames = get_helper_vars(obj, idx);

  try
    delete_current_sphandles(obj, idx, setdiff(old_handlenames, new_handlenames));
    create_current_sphandles(obj, idx, setdiff(new_handlenames, old_handlenames));
  catch
    lerr = lasterror;
    fprintf(1, 'Error with Helper Vars: "%s"\n', lerr.message);
  end;
else
  ts{idx, col} = new_ts;
  obj.training_stages = ts; 
end;

   

% ------------------------------------------------------------------------
function [concat] = get_string(str)
t = cellstr(str);
concat = 't{1}';
for ctr = 2:size(t,1)
    temp = t{ctr}; t{ctr} = [' ' temp ' '];
    concat = [concat ', t{' num2str(ctr) '}'];
end;
return;


% ------------------------------------------------------------------------
function [cvars] = cellize_tokens(vars)
   if ~isstr(vars), error('Sorry, vars can only be of string form'); end;

   % If multi-line, make sure lines are separated by whitespace, and
   % then concatenate all into one string:
   vars = [vars ones(rows(vars), 1)*' '];
   vars = vars';
   vars = vars(:);
   vars = vars';
   
   cvars = {};
   [s, vars] = strtok(vars);
   if ~isempty(s),
      cvars = [cvars ; {s}];
      [s, vars] = strtok(vars);
   end;
   return;
   
   
   
   
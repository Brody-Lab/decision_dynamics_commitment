function [obj] = add_training_stage(obj, varargin)
%
% Adds a training stage to the *end* of the list of registered
% training stages.
% A training stage has three parts:
% 1) train_string: The autoset string that is evaluated at the end of each
% trial; this string updates the parameters for that training stage
% 2) complete_test: An expression which evaluates to either true or false,
% and determines the point till when "train_string" is the active autoset
% string.
% Once 'complete_test' evaluates to true, SessionModel flags the
% corresponding train_string as being complete and proceeds to set the next
% autoset string as the active one
% 3) is_complete: 1 or 0, depending on whether SessionModel should evaluate
% the autoset string when it is set as the active one. Set this value to 1
% if the corresponding training stage has been completed; else, set it to
% 0.
%
% Examples of use:
% Example 1:
% add_training_stage(obj,...
% 'train_string', 'ChordSection_Tone_Dur1.value_callback =
% ChordSection_Tone_Dur1 + 0.1', ...
% 'complete_test', 'single(value(ChordSection_Tone_Dur1)) == single(0.3)',
% 'is_complete', 0 );
%
% translates to a training stage where ChordSection_Tone_Dur1 is
% incremented by 0.1 at the end of every trial, until the value reaches
% 0.3; then the stage is marked as complete and this increment no longer
% occurs.
%
% Default values:
% 'train_string': (blank)
% 'complete_test': '1' (true),
% 'is_complete': 0 (false).
%

pairs = { ...
    'train_string', ''  ; ...
    'complete_test', '1' ; ...
    'is_complete', 0    ; ...
    'name', 'unnamed'   ; ...
    'vars', ''          ; ...
    'eod', '' ; ...
    };
parse_knownargs(varargin, pairs);

t1   = get_string(train_string);
eodstr = get_string(eod);
if isstr(vars), vars = cellize_tokens(vars); end;

if isempty(eod)
    eod = ' ';
end;
if isempty(train_string)
    train_string = ' ';
elseif ~isstr(name)
    error('Training stage name should be a string!');
elseif isnumeric(train_string),
    error('Sorry, training string can only be a string');
elseif isnumeric(complete_test),
    if complete_test == 1 | complete_test == 0
        complete_test = num2str(complete_test);
    else
        error('Use only ''1'' and ''0'' to indicate ''true'' and ''false'' respectively');
    end;
end;

ts = get_training_stages(obj);
ts(rows(ts)+1, 1:6) = { train_string, complete_test, is_complete, name, vars,eod};
obj.training_stages = ts;

% ------------------------------------------------------------------------
function [concat] = get_string(str)
if isempty(str),
    concat = '';
else
    t = cellstr(str);

    concat = 't{1}';
    for ctr = 2:size(t,1)
        temp = t{ctr}; t{ctr} = [' ' temp ' '];
        concat = [concat ', t{' num2str(ctr) '}'];
    end;
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

cvars = {};
[s, vars] = strtok(vars);
if ~isempty(s),
    cvars = [cvars ; {s}];
    [s, vars] = strtok(vars);
end;



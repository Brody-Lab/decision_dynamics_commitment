function [obj] = SessionModel(varargin)
%
% Constructor for a SessionModel object
% In a nutshell, a SessionModel is an object that allows a serialised collection of 
% autoset strings to be evaluated in controlled succession; this is the
% programmatic equivalent of automated phases of training.
%
% A SessionModel object can be owned by an entity that can own SoloParamHandles; 
% It then automatically has read-write access to all the SPH's of its
% owner. This access means that unlike parameter-specific autoset strings,
% the autoset string of a SessionModel can:
% 1. control the values of SPH's owned by different SoloFunctions of its
% owner object
% 2. additionally call the callback of those SPH's after changing their
% value.
%
% NOTE!! To ensure that the callback of a changed parameter is infact
% called, the ".value_callback" notation should be used to update a
% parameter value, instead of the regular ".value" call.
% i.e. ChordSection_Tone_Dur1.value_callback = ChordSection_Tone_Dur1 + 0.1
% WILL invoke the callback of ChordSection_Tone_Dur1, but 
% ChordSection_Tone_Dur1.value = ChordSection_Tone_Dur1 + 0.1
% WILL NOT!



s = struct('training_stages', {{}}, ...
    'current_train_stage', 1, ...
    'train_string_COL', 1, ...
    'completion_test_COL', 2, ...
    'is_complete_COL', 3, ...
    'name_COL', 4, ...
    'vars_COL', 5, ...  
    'EOD_logic_COL', 6, ...
    'param_owner', '');

obj = class(s, 'SessionModel');

% default object
if nargin == 0,return;
elseif nargin == 1
    arg = varargin{1};
    if isa(arg, 'SessionModel'), obj = arg; return; end;
else
   
    pairs = { ...
        'in_train_set', {} ; ...
        'in_curr_stage', 1 ; ...
        'param_owner', ''; ...
        };
    parse_knownargs(varargin, pairs);
    
    % get my owner
    if ~isobject(param_owner) && ...
            ~(ischar(param_owner) && strcmp(param_owner, 'base')),
        error('param owner an object or the string ''base''');
    end;
    if isstr(param_owner), param_owner = 'base';
    elseif isobject(param_owner), 
        param_owner = ['@' class(param_owner)];
    end;

    if ~isempty(in_train_set)
        obj = add_training_stage_many(obj, in_train_set);
    end;
        obj = set_current_training_stage(obj, in_curr_stage);
    obj = set_param_owner(obj, param_owner); 
end;
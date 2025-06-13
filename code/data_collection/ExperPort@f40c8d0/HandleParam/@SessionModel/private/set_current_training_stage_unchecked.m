% [obj] = set_current_training_stage_unchecked(obj, val, {'hvar_names_and_values', [])
%
% Assumes that val is numeric and is within appropriate range.
%
% If val is equal to the current training stage, does
% nothing. Otherwise, calls manage_helper_var_creation_and_deletion on the
% old and new training stage numbers, and sets the current training stage
% number to val.
%
% OPTIONAL PARAMS:
% ----------------
%
% 'hvar_names_and_values'  By default, an empty matrix []. In this case,
%                          normal operation proceeds. However, if it is
%                          passed as an n-by-1 structure, with fieldnames 
%                          'name' and 'value', then the previous stage's
%                          (i.e., currently existing) helper vars are
%                          treated as if they included the passed names and
%                          values. Any preexisting helper var whose name
%                          matches one of those passed is set to the passed
%                          value. Also, any vars with forceinit=1 are
%                          reinitialized, even if we're jumping within the
%                          same stage.
%
%


function [obj] = set_current_training_stage_unchecked(obj, val, varargin)
   pairs = { ...
     'hvar_names_and_values'     []  ; ...
   }; parseargs(varargin, pairs);

   if obj.current_train_stage == val && ~isstruct(hvar_names_and_values), return; end;
   try
     manage_helper_var_creation_and_deletion(obj, obj.current_train_stage, val, ...
       'hvar_names_and_values', hvar_names_and_values);
   catch %#ok<CTCH>
     lerr = lasterror; %#ok<LERR>
     fprintf(1, 'Error with Helper Vars: "%s"\n', lerr.message);
   end;
     
   obj.current_train_stage = val;
    
% [obj] = set_current_training_stage(obj, val, {'hvar_names_and_values', [])
%
% Sets the index of the currently active training string.
% Note: If the set of training stages is empty, sets the value to 1
% regardless of what value is provided as an input argument. Jumping from
% stage x to the same stage x is not counted as a transition-- there are
% helper var shenanigans in that case only if the optional
% hvar_names_and_values parameter is passed in.
%
% Under normal operation, current helper values are kept over a transition
% if the new stage has a helper var with the same name. This can be
% overridden with the optional param 'hvar_names_and_values'.
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
%                          value.                          
%
% 

function [obj] = set_current_training_stage(obj, val, varargin)

pairs = { ...
  'hvar_names_and_values'     []  ; ...
}; parseargs(varargin, pairs);

ts   = get_training_stages(obj);

if ~isempty(ts)

   if val > rows(ts),
      comp_sum = 0;
      for k = 1:rows(ts), comp_sum = comp_sum + ts{k,obj.is_complete_COL}; end;
      if comp_sum < rows(ts),
         error(['Current training stage exceeds total number of training ' ...
                'stages! Are you really done?']);
      else
         val = rows(ts);
      end;
   
   elseif val < 0, 
      error('Current training stage must be a natural number');
   end;

   
   obj = set_current_training_stage_unchecked(obj, val, 'hvar_names_and_values', hvar_names_and_values);

else

   obj.current_train_stage = 1;
end;


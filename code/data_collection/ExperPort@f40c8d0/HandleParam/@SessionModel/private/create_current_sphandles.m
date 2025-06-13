%create_current_sphandles.m     [] = create_current_sphandles(obj, [ind], [handlenames])
%
% If passed only one argument, a SessionModel object, looks up the var names
% for that SessionModel object for the current training stage, and
% creates, for each name, a SoloParamHandles with that name and owner =
% get_owner(obj), funcowner = 'SessionModel', value initialized according
% to the training string. 
%
% Two optional arguments can be passed, in either order. Note that these are 
% not param-name, param-value pairs. You just pass the args.
% 
% ind     This is a scalar integer. It indicates
%         the stage number for which vars are to be created. If the index
%         is out of range, does nothing.
%
% handlenames  By default an empty matrix, which means ignore this param.
%         If instead it is a cell, it should contain strings, and *ONLY*
%         those strings will be created-- i.e., the varlist in
%         training_stage will be ignored.
%
%
% EXAMPLE CALL:
% --------------
%
% create_current_sphandles(obj, 3, {'this_var'});
%

function [] = create_current_sphandles(obj, ind, handlenames)

   % Case where passed no args other than obj
   if nargin < 2, ind = get_current_training_stage(obj); handlenames = []; end;
   % Case where passed only one arg, the index:
   if nargin==2 && isnumeric(ind) && isscalar(ind), handlenames = []; end;
   % Case where passed only one arg, the handlenames:
   if nargin==2 && (~isnumeric(ind) || ~isscalar(ind)), 
     handlenames = ind; ind = get_current_training_stage(obj); 
   end;
   % If passed both extra args, don't need to fix anything.
   
   % If we weren't passed explicit list of handle names, then get all of
   % the ones from stage number ind:
   if ~iscell(handlenames),
     [handlenames, initvals] = get_helper_vars(obj, ind);
   else
     [varnames,    initvals] = get_helper_vars(obj, ind);
     [handlenames, iv] = intersect(varnames, handlenames);
     initvals = initvals(iv);
   end;

   % Now create those SoloParamHandles:
   for i=1:length(handlenames)
     SoloParamHandle(obj, handlenames{i}, 'param_owner', get_owner(obj), ...
                    'param_funcowner', 'SessionModel', 'value', initvals{i}, ...
                    'save_with_settings', 1, 'callback_on_load', 0);
	 set_userprop(eval(handlenames{i}), 'save_to_helper_vars_table', 1);  
   end;

   
% [] = manage_helper_var_creation_and_deletion(obj, old_stagenum, new_stagenum, {'hvar_names_and_values', [])
%
% Handles creation and/or deletion of Help var SoloParamHandles, given a
% SessionModel object, an old training stage number, and a new training
% stage number.
%
% The rules are: if old_stagenum==new_stagenum, nothing happens. If the two
% stagenumbers are different, then any helper var names *shared* by the two
% stages are left intact. Any helper var names in the old stage but not the
% new stage have their corresponding SoloParamHandle deleted. Any helper
% var names in the new stage but not the old stage have a SoloParamHandle
% created, and initialized to numeric the value 0.
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




function [] = manage_helper_var_creation_and_deletion(obj, old_stagenum, new_stagenum, varargin)

   pairs = { ...
     'hvar_names_and_values'     []  ; ...
   }; parseargs(varargin, pairs);
 
   if isstruct(hvar_names_and_values)
     if ~isfield(hvar_names_and_values, 'name') || ~isfield(hvar_names_and_values, 'value')
       fprintf(1, ['@SessionModel/private/manage_helper_var_creation_and_deletion: the hvar_names_and_values\n' ...
         'struct vector must have a field called "name" and a field called "values". Ignoring the fact that you\n' ...
         'passed in this malformed struct\n']);     

       oldnames = get_helper_vars(obj, old_stagenum);
     else
       [pnames{1:numel(hvar_names_and_values)}] = deal(hvar_names_and_values.name);
       oldnames = get_helper_vars(obj, old_stagenum);

       % Create any sphandles that are passed but not preexisting:
       create_current_sphandles(obj, old_stagenum, setdiff(pnames, oldnames));
       
       % Set the values of any of the passed ones:
       [current_hvars, current_hvar_names] = get_current_helper_var_handles(obj);
       [guys, i_pnames, i_current] = intersect(pnames, current_hvar_names);
       for i=1:length(i_pnames),
         current_hvars{i_current(i)}.value = hvar_names_and_values(i_pnames(i)).value; %#ok<NASGU>
       end;

       oldnames = union(pnames, current_hvar_names);
       % Ok, at this point it is as if the old_stagenum had included any of
       % the vars passed in the hvar_names_and_values parameter.
     end;
     
   else % hvar_names_and_values was not passed:
        oldnames = get_helper_vars(obj, old_stagenum);
   end;

   newnames = get_helper_vars(obj, new_stagenum);
   
   to_delete = setdiff(oldnames, newnames);
   to_create = setdiff(newnames, oldnames);
   
   delete_current_sphandles(obj, old_stagenum, to_delete);
   create_current_sphandles(obj, new_stagenum, to_create);

   % Get all the guys that have forceinit=1
   [varlist, initvals, forceinit] = get_helper_vars(obj, new_stagenum);
   u = find(forceinit); varlist = varlist(u); initvals = initvals(u); 

   % for those guys with forceinit=1, set their values to their
   % initialization value
   % We're behaving as if we're in the new stage:
   obj.current_train_stage = new_stagenum;
   % Now get the helper vars:
   [current_hvars, current_hvar_names] = get_current_helper_var_handles(obj);
   [guys, i_force, i_current] = intersect(varlist, current_hvar_names);
   for i=1:length(i_force),
     current_hvars{i_current(i)}.value = initvals{i_force(i)};
   end;

   

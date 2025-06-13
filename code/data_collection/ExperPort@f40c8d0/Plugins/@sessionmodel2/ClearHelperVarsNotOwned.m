function ClearHelperVarsNotOwned(obj)
%CLEARHELPERVARSNOTOWNED Function to clear all helper vars which are not
%owned by the currently active training stage.
%
%   Author: Sundeep Tuteja
%           sundeeptuteja@gmail.com

helper_vars_list_structure = SessionDefinition(obj, 'get_helper_var_details');
active_stage_structure = SessionDefinition(obj, 'get_active_stage_details');
for ctr = 1:length(helper_vars_list_structure)
    if ~strcmp(helper_vars_list_structure(ctr).stage_name, active_stage_structure.name)
        evalin('caller', ['clear(''' helper_vars_list_structure(ctr).var_name ''');']);
    end
end

end
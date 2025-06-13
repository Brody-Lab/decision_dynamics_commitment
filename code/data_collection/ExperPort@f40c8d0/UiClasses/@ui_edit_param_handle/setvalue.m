%set.m  [uph] = setvalue(uph, value)        Sets the value of the ui_edit_param that 
%                                           corresponds to the uph handle.
%                                           See ui_edit_param/setvalue.m

function [uph] = set(uph, value)

global private_ui_edit_param_list

up = private_ui_edit_param_list{uph.list_position};
up = setvalue(up, value);

private_ui_edit_param_list{uph.list_position} = up;


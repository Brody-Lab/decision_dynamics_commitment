%set.m  [uph] = set(uph, fieldname, value)  Sets the content of a field of the ui_edit_param that 
%                                           corresponds to the uph handle.
%                                           See ui_edit_param/set.m

function [uph] = set(uph, fieldname, value)

global private_ui_edit_param_list

up = private_ui_edit_param_list{uph.list_position};
up = set(up, fieldname, value);

private_ui_edit_param_list{uph.list_position} = up;


%set.m  [uph] = setvalue(uph, value)        Sets the value of the ui_menu_param that 
%                                           corresponds to the uph handle.
%                                           See ui_menu_param/setvalue.m

function [uph] = set(uph, value)

global private_ui_menu_param_list

up = private_ui_menu_param_list{uph.list_position};
up = setvalue(up, value);

private_ui_menu_param_list{uph.list_position} = up;


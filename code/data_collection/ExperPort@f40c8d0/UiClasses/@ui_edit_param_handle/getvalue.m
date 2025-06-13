function [val] = getvalue(uph)

global private_ui_edit_param_list;

up = private_ui_edit_param_list{uph.list_position};

val = value(up);


function [val] = value(uph)

global private_ui_menu_param_list;

up = private_ui_menu_param_list{uph.list_position};

val = getvalue(up);


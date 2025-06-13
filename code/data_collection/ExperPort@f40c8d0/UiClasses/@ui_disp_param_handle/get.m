function [val] = get(uph, fieldname)

global private_ui_disp_param_list;

up = private_ui_disp_param_list{uph.list_position};

val = get(up, fieldname);


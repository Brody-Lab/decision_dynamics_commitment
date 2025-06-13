function [] = delete(uph)

global private_ui_pushbutton_param_list;

lid = uph.list_position;

if ~isempty(private_ui_pushbutton_param_list{lid}),
    up = private_ui_pushbutton_param_list{lid};
    delete(get(up, 'handle'));
    private_ui_pushbutton_param_list{uph.list_position} = [];
else
    warning('ui_pushbutton_param_handle being deleted doesn''t exist');
end;


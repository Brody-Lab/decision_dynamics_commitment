function [] = delete(uph)

global private_ui_disp_param_list;

lid = uph.list_position;

if ~isempty(private_ui_disp_param_list{lid}),
    up = private_ui_disp_param_list{lid};
    delete(get(up, 'handle'));
    delete(get(up, 'label_handle'));
    private_ui_disp_param_list{uph.list_position} = [];
else
    warning('ui_disp_param_handle being deleted doesn''t exist');
end;


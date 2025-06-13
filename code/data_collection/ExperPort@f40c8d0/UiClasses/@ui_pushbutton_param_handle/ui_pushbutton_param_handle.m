function [uph] = ui_pushbutton_param_handle(varargin)

if length(varargin)==1 & iscell(varargin), varargin = varargin{1}; end; % It's a cell containing name-value pairs

if length(varargin)==1 & isa(varargin{1}, 'ui_pushbutton_param_handle'),
    uph = varargin{1}; 
    return;
    
else

    global private_ui_pushbutton_param_list;
    
    up = ui_pushbutton_param(varargin);

    if isempty(private_ui_pushbutton_param_list),
        private_ui_pushbutton_param_list = {up};
    else
        private_ui_pushbutton_param_list = [private_ui_pushbutton_param_list ; {up}];
    end;
    
    uph = struct('list_position', length(private_ui_pushbutton_param_list));
    uph = class(uph, 'ui_pushbutton_param_handle', ui_param_handle);
    
    h = get(uph, 'handle'); % get the graphics handle
    set(h, 'Callback', {@ui_callback, uph}); 
    return;
end;



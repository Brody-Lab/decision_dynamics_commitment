function [up] = ui_pushbutton_param(varargin)

if isa(varargin, 'ui_pushbutton_param'),
    up = varargin;
    return;
    
else
    if length(varargin)==1 & iscell(varargin{1}), varargin = varargin{1}; end; % 
    
    ui_param_defaults; range = []; handle = [];
    pairs = [pairs ; { ...
                'label'            ''            ; ...
                'position'         [10 10 20 20] ; ...
            }]; 
    parseargs(varargin, pairs);
    
    h  = uicontrol('Style','Pushbutton','HorizontalAlignment','right','BackgroundColor',[0.8 0.3 0], ...
        'position', round(position), 'String', label, 'FontWeight', 'bold');

    u0 = ui_param('param_owner', param_owner, 'param_name', param_name, 'handle', h);
        
    up = struct('a', 1);
    up = class(up, 'ui_pushbutton_param', u0);    
    return;
end;


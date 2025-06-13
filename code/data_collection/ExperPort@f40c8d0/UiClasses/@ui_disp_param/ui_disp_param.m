function [up] = ui_disp_param(varargin)

if isa(varargin, 'ui_disp_param'),
    up = varargin;
    return;
    
else
    if length(varargin)==1 & iscell(varargin{1}), varargin = varargin{1}; end; % 
    
    ui_param_defaults; range = []; handle = [];
    pairs = [pairs ; { ...
                'label'            ''            ; ...
                'position'         [10 10 80 20] ; ...
            }]; 
    parseargs(varargin, pairs);
    
    h  = uicontrol('Style','text','HorizontalAlignment','right','BackgroundColor', 0.7*[1 1 1], ...
        'position', round([position(1:2) position(3)/2-2 position(4)]), 'String', label);

    lh = uicontrol('Style', 'Text', 'HorizontalAlignment', 'left', 'BackgroundColor', 0.8*[1 1 1], ...
        'position', round([position(1) + position(3)/2+2 position(2) position(3)/2-2 position(4)]), ...
        'String', label);

    u0 = ui_param('param_owner', param_owner, 'param_name', param_name, 'handle', h);
        
    up = struct('label_handle', lh);
    up = class(up, 'ui_disp_param', u0);    
    return;
end;


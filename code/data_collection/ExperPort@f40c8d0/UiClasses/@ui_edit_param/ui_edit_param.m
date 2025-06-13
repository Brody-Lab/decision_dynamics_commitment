function [up] = ui_edit_param(varargin)

if isa(varargin, 'ui_edit_param'),
    up = varargin;
    return;
    
else
    if length(varargin)==1 & iscell(varargin{1}), 
       varargin = varargin{1}; 
    end; 
    
    ui_param_defaults; range = []; handle = [];
    pairs = [pairs ; { ...
                'label'            ''            ; ...
                'position'         [10 10 80 20] ; ...
                'force_numeric'    0             ; ...
            }]; 
    parseargs(varargin, pairs);
    
    h  = uicontrol('Style','Edit','HorizontalAlignment','right', ...
                   'BackgroundColor',[1 1 1], 'position', ...
                   round([position(1:2) position(3)/2 position(4)]));
    lh = uicontrol('Style', 'Text', 'HorizontalAlignment', 'left', ...
                   'BackgroundColor', 0.8*[1 1 1], 'position', ...
                   round([position(1) + position(3)/2+1 position(2) ...
                        position(3)/2-1 position(4)]), 'String', label);

    u0 = ui_param('value', value, 'param_owner', param_owner, ...
                  'param_name', param_name, 'handle', h, 'range', range);
    
    if ischar(value),  set(h, 'String', value);
    elseif isnumeric(value) & min(size(value))==1,
        set(h, 'String', sprintf('%g ', value));
    else
        error('ui_edit_param values can only be scalar numbers or strings');
    end;

    
    up = struct('label', label, 'force_numeric', force_numeric, ...
                'label_handle', lh);
    up = class(up, 'ui_edit_param', u0);    
    return;
end;


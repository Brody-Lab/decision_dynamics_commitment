function [up] = ui_menu_param(varargin)

if isa(varargin, 'ui_menu_param'),
    up = varargin;
    return;
    
else
    if length(varargin)==1 & iscell(varargin{1}), varargin = varargin{1}; end; % 
    
    ui_param_defaults; range = []; handle = []; value = []; string = [];
    pairs = [pairs ; { ...
                'label'            ''            ; ...
                'position'         [10 10 160 20] ; ...
                'string'          {''}           ; ...
            }]; 
    parseargs(varargin, pairs);
    if ~isempty(range), error('the range property is not used for menu items'); end;
    
    h  = uicontrol('Style', 'PopupMenu', 'String', string, 'BackgroundColor',[1 1 1], ...
        'position', round([position(1:2) position(3)/2-1 position(4)]));
    lh = uicontrol('Style', 'Text', 'HorizontalAlignment', 'left', 'BackgroundColor', 0.8*[1 1 1], ...
        'position', round([position(1) + position(3)/2+1 position(2) position(3)/2-1 position(4)]), ...
        'String', label);
    
    u0 = ui_param('param_owner', param_owner, 'param_name', param_name, 'handle', h);
        
    up = struct('label_handle', lh);
    up = class(up, 'ui_menu_param', u0);    

    % Check that the desired value is in the list. If not passed a value,
    % the standard default of one will be used here.
    if isnumeric(value), strval = sprintf('%g ', value); elseif ischar(value) strval = value; 
    else error('value must be numeric or a string, and must be one of the menu items');
    end;
    listpos = find(strcmp(strval, string));
    if isempty(listpos),  % didn't find value on list
        value = string{1};
    end;

    up = setvalue(up, value);
    return;
end;


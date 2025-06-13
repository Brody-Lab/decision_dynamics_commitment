% [sph] = ToggleParam(obj, parname, parval, x, y, {'position', gui_position(x, y)}, ...
%                              {'TooltipString', ''}, {'label', parname}, ...
%                              {'OnString', label}, {'OffString', label}, ...
%                              {'OnFontWeight', 'bold'}, {'OffFontWeight', 'bold'}, ...
%                              {'BackgroundColor', [0.8 0.55 0.4]}, ...
%                              {'ForegroundColor', [0   0    0]}, ...
%                              {'param_owner', ['@' class(obj)]}, ...
%                              {'param_funcowner', determine_fullfuncname})
%
% 
% Create and instantiate in the caller's workspace a SoloParamHandle of type
% 'solotoggler'. This SoloParamHandle can have a value of either 0 or 1,
% and toggles between the two when the user clicks it.
%
% RETURNS:
% --------
%
% sph      The SoloParamHandle just created. Most often this return value is
%          neither asked for nor used: instead, the fact that a variable with
%          name parname will have been created is used as the return value.
%
%
% PARAMETERS:
% ------------
%
% obj      Either the string 'base' or a Matlab object to which this
%          SoloParamHandle will belong. Currently it is the class of the
%          object that matters: different instantiations of objects of the
%          same class will all share their SoloParamHandles. If obj is passed
%          as the string 'base', then no object owns this SoloParamHandle the
%          base workspace does.
%
% parname  The name with which the variable will be created. This is the
%          name with which the SoloParamHandle will be stored, and will
%          also be the name of the variable instantiated in the caller's
%          workspace.
%
% parval   Initial value of the toggle button. Can be either 0 or 1.
%
% x, y     The position, in pixels, at which to create the GUI display for
%          the SoloParamHandle. This position refers to the lower left
%          corner of the SoloParamHandle, and is counted from the lower
%          left corner of the current figure.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'position'   A 4-by-1 vector, indicating [x, y, width, height], in pixels
%          from lower left-hand corner, at which to put the GUI part of the
%          SoloParamHandle. Default value is gui_position(x, y) (see
%          gui_position.m)
%
% 'TooltipString'   A string which will be displayed if the mouse floats
%          over the GUI portion of the SoloParamHandle. Typically this is
%          used to explain to users what this variable does.
%
% 'label'  A string that indicates the label that will appear in the middle
%          of the GUI portion of the SoloParamHandle. The default value of
%          this is parname, the name of the SoloParamHandle.
%
% 'OnString'       The string to display as a label on the toggle button
%          when the toggle is On (value 1). Default is label.
%
% 'OffString'      The string to display as a label on the toggle button
%          when the toggle is Off (value 0). Default is label.
%
% 'OnFontWeight'   Either 'bold' or 'normal', indicates the weight of the
%          font used for the label when the toggle is On (value 1). Default
%          is 'bold'.
%
% 'OffFontWeight'   Either 'bold' or 'normal', indicates the weight of the
%          font used for the label when the toggle is Off (value 0). Default
%          is 'bold'.
%
% 'BackgroundColor' The background color when 'off' and the foreground
%          color when 'on'. Default is beige.
%
% 'ForegroundColor' The foreground color when 'off' and the background
%          color when 'on'. Default is black.
%
%
% 'param_owner'  Typically used only by developers, not users of the
%          SoloParamHandle code. This optional parameter allows overriding
%          the default owner, which is ['@' class(obj)].
%
% 'param_funcowner'  Typically used only by developers, not users of the
%          SoloParamHandle code. This optional parameter allows overriding
%          the default full function owner name. The default is 
%          obtained from determine_fullfuncname.m
%
%
%
% EXAMPLES:
% ---------
%
% >> ToggleParam('base', 'this', 1, 10, 20, 'OffFontWeight', 'normal')
%    will create a variable named this, together with a button that says
%    'this'. You can toggle it by clicking it, or set its value: 
%               >> this.value = 1;
%               >> this.value = 0;
%

% Carlos Brody wrote me sometime in late 2005. Shraddha Pai helped a lot
% with modifications and improvements.


function [ed] = ToggleParam(obj, parname, parval, x, y, varargin)

   % First get the label value:
   pairs = { ...
       'label',              parname                    ; ...
       }; parse_knownargs(varargin, pairs);

   if ischar(obj) && strcmp(obj, 'base'), param_owner = 'base';
   elseif isobject(obj),                  param_owner = ['@' class(obj)];
   else   error('obj must be an object or the string ''base''');
   end;
   
   % Now parse other args, including OnString and OffString
   pairs = { ...
       'param_owner',        param_owner                ; ...
       'param_funcowner',    determine_fullfuncname     ; ...
       'position',           gui_position(x, y)         ; ...
       'TooltipString',      ''                         ; ...
       'OnString'            label                      ; ...
       'OffString'           label                      ; ...
       'OnFontWeight'        'bold'                     ; ...
       'OffFontWeight'       'bold'                     ; ...
       'label'               label                      ; ...
       'BackgroundColor'      [0.8 0.55 0.4]            ; ...
       'ForegroundColor'      [0.3 0.3  0.3]            ; ...

       }; parseargs(varargin, pairs);


   if parval, parval = 1; else parval = 0; end;
   
   ed = SoloParamHandle(obj, parname, ...
                        'type',            'solotoggler', ...
                        'value',           parval, ...
                        'position',        position, ...
                        'TooltipString',   TooltipString, ...
                        'label',           label, ...
                        'OnString',        OnString,  ...
                        'OffString',       OffString, ...
                        'OnFontWeight',    OnFontWeight, ...
                        'OffFontWeight',   OffFontWeight, ...
                        'BackgroundColor', BackgroundColor, ...
                        'ForegroundColor', ForegroundColor, ...
                        'param_owner',     param_owner, ...
                        'param_funcowner', param_funcowner);
   assignin('caller', parname, eval(parname));
   return;   
   

   

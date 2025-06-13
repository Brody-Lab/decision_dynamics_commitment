% [sph] = PushbuttonParam(obj, parname, x, y, {'position', gui_position(x, y)}, ...
%                              {'TooltipString', ''}, {'label', parname}, ...
%                              {'FontWeight', 'bold'}, ..
%                              {'BackgroundColor', [0.75 1 0.75]}, ...
%                              {'param_owner', ['@' class(obj)]}, ...
%                              {'param_funcowner', determine_fullfuncname})
%
% 
% Create and instantiate in the caller's workspace a SoloParamHandle of type
% 'pushbutton'. This is not editable, but is used to generate callbacks
% when a suer clicks it.
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
% 'FontWeight'   Either 'bold' or 'normal', indicates the weight of the
%          font used for the label. Default is 'bold'.
%
% 'BackgroundColor'   1-by-3 vector, with each element in [0,1], indicating
%          the Red, Greeb, Blue, value of the background color of the
%          button. Default is [0.75 1 0.75], a light green.
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
% >> PushbuttonParam('base', 'this', 10, 20, 'label', 'gee!')
%    will create a variable named this, together with a button that says
%    'gee!' 
%

% Carlos Brody wrote me sometime in late 2005. Shraddha Pai helped a lot
% with modifications and improvements.



function [pb] = PushbuttonParam(obj, parname, x, y, varargin)

   if ischar(obj) && strcmp(obj, 'base'), param_owner = 'base';
   elseif isobject(obj),                  param_owner = ['@' class(obj)];
   else   error('obj must be an object or the string ''base''');
   end;

   pairs = { ...
       'param_owner',        param_owner            ; ...
       'param_funcowner',    determine_fullfuncname     ; ...
       'position',           gui_position(x, y)         ; ...
       'TooltipString',      ''                         ; ...
       'label',              parname                    ; ...
       'FontWeight'          'bold'                     ; ...
       'BackgroundColor'     [0.75 1 0.75]              ; ...
       'labelpos',           'right'                    ...  
   }; parseargs(varargin, pairs);
    

   pb = SoloParamHandle(obj, parname,        ...
                        'type',            'pushbutton', ...
                        'position',        position, ...
                        'TooltipString',   TooltipString, ...
                        'label',           label, ...
                        'labelpos',        labelpos, ...
                        'FontWeight',      FontWeight, ...
                        'BackgroundColor', BackgroundColor, ...
                        'param_owner',     param_owner, ...
                        'param_funcowner', param_funcowner);
   assignin('caller', parname, eval(parname));
   return;
   

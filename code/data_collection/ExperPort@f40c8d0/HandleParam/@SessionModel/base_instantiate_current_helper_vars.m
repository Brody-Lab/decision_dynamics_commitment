% [] = base_instantiate_current_helper_vars(obj, {'doprint' 0})
%
% Instantiates current helper SoloParamHandles in the base workspace, for
% ease of operator use.
%
% OPTIONAL PARAMS:
% -----------------
%
% 'doprint'    Default value is 0. If this is passed as 1, then each Helper
%              var's name and value are displayed on the base workspace as
%              they are instantiated.
%

function [] = base_instantiate_current_helper_vars(obj, varargin)

   pairs = { ...
     'doprint'    0  ; ...
   }; parseargs(varargin, pairs);
 
   GetSoloFunctionArgs('func_owner', get_owner(obj), 'func_name', 'SessionModel');  
   private__handlenames = get_helper_vars(obj);
      
   for i=1:length(private__handlenames),
     assignin('base', private__handlenames{i}, eval(private__handlenames{i}));
     if doprint,
       try
         fprintf(1, '%s = ', private__handlenames{i});
         disp(value(eval(private__handlenames{i})));
       catch %#ok<CTCH>
         fprintf(1, '%s exists, but couldn''t display it on the screen\n', private__handlenames{i});
       end;
     end;
   end;

   
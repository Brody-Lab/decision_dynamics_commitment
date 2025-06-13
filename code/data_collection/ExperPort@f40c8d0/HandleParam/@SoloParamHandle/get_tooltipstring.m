%get_tooltipstring.m    [str] = get_tooltipstring(sph)
%
% Get the tooltip string for a SoloParamHandle. Trying to do this for a
% non-GUI SPH results in an error.
%

function [str] = get_tooltipstring(sph)
   
   if isempty(get_type(sph)),
      error('Cannot get TooltipString for non-GUI SoloParamHandle');
   end;
   
   gh = get_ghandle(sph);
   str = get(gh, 'TooltipString');

   

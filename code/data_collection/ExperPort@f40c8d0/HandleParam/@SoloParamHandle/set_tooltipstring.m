%set_tooltipstring.m    [] = set_tooltipstring(sph, str)
%
% Set the tooltip string for a SoloParamHandle. Trying to do this for a
% non-GUI SPH results in an error.
%
% str must be a string.
%

function [] = set_tooltipstring(sph, str)
   
   if isempty(get_type(sph)),
      error('Cannot set TooltipString for non-GUI SoloParamHandle');
   end;
   
   gh = get_ghandle(sph);
   lh = get_lhandle(sph);

   if ~isempty(gh),
      set(gh, 'TooltipString', [get_name(sph) ': ' str]);
   end;

   if ~isempty(lh),
      set(lh, 'TooltipString', [get_name(sph) ': ' str]);
   end;
   

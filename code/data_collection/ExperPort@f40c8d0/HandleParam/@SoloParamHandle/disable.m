% [] = disable(sph)     Graphically disable both GUI and label of a SoloParamHandle.
%
% An enabled GUI is one that can be edited by the user; a disabled one
% cannot. disable.m has no effect on SoloParamHandles that aren't GUIs.
%

% Written by Carlos Brody April 2007


function [] = disable(sph)

if isempty(get_type(sph)), return; end;

gh = get_ghandle(sph);
lh = get_lhandle(sph);

if ~isempty(gh), set(gh, 'Enable', 'off');  end;
if ~isempty(lh), set(lh, 'Enable', 'off'); end;


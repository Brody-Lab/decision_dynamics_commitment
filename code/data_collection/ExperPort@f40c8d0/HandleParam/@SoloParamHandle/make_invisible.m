% [] = make_invisible(sph)   Set 'Visible' property to OFF for both GUI and label of a SoloParamHandle.
%
% A visible GUI is one that can be seen by the user; an invisible one
% cannot. make_invisible.m has no effect on SoloParamHandles that aren't GUIs.
%

% Written by Carlos Brody Aug 2007


function [] = make_invisible(sph)

if isempty(get_type(sph)), return; end;

gh = get_ghandle(sph);
lh = get_lhandle(sph);

if ~isempty(gh), set(gh, 'Visible', 'off');  end;
if ~isempty(lh), set(lh, 'Visible', 'off'); end;


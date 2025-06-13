% [] = make_visible(sph)   Set 'Visible' property to ON for both GUI and label of a SoloParamHandle.
%
% A visible GUI is one that can be seen by the user; an invisible one
% cannot. make_visible.m has no effect on SoloParamHandles that aren't GUIs.
%

% Written by Carlos Brody Aug 2007


function [] = make_visible(sph)

if isempty(get_type(sph)), return; end;

gh = get_ghandle(sph);
lh = get_lhandle(sph);

if ~isempty(gh), set(gh, 'Visible', 'on');  end;
if ~isempty(lh), set(lh, 'Visible', 'on'); end;


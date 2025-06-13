% [t] = is_enabled(sph)   1 if GUI and label are graphically enabled; 0 if not.
%
% An enabled GUI is one that can be edited by the user; a disabled one
% cannot. is_enabled.m returns NaN for SoloParamHandles that aren't GUIs.
%
% PARAMETERS:
% -----------
%
% sph     A SoloParamHandle object
%
%
% RETURNS:
% --------
%
% t       a scalar that is 1 if the SPH is graphically enabled, 0 if not.
%         The test is made on the editable part of the SPH, not on its
%         label.
%


% Written by Carlos Brody April 2007


function [t] = is_enabled(sph)

if isempty(get_type(sph)), t = NaN; return; end;

gh = get_ghandle(sph);

if isempty(gh), t = NaN; return; end;

t = strcmp(get(gh, 'Enable'), 'on');



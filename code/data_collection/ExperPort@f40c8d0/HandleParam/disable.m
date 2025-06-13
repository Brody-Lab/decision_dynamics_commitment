% [] = disable(sph)     Graphically disable both GUI and label of a SoloParamHandle.
%
% An enabled GUI is one that can be edited by the user; a disabled one
% cannot. disable.m has no effect on SoloParamHandles that aren't GUIs.
% If sph is a cell, assumes all its elements are SoloParamHandles, and
% atempts to disable them all.


function [] = disable(sph)

if iscell(sph); for i=1:numel(sph), disable(sph{i}); end; end;
   

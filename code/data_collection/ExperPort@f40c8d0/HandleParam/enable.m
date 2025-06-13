% [] = enable(sph)     Graphically enable both GUI and label of a SoloParamHandle.
%
% An enabled GUI is one that can be edited by the user; a disabled one
% cannot. enable.m has no effect on SoloParamHandles that aren't GUIs.
% If sph is a cell, assumes all its elements are SoloParamHandles, and
% atempts to enable them all.


function [] = enable(sph)

if iscell(sph); for i=1:numel(sph), enable(sph{i}); end; end;
   

% [] = push_history(owner);
%
% This function does push_history on multiple SoloParamHandles at once. For
% push_history on a single SoloParamHandle, see
% @SoloParamHandle/push_history.m
% 
% This function calls push_history on every GUI SoloParamHandle that
% belongs to owner. In behavioral experiments, this is typically called
% once every trial, so as to record an exact history of what the GUI
% components were.
%
% PARAMETERS:
%
% owner      A string that will be regexp matched against the owners of all
%            existing SoloParamHandles. If owner is passed as an object,
%            then it is formed by ['^@' class(owner) '$'], i.e., match that
%            object's class exactly.
%


function [] = push_history(owner)
%
% For all the SoloParamHandles that are GUI types and that have an
% owner string that match a regexp with the passed param owner, do a
% push_history on them. See SoloParamHandle/push_history.m
%
   
   if isobject(owner), owner = ['^@' class(owner) '$']; end;
   
   handles = get_sphandle('owner', owner);
   for i=1:length(handles),
      if ~isempty(get_type(handles{i})), push_history(handles{i}); end;
   end;
   
   

% [] = clear_history(owner);
%
% This function does clear_history on multiple SoloParamHandles at once. For
% clear_history on a single SoloParamHandle, see @SoloParamHandle/pop_history.m
% 
% This function calls clear_history on every SoloParamHandle that
% belongs to owner.  ** NOTE THAT, UNLIKE HandleParam/pop_history.m 
% AND HandleParam/push_history.m, THIS INCLUDES NON-GUI SOLOPARAMHANDLES AS
% WELL AS GUI SOLOPARAMHANDLES. **
%
% PARAMETERS:
%
% owner      A string that will be regexp matched against the owners of all
%            existing SoloParamHandles. If owner is passed as an object,
%            then it is formed by ['^@' class(owner) '$'], i.e., match that
%            object's class exactly.
%


function [] = clear_history(owner)

   if isobject(owner), owner = ['^@' class(owner) '$']; end;

   handles = get_sphandle('owner', owner);
   for i=1:length(handles),
      clear_history(handles{i});
   end;
   
   
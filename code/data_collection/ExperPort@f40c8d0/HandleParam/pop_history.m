% [] = pop_history(owner, {'include_non_gui', 0});
%
% This function does pop_history on multiple SoloParamHandles at once. For
% pop_history on a single SoloParamHandle, see
% @SoloParamHandle/pop_history.m
% 
% This function calls pop_history on every GUI SoloParamHandle that
% belongs to owner. 
%
% PARAMETERS:
% -----------
%
% owner      A string that will be regexp matched against the owners of all
%            existing SoloParamHandles. If owner is passed as an object,
%            then it is formed by ['^@' class(owner) '$'], i.e., match that
%            object's class exactly.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'include_non_gui'    By default 0, if this is passed as 1, then *ALL*
%                      SoloParamHandles belonging to the specified owner
%            will have their history popped, not just the GUI ones.
%

function [] = pop_history(owner, varargin)

   pairs = { ...
     'include_non_gui'   0  ; ...
   }; parseargs(varargin, pairs);

   if isobject(owner), owner = ['^@' class(owner) '$']; end;

   handles = get_sphandle('owner', owner);
   for i=1:length(handles),
     if include_non_gui, 
       pop_history(handles{i});
     else       
      if ~isempty(get_type(handles{i})), pop_history(handles{i}); end;
     end;
   end;
   
   
%  [modid, flist, glbls]=find_modules_funclist(func_owner)
%
% Helper function for dealing with private_solofuncion_list. Given a
% function owner name (that is, a string identifying the owner of a set of
% functions), finds where in the global private_solofunction_list is the
% list of functions and their variables corresponding to a specific owner.
% Returns position in provate_solofunction_list, the list of funcs and
% vars, and a list of globals belonging to that owner.
%
% RETURNS:
% --------
%
% modid     An integer, saying where in private_function_list this
%           func_owner has its entry. An empty entry is created if one
%           did not exist before.
%
% flist     An n-by-3 cell, where the first column is full function name,
%           the second column is read-write SoloParamHandles, and the
%           third column is read-only SoloParamHandles.
%
% glbls     A cell containing SoloParamHandles declared global within
%           the func_owner.
%


function [mod, funclist, globals] = find_modules_funclist(func_owner)

   % func_owner should be a row string vector:
   if size(func_owner,1) > size(func_owner,2), func_owner = func_owner'; end;
   
   global private_solofunction_list;
   
   if isempty(private_solofunction_list), mod = []; 
   else mod = find(strcmp(func_owner, private_solofunction_list(:,1)));
   end;
   if isempty(mod),
      empty_globals_list = {cell(0,2) cell(0,2)};
      private_solofunction_list = ...
          [private_solofunction_list;{func_owner {} empty_globals_list}];
      mod = size(private_solofunction_list, 1);
   end;

   funclist = private_solofunction_list{mod, 2};
   globals  = private_solofunction_list{mod, 3};
   
   return;

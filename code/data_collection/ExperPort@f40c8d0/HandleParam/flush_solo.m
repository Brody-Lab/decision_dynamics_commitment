% [] = flush_solo({owner})
%
% If called without any arguments, cleans out all Solo registries: all
% SoloParamHandles are deleted, all SoloFunction entries are cleared
% out, and all AutoSet entries are cleared out.
%
% If called with one arg, this arg must be a string; flush_solo then
% cleans all Solo registries for that owner only.

function [] = flush_solo(owner)
   
   global private_soloparam_list
   global private_solofunction_list
   global private_autoset_list
   
   if nargin==0,
      delete_sphandle;   

      private_soloparam_list = {};
      private_solofunction_list = {};
      private_autoset_list = {};
      return;
   end;
   
   if nargin~=1 || ~isstr(owner),
      error(['flush_solo takes at most one arg, a string representing ' ...
             'an owner name']);
   end;

   % The ^ and $ make sure we match this owner name exactly (no
   % leading or trailing anything elses):
   delete_sphandle('owner', ['^' owner '$']);
   RegisterAutoSetParam(owner);
   SoloFunctionAddVars(owner);
      

%rescan_sphandles_during_load.m     [] = rescan_sphandles_during_load(obj)
%
% After a load, and after the current stage has been set, rescans the
% loading data for values of the vars in Helper vars.
%


function [] = rescan_sphandles_during_load(obj, ind)

   GetSoloFunctionArgs('func_owner', get_owner(obj), 'func_name', 'SessionModel');

   if nargin < 2, ind = get_current_training_stage(obj); end;
   varlist = get_helper_vars(obj, ind);
   
   local_sphandles = cell(size(varlist));
   for i=1:length(local_sphandles),
      local_sphandles{i} = eval(varlist{i});
   end;

   load_solouiparamvalues(obj, 'dummy_ratname', 'rescan_during_load', local_sphandles);
   load_soloparamvalues(obj,   'dummy_ratname', 'rescan_during_load', local_sphandles);
   
   
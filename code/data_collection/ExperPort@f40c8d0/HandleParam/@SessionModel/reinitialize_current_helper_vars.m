% [] = reinitialize_current_helper_vars(obj)
%
% Deletes all current training stage helper vars that it can delete; then
% recreates them, initializing them with value 0.
%

function [] = reinitialize_current_helper_vars(obj)

try
   delete_current_sphandles(obj);
   create_current_sphandles(obj);
catch
    lerr = lasterror;
    fprintf(1, 'Error with Helper Vars: "%s"\n', lerr.message);
end;

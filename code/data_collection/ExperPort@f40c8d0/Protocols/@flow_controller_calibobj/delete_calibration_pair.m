% GF 4/30/07

function [] = delete_calibration_pair(obj)
   
GetSoloFunctionArgs;

% delete the most recently added column from the lookup_table sph
lt = value(lookup_table);

lookup_table.value = lt(:, (1:(end - 1)));

% update the plot
plot_entries(obj, 'update');
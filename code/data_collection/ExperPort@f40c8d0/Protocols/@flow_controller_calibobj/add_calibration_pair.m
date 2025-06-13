% GF 4/30/07

function [] = add_calibration_pair(obj)
   
GetSoloFunctionArgs;

new_entries = [voltage; flow_rate];

% add the entries to the lookup_table sph
lookup_table.value = [value(lookup_table) new_entries];

% update the plot
plot_entries(obj, 'update');
function [SC, plottables]=state_colors(obj)

GetSoloFunctionArgs;

% Colors that the various states take when plotting
[SC, plottables] = state_colors(value(super));

% Add child class's extra states here
SC_child = struct();					% Note: Child fields overwrite parent fields
child_fields = fieldnames(SC_child);
super_fields = fieldnames(SC);
for f_num = 1:size(child_fields,1)
	f_name = child_fields(f_num,:);
	if find(strcmp(super_fields, f_name))
		error('Sorry, cannot overwrite parental state %s', f_name);
	end;
	SC = setfield(SC, f_name, eval(['SC_child.' f_name]));
end;

% Add child class's extra 'plottable' items here
plottables_child = {};
p_super = size(plottables, 1);
for p_num = 1:size(plottables_child,1)
	plottables(p_super+pnum,:) = plottables_child(p_num,:);
end;


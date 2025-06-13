function [SC, plottables]=state_colors(obj)

GetSoloFunctionArgs;

% Colors that the various states take when plotting
[SC, plottables] = state_colors(value(super));

% Add child class's extra states here
SC_child = struct(  'pre_go',   [0.7 0.7 0.7],    ...
                    'cue',      [0.6 0.4 1], ...
                    'drink_grace', [1 0.2 0.2] ... 
    );					% Note: Child fields overwrite parent fields
child_fields = fieldnames(SC_child);
super_fields = fieldnames(SC);
for f_num = 1:rows(child_fields)
	f_name = child_fields{f_num};
	if ~isempty(find(strcmp(super_fields, f_name)))
		error('Sorry, cannot overwrite parental state %s', f_name);
	end;
	SC = setfield(SC, f_name, eval(['SC_child.' f_name]));
end;

% Add child class's extra 'plottable' items here
plottables_child = { ...
  'pre_go'  1:7   ; ...
  'cue'     1:7   ; ...
  'drink_grace', 1:7 ; ...
};
ps = rows(plottables);
for p_num = 1:size(plottables_child,1)
	plottables(ps+p_num,1:2) = plottables_child(p_num,:);
end;

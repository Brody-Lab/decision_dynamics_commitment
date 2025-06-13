function [x, y, chord_sound_len] = ChordSection(obj, action, x, y)

GetSoloFunctionArgs;

% init_ro_args = { 'side_list', side_list, ...
% 	'n_done_trials', n_done_trials,	...
% 	'n_started_trials', n_started_trials, ...
% };

if nargin > 2
[x, y, chord_sound_len] = ChordSection(value(super), action, x, y);
else
    ChordSection(value(super), action);
end;


function [ind] = classify_task_level(saved_history, type)
% 
% Given the saved_history struct from a task data file, 
% returns the trial numbers for the required task level.
% 
% Levels may be one of the following:
% primary: Tone localisation ON, GO localisation ON
% only_go_on: Tone localisation OFF, GO localisation ON
% secondary: Tone localisation ON, GO localisation OFF
% final: Tone localisation OFF, GO localisation OFF

go_loc = 'ChordSection_GO_Loc';
tone_loc = 'ChordSection_Tone_Loc';

if ~isfield(saved_history, go_loc)
    error(['GO Localisation (' go_loc ') is simply not available for this dataset']);
end;
if ~isfield(saved_history, tone_loc)
	error(['Tone Localisation (' tone_loc ') is simply not available for this dataset']);   
end;

go = getfield(saved_history, go_loc);
tone = getfield(saved_history, tone_loc);

switch type
    case 'secondary'    % go OFF, tone ON
        go_filt = find(~strcmp(go,'on'));
        tone_filt = find(strcmp(tone,'on'));
    case 'final'        % go OFF, tone OFF
        go_filt = find(~strcmp(go,'on'));
        tone_filt = find(~strcmp(tone,'on'));
    case 'primary'           % both ON
        go_filt = find(strcmp(go,'on'));
        tone_filt = find(strcmp(tone,'on'));
    case 'only_go_on'
        go_filt = find(strcmp(go,'on'));
        tone_filt = find(~strcmp(tone,'on'));
    otherwise
        error('Invalid task type! Use [primary|secondary|final]');
end;

ind = intersect(go_filt, tone_filt);
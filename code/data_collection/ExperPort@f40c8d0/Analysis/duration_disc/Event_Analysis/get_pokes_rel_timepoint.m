function [out] = get_pokes_rel_timepoint(evs, poketype, moment, before_or_after)
%
% Returns all pokes made after timepoint "moment".
%
% Input parameters:
% --------------------------------------------------
% evs 
% A struct whose fields are RealTimeStates and 
% values are e-by-2 cells, where the rows (e) indicate each transition through that state
% and columns are start and end times of those states
% In the case of the pokes (center1, left1, right1), the rows indicate
% occurrences of the type of pokes and the columns indicate the poke-in and
% withdrawal of that instance
%
% poketype: one of "center", "left", "right", "all" (case-insensitive)
%
% moment: a timepoint
%
% It is also a single cell entry from the output of parse_trials
% Sample usage of script:
% p = parse_trials(evs,rts)
% t = 23.54;    % timepoint - pretend this is the time when extra_iti
% started
% c = get_pokes_after(p{5}, "center", 23.54)
%
% The above would return all center pokes made after extra_iti started for
% the 5th trial of the session
%
% Returns
% --------------------------------------------------
% An 1-by-2 double array with start and end times of the specified types of pokes 
% If poketype is "all", returns an 3-by-2 cell array, where the first column
% indicates the type of poke ("center"|"left"|"right")

op = '';
switch before_or_after,
    case 'before_strict',   op = '<';
    case 'after_strict',    op = '>';
    case 'before',          op = '<=';
    case 'after',           op = '>=';
    case 'at',              op = '==';
    otherwise
        error('Invalid logical operator. Should be ''before_strict''|''after_strict''|''before''|''after''');
end;

pk = cell(1,1);
if strcmpi(poketype,'center')
    pk{1} = 'center';
elseif strcmpi(poketype, 'left')
    pk{1} = 'left';
elseif strcmpi(poketype, 'right')
    pk{1} = 'right';
elseif strcmpi(poketype, 'all')  
    pk{1} = 'center'; pk{2} = 'left'; pk{3} = 'right';
else 
    error('What poketype is this? It should be ''center''|''left''|''right''|''all''.');
end

if strcmpi(poketype,'all'), out = cell(0,0); else out = []; end;
for k = 1:cols(pk),
    curr_pokes = eval(['find(evs.' pk{k} '1(:,1)' op 'moment)']);
    curr_pokes = eval(['evs.' pk{k} '1(curr_pokes,:)']);
    if strcmpi(poketype, 'all'), 
        out{k,1} = pk{k}; out{k,2} = curr_pokes;
    else
        out = curr_pokes;            
    end;
end;





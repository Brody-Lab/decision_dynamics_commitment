function [out, match_ind] = get_pokes_fancy(evs, poketype, conditions, filter_type, varargin)
%
% A fancier version of get_pokes_rel_timepoint, it allows filtering of
% pokes by multiple criteria
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
% It is also a single cell entry from the output of parse_trials
%
% poketype: one of "center", "left", "right" (case-insensitive)
%
% conditions: A c-by-3 cell array where each row is a condition.
% A condition is specified by three parameters (cols):
%   1. 'in' | 'out' : start/endtimes of poketype
%   2.  operator: one of 'before_strict' | 'before' | 'after_strict' |
%   'after' (operators may themselves also be used: <=, <, >=, >, ==)
%   3. timepoint: the timepoint relative to which poke times are filtered
%
% e.g. Condition "get left poke-in strictly after time t"
%   --> ('in', after_strict', t)
%
% filter_type: one of 'any', 'all'.
%   'all' returns only those pokes that satisfy ALL criteria;
%   'any' returns those pokes that satisfy ANY one criterion
%
% Sample usage of script:
% p = parse_trials(evs,rts)
% conditions(1,1:3) = { 'in', 'after', p.timeout(1,1) };
% conditions(2,1:3) = { 'out',   'before', p.timeout(1,2) };
% c = get_pokes_fancy(p{5}, 'center', conditions, 'all');
% This call would return all center pokes made during the first
% timeout
%
% Returns
% --------------------------------------------------
% An 1-by-2 double array with start and end times of the specified types of pokes
% If poketype is "all", returns an 3-by-2 cell array, where the first column
% indicates the type of poke ("center"|"left"|"right")

pairs = { ...
    'pokes_in_condition',  0 ; ...
    };
parse_knownargs(varargin, pairs);

temp_cond = {};
if pokes_in_condition == 0
    
    pk = '';
    if strcmpi(poketype,'center')
        pk = 'center';
    elseif strcmpi(poketype, 'left')
        pk = 'left';
    elseif strcmpi(poketype, 'right')
        pk = 'right';
    else
        error('What poketype is this? It should be center|left|right');
    end;
    
    for k = 1:rows(conditions)
        temp_cond(k, 1:4) = { pk, conditions{k, 1:3} };        
    end;
    conditions = temp_cond;
end;      

condit = parse_conditions(conditions, filter_type);

match_ind = eval(['find(' condit ');']);
curr_pokes = eval(['evs.' pk '1(match_ind,:);']);

out = curr_pokes;

% --------------------------------------------------

function [cond] = parse_conditions(in, filt)

if strcmpi(filt,'any'),
    conn = '|';
elseif strcmpi(filt,'all'),
    conn = ' &';
else
    error('Connector should be one of ''any'' or ''all''');
end;

cond = '';
for i = 1:rows(in)
    if strcmpi(in{i,2},'in'),    % start or end?
        tm = '1';
    elseif strcmpi(in{i,2},'out'),
        tm = '2';
    else error('Time should be ''in'' or ''out''');
    end;

    op = get_op(in{i,3});           % operator

    cond = [ cond ...
        '(evs.' in{i,1} '1(:,' tm ') ' op ' conditions{' int2str(i) ',4})'];

    if i < rows(in), cond = [cond conn];end;
end;

% --------------------------------------------------
function [op] = get_op(strop)

logie = {'<=', '>=', '>', '<', '=='};
if ismember(strop, logie), op = strop; return; end;

switch strop,
    case 'before_strict',   op = '<';
    case 'after_strict',    op = '>';
    case 'before',          op = '<=';
    case 'after',           op = '>=';
    case 'at',              op = '==';
    otherwise
        error('Invalid logical operator. Should be ''before_strict''|''after_strict''|''before''|''after''');
end;

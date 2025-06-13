function [] = calc_poke_rate_Last15(ratname, indate)

pstruct = get_pstruct(ratname, indate);
iti_poke_count = [];

pk_rate = [];

        [co lo ro] = pokes_during_iti(pstruct);
for k = 1:rows(pstruct)
% iti poke count
         iti_poke_count(k) = rows(co{k}) + rows(lo{k}) + rows(ro{k});
end;

for k = 1:length(iti_poke_count)     
        mn = max([1 k-16]);
        pk_rate(end+1)= mean(iti_poke_count(mn:k));
    %    fprintf(1,'TO Rate is: %2.2f, and Poke rate is: %2.2f\n',
    %    value(to_rate_Last15), value(poke_rate_Last15));
end;
figure; subplot(2,1,1); plot(iti_poke_count,'.b'); title('iti poke count total');
subplot(2,1,2); plot(pk_rate,'.b'); title('poke rate last 15');
2;


        %----------------------------------------------------------
% %%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------

function [cpokes lpokes rpokes] = pokes_during_iti(pstruct)
%
% Given the output of Analysis/parse_trial.m (pstruct), 
% returns the number of pokes made during ITIs.
% Specifically, it returns the center pokes, left pokes and right pokes
% (each in a separate structure), made during the following RealTimeStates:
% * iti
% * dead_time
% * extra_iti
% Output:
%   Three cell arrays of identical structure, one for each type of poke.
%   There is a row for every trial, which contains the array of start and
%   endtimes of the particular pokes during the trial.
%
% e.g. [cpokes lpokes rpokes] pokes_during_iti(pstruct)
% >> cpokes{5}
% ans =
% 
%   780.4855  781.4078
%   783.1033  783.5067
%   791.4746  791.7648
%   793.2047  793.4459
%   795.5236  795.7657
%

cpokes = cell(0,0);
lpokes = cell(0,0);
rpokes = cell(0,0);

for k = 1:rows(pstruct)
    temp_c = []; temp_r = []; temp_l = [];
    for itir = 1:rows(pstruct{k}.iti)
        [tc, tl, tr] = cpoke_mini(pstruct{k}, pstruct{k}.iti(itir,1), pstruct{k}.iti(itir,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;
    for dr = 1:rows(pstruct{k}.dead_time)
        [tc, tl, tr]  = cpoke_mini(pstruct{k}, ...
            pstruct{k}.dead_time(dr,1), pstruct{k}.dead_time(dr,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;
    for eitir = 1:rows(pstruct{k}.extra_iti)
        [tc, tl, tr]  = cpoke_mini(pstruct{k}, ...
            pstruct{k}.extra_iti(eitir,1), pstruct{k}.extra_iti(eitir,2));
        temp_c = [temp_c; tc]; temp_l = [temp_l; tl]; temp_r = [temp_r; tr];
    end;

    cpokes{k} = temp_c; lpokes{k} = temp_l; rpokes{k} = temp_r;
end;

function [outrow_c outrow_l outrow_r] = cpoke_mini(minip, st_time, fin_time)
conditions = {'in', 'after', st_time};
conditions(2,1:3) = {'out', 'before', fin_time};
outrow_c = get_pokes_fancy(minip, 'center', conditions, 'all');
outrow_l = get_pokes_fancy(minip, 'left', conditions, 'all');
outrow_r = get_pokes_fancy(minip, 'right', conditions, 'all');


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




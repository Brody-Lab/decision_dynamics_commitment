function [x, y, timeout_count] = RewardsSection(obj, action, x, y);
%
% [x, y] = InitRewards_Display(x, y, obj);
%
% args:    x, y                 current UI pos, in pixels
%          obj                  A locsamp3obj object
%
% returns: x, y                 updated UI pos
%
% Updates (and stores) history of various measures of hit (or reward
% rates); e.g. Hit rate for Last 15 trials, # Right rewards, etc.,
% Also updates the on-screen hit-rate display
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetSoloFunctionArgs;
% SoloFunction('RewardsSection', 'rw_args', {'LastTrialEvents', 'hit_history'}, ...
%    'ro_args', {'RealTimeStates', 'side_list', 'n_done_trials', 'n_started_trials'});

switch action,
    case 'init',

        SoloParamHandle(obj, 'LeftRewards', 'value', zeros(1, maxtrials)); %next_row(y);
        SoloParamHandle(obj, 'RightRewards', 'value',zeros(1, maxtrials)); %next_row(y);
        DispParam(obj, 'Rewards',     0, x, y); next_row(y);
        SoloParamHandle(obj,'RewardTracker', 'value', 0);
        DispParam(obj, 'Trials',      0, x, y); next_row(y);
        SoloParamHandle(obj,'TrialTracker', 'value', 0);

        next_row(y);

        DispParam(obj, 'Last10',      0, x, y, 'labelfraction',0.2); next_row(y);
        DispParam(obj, 'Last30',      0, x, y, 'labelfraction', 0.2); next_row(y);
        DispParam(obj, 'Last65',      0, x, y, 'labelfraction', 0.2); next_row(y);
        DispParam(obj, 'Last100',      0, x, y, 'labelfraction', 0.2); next_row(y);

        % hit rate tracker
        SoloParamHandle(obj,'Last10num', 'value', 0);
        SoloParamHandle(obj, 'Last15num', 'value', 0);
        SoloParamHandle(obj,'Last30num', 'value', 0);
          SoloParamHandle(obj,'Last50num', 'value', 0);
        SoloParamHandle(obj,'Last65num', 'value', 0);
        SoloParamHandle(obj,'Last100num', 'value', 0);

        % timeout tracker
        SoloParamHandle(obj, 'timeout_count', 'value', zeros(1,maxtrials));
        SoloParamHandle(obj, 'to_rate_Last25', 'value', 0);
        SoloParamHandle(obj, 'to_rate_Last15', 'value', 0);
        SoloParamHandle(obj, 'to_rate_Last10', 'value', 0);
             SoloParamHandle(obj,'to_rate_tracker', 'value',NaN(1,maxtrials));

        % ITI poke tracker
        SoloParamHandle(obj,'iti_poke_count', 'value', zeros(1,maxtrials));
        SoloParamHandle(obj, 'poke_rate_Last15', 'value',0);
                SoloParamHandle(obj,'poke_rate_tracker', 'value',NaN(1,maxtrials));      

        % practise counter
        SoloParamHandle(obj, 'practice_ctr', 'value', 0);

        next_row(y,0.5);

        DeclareGlobals(obj, 'ro_args', {'Last10num', 'Last15num', ...
            'Last30num', 'Last65num', 'Last100num', 'to_rate_Last15', 'poke_rate_Last15', ...
            'LeftRewards', 'RightRewards'});

        LastTrialevents.value = [];

        SubheaderParam(obj, 'hitrt_sbh', 'Hit History', x, y); next_row(y);

    case 'update',
        TrialTracker.value = value(TrialTracker) + 1;
        sides_till_now = side_list(1:n_done_trials);
        Trials.value = sprintf('%i (L:%i, R:%i) ', value(TrialTracker), sum(sides_till_now), length(find(sides_till_now == 0)));
        evs = value(LastTrialEvents);
        rts = value(RealTimeStates);

        % Find first left-right response after tone:
        u = find(evs(:,1)==rts.wait_for_apoke  & (evs(:,2)==3 | evs(:,2)==5));
        if isempty(u), % no wat-for-answer poke, must've been direct delivery
            % Find dirdel state and first left-right response after that
            u = [];
            for k = 1:length(rts.left_dirdel), if find(evs(:,1)==rts.left_dirdel(k)), u = 1; end; end;
            for k = 1:length(rts.right_dirdel), if find(evs(:,1)==rts.right_dirdel(k)), u =1; end; end;
            if isempty(u), error(['No wait-for-answer, no dir del state!']); end;
            u2 = find(evs(u(1):end,2)==3  |  evs(u(1):end,2)==5);
            if isempty(u2), error('No left-right answer after dir del state!'); end;
            u = u2(1) + u(1)-1;
        end;
        % Now, did we go right when right was correct or left when left was
        % correct?
        if  (evs(u(1),2)==3  &  side_list(n_done_trials)==1)
            rew= value(LeftRewards); rew(n_done_trials)=1; LeftRewards.value= rew;
            hit_history(n_done_trials) = 1;
        elseif (evs(u(1),2)==5  &  side_list(n_done_trials)==0),
            rew=value(RightRewards); rew(n_done_trials)=1; RightRewards.value=rew;
            hit_history(n_done_trials) = 1;
        else
            hit_history(n_done_trials) = 0;
        end;

         if hit_history(n_done_trials) == 1, RewardTracker.value = value(RewardTracker)+1; end;
        % update Reward View
        rew_val = sprintf('%i (L:%i, R: %i) ', value(RewardTracker), sum(value(LeftRewards)), sum(value(RightRewards)));
        Rewards.value = rew_val;

        % Update the GUI
        for del=[10 15 30 50 65 100],
            mn = max([1 n_done_trials-del]);
            muhits = mean(hit_history(mn:n_done_trials));

            % calculate side-specific hits/misses
            left_trials = sum(side_list(mn:n_done_trials));
            rew = value(LeftRewards); lefthits = sum(rew(mn:n_done_trials));
            if left_trials == 0, lefthits=0; else lefthits = lefthits/left_trials; end;

            tmp = side_list(mn:n_done_trials); right_trials = length(find(tmp==0));
            rew=value(RightRewards); righthits = sum(rew(mn:n_done_trials));
            if right_trials == 0, righthits = 0; else righthits = righthits/right_trials; end;

            eval(['Last' num2str(del) 'num.value = muhits;']);
            if ((del ~= 15) && (del ~=50))
                muhits_str = sprintf('%2.1f (L: %2.1f, R: %2.1f) ', muhits*100, lefthits*100, righthits*100);
                eval(['Last' num2str(del) '.value = muhits_str;']);
            end;
        end;


        % reset the events store
        push_history(LastTrialEvents);
        LastTrialEvents.value = [];

        % now calculate all the values needed for automation
        pstruct = parse_trial(get_history(LastTrialEvents,value(TrialTracker)), get_history(RealTimeStates,value(TrialTracker)));
        % timeout count
        temp = value(timeout_count);
        temp(value(TrialTracker)) = rows(pstruct.timeout); timeout_count.value = temp;
        % iti poke count
        [co lo ro] = pokes_during_iti({pstruct});
        temp = value(iti_poke_count);
        temp(value(TrialTracker)) = rows(co{1}) + rows(lo{1}) + rows(ro{1});
        iti_poke_count.value = temp;

        % calculate timeout rate
        for del = [25 10 15],
            mn = max([1 n_done_trials-del]);
            eval(['to_rate_Last' num2str(del) '.value = mean(timeout_count(mn:n_done_trials));']);;
        end;
                to_rate_tracker(n_done_trials) = value(to_rate_Last15);

        mn = max([1 n_done_trials-16]);
        poke_rate_Last15.value = mean(iti_poke_count(mn:n_done_trials));
                poke_rate_tracker(n_done_trials) = value(poke_rate_Last15);
%        fprintf(1,'TO Rate is: %2.2f, and Poke rate is: %2.2f\n', value(to_rate_Last15), value(poke_rate_Last15));

    otherwise,
        error(['Don''t know how to handle action ' action]);
end;

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









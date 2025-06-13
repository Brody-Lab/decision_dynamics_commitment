function [c] = temp

rat = 'chanakya';
task = 'dual_discobj';
date = '051212';
f_ver ='a';

COUT = 2;

load_datafile(rat, task, date, f_ver);
trials = eval(['saved.' task '_n_done_trials']);
[t_pd, t_dd]= indicate_pd_dd_trials(saved, saved_history, task, '', 'plot_on', 0);

vpd = saved.VpdsSection_vpds_list;
sides = saved.SidesSection_side_list;
pre_cd = saved.ChordSection_prechord_list;
godur = saved_history.ChordSection_GODur;

% An watchpoint list would have:
%   1. The name of the watchpoint (e.g. "F1","F2")
%   2. The state in which the watchpoint occurs (e.g. prechord, chord)
%   3. The start time of the watchpoint
%   4. The end time of the watchpoint
% e.g. if the relevant tone occurs in prechord, the row in the cell array
% would have ({'relevant tone', 42, 400, 700}

timeout_count = zeros(trials,1);

t = 134;    % has three timeouts
% 2 has 5, 167 has 10, 187 has 4, 83 has 4
[evs, rts] = get_trial_events(saved_history, task, t);
to_state = rts.timeout; to_state = to_state(1);
to = get_state_events(evs, 'RTS', rts, 'qnum', to_state);

vpd_now = vpd(t);
side_now = sides(t);
pre_now = pre_cd(t);
go_now = godur(t);

q_prev = zeros(1,3);
for ctr = 1:length(to)
    t_ind = to(ctr,1);
    if evs(t_ind-1,2) == COUT
        q_prev = [q_prev; ...
            t_ind-1 evs(t_ind-1,1) evs(t_ind-1,3) ...
            ];
    end;
end;

q = q_prev(2:end,:);
names = get_state_name(q(:,2), rts);
start_times = get_entry(q(:,1:2), evs, rts);

% columns: index, state name, time of Cout
c = cell(length(q),3);
c(:,1) = num2cell(q(:,1));
c(:,2) = names;
c(:,3) = num2cell((q(:,3)-start_times)*1000);

% ---------------------------------------------
function [st] = get_entry(q, evs, rts)
CIN = 0;
r = [rts.chord rts.pre_chord];
if sum(~ismember(q(:,2),r)) > 0
    error('Found a time-out during something other than prechord/chord. What now?');
end;
inds = q(:,1)-1;    % look one step behind
if (sum(evs(inds,1) == q(:,2)) == size(q,1)) && ...
        (sum(evs(inds,2) == CIN) == size(q,1))
    st = evs(inds,3);
end;

return;
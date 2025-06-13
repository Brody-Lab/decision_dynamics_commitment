function [trial_cat] = mark_cout_type(ratname, date)
% Categorizes each trial based on which state the Cout occurred during
% 1 - Cout during pre-cue
% 2 - Cout during either cue/pre-chord/chord
% 3 - Valid Cout
% If there are multiple timeouts in a trial, categorizes a trial based on
% which state the earliest timeout occurred in.

load_datafile(ratname,date);
ratrow = rat_task_table(ratname);
task = ratrow{1,2};
evs = eval(['saved_history.' task '_LastTrialEvents']);
rts = eval(['saved_history.' task '_RealTimeStates']);
if rows(rts) == rows(evs) + 1
    rts = rts(1:end-1);
elseif rows(rts) ~= rows(evs), error('rts & evs don''t match!'); end;

p = parse_trial(evs,rts);

trial_cat = zeros(rows(p), 1);

for k = 1:rows(p) % for each trial
    legit_couts = [];

    % first find those couts that occurred in the
    % cue/pre-chord/chord state JUST BEFORE a timeout.
    rt = rows(p{k}.timeout); t = 1;
    while isempty(legit_couts) && (t <= rt)
        % get cpokes that occurred just before this timeout.
        cond = { 'in', 'after', p{k}.wait_for_cpoke(t,1) ; ...
            'out', 'before', p{k}.timeout(t,1) ; ...
            };
        [cpokes1 idx1] = get_pokes_fancy(p{k}, 'center', cond, 'all');
        statenums1 = p{k}.center1_states(idx1,2);

        % keep only those couts that occurred *just* before timeout
        % start
        idx = find(abs(p{k}.timeout(t,1)-cpokes1(:,2)) < 0.1);
        cpokes = cpokes1(idx); statenums = statenums1(idx); % there should only be 1 such cpoke
        if rows(cpokes) ~= 1,
            error( 'Whoa; either we have too many Cpokes meeting criterion or none. Either way, something is fishy!');
        end;

        if (ismember(statenums, rts{k}.pre_chord))
            trial_cat(k) = 1;
            legit_couts = vertcat(legit_couts, cpokes);
        elseif (ismember(statenums, rts{k}.cue) || ...
                ismember(statenums, rts{k}.pre_go) || ...
                ismember(statenums, rts{k}.chord ) ) 
            trial_cat(k) = 2;
            legit_couts = vertcat(legit_couts, cpokes);
        end;
        t = t+1;
    end;

    if rows(legit_couts) < 1
        trial_cat(k) = 3;
    end;
end;

cums = [];
for c = 1:3
   cums(c) = length(find(trial_cat == c));
end;
cums = cums / length(trial_cat);

figure; set(gcf,'Toolbar','none','Position',[  459   779   399   215');
pie(cums, {'Pre-cue','Cue onset', 'Valid'});
t=title('When does my rat Cout? (%s: %s)', ratname, date);
set(t,'FontSize',14,'FontWeight','bold');

function [rxn_time dropped_idx cpoke_array dropped_bobs too_many_bobs bob_trial is_bob] = rxn_time(p,varargin)
% input: pstruct
% output:
% 1 - rxn_time: time from tone offset to valid cout
% 2 - dropped_idx: trials with no valid cpokes
% 3 - cpoke_array: C-by-2 array with the valid cpoke for each trial
% 4 - dropped_bobs: trials with no bobs nor valid cpokes
% 5 - too_many_bobs: trials with > 1 bob
% 6 - bob_trial: trial with exactly 1 bob
% 7 - is_bob: binary to mark whether a given trial is a bob_trial
% (redundant with 'bob_trial', but computed in a different way for
% crosschking)
pairs = { ...
    'ispitch', 0 ; ...
    'rxntime_measure', 'offset2cout' ; ...% can be [offset2cout | onset2cout | cin2cout]
    % Note: rxntime_measure for dual_discobj will always be forced to be onset2cout
    % offset2cout : rxn time is : | cout - tone_offset |
    % onset2cout  : rxn time is:  | cout - tone_onset |
    % cin2cout    : rxn time is : | cout - cin |

    %    'inc_premature_couts', 0 ; ... % when on, the cout is one made either during the {cue, pre_go, chord} stages. If there are multiple such Couts, only the first one is counted.
    'rts', 0 ; ...  % NEEDED if 'rxntime_measure = cin2cout
    'suppress_stdout',0 ; ... % 1 to suppress all messages
    'belenient', 0 ; ... % set to true to include couts that occur anytime after cue onset
    };
parse_knownargs(varargin,pairs);

if suppress_stdout == 0
    fprintf(1,'Measure of reaction time: %s\n', rxntime_measure);
end;

% different data arrays
rxn_time = ones(rows(p),1) *-1; % rows(p)-by-1; contains either valid rxn time or -1
dropped_idx =[];    % i-by-1; if pitch task, those trials that don't have any couts matching rxn time criteria
% if duration task & inc_premature_couts on, those trials
% which DO NOT have premature couts during cue/pre-chord/chord trials
dropped_bobs = [];  % i-by-1; contains trial numbers for only those trials where no valid cpoke and no bobs occurred. Shouldn't happen.
too_many_bobs = []; % i-by-1; contains trial numbers for only those trials where > 1 bob occurred.
bob_trial=[];       % i-by-1; contains trial numbers for only those trials where a single bob occurred
cpoke_array = [];   % C-by-1; contains cpokes from only those trials with a valid/bob cpoke
is_bob = zeros(1,rows(p)); % rows(p)-by-1; 1 or 0; 1 only on those trials with a single bob.

short_short_poke=0;
if ispitch > 0
    for k = 1:rows(p) % for each trial

        if rows(p{k}.cue) == 0,
            short_short_poke = short_short_poke+1;
            if short_short_poke > 100
                error('WHOA, this guy''s making way too many short pokes');
            end;

        else
            tone_onset = p{k}.cue(end,1);
            basestate = p{k}.wait_for_cpoke(end, 1);
            wp1 = p{k}.wait_for_apoke(end,1);

            % "trial" pokes which ended before wait_for_apoke
            outcometype = 'left_reward';
            if rows(p{k}.left_reward) > 0,
                outcometype = 'left_reward';
            elseif rows(p{k}.right_reward) > 0,
                outcometype = 'right_reward';
            elseif rows(p{k}.extra_iti) > 0,
                outcometype = 'extra_iti';
            else
                error('Invalid outcometype')
            end;

            cond = {'in', 'after', basestate; ...
                'in', 'before', wp1; ...
                'out', 'before', eval(['p{k}.' outcometype '(1,1)'])};

            try
                cpokes = get_pokes_fancy(p{k}, 'center', cond, 'all');
            catch
                addpath('Analysis/duration_disc/Event_Analysis/');
                cpokes = get_pokes_fancy(p{k}, 'center', cond, 'all');
            end;
            cpokes = cpokes(find(cpokes(:,2) == max(cpokes(:,2))),:);

            if rows(cpokes) > 1,
                error('Only 1 valid cpoke to compute reaction time!');
            elseif rows(cpokes) < 1,
                dropped_idx = horzcat(dropped_idx, k);
            else
                rxn_time(k) = cpokes(1,2) - tone_onset;
                cpoke_array = vertcat(cpoke_array, cpokes);
            end;
        end;
    end;

else
    for k = 1:rows(p) % for each trial
        if isempty(p{k})
            rxn_time(k) = NaN;
            dropped_idx = horzcat(dropped_idx,k);
        else

            tone_offset = p{k}.cue(end,2);
            tone_onset = p{k}.cue(end,1);
            legit_cout = [];
            switch rxntime_measure
                case 'cin2cout'
                    % first find those couts that occurred in the
                    % cue/pre-chord/chord state JUST BEFORE a timeout.
                    rtmp = sub__get_cout_after_cue_onset(p{k},rts{k});
                    if ~isempty(rtmp)
                        rxn_time(k) = rtmp;
                    else % no legit couts; use the legal one
                        cpokes = sub__get_valid_cout(p{k}, belenient);
                        rxn_time(k) = cpokes(1,2) - tone_offset;
                        dropped_idx = horzcat(dropped_idx, k);
                    end;


                case 'offset2cout'
                    cpokes = sub__get_valid_cout(p{k},0);
                    if rows(cpokes) < 1
                        dropped_idx = horzcat(dropped_idx, k);

                        cpokes = get_bobbing_poke(p{k});
                        if rows(cpokes) < 1
                            dropped_bobs = horzcat(dropped_bobs,k);
                        elseif rows(cpokes) > 2
                            too_many_bobs = horzcat(too_many_bobs, k);
                            % don't take rxn time for such trials.
                        elseif rows(cpokes) == 1,
                            warning('Hey, a bobbing poke should have atleast *TWO* center pokes for the trial');
                        else
                            cpokes = cpokes(end,:); % keep only the second of the cpokes
                            is_bob(k)= 1;
                            bob_trial = horzcat(bob_trial, k);
                            rxn_time(k) = cpokes(1,2) - tone_offset;
                            cpoke_array = vertcat(cpoke_array, cpokes(1,:));
                        end;
                    else
                        rxn_time(k) = cpokes(1,2) - tone_offset;
                        cpoke_array = vertcat(cpoke_array, cpokes(1,:));
                    end;

                case 'onset2cout'
                    cpokes = sub__get_valid_cout(p{k},belenient);
                    if rows(cpokes) < 1
                        dropped_idx = horzcat(dropped_idx, k);

                        cpokes = get_bobbing_poke(p{k});
                        if rows(cpokes) < 1
                            dropped_bobs = horzcat(dropped_bobs,k);
                        elseif rows(cpokes) > 2
                            too_many_bobs = horzcat(too_many_bobs, k);
                            % don't take rxn time for such trials.
                        elseif rows(cpokes) == 1,
                            warning('Hey, a bobbing poke should have atleast *TWO* center pokes for the trial');
                        else
                            cpokes = cpokes(end,:); % keep only the second of the cpokes
                            is_bob(k)=1;
                            bob_trial = horzcat(bob_trial, k);
                            rxn_time(k) = cpokes(1,2) - tone_onset;
                            cpoke_array = vertcat(cpoke_array, cpokes(1,:));
                        end;
                    else
                        rxn_time(k) = cpokes(1,2) - tone_onset;
                        cpoke_array = vertcat(cpoke_array, cpokes(1,:));
                    end;
                otherwise
                    error('Invalid rxntime_measure option: must be one of: offset2cout, cin2cout, onset2cout');
            end;
        end;
    end;
end;

3;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rtmp] = sub__get_cout_after_cue_onset(evs,rts)
rt = rows(evs.timeout); t = 1;
rtmp = [];
while isempty(rtmp) && (t <= rt)
    % get cpokes that occurred just before this timeout.
    cond = { 'in', 'after', evs.wait_for_cpoke(t,1) ; ...
        'out', 'before', evs.timeout(t,1) ; ...
        };
    try
        [cpokes1 idx1] = get_pokes_fancy(evs, 'center', cond, 'all');
    catch
        addpath('Analysis/duration_disc/Event_Analysis/');
        [cpokes1 idx1] = get_pokes_fancy(evs, 'center', cond, 'all');
    end;
    statenums1 = evs.center1_states(idx1,2);

    % keep only those couts that occurred *just* before timeout
    % start
    idx = find(abs(evs.timeout(t,1)-cpokes1(:,2)) < 0.1);
    cpokes = cpokes1(idx,:); statenums = statenums1(idx); % there should only be 1 such cpoke
    if rows(cpokes) ~= 1,
        durs = cpokes(:,2)-cpokes(:,1); idx = find(durs > 0.03); cpokes_tmp = cpokes(idx,:);
        if rows(cpokes_tmp) < rows(cpokes)
            warning('Found 1+ valid cpokes <30ms that I''m taking out');
            cpokes = cpokes_tmp;
        end;
        if rows(cpokes) ~= 1
            error( 'Whoa; either we have too many Cpokes meeting criterion or none. Either way, something is fishy!');
        end;
    end;

    if (sum(ismember(statenums, rts.cue)) > 0 || ...
            sum(ismember(statenums, rts.pre_go)) > 0 || ...
            sum(ismember(statenums, rts.chord )) > 0 )
        cue_sets = cpokes(1,2) - evs.cue(:,1);
        idx = find(cue_sets > 0); starts = evs.cue(idx,1);
        idx = find(starts == min(starts));

        %tone_onset = evs.cue(t,1);
        rtmp = cpokes(1,2) - starts(idx);
    end;
    t = t+1;
end;

%
% function [cpokes] = sub__get_valid_cout(evs)
% basestate_start = evs.wait_for_cpoke(end, 1);
% basestate_end = evs.wait_for_cpoke(end,2);
% wp1 = evs.wait_for_apoke(end,1);
% cue_on = evs.cue(end,1);
%
% lastgo_1 = evs.chord(end,1) + 0.03;
% lastgo_2 = evs.chord(end,2);
%
% % "trial" pokes which ended before wait_for_apoke
% cond = {...
%     'in',   'before',    basestate_end+0.02; ... % rough coincidence with basestate_start
% %    'in',   'before',   basestate_end; ...
% %    'in',   'before',   wp1; ... % discount pokes made during wait_for_apoke
% %    'in',   'before',   cue_on; ...
%     'out', 'after', lastgo_1; ...
%     'out', 'before', lastgo_2};
% cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
%
% % cout was made during wait_for_apoke state
% if rows(cpokes) < 1
%     cpokes = get_pokes_fancy(evs, 'center', ...
%         {'in', 'before', basestate_end+0.02; ...
%         'in', 'before', wp1 ; ...
%         'out', 'after', wp1}, ...
%         'all');
% end;
%
% if rows(cpokes) > 1,
%     error(['There should only be one long valid poke ' ...
%         'per trial']);
% end;


function [cpokes] = sub__get_valid_cout(evs, belenient)

basestate_start = evs.wait_for_cpoke(end, 1);
basestate_end = evs.wait_for_cpoke(end,2);
if rows(evs.wait_for_apoke) == 0
    cpokes = [];
    return;
end;
wp1 = evs.wait_for_apoke(end,1);
cue_on = evs.cue(end,1);
cpokes=[];

if belenient > 0
    wapoke_start = evs.wait_for_apoke(end,1);
    wapoke_end = evs.wait_for_apoke(end,2);
    
    cond = { ...
        'in', 'before', basestate_end+0.02; ...
        'out', 'before', wapoke_start-0.02; ...
        };
 try
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
catch
    addpath('Analysis/duration_disc/Event_Analysis/');
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
end;   
    
else
    try

        lastgo_1 = evs.chord(end,1) + 0.03;
        lastgo_2 = evs.chord(end,2);
    catch
        error('whoops, didn''t find a GO state - what''s going on?');
    end;
    

% "trial" pokes which ended before wait_for_apoke
cond = {...
    'in',   'before',    basestate_end+0.02; ... % rough coincidence with basestate_end
    'out', 'after', lastgo_1; ...
    'out', 'before', lastgo_2};
try
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
catch
    addpath('Analysis/duration_disc/Event_Analysis/');
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
end;
end;

% cout was made during wait_for_apoke state
if rows(cpokes) < 1
    try
        cpokes = get_pokes_fancy(evs, 'center', ...
            {'in', 'before', basestate_end+0.02; ...
            'in', 'before', wp1 ; ...
            'out', 'after', wp1}, ...
            'all');
    catch
        addpath('Analysis/duration_disc/Event_Analysis/');
        cpokes = get_pokes_fancy(evs, 'center', ...
            {'in', 'before', basestate_end+0.02; ...
            'in', 'before', wp1 ; ...
            'out', 'after', wp1}, ...
            'all');
    end;
end;

if rows(cpokes) > 1,
    error(['There should only be one long valid poke ' ...
        'per trial']);
end;



function [cpokes] = get_bobbing_poke(evs)

basestate_end = evs.wait_for_cpoke(end,2);
lastgo_1 = evs.chord(end,1) + 0.03;
lastgo_2 = evs.chord(end,2);

% bobbing pokes which ended before wait_for_apoke
if rows(evs.wait_for_apoke) < 1
    cond = {...
        'in',   'after',    basestate_end-0.02; ... % rough coincidence with basestate_end
        'out', 'before', lastgo_2};
else
    cond = { ...
        'in','after', basestate_end - 0.02; ...
        'in','before', evs.wait_for_apoke(1,1);...
        'out', 'before', evs.wait_for_apoke(1,2) ; ...
        };
end;
try
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
catch
    addpath('Analysis/duration_disc/Event_Analysis/');
    cpokes = get_pokes_fancy(evs, 'center', cond, 'all');
end;





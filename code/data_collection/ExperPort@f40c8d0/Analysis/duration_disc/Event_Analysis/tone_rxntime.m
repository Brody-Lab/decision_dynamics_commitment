function [tone_bins rxn_bins tone_indie rxn_indie side_indie cpoke_indie sig ...
    dropped_bobs too_many_bobs isbob_indie] = tone_rxntime(ratname, varargin)
% Plots average reaction time for binned stimulus parameters.
% Output -
% 1) tone_bins: The centers of the bins into which stimuli were
% categorized
% 2) rxn_bins: a struct.
% If separate_hit_miss == 1, keys = rxn_hit and rxn_miss; else keys = rxn
% Each value is a bx2 array - each row for a bin, columns are mean and sem of
% reaction times respectively
% 3 - tone_indie: struct with keys hit and miss. Contains tone params
% (duration/pitch) for individual trials
% 4 - rxn_indie: struct with keys hit and miss. Contains reaction times for
% individual trials
% 5 - side_indie: struct with keys hit and miss. Contains side choice ("1"
% for left and "0" for right) for individual trials
% 6 - cpoke_indie: struct with keys hit and miss. Contains start and end
% times for valid center pokes for individual trials. Valid center pokes
% are those used to compute reaction time by rxn_time.m
% 3) sig: (bx1) or (b+1 x 1) array. Results of testing whether reaction
% times in adjacent bins are sig different from each other
%    sig(i) = 1 if |rxn_binB - rxn_binB-1 | ~= 0
% if compare_firstlast flag is set, this array will have (b+1) entries, the
% last one testing sig for |rxn_LASTBIN - rxn_FIRSTBIN| ~= 0


pairs = { ...
    'from', '000000'; ...
    'to', '999999'; ...
    'psych_only', 0 ; ... % filter: uses only psychometric trials
    'separate_hit_miss', 0 ;...   % filter: treats hits and misses separately
    'numbins', 8 ; ... % if set to zero, will separate results for each tone
    'multfactor', 1000 ; ...
    'rxntime_measure', 'offset2cout' ; ...% can be [offset2cout | onset2cout | cin2cout]
    % Note: rxntime_measure for dual_discobj will always be forced to be onset2cout
    % offset2cout : rxn time is : | cout - tone_offset |
    % onset2cout  : rxn time is:  | cout - tone_onset |
    % cin2cout    : rxn time is : | cout - cin |

    %    'include_premature_couts', 0 ; ... % Affects duration task only:
    % if set, will count those couts
    % that occurred after cue onset as
    % well. Incase of multiple timeouts,
    % will take the earliest such cout. --- DEFUNCT: for this option, set
    % rxntime_measure to 'cin2cout'
    'compare_firstlast', 0 ; ... % when set will do sigtest of reaction times in first & last bins
    'belenient',0 ; ... % set to true to include couts that occur anytime after cue onset
    };
parse_knownargs(varargin, pairs);

if isempty(strcmpi(rxntime_measure,{'offset2cout','onset2cout','cin2cout'}))
    error('Invalid option for rxntime_measure; must be one of ''offset2cout'',''onset2cout'',''cin2cout''');
end;

% get data fields -----------
ratrow = rat_task_table(ratname);
task = ratrow{1,2};
if strcmpi(task(1:3),'dur')
    left_tones = 'dur_short';
    right_tones ='dur_long';
    psychf = 'psych';
    ispitch = 0;
else
    left_tones = 'pitch_low';
    right_tones = 'pitch_high';
    psychf = 'pitch_psych';
    multfactor = 1;
    ispitch = 1;
end;

rts=0;
datafields = {left_tones, right_tones, 'sides','pstruct'};
if psych_only, datafields{end+1} = psychf;end;
if strcmpi(rxntime_measure,'cin2cout'), datafields{end+1} = 'rts'; end;

get_fields(ratname,'from',from,'to',to,'datafields',datafields);

sl = sides;
if strcmpi(task(1:3),'dur')
    left_tones = dur_short;
    right_tones = dur_long;
else
    left_tones = pitch_low;
    right_tones = pitch_high;
    if psych_only > 0
        psych = pitch_psych;
    end;
end;

tones = zeros(size(sl));
tones(find(sl > 0)) = left_tones(find(sl > 0));
tones(find(sl < 1)) = right_tones(find(sl < 1));


% now compute reaction time -------------
[rxn dropped_idx cpoke_array dropped_bobs too_many_bobs bob_trial is_bob] = rxn_time(pstruct,'ispitch', ispitch, ...
    'rts', rts,'rxntime_measure', rxntime_measure, 'belenient', belenient);

% do necessary filtering based on options ----------------
drop_indices = union(dropped_bobs, too_many_bobs);
if length(drop_indices)>0,
    fprintf(1,'*** %i trials with 0 or 1+ bobs. Ignoring.', length(drop_indices));
    leftover = setdiff(1:rows(pstruct), drop_indices);
        fnames = {'tones','sl','hit_history','psych','rxn','is_bob'};
    for f = 1:length(fnames)
        eval([fnames{f} ' = ' fnames{f} '(leftover);']);
    end;
end;

if psych_only >0
    idx = find(psych>0);
        fnames = {'tones','sl','hit_history','rxn','is_bob'};
    for f = 1:length(fnames)
        eval([fnames{f} ' = ' fnames{f} '(idx);']);
    end;   
    cpoke_array = cpoke_array(idx,:);
end;

fprintf(1,'tone_rxntime: is_bob count = %i\n',sum(is_bob));

if separate_hit_miss > 0
    idx = find(hit_history > 0);
    hit_tones = tones(idx);
        hit_sl = sl(idx);
    hit_rxn = rxn(idx);
    hit_cpoke = cpoke_array(idx,:);
    hit_isbob = is_bob(idx);

    idx = find(hit_history < 1);
    miss_tones = tones(idx);
    miss_rxn = rxn(idx);
    miss_sl = sl(idx);
    miss_cpoke = cpoke_array(idx,:);
    miss_isbob = is_bob(idx);
end;

base_title = sprintf('%s (%s-%s): Rxn time versus tone duration',ratname, from, to);


clen = cpoke_array(:,2) - cpoke_array(:,1);

% start plotting -------------------

figure; set(gcf,'Toolbar','none','Position', [360   609   375   249]);

if separate_hit_miss < 1
    if numbins < 1
        [x means sems] = agg_tones(tones, rxn);
    else
        [x means sems] = bin_hits(tones, numbins, rxn, 'multfactor',1);
    end;
    l=errorbar(x*multfactor, means, sems, sems, '.r'); set(l,'MarkerSize',12);
    if psych_only > 0
        base_title = sprintf('%s\n(Psych only)',base_title);
    end;
    t=title(base_title);

    tone_bins.all = x;
    if cols(means) > 1, means = means'; end;
    if cols(sems) > 1, sems = sems'; end;
    rxn_bins.all = [means sems];

else
    if numbins < 1
        [hit_x hit_means hit_sems] = agg_tones(hit_tones, hit_rxn);
        [miss_x miss_means miss_sems] = agg_tones(miss_tones, miss_rxn);

    else
        [hit_x hit_means hit_sems] = bin_hits(hit_tones, numbins, hit_rxn,'multfactor',1);
        [miss_x miss_means miss_sems] = bin_hits(miss_tones, numbins, miss_rxn,'multfactor',1);
    end;

    %    [sig bins] = sig_effect_outcome(rxn, tones, hit_history, numbins);

    tone_bins.hit = hit_x;
    tone_bins.miss = miss_x;

    if cols(hit_means) > 1, hit_means = hit_means'; end;
    if cols(miss_means) > 1, miss_means = miss_means'; end;
    if cols(hit_sems) > 1, hit_sems = hit_sems'; end;
    if cols(miss_sems) > 1, miss_sems = miss_sems'; end;

    rxn_bins.hit = [hit_means hit_sems];
    rxn_bins.miss = [miss_means miss_sems];


    % Test significance
    [sig bins] = sig_prevbin(hit_rxn, hit_tones, numbins, 'sig_firstlast',compare_firstlast);

    % Now plot
    l=errorbar(hit_x*multfactor, hit_means, hit_sems, hit_sems, '.g'); set(l,'MarkerSize',12);    hold on;
    l=errorbar(miss_x*multfactor, miss_means, miss_sems, miss_sems, '.r'); set(l,'MarkerSize',12);
    top = max(max(hit_means', miss_means'));
    for k = 1:length(bins)
        if sig(k) >0
            t=text(bins(k)*multfactor, top*1.1, '*');
            set(t,'FontSize',18,'FontWeight','bold','Color',[0 0.5 0]);
        elseif sig(k) == 0
            t=text(bins(k)*multfactor, top*1.1, 'ns');
            set(t,'FontSize',10,'FontWeight','bold','Color',[0 0.5 0]);
        elseif sig(k) == -1
            t=text(bins(k)*multfactor, top*1.1, 'n/a');
            set(t,'FontSize',10,'FontWeight','bold','Color',[0 0.5 0]);
        else
            error('Invalid value in sig array: should be {-1,0,1}');
        end;
    end;
    if compare_firstlast > 0
        l=line([bins(1)*multfactor bins(end)*multfactor], [top * 1.2 top * 1.2]);
        set(l,'Color',[0.5 0 0]);
        l=line([bins(1)*multfactor bins(1)*multfactor], [top * 1.2 top * 1.1]);
        set(l,'Color',[0.5 0 0]);
        l=line([bins(end)*multfactor bins(end)*multfactor], [top * 1.2 top * 1.1]);
        set(l,'Color',[0.5 0 0]);

        if sig(end) > 0
            t=text(bins(numbins/2)*multfactor, top*1.3, '*');
            set(t,'FontSize',18,'FontWeight','bold','Color',[0.5 0 0]);
        else
            t=text(bins(numbins/2)*multfactor, top*1.3, 'ns');
            set(t,'FontSize',10,'FontWeight','bold','Color',[0.5 0 0]);
        end;
    end;
    %legend({'Hit','Miss'});
    if psych_only > 0
        base_title = sprintf('%s\n(Psych only) (Correct and error trials)',base_title);
    else
        base_title =sprintf('%s\n : Correct and error trials', base_title);
    end;
    t=title(base_title);

    % set reaction time (rxn) for output
    derived_sides = zeros(size(sl));
    went_left = union(intersect(find(sl > 0), find(hit_history>0)), ... % correct Left trials OR
        intersect(find(sl < 1), find(hit_history<1)));    % incorrect Right trials
    derived_sides(went_left) = 1; % everything else is "Right"

    % populate all the structs storing individual trial data divided by
    % trial outcome (hit or miss)
    side_indie.hit = derived_sides(find(hit_history > 0));
    side_indie.miss = derived_sides(find(hit_history < 1));

    rxn_indie.hit =  hit_rxn;
    rxn_indie.miss = miss_rxn;

    tone_indie.hit = hit_tones;
    tone_indie.miss = miss_tones;

    cpoke_indie.hit = hit_cpoke;    
    cpoke_indie.miss = miss_cpoke;
    
    isbob_indie.hit = hit_isbob;
    isbob_indie.miss = miss_isbob;
end;

set(t,'FontSize',10);
if strcmpi(task(1:3),'dur')
    xlabel('Tone duration (ms)');
else
    xlabel('Frequency (KHz)');
end;
ylabel('Reaction time (s)');
set(gca,'YLim',[0 0.6]);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% is data in current bin significantly different from that in the previous
% bin?
% does not separate based on hit/miss
function [sigarray bins] = sig_prevbin(rxn, tones, numbins, varargin)

pairs = { ...
    'sig_firstlast', 0 ; ... % when set, does sig test for |rxnN-rxn1| being different from zero
    };
parse_knownargs(varargin, pairs);
if numbins > 0
    [bins bin_idx blah2] = bin_hits(tones, numbins, rxn, 'multfactor',1,'get_bin_indices',1);
else
    bins = unique(tones);
end;
sigarray = [-1]; % -1 means "n/a"
% get data for first bin
if numbins > 0
    idx = find(bin_idx == 1);
else
    idx = find(tones == bins(1));
end;
prev_rxn = rxn(idx);
first_rxn = rxn(idx);

if sig_firstlast > 0
    numcompare = length(bins);
else
    numcompare = length(bins)-1; % since we compare each bin to the previous one, we are doing n-1 comparisons
end;

for k = 2:length(bins)
    if numbins > 0
        idx = find(bin_idx == k);
    else
        idx = find(tones == bins(k));
    end;
    rxn_tone = rxn(idx);

    sig=permutationtest_diff(rxn_tone, prev_rxn,'alphaval',0.05/numcompare);
    sigarray = horzcat(sigarray, sig);

    prev_rxn = rxn_tone;

    if k == length(bins) && sig_firstlast > 0
        sig=permutationtest_diff(rxn_tone, first_rxn,'alphaval',0.05/numcompare);
        sigarray = horzcat(sigarray, sig);
    end;
end;


% is the reaction time for hit-versus-miss for the SAME tone
% sig different? (permutation test)
function [sigarray bins] = sig_effect_outcome(rxn,tones, hit_history,numbins)
if numbins > 0
    [bins bin_idx blah2] = bin_hits(tones, numbins, rxn, 'multfactor',1,'get_bin_indices',1);
else
    bins = unique(tones);
end;

sigarray = [];
for k = 1:length(bins)
    if numbins > 0
        idx = find(bin_idx == k);
    else
        idx = find(tones == bins(k));
    end;
    rxn_tone = rxn(idx);
    hit_tone = hit_history(idx);

    correct = find(hit_tone > 0); missed = find(hit_tone < 1);
    sig=permutationtest_diff(rxn_tone(correct), rxn_tone(missed),'alphaval',0.05/length(bins));

    sigarray = horzcat(sigarray, sig);
end;


function [bins binned_means binned_sems] = agg_tones(tones, rxn)
bins = unique(tones);
binned_means = [];
binned_sems = [];
for u = 1:length(bins)
    idx =  find(tones == bins(u));
    hitbin = rxn(idx);
    binned_means = [binned_means mean(hitbin);];
    binned_sems = [binned_sems std(hitbin)/sqrt(length(hitbin))];
end;

% % BEGIN MVMT: Only use the below check if using "movement_time" instead of
% % "rxn_time"
% if 0
%     % now check that side_picked is consistent with other trial-related data
%     derived_sides = zeros(size(sl));
%     went_left = union(intersect(find(sl > 0), find(hit_history>0)), ... % correct Left trials OR
%         intersect(find(sl < 1), find(hit_history<1)));    % incorrect Right trials
%     derived_sides(went_left) = 1; % everything else is "Right"
%
%     if cols(side_picked) > 1, side_picked = side_picked'; end;
%     if cols(derived_sides) > 1, derived_sides = derived_sides'; end;
%     if length(find(side_picked - derived_sides ~= 0)) > 5
%         error('Uh oh; smallest_side from rxn_time does not match data from sl & hit_history.\n');
%     end;
% end;

% figure;
% subplot(1,2,1);
% % plot reaction time
% %plot(1:length(rxn),rxn,'.r');
% hist(rxn);
% title('Reaction time');
% % plot length of tones
% tones = tones*1000;
% subplot(1,2,2);
% plot(1:length(tones),tones,'.b');title('Tone duration');


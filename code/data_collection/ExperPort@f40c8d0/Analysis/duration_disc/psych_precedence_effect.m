function [] = psych_precedence_effect(ratname, varargin)
% When a difficult sound precedes an easy one & the rat gets the first one
% correct, is he more likely to get the easy one correct too?
% That is, are the trials truly independent or is there a context effect?

pairs= {...
    % Which dates to use? ---------------------
    'use_dateset', '' ; ... % [psych_before | psych_after | given | span_surgery | '']
    'last_few_pre', 5; ...
    'given_dateset', {} ; ... % when 'use_dateset' = given_set, this cell array should contain a set of dates (yymmdd) for which superimposed graphs will be plotted
    'from','000000';...
    'to', '999999';...
    'dstart', 1; ... % option to plot only session A to session B; this is where you set value for A...
    'dend', 1000; ... % and this is where you set value for B
    'lastfew', 1000; ... % option to plot only last X sessions
    'first_few', 3; ...
    % Tone parameters -------------------------
    'dur_mp', sqrt(200*500);...
    'freq_mp', sqrt(8*16);  ...
    % What fields to retrieve?------------------
    'tones_setA', 'default'; ...
    'tones_setB', 'default'; ...
    % Merge multiday data or analyze singly?----------
    'bundle_across_days', 0; ... % combine data over days if 1. Else analyze and print each day's data separately.

    };
parse_knownargs(varargin,pairs);

ratrow = rat_task_table(ratname);
task=ratrow{1,2};

if ~strcmpi(task(1:3), 'dur')
    if strcmpi(tones_setA, 'default')
        tones_setA = 'pitch_low'; end;
    if strcmpi(tones_setB, 'default')
        tones_setB = 'pitch_high'; end;

    mp = freq_mp;
else
    if strcmpi(tones_setA, 'default')
        tones_setA = 'dur_short'; end;
    if strcmpi(tones_setB, 'default')
        tones_setB = 'dur_long'; end;
    mp = dur_mp/1000;
end;

datafields={tones_setA, tones_setB};


% ----------------------------------------------------------
% BEGIN Date set retrieving module: Use this piece of code to get either
% a pre-buffered date set, a range, or a specified date_set.
% To use this, have two switches in your 'pairs' cell array:
% 1 - 'vanilla_task' - binary; indicates whether rat was lesioned during
% vanilla task (1) or not (0)
% 2 - 'use_dateset' - specifies how to obtain dates to analyze

switch use_dateset
    case 'psych_before'
        error('Sorry, not yet implemented');
    case 'psych_after'
        error('Sorry, not yet implemented');
    case 'given'
        if cols(given_dateset) > 1, given_dateset = given_dateset'; end;
        dates = given_dateset;
        get_fields(ratname, 'use_dateset', 'given', 'given_dateset', given_dateset,'datafields', datafields);
    case ''
        get_fields(ratname, 'from', from, 'to', to,'datafields',datafields);
    case 'span_surgery'
        error('Sorry, not yet implemented');
    otherwise
        error('invalid use_dateset');
end;
% END Date set retrieving module
% ---------------------------------------------------------

hh=hit_history;

tones_setA = eval(tones_setA);
tones_setB = eval(tones_setB);

if bundle_across_days < 1 % analyze and print data for each day separately.
    cumtrials=cumsum(numtrials);
    for d= 1:length(numtrials)
        fprintf(1,'%s\n', dates{d});
        sidx=1; if d>1, sidx = cumtrials(d-1)+1; end;
        eidx=cumtrials(d);

        currhh = hh(sidx:eidx);
        curr_toneA = tones_setA(sidx:eidx);
        curr_toneB = tones_setB(sidx:eidx);

        sub__analyze(curr_toneA, currhh, mp,'plotclr','b');
        sub__analyze(curr_toneB, currhh, mp,'plotclr','r');
    end;
else
    fprintf(1,'Bundling data for %s to %s (%i days)\n', dates{1}, dates{end}, length(dates));
    sub__analyze(tones_setA, hh,mp,'plotclr','b','diff2easy', 'lower');
    sub__analyze(tones_setB, hh,mp,'plotclr','r','diff2easy','higher');
end;


% -----------------------------------------------------------
% Subroutines
% -----------------------------------------------------------

function [] = sub__analyze(tone_array,hh,mp,varargin)
pairs = {...
    'plotclr', 'b' ; ...
    'diff2easy','higher'; ... % the expected value of the easy stimulus relative to the difficult one
    };
parse_knownargs(varargin,pairs);

tone_array(find(tone_array == 0)) = NaN;

[t1runs t1ridx t1rlen] = sub__findruns(tone_array);
[toneseq idxseq] = sub__find_diff2easy_seq(t1runs, t1ridx, mp, diff2easy);

% sanity check plot - are all tones in the sequence ordered the same way?
f =findobj('Tag', 'psych_preced');
if isempty(f)
    figure; uicontrol('Style','text','String','blah', 'Visible','off','Tag', 'psych_preced');
end;

for k = 1:length(toneseq)
    plot([1 2], toneseq(k,2:3),'.b','Color', plotclr); hold on;
    plot([1 2], toneseq(k,2:3),'-b','Color', plotclr); hold on;
end;
set(gca,'XLim',[0.98 2.02], 'XTick', [1 2]);

% make sure that index in toneseq matches the trial #s in the original tone
% array
for r =1:rows(idxseq),
    ct = toneseq(r, 2:3); rt = tone_array(idxseq(r,2:3));
    if ct ~= rt, fprintf(1,'Mismatch at row %i\n', r); end;
end;

[diffwrong diffright] = next_hrate(idxseq, hh);
fprintf(1,'Hit rate following error = %2.1f%%\nHit rate following success = %2.1f%%\n\n',...
    diffwrong, diffright);

% Finds "Runs" of same-side tones (ie instances where multiple tones are
% presented on the same side one after the other)
% Returns:
% 1. toneruns - a cell array, each entry of which is the values of tones in the run
% 2. runidx - a cell array, each entry contains the *index* (trial #) of
% tones in the run
% 3. runlens - an array containing the corresponding length of each run in
% toneruns
function [toneruns runidx runlens] = sub__findruns(tone_array)
% find spots where two consecutive tones are presented on the same side
t1diff = diff(tone_array);
t1_rptidx = find(~isnan(t1diff)); % the consecutive tones are on the indices found and those following it.
% eg. if "5" is in t1_rptidx, it means
% that "5" and "6" were repeated on the
% same side.

runs = diff(t1_rptidx); % diff of 1 means that 2+ sounds were presented on the same side

toneruns = {};
runlens = [];
runidx={};
i = 1;
j = 1;
while i < length(runs)
    tmp = [];
    if runs(i) > 1 % run of two
        tmp = [t1_rptidx(j) t1_rptidx(j)+1];
        i=i+1;
        j=j+1;
    else % run of 2+
        tmp = [t1_rptidx(j)];
        i=i+1; j=j+1;
        while runs(i) == 1 && i < length(runs)
            tmp = [tmp t1_rptidx(j)];
            i=i+1; j=j+1;
        end;
        tmp = [tmp t1_rptidx(j) t1_rptidx(j)+1];
        i=i+1;j=j+1;
    end;
    toneruns{end+1} = tone_array(tmp);
    runidx{end+1} = tmp;
    runlens = horzcat(runlens, length(tmp));
end;

% Finds pairs of tones in a run where a difficult one is succeeded by an
% easy one.
% here, the closer a tone is to the provided midpoint, the more difficult
% it is considered
function [toneseq idxseq] = sub__find_diff2easy_seq(toneruns, runidx, mp,diff2easy)
toneseq = [];
idxseq = [];
fprintf(1,'**** mp is : %2.2f\n', mp);
for r = 1:length(toneruns)
    curr = toneruns{r};
    curridx = runidx{r};
    dist2mp = abs(curr - mp); % how close to mp?
    reldist = diff(dist2mp); % +ve value at i means (i) is closer to the midpoint than (i+1)
    idx = find(reldist >0);
    for k = 1:length(idx)
        m = idx(k);
        toneseq = vertcat(toneseq, [r curr(m) curr(m+1)]);
        idxseq = vertcat(idxseq, [r curridx(m) curridx(m+1)]);
        if strcmpi(diff2easy,'higher') % easy should be higher than difficult
                 if curr(m) > curr(m+1)
                    error('Ooh, putting in a pair that isn''t going the right way!');
                 end;
        else
                 if curr(m) < curr(m+1)
                    error('Ooh, putting in a pair that isn''t going the right way!');
                 end;
        end;
    end;
end;


function [hratewrong hrateright] = next_hrate(idxseq, hh)
% Columns
% idxseq - run #, idx_for_difficult_tone, idx_for_easier_tone, ...
%          hit_value_For_difficult, hit_value_For_easier
hhseq = [];
for r=1:rows(idxseq)
    diffidx = idxseq(r,2); easyidx=idxseq(r,3);
    hhseq = vertcat(hhseq, ...
        [ idxseq(r,1) diffidx easyidx ...
        hh(diffidx) hh(easyidx) ]);
end;

% Question: What is the average hit rate for easier when you get the
% difficult tone correct?
diffwrong=  find(hhseq(:,4)==0);
diffright = find(hhseq(:,4)==1);

hratewrong = mean(hhseq(diffwrong,5))*100;
hrateright = mean(hhseq(diffright,5))*100;
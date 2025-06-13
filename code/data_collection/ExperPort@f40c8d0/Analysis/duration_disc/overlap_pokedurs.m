function [] = overlap_pokedurs(rat, task, varargin)
% This script works for duration_discobj
% In the case where the short and long tone trial durations are mostly
% non-overlapping, analyzes the rat's performance in the section that
% _does_ overlap.
% The goal is to retrospectively determine if the rat made its decision
% based on poke duration. If a 'hit' were defined relative to the poke
% duration midpoint (instead of our intention where a 'hit' is relative
% to the tone duration midpoint), how well is the rat doing?

pairs =  { ...
    'task','duration_discobj' ; ...
    'from', '000000'; ...
    'to', '999999'; ...
    'max_trials', 150 ; ...
    };
parse_knownargs(varargin, pairs);

dates = get_files(rat, 'fromdate', from, 'todate', to);

mega_pre_min = [];
mega_pre_max = [];
mega_post_min = [];
mega_post_max = [];
mega_short_tone =[];
mega_long_tone = [];
mega_prevpd = [];
mega_postvpd = [];
mega_hh = [];
mega_sides = [];
mega_logdiff = [];
mega_psych = [];

for d = 1:rows(dates)
    date = dates{d};
    load_datafile(rat, task, date);

    % Get variable period lengths
    pre_min = cell2mat(saved_history.VpdsSection_MinValidPokeDur);
    pre_max = cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
    post_min = cell2mat(saved_history.ChordSection_Min_2_GO);
    post_max = cell2mat(saved_history.ChordSection_Max_2_GO);

    % Get tone duration lengths
    short_tone = saved.ChordSection_tone_list1;
    long_tone = saved.ChordSection_tone_list2;
    logdiff = cell2mat(saved_history.ChordSection_logdiff);
    psych = cell2mat(saved_history.ChordSection_psych_on);

    % Get trial length
    pre = saved.VpdsSection_vpds_list;
    post = saved.ChordSection_prechord_list;
    sides = saved.SidesSection_side_list;

    tr = eval(['saved.' task '_n_done_trials']);
    hit_history = eval(['saved.' task '_hit_history']);
    %  hh = hit_history(find(~isnan(hit_history)));

    pre_min = pre_min(2:tr);
    pre_max = pre_max(2:tr);
    post_min = post_min(2:tr);
    post_max = post_max(2:tr);

    short_tone = short_tone(2:tr);
    long_tone = long_tone(2:tr);
    logdiff = logdiff(2:tr);

    hh = hit_history(2:tr);
    sides =sides(2:tr);
    pre = pre(2:tr);
    post = post(2:tr);

    mega_pre_min = [mega_pre_min; pre_min];
    mega_post_min = [mega_post_min; post_min];
    mega_pre_max = [mega_pre_max; pre_max];
    mega_post_max = [mega_post_max; post_max];


    mega_short_tone = [mega_short_tone; short_tone];
    mega_long_tone = [mega_long_tone; long_tone];
    mega_logdiff = [mega_logdiff; logdiff];
    mega_psyc = [mega_psych; psych];

    mega_sides = [mega_sides sides];
    mega_hh = [mega_hh hh];
    mega_prevpd = [mega_prevpd pre];
    mega_postvpd = [mega_postvpd post];

end;

% Change names
pre_min = mega_pre_min;
pre_max = mega_pre_max;
post_min = mega_post_min;
post_max = mega_post_max;
short_tone = mega_short_tone;
long_tone = mega_long_tone;
pre = mega_prevpd;
post = mega_postvpd;
hh = mega_hh;
sides = mega_sides;
logdiff = mega_logdiff;
psych = mega_psych;


% ------------------------------------
% Get variable period ranges
% ------------------------------------

if length(unique(pre_min)) > 1 | length(unique(pre_max))>1, error('>1 Pre-sound range. Check datafile'); ...
end;
if length(unique(post_min)) > 1 | length(unique(post_max))>1, error('>1 Post-sound range. Check datafile'); ...
end;

pre_min = pre_min(1);
pre_max = pre_max(1);
post_min = post_min(1);
post_max = post_max(1);
[silent_lengths, silent_pdf] = pdf_sum_uni(pre_min, pre_max, post_min, ...
    post_max);
% trial length distribution
if length(unique(short_tone)) > 1 | length(unique(long_tone))>1, error('>1 tone pair! check datafile'); ...
end;

short_tone = short_tone(1); long_tone = long_tone(1);

short_simtrials = silent_lengths + short_tone;
long_simtrials = silent_lengths + long_tone;


% Print summary info
fprintf(1,'VPD specified range: [%1.1f, %1.1f]\n', pre_min, pre_max);
fprintf(1,'VPD sampled extremes: [%1.1f, %1.1f]\n', min(pre), max(pre));
fprintf(1,'Post sampled extremes: [%1.1f, %1.1f]\n', min(post), max(post));
fprintf(1,'Short tone: %1.1f, Long tone: %1.1f\n', short_tone, long_tone);

% ------------------------------------
% Calculate trial length
% ------------------------------------

stim = zeros(size(sides)); stim(find(sides > 0)) = short_tone;
stim(find(sides < 1)) = long_tone;
trial_length = stim + pre + post;

idx_left = find(sides > 0);
idx_right = find(sides < 1);

short_realtrials = trial_length(idx_left);
long_realtrials = trial_length(idx_right);
fprintf(1,'Short trials: %1.1f-%1.1f\n', min(short_realtrials), max(short_realtrials));
fprintf(1,'Long trials: %1.1f-%1.1f\n',min(long_realtrials), max(long_realtrials));


% Plot 1: Pre-post distribution for short and long trials
figure;
set(gcf,'Menubar','none','Toolbar','none','Position',[18   392   358   368]);

short_pre = pre(find(sides > 0));
long_pre = pre(find(sides < 1));
short_post = post(find(sides > 0));
long_post = post(find(sides < 1));

subplot(2,2,1);
hist(short_pre);

xlabel('Pre-sound length (s)'); ylabel('# trials');title('Short trials');
subplot(2,2,3); hist(long_pre);
xlabel('Pre-sound length (s)'); ylabel('# trials');  title('Long trials');

subplot(2,2,2);
hist(short_post);

subplot(2,2,4);
hist(long_post);

% -------------------
% Plot 2; Trial length distribution
% -------------------

nsh = hist(short_realtrials);
nlo = hist(long_realtrials);
maxn = max(max(nsh), max(nlo));

figure;
set(gcf,'Menubar','none','Toolbar','none','Position',[40 0 358 368]);

subplot(2,1,1);
hist(short_realtrials);
set(gca,'XLim',[0.6 1.6],'YLim', [0 1.1*maxn]);
hold on;
line([1 1],[0 1.1*maxn], 'LineStyle',':','Color','r','LineWidth',2);
line([1.2 1.2],[0 1.1*maxn], 'LineStyle',':','Color','r','LineWidth',2);
xlabel('SHORT Trial length (Seconds)'); ylabel('# trials');

subplot(2,1,2);
hist(long_realtrials);
hold on;
line([1 1],[0 1.1*maxn], 'LineStyle',':','Color','r','LineWidth',2);
line([1.2 1.2],[0 1.1*maxn], 'LineStyle',':','Color','r','LineWidth',2);
set(gca,'XLim',[0.6 1.6],'YLim', [0 1.1*maxn]);
xlabel('LONG Trial length (Seconds)'); ylabel('# trials');
title(['Trial length dist''n for short & long tone trials']);




% -------------------
% Look at side choice as a function of tone and trial length
% -------------------

side_choice = zeros(size(hh));

% side_choice = 1 means 'chose left'
% side_choice = 0 means 'chose right'
side_choice(find(sides > 0 & hh > 0)) = 1; % short tone trial correct
side_choice(find(sides < 1 & hh < 1)) = 1; % long tone trial incorrect

side_choice_longt = side_choice(idx_right);
side_choice_shortt = side_choice(idx_left);

% Make sure side_choice is infact what we think it is
tmp = side_choice(find(sides > 0 & hh < 1)); if sum(tmp) > 0, ...
        error('side_choice defined inccorectly!'); end;
tmp = side_choice(find(sides < 1 & hh > 0)); if sum(tmp) > 0, ...
        error('side_choice defined inccorectly!'); end;



% Get side choice rate as fn of trial length
numbins = 10;
[xshort binned_hits_short sd_hit_short] = bin_hits(short_realtrials, numbins, ...
    side_choice_shortt);
binned_hits_short = 100 - binned_hits_short; % Want frequency going RIGHT
% for short trials
[xlong binned_hits_long sd_hit_long] = bin_hits(long_realtrials, numbins, side_choice_longt);


% -------------------
% Show frequency of side choice for long trials ...
% -------------------
figure;
% set(gcf,'Menubar','none','Toolbar','none');
set(gcf,'Position',[382 184 823 300]);
%    subplot(2,2,1);
%   hist(long_realtrials,numbins);
%   h = findobj(gca,'Type','patch');
%   set(h, 'FaceColor','r');
%   t=xlabel('Poke duration (seconds)');
%
% set(t,'FontSize',14,'FontWeight','bold');
%   t=ylabel('# trials');
%
% set(t,'FontSize',14,'FontWeight','bold');
%    %  s = sprintf('%s: %s (%s to %s)\nLong tone trial length distribution', ...
%    %              make_title(rat), make_title(task), from, to);
%        s = sprintf('Long tone trial length distribution');
% t=title(s);
%
% set(t,'FontSize',14,'FontWeight','bold');
% -------------------
% Show frequency of side choice for short trials ...
% -------------------
% figure;
%set(gcf,'Menubar','none','Toolbar','none');
%    subplot(2,2,2);
%   hist(short_realtrials,numbins);
%   h = findobj(gca,'Type','patch');
%   set(h, 'FaceColor','g');
%   t = xlabel('Poke duration (seconds)');
% set(t,'FontSize',14,'FontWeight','bold');
%   t= ylabel('# trials');
% set(t,'FontSize',14,'FontWeight','bold');
%     % s = sprintf('%s: %s (%s to %s)\nShort tone trial length distribution', make_title(rat), make_title(task), from,to);
%  s = sprintf('Short tone trial length distribution');
%     t = title(s);
% set(t,'FontSize',14,'FontWeight','bold');
%
% ------
% Plot frequency of "Error" for both short and long trials
% --------

%subplot(2,2,[3 4]);
l = errorbar(xlong, binned_hits_long, sd_hit_long, sd_hit_long, ...
    '.r','MarkerSize',20);
%  set(l, 'Color','r');
hold on;
%  line([min(trial_length) max(trial_length)], [0.8 0.8],
%  'LineStyle',':', 'Color','r');

l = errorbar(xshort, 100-binned_hits_short,sd_hit_short,sd_hit_short, ...
    '.b','MarkerSize',18);
set(l,'Color',[0  0 0.5]);


line([min(xshort) max(xlong)], [75 75], 'LineStyle', ':', 'Color','r');
%  line([min(trial_length) max(trial_length)], [0.8 0.8], 'LineStyle',':', 'Color','r');

t=xlabel('Trial length (seconds)');
set(t,'FontSize',14,'FontWeight','bold');
t=ylabel({'frequency of reporting "Short" (%)'});
set(t,'FontSize',14,'FontWeight','bold');
%  s = sprintf('%s: %s (%s to %s)\nFrequency of error choice ', make_title(rat), make_title(task), from, to);
% s = sprintf('Frequency of error choice ');
% t=title(s);
set(t,'FontSize',14,'FontWeight','bold');
set(gca,'YLim',[0 110],'YTick',0:10:100);
%

legend({'Long tones','Short tones'});


% Bins the range "to_bin" into "numbins" equally-spaced bins
% For each bin, calculates the hit rate.
% Returns: 1) The # of entries in each bin
%  2) The mean hit rate for the bin
function [x binned_hrate binned_sem] = bin_hits(to_bin, numbins, hits)
idx_crosschk = [];
binwidth = (max(to_bin) - min(to_bin)) / numbins;
[n,x] = hist(to_bin,numbins);
binned_hrate = []; binned_sem = [];
idx_so_far = []; % avoid rebinning
for k = 1:numbins
    idx=[];
    if k == 1,
        idx = find(to_bin < x(k));
    end;
    idx = [ idx find(to_bin > (x(k)-(binwidth/2)) & ...
        to_bin <= (x(k)+(binwidth/2)) )];
    idx = unique(idx);

    idx = setdiff(idx, idx_so_far);
    idx_so_far = [idx_so_far idx];
    idx_crosschk = [ idx_crosschk  length(idx)];

    hitbin = hits(idx); hitbin = hitbin*100;
    binned_hrate = [binned_hrate mean(hitbin);];
    binned_sem = [binned_sem std(hitbin)/sqrt(length(hitbin))];

end;
%idx_crosschk
%n
fprintf(1, 'Bin count #1: %i, Bin count #2: %i\n', sum(idx_crosschk), sum(n));


function [bin_tally, bin_reps, numtrials] = plot_psychometric_curve_single(ratname, task, date, varargin)
% Plots the %(reporting long) for different time points when given hit data

pairs = { ...
    'min_freq',	350; ...
    'max_freq', 	858; ...
    'steps',	8;	...
    'plot_title',	['Decision curve: ' ratname ', Duration Discrimination (' int2str(date) ')'] ; ...
    'no_plot', 0     ; ...
    'plot_log', 1   ; ...
    'drop', 0       ; ...
    'drop_last', 0  ; ...
    };parse_knownargs(varargin, pairs);

if min_freq > max_freq
    error('Invalid frequency combination! Min should be <= Max');
end;

% get psychometric trials
load_datafile(ratname, task, date(1:end-1), date(end));
t1r = saved_history.ChordSection_Tone1_random;
t2r = saved_history.ChordSection_Tone2_random;
trials = intersect(find(strcmp(t1r,'on')), find(strcmp(t2r,'on')));
d = make_contig(trials);
if cols(d) > 1
    sprintf('>1 contig of trials found; taking last such one.');
    trials = d{cols(d)};
end;

trials = trials(find(trials <= saved.duration_discobj_n_done_trials));

% sort trials by frequency
dummy = protocolobj('empty');
left = get_generic(dummy, 'side_list_left'); right = 1-left;

sides = saved.SidesSection_side_list;
left_side = intersect(trials, find(sides == left));
right_side = intersect(trials, find(sides == right));
tone_short = saved.ChordSection_tone1_list;
tone_long = saved.ChordSection_tone2_list;
tone_list = [tone_short(left_side) tone_long(right_side)] * 1000;

% now, convert hit history to "reported long"
hh = eval(['saved.' task '_hit_history']);
hh = hh(find(~isnan(hh)));
short_said_long = intersect(left_side, find(hh == 0)); 
short_said_short = intersect(left_side, find(hh == 1));
rep_long(short_said_long) = 1;
rep_long(short_said_short) = 0;
rep_long = hh(trials);

[bin_center, bin_at] = generate_bins(min_freq, max_freq, steps);
[tally my_bins]= histc(tone_list, bin_at);

% extract only those data needed for analysis
tone_list = tone_list(trial_start:trial_end) * 1000; % convert to ms scale
rep_long = rep_long(trial_start:trial_end);

%bin_size = 75;
%bins = min_freq:bin_size:max_freq; %generate_bins(min_freq, max_freq, steps);
bins = generate_bins(min_freq, max_freq, steps);

bin_tally = zeros(size(bins));  % count of tones in this bin
bin_reps  = zeros(size(bins));  % count of rep longs in this bin
test_bin = zeros(length(tone_list),2);
for curr = 1:length(rep_long)
    x = tone_list(curr);
    my_bin = min(find(x-bins <= 0));
    test_bin(curr,:) = [x my_bin];
    bin_tally(my_bin) = bin_tally(my_bin) + 1;
    bin_reps(my_bin) = bin_reps(my_bin) + rep_long(curr);   
end;
tally = tally(1:end-1);
if reps(end) > 0, error('H''m, the last bin should not have anything in it!');end;
reps = reps(1:end-1);
pct = reps ./ tally; 

if ~no_plot        
    y = pct; x = bins; n = tally;
    variance = y .* (1-y);
    variance_single = zeros(size(n));
    ind = find(n~=0 & ~isnan(n));
    variance_single(ind) = variance(ind) ./ n(ind);
    stdev = sqrt(variance_single);

    if plot_log
        errorbar(log(x(1:end-1)), y, stdev, stdev, '-r.');
        %    plot(log(x), y, 'or');          % plot datapoints
    else
        %    plot(x,y,'or');
        errorbar(log(x(1:end-1)),y, stdev, stdev, '-r.');
    end;

    ylabel('%(Reported Long)');
    xlabel('Tone duration (ms)');

end;

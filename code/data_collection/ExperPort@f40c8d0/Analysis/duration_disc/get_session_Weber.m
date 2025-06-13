function [mean, sd, weber] = get_session_Weber(ratname, task, date, f_ver, varargin)

% Given the session information for a duration discrimination task
% (duration_discobj) with psychometric trials, returns the Weber ratio
%
% The Weber ratio is defined to be the ratio of (sd/mean) where the two values are 
% defined as follows: 
% mean = log(duration of mean probability of reporting long)
% sd = log(duration where probability of reporting long is the standard
% deviation of the entire distribution)

pairs = { ...
    'bin_min', 300 ; ...
    'bin_max', 1000 ; ...
    'steps', 8 ; ...
    };
parse_knownargs(varargin, pairs);

bins = generate_bins(bin_min, bin_max, steps);

% get the counts for each bin
[bt, br, numtrials] = plot_psychometric_curve_single(ratname, task, date, 'f_ver', f_ver, ...
    'min_freq', bin_min, 'max_freq', bin_max, 'steps', steps, 'no_plot', 1);

% derive a percentage(reported long) out of them
bin_pct = zeros(size(bins));    % %age reported long
for b = 1:length(bins)
    if bt(b) > 0
        bin_pct(b) = br(b) / bt(b);
    end;
end;

% remove NaN entries
inds = find(bt > 0);
x = log(bins(inds));
y = bin_pct(inds);

% get psychophysical threshold (50% discriminability), and variability (25
% & 75% discriminability)
[mid, sd] = get_discriminability_points(x,y);
mid = exp(mid);
sd = exp(sd);

weber = log(sd) / log(mid);

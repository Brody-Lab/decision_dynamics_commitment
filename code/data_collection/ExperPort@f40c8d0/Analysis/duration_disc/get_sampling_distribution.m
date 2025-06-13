function [overall] = get_sampling_distribution(rat, date, shortest, longest)

load_datafile(rat, 'duration_discobj', date(1:end-1), date(end));

tone_short = saved.ChordSection_tone1_list;
tone_long = saved.ChordSection_tone2_list;

tone1_random = saved_history.ChordSection_Tone1_random;
tone2_random = saved_history.ChordSection_Tone2_random;
sides = saved.SidesSection_side_list;

psych = intersect(find(strcmp(tone1_random,'on')), find(strcmp(tone2_random,'on')));
bins = generate_bins(shortest, longest, 8);

left = 1; right = 0;
left_side = intersect(psych, find(sides == left));
right_side = intersect(psych, find(sides == right));
overall = [tone_short(left_side), tone_long(right_side)];

hist(overall*1000, bins);

n = hist(overall*1000, bins);
for k = 1:length(n)
    text(bins(k)-2, n(k)+2, int2str(n(k)));
end;

title([rat '(' date '): Distribution of ' int2str(numel(overall)) ' ''randomly'' sampled tones'])
xlabel('Tone duration (milliseconds)');
ylabel('Frequency')
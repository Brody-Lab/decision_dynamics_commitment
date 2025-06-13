function [aa] = dur_v_accuracy(ratstr, daterange, varargin)

pairs = { ...
    'fignum_in'     100 ; ...
    'skip_first'    0   ; ...
	'bins'          10  ; ... % number of bins
	'swindow'       0.1 ; ... % 100 msec window for sliding window average
	'sstep'         0.01; ...
	'save_to_eps'   0   ; ... % saves the figures as .eps to ~/Desktop
}; parseargs(varargin, pairs);


%% Get dates and ratnames
% Get appropriate daterange
if ischar(daterange),
	if iscell(daterange),
		date_str = ['sessiondate>"' daterange{1} '" and sessiondate<= "' daterange{2} '"'];
		startdate = daterange{1};
		enddate   = daterange{2};
	else
	    date_str = ['sessiondate="' daterange '"'];
		startdate = daterange;
		enddate   = daterange;
	end;
else % if daterange is numeric
    if length(daterange) == 1, %#ok<ALIGN>
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(0) ' day)']);
    else
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(1)) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(2)) ' day)']);
	end;
    date_str = ['sessiondate>"' startdate{1} '" and sessiondate<= "' enddate{1} '"'];
	startdate = startdate{1};
	enddate   = enddate{1};
end

% Get rats
if strfind(ratstr,'%')
    ratnames = bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and ' date_str ' order by ratname']);
else
    ratnames = bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and ' date_str ' order by ratname'], ratstr);
end

%% fetch data

aa = cell(numel(ratnames),1);

for rat_i = 1:numel(ratnames),
	dates = bdata(['select sessiondate from sessions where ratname="' ratnames{rat_i} '" and ' date_str]);
	
	sample_duration = [];
	hits            = [];
	gammas          = [];
	observer        = [];
	observer_hits   = [];

    for i = 1:numel(dates),
        [pd pe] = fetch_pd_and_pe(ratnames{rat_i}, dates{i});
        stim_start_delay = fetch_sph(ratnames{rat_i}, dates{i}, 'StimulusSection_stim_start_delay');
        if ~isempty(pd) && ~isempty(pe),
			% s = sample_duration; g = gammas; h = hits; o = ideal observer (-1 or 1) based on s
            [s g h o] = parse_pbups_data(pd, pe, stim_start_delay, skip_first);

            sample_duration = [sample_duration; s];
            hits = [hits; h];
			gammas = [gammas; g];
			observer = [observer; o];
			o_hits = zeros(size(o));
			o_hits(intersect(find(o==-1), find(g<0))) = 1;
			o_hits(intersect(find(o==1),  find(g>0))) = 1;
			unsure = find(o == 0); o_hits(unsure) = rand(size(unsure))>0.5;
			observer_hits = [observer_hits; o_hits];
        else
            display(['was unable to fetch data for ' dates{i}]);
        end;
    end;

	edges = linspace(min(sample_duration), max(sample_duration), bins);
	trial_types = unique(abs(gammas));

	%% plot accuracy as a function of sample duration

	acc   = zeros(numel(trial_types), numel(edges));
	acc_N = zeros(numel(trial_types), numel(edges));

	leg_text = {};
	for j = 1:numel(trial_types),
		hit_guys  = intersect(find(abs(gammas)==trial_types(j)), find(hits == 1));
		miss_guys = intersect(find(abs(gammas)==trial_types(j)), find(hits == 0));

		hit_counts  = histc(sample_duration(hit_guys), edges);
		miss_counts = histc(sample_duration(miss_guys), edges);

		% do the accuracy accounting
		acc(j,:) = hit_counts./(sum([hit_counts miss_counts], 2));
		acc_N(j,:) = sum([hit_counts miss_counts], 2); %#ok<AGROW>
		bad_bins = find(acc_N < 10);
	end;
	acc(bad_bins) = NaN;
	acc_N(bad_bins) = 0;
	for j = 1:numel(trial_types),
		leg_text{j} = ['gamma = ' num2str(trial_types(j)) ', n = ' num2str(sum(acc_N(j,:)))]; %#ok<AGROW>
	end;
	
    fh3 = figure(fignum_in+10*rat_i);
	subplot(3,1,1);
	hist(sample_duration, numel(edges)+1);
	title('histogram of sample durations presented');
	subplot(3,1,2:3);
	plot(edges, acc, '.-', 'MarkerSize', 20);
	title('accuracy as a function of gamma and sample duration');
	xlabel('sample duration (sec)');
	ylabel('prob. correct');
	legend(leg_text, 'Location', 'Best');

	set(fh3, 'Name', [ratnames{rat_i} ':  ' startdate ' to ' enddate]);
	ss = get(0, 'ScreenSize');
	set(fh3, 'Position', [1 ss(4)-800 500 800]);

	%% sliding window average 
	
	range  = [edges(1) edges(end)];

	rt = range(1):sstep:range(2);
	pcorrect = zeros(numel(rt), numel(trial_types));
	pcorrect_ideal = pcorrect;
	pcorrect_l = pcorrect;
	pcorrect_r = pcorrect;

	for j = 1:numel(trial_types),

		this_type = find(abs(gammas)==trial_types(j));
		hit_guys  = intersect(this_type, find(hits == 1));
		miss_guys = intersect(this_type, find(hits == 0));
		ideal_hit  = intersect(this_type, find(observer_hits == 1));
		ideal_miss = intersect(this_type, find(observer_hits == 0));

		left = find(gammas < 0);
		hit_guys_l  = intersect(hit_guys, left);
		miss_guys_l = intersect(miss_guys, left);


		right = find(gammas > 0);
		hit_guys_r  = intersect(hit_guys, right);
		miss_guys_r = intersect(miss_guys, right);

		for t = 1:numel(rt),
			rt_guys = intersect(find(sample_duration>rt(t)-swindow/2), find(sample_duration<rt(t)+swindow/2));
			h   = intersect(hit_guys, rt_guys);
			m   = intersect(miss_guys, rt_guys);
			ih  = intersect(ideal_hit, rt_guys);
			im  = intersect(ideal_miss, rt_guys);

			h_l = intersect(hit_guys_l, rt_guys);
			m_l = intersect(miss_guys_l, rt_guys);

			h_r = intersect(hit_guys_r, rt_guys);
			m_r = intersect(miss_guys_r, rt_guys);

			if numel([h; m]) < 5,
				pcorrect(t, j) = NaN;
			else
				pcorrect(t, j) = numel(h)/(numel([h; m]));
			end;
			
			if isempty(ih) && isempty(im),
				pcorrect_ideal(t, j) = NaN;
			else
				pcorrect_ideal(t, j) = numel(ih)/(numel([ih; im]));
			end;


			if numel([h_l; m_l]) < 5,
				pcorrect_l(t, j) = NaN;
			else
				pcorrect_l(t, j) = numel(h_l)/(numel([h_l; m_l]));
			end;


			if numel([h_r; m_r]) < 5,
				pcorrect_r(t, j) = NaN;
			else
				pcorrect_r(t, j) = numel(h_r)/(numel([h_r; m_r]));
			end;
		end;
	end;

	fh4 = figure(fignum_in+10*rat_i+1);
	clf;
	subplot(3,1,1); hold on;
	plot(rt', pcorrect, '.-', 'MarkerSize', 20);
% 	plot(rt', pcorrect_ideal);
	title('All trials');
	subplot(3,1,2);
	plot(rt', pcorrect_l, '.-', 'MarkerSize', 20);
	title('Left trials');
	subplot(3,1,3);
	plot(rt', pcorrect_r, '.-', 'MarkerSize', 20);
	title('Right trials');
	xlabel('sample duration');
	ylabel('prob. correct');
% 	legend(leg_text, 'Location', 'Best');
	set(fh4, 'Name', [ratnames{rat_i} ':  ' startdate ' to ' enddate]);
	ss = get(0, 'ScreenSize');
	set(fh4, 'Position', [510 ss(4)-800 500 800]);
	
	%% output accounting
	ratdata.ratname = ratnames{rat_i};
	ratdata.edges = edges;
	ratdata.trial_types = trial_types;
	ratdata.binned_hitfrac = acc;
	ratdata.binned_trials = acc_N;
	aa{rat_i} = ratdata;
	
	%% saving figures
	if ~isempty(save_to_eps) && ischar(save_to_eps),
		saveas(fh3, [save_to_eps ratnames{rat_i} '_' startdate '_to_' enddate '_fig1.eps'], 'psc2');
		saveas(fh4, [save_to_eps ratnames{rat_i} '_' startdate '_to_' enddate '_fig2.eps'], 'psc2');
	end;
   
end;

function [sample gammas hit_history observer] = parse_pbups_data(pd, pe, stim_start_delay, skip_first)
% inputs:
% pd = protocol_data from sessions table
% pe = ProtocolsSection_parsed_events from protocol.samedifferent
% stim_start_delay = StimulusSection_stim_start_delay from
% protocol.samedifferent
% skip_first = ignore these first trials
%
% outputs are Nx1 vectors, where N is the number of valid (not cpoke
% violations) trials:
% sample = sample durations
% gammas = gammas of pbups stimulus
% hit_history = hit_history
% observer = based on the pbups stimulus that was sample, the
% discrimination of an ideal observer that counts bups
ntrials = min(length(pd.hits), rows(pe));

if skip_first+1 > ntrials,
	sample = [];
	gammas = [];
	hit_history = [];
	observer = [];
	return;
end;

sample = zeros(ntrials,1);
gammas = zeros(ntrials,1);
observer = zeros(ntrials,1);
hit_history = pd.hits(1:ntrials);
stim_start_delay = stim_start_delay(1:ntrials);
	
for i = skip_first+1:ntrials,
    events = pe{i};
    events = events{1};
	
	if isnan(hit_history(i)) || rows(events.states.cpoke1) > 1,
		sample(i) = NaN;
		gammas(i) = NaN;
		hit_history(i) = NaN;
	else
		nose_in_center = diff(events.states.cpoke1(1,:));
		sample(i) = nose_in_center - stim_start_delay(i);
		gammas(i) = pd.bupsdata{i}.gamma;
		observer(i) = pbups_observer(pd.bupsdata{i}.left, pd.bupsdata{i}.right, sample(i));
	end;
end;

good = setdiff(find(~isnan(hit_history)), 1:skip_first);
sample = sample(good);
gammas = gammas(good);
hit_history = hit_history(good);
observer = observer(good);
return;

function [ob] = pbups_observer(left, right, sample)
% inputs:
% left = times (in sec) of bups on the left
% right = times of bups on the right
% sample = time (in sec) the stimulus was played
%
% output:
% based on the sample duration, the left/right discrimination based on an
% ideal observer that is able to count bups on either side
% -1 means left, +1 means right

l = sum(left <= sample);
r = sum(right <= sample);
if l > r,     ob = -1;
elseif r > l, ob = 1;
else          ob = 0;
end;
return;
	
	
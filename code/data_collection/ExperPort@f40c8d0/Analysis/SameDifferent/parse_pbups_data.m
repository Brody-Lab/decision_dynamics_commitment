function [sample gammas hit_history observer good rt diff_nbups] = parse_pbups_data(pd, pe, stim_start_delay, skip_first, stim_dur)
% inputs:
% pd = protocol_data from sessions table
% pe = ProtocolsSection_parsed_events from protocol.samedifferent or the
%		parsed events table
% stim_start_delay = StimulusSection_stim_start_delay from
% protocol.samedifferent
% skip_first = ignore these first trials
% stim_dur = if not empty, then these are the actual fixed_stim_dur
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
rt = zeros(ntrials,1);
diff_nbups = zeros(ntrials,1);
hit_history = pd.hits(1:ntrials);
stim_start_delay = stim_start_delay(1:ntrials);
	
if isempty(stim_dur),
	extract_dur = 1;
else
	extract_dur = 0;
end;

for i = skip_first+1:ntrials,
    events = pe(i);
	
	if isnan(hit_history(i)) || rows(events.states.cpoke1) ~= 1,
		sample(i) = NaN;
		gammas(i) = NaN;
		hit_history(i) = NaN;
		rt(i) = NaN;
		diff_nbups(i) = NaN;
	else
		nose_in_center = diff(events.states.cpoke1(1,:));
		first_bup = min([pd.bupsdata{i}.left pd.bupsdata{i}.right]);
		if extract_dur,
			sample(i) = nose_in_center - stim_start_delay(i) - first_bup;
		else
			sample(i) = stim_dur(i);
		end;
		gammas(i) = pd.bupsdata{i}.gamma;
		observer(i) = pbups_observer(pd.bupsdata{i}.left, pd.bupsdata{i}.right, sample(i));
		
		lastcpoke = find(events.pokes.C(:,1) < events.states.cpoke1(1,2), 1, 'last');
		rt(i) = events.pokes.C(lastcpoke, 2) - events.states.cpoke1(1,2);
		diff_nbups(i) = sum(pd.bupsdata{i}.right-first_bup < sample(i)) - sum(pd.bupsdata{i}.left-first_bup < sample(i));
	end;
end;

good = setdiff(find(~isnan(hit_history)), 1:skip_first);
sample = sample(good);
gammas = gammas(good);
hit_history = hit_history(good);
observer = observer(good);
rt = rt(good);
diff_nbups = diff_nbups(good);
return;
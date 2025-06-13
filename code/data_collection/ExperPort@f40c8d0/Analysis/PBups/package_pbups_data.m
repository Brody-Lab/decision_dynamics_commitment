function [ratdata avgdata] = package_pbups_data(ratname, daterange, hitfrac_thresh, probes_only)
%
%
%
%
% ratdata will contain a struct array with the following fields, where each
% element of the array represents an individual, non-violation trial:
%	T:			duration of the stimulus, in seconds
%	leftbups:	times of bups played on left
%	rightbups:	times of bups played on right
%	pokedR:		whether the rat poked right
%
% avgdata, unlike ratdata, will not contain trial-by-trial bup times, but
% contains the following fields for all non-violation trials:
%	T:			duration of the stimulus, in seconds
%	gamma:		the log of (rrate/lrate)
%	hits:		hit or miss
%	is_probe:	1 if it's a probe trial (bupsdata.is_probe)

if nargin < 3, 
	hitfrac_thresh = 0.70; 
	probes_only = 0;
end;

if nargin < 4,
	probes_only = 0;
end;

[date_str] = parse_daterange(daterange);

[sessions] = bdata(['select sessid from sessions where ratname="' ratname '" and ' date_str ' order by sessiondate']); %#ok<NASGU>

S = get_sessdata(sessions);

ratdata = [];
avgdata.T = [];
avgdata.gamma = [];
avgdata.hits = [];
for i = 1:length(sessions),
	sessid  = S.sessid(i);
	pd		= S.pd{i};
	peh		= S.peh{i};
	protocol= S.protocol{i};
	
	if length(pd.hits) > 100 && nanmean(pd.hits) > hitfrac_thresh,
		if strcmpi(protocol, 'samedifferent'),
			nvio = parse_cpoke_violations(peh);
			good = find(nvio == 0);
		elseif strcmpi(protocol, 'pbups'),
			good = find(pd.violations == 0);
		else
			display(['package_pbups_data does not recognize how to process protocol ' protocol '\n']);
			ratdata = [];
			return;
		end;

		stim_start_delay = fetch_sph('StimulusSection_stim_start_delay', sessid);
		T = zeros(length(peh),1);
		first_bup = zeros(length(peh),1); % time of the first bup
		for j = 1:length(peh),
			if ~isempty(pd.bupsdata{j}.left),
				first_bup(j) = pd.bupsdata{j}.left(1);
			else
				first_bup(j) = pd.bupsdata{j}.right(1);
			end;
			if ismember(j, good) && isfield(peh(j).states, 'cpoke1') && ~isempty(peh(j).states.cpoke1),
				T(j) = diff(peh(j).states.cpoke1(1,:)) - stim_start_delay(j) - first_bup(j);
			end;
		end;
		T(T <= 0) = 0;
		good = intersect(good, find(T > 0));  % ignore trials where no bups played
		
		good = intersect(good, find(~isnan(pd.hits)));
		if probes_only,
			good = intersect(good, find(pd.sounds==0));
		else
			good = intersect(good, find(abs(pd.sounds)>0));
		end;
		
		a = length(ratdata);
		for g = 1:length(good),
			gtrial = good(g);
			ratdata(a+g).T     = T(gtrial); %#ok<AGROW>
			ratdata(a+g).leftbups  = pd.bupsdata{gtrial}.left - first_bup(gtrial); %#ok<AGROW>
			ratdata(a+g).rightbups = pd.bupsdata{gtrial}.right - first_bup(gtrial); %#ok<AGROW>
			ratdata(a+g).pokedR    = (pd.sides(gtrial)=='r' & pd.hits(gtrial)==1) | (pd.sides(gtrial)=='l' & pd.hits(gtrial)==0); %#ok<AGROW>
			ratdata(a+g).hit       = pd.hits(gtrial); %#ok<AGROW>

			avgdata.T(a+g)			= T(gtrial);
			avgdata.gamma(a+g)		= pd.bupsdata{gtrial}.gamma;
			avgdata.hits(a+g)		= pd.hits(gtrial);
			avgdata.is_probe(a+g)	= (pd.sounds(gtrial)==0);
		end;
	end;
end;
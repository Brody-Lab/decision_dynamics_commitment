function dep = extract_electrode_depth(ratname, sessids)
% given sessids, use the ratinfo.turn_down_log table to estimate the
% depth of the electrodes on that date.
%
% ratname is a string, sessids is nx1 vector
%
% returns dep, a vector the same size as sessids containing the estimated
% depths in micrometers from the first entry in the turn_down_log table,
% which we will assume is the initial position of the electrodes at surgery

turnlog = 'ratinfo.turn_down_log';
fullturn = 317.5; % microns, assuming a 0-80 threaded rod

[turn_date turn_time turn turned_to] = ...
	bdata(['select turn_date,turn_time,turn,turned_to from ' turnlog ' where ratname="' ratname '" order by turn_date']);

if isempty(turn_date),
	display(['Cannot retrieve turn down information for rat ' ratname ' in ' turnlog]);
	dep = [];
	return;
end;

turntimes = zeros(size(turn_date));
cumul_turns = zeros(size(turn_date));
for t = 1:length(turn_date),
	turntimes(t) = datenum([turn_date{t} ' ' turn_time{t}]);
	if t > 1,
		cumul_turns(t) = cumul_turns(t-1) + (mod(12+diff(turned_to(t-1:t)),12))/12*fullturn;
		if turn(t) >= 1, cumul_turns(t) = cumul_turns(t) + floor(turn(t))*fullturn; end;
	end;
end;

dep = zeros(size(sessids));
for i = 1:length(sessids),
	[sdate starttime] = bdata('select sessiondate,starttime from sessions where sessid="{S}"', sessids(i));
	sessiontime = datenum([sdate{1} ' ' starttime{1}]);
	d = find(turntimes < sessiontime, 1, 'last');
	dep(i) = cumul_turns(d);
end;
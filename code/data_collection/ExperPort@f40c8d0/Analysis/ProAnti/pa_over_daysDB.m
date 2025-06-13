% [a]= pa_over_daysDB(rat, daterange, {'min_pro_trials', 30}, ...
%                             {'min_anti_trials', 30}, {'fignum', []}, {'usdb', 1})
%
% Runs a trial-type-by-trial-type daily percent hit rate analysis on a rat in the
% ProAnti2 protocol. Brings up a new figure and displays the results of the
% analysis.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'min_trials'     By default 30, it is the minimum number of trials for the
%           overall average to be counted in a day.
%
% 'min_pro_trials' By default 30, it is the minimum number of pro trials for the
%           pro average to be counted in a day.
%
% 'min_anti_trials' By default 30, it is the minimum number of pro trials for the
%           pro average to be counted in a day.
%
% 'fignum'  By default empty. If empty, a new figure is created to plot the
%           analysis. If non-empty, figure fignum is cleared, and the data
%           is plotted on that figure. Does not make fignum the current
%           figure, so can run in background.
%
% 'protocol'   By default 'ProAnti2', can also be 'ProAnti'
%
% 'usedb'   Default value is 1. If usedb is 1, the pa_over_days uses the
%           MySQL database; if 0, it reads raw data files instead.
%
%
% EXAMPLES:
% ---------
%
% >> pa_over_days('C016', 'Carlos', -21);
%
% >> pa_over_days('Ibix', 'Jeff', -21, 'protocol', 'ProAnti');
%

% written by CDB Dec 07


function [aa]= pa_over_daysDB(ratstr, daterange, varargin)

pairs = { ...
	'min_pro_trials'   20  ; ...
	'min_anti_trials'  20  ; ...
	'min_trials',      30  ; ...
	'fignum_in'     []  ; ...
	'protocol',  'ProAnti2'  ; ...
	}; parseargs(varargin, pairs);

olddir=pwd;
ddir=bSettings('get','GENERAL', 'Main_Code_Directory');
cd(ddir)

startdate=bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
if strfind(ratstr,'%')
	all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and sessiondate>"' startdate{1} '" order by ratname']);
else
	all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and sessiondate>"' startdate{1} '" order by ratname'], ratstr);
end


figP=fig_place(numel(all_rats));


for ri=1:numel(all_rats)
	rat=all_rats{ri};
	
	
	
	% this just uses mysql's built in date/time arithmetic instead of doing it in matlab.
	startdate=bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
	
	
	[pd,protocol]=bdata(['select protocol_data,protocol from bdata.sessions where ratname="' rat '" and sessiondate>="' startdate{1} '" and (protocol like "ProAnti%" OR protocol="SameDifferent") order by sessiondate']);
	
	% Translate db-obtained data into what it would look like when read from
	% raw data files:
	a = cell(length(pd), 1, 4);
	for i=1:length(pd),
		switch protocol{i}
			case 'SameDifferent'
				
				a{i,1,1} = num2cell([pd{i}.side_lights(:) ; 0]);  % Pad it with dummy final value to match raw data files
				a{i,1,3} = num2cell(pd{i}.hits(:)');
				a{i,1,4} = num2cell(pd{i}.hits(:)');
			case {'ProAnti2','ProAnti3'}
				
				a{i,1,1} = num2cell([pd{i}.context(:) ; 0]);  % Pad it with dummy final value to match raw data files
				a{i,1,3} = num2cell(pd{i}.gotit(:)');
				a{i,1,4} = num2cell(pd{i}.hit(:)');
		end
		a{i,1,2} = num2cell([pd{i}.sides(:)   ; 0]);  % Pad it with dummy final value to match raw data files
		
	end;
	
	cd(olddir);
	
	pro_trial = []; goodPoke3 = []; gotit_history = [];
	hit_history = [];
	avg = []; avgt = []; avgp = [];  avgpt = []; avga = []; avgat = [];
	
	for i=1:size(a(:,1,1),1),
		ntrials = length(a{i,1,4});
		
		pro_trial     = [pro_trial     ; cell2mat(a{i,1,1}(end-ntrials:end-1))];
		goodPoke3     = [goodPoke3     ; cell2mat(a{i,1,2}(end-ntrials:end-1))];
		gotit_history = [gotit_history ; cell2mat(a{i,1,3}')];
		hit_history   = [hit_history   ; cell2mat(a{i,1,4}')];
		
		u     = find(~isnan(hit_history(end-ntrials+1:end)));
		guys  = gotit_history(end-ntrials+1:end);
		pmark = pro_trial(end-ntrials+1:end);
		if length(u) > min_trials,
			avg   = [avg  ; sum(guys(u))/length(u)];
			avgt  = [avgt ; i];
		end;
		
		up   = u(pmark(u)==1);
		ua   = u(pmark(u)==-1);
		if length(up) > min_pro_trials,
			avgp  = [avgp ; sum(guys(up))/length(up)];
			avgpt = [avgpt ; i];
		end;
		if length(ua) > min_anti_trials,
			avga  = [avga ; sum(guys(ua))/length(ua)];
			avgat = [avgat ; i];
		end;
	end;
	
	
	if isempty(fignum_in),  %#ok<NODEF>
		figure; fignum = gcf;
	end;
	if ~ishandle(fignum_in),
		figure(fignum);
	end;
	
	ch = get(fignum, 'Children');
	if ~isempty(ch), delete(ch); end;
	ax = axes('Parent', fignum);
	
	plot(ax, avgt,  avg,  'k.-'); hold(ax, 'on');
	plot(ax, avgpt, avgp, 'b.-'); hold(ax, 'on');
	plot(ax, avgat, avga, 'r.-'); hold(ax, 'on');
	
	yl = get(ax, 'ylim');
	set(ax, 'ylim', [yl(1) 1.03]);
	set(ax, 'xlim', [0 size(a(:,1,1),1)+1]);
	
	
	set(ax, 'Layer', 'top');
	legend(ax, 'overall', 'pro', 'anti', 'Location', 'Best');
	legend(ax, 'boxoff');
	set(ax, 'YAxisLocation', 'right', 'YGrid', 'on')
	xlabel('days');
	ylabel('hitrate');
	title(rat);
	
	set(fignum, 'Name', rat);
	set(fignum,'Position',figP(ri,:));
	
	if nargout>0, aa = a; end;
	
end
end


function [aa myfigures myaxes] = pbups_psych(ratstr, daterange, varargin)

pairs = {...
	'use_nbups'         0   ; ...
	'fignum_in'			[]	; ...
	'axes_in'			[]  ; ...
	'dotclr'            'b' ; ...
	'fit_psycho'		1	; ...
	'inverted'			0	; ...
	'skip_first'		0	; ...
	'arrange_plots'		1	; ...
	'show_fit'          1   ; ...
	'screensize'		get(0, 'ScreenSize'); ...
}; parseargs(varargin, pairs);

[date_str] = parse_daterange(daterange);

% Get rats
if strfind(ratstr,'%')
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and (' date_str ') order by ratname']);
else
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and (' date_str ') order by ratname'], ratstr);
end

if numel(screensize) < 4, %#ok<NODEF>
	screensize = get(0, 'ScreenSize');
end;
figP = fig_place(numel(all_rats), 'ss', screensize);

aa = cell(numel(all_rats),1);

for rat_i = 1:numel(all_rats)
    ratname = all_rats{rat_i};
	
    [sdate, sessid, protocol, pd] = bdata(['select sessiondate,sessid,protocol,protocol_data from bdata.sessions where ratname="' ratname '" and (' date_str ') order by sessiondate']);
	protocol = lower(protocol{1});
	
	x_vals     = [];
	went_right = [];
	sample     = [];
	
	if strcmp(protocol, 'pbups'),
		for i = 1:numel(pd),
			if ~strcmp(pd{i}, 'NULL'), % ignore days with no protocol_data
				h = pd{i}.hits(1:end-1);  % ignore last trial of session
				g = zeros(size(h));
				diff_nbups = zeros(size(h));
				for k = 1:numel(h),
					g(k) = pd{i}.bupsdata{k}.gamma;
					if pd{i}.samples(1) == 0, T = pd{i}.samples(k+1);  % a hacky fix to a bug in the code that padded an extra 0 for trial 1
					else					  T = pd{i}.samples(k); end;
					diff_nbups(k) = sum(pd{i}.bupsdata{k}.right < T) - sum(pd{i}.bupsdata{k}.left < T);
				end;
				good = find(pd{i}.violations(1:end-1) == 0);
				sample     = [sample; pd{i}.samples(good)]; %#ok<AGROW>
				if use_nbups, x_vals = [x_vals; diff_nbups(good)]; %#ok<AGROW>
				else     	  x_vals	   = [x_vals; g(good)]; end; %#ok<AGROW> 
				r		   = (g < 0 & h == 0) | (g > 0 & h == 1);
				went_right = [went_right; r(good)]; %#ok<AGROW>
			end;
		end;
	elseif strcmp(protocol, 'samedifferent'),
		for i = 1:numel(pd)
			if ~strcmp(pd{i}, 'NULL'), % ignore days with no protocol_data
				pe = get_peh(sessid(i));
            if numel(pd{i}.bupsdata) < numel(pe) || numel(pe)==0,
               fprintf(1, '%s Warning: ignoring session %d from date %s, numel(bupsdata)=%d numel(pe)=%d\n', ...
                  mfilename, sessid(i), get_sessiondate(sessid(i)), numel(pd{i}.bupsdata), numel(pe));
            else
               stim_start_delay = bdata(['select StimulusSection_stim_start_delay from protocol.' protocol ' where sessid=' num2str(sessid(i))]);

               [s g h x1 x2 x3 dbups] = parse_pbups_data(pd{i}, pe, stim_start_delay, skip_first, []);

               sample     = [sample; s]; %#ok<AGROW>
               if use_nbups, x_vals = [x_vals; dbups]; %#ok<AGROW>
               else		  x_vals = [x_vals; g]; end; %#ok<AGROW>
               r          = (g < 0 & h == 0) | (g > 0 & h == 1);
               went_right = [went_right; r(:)]; %#ok<AGROW>
            end;
         end;
		end;
	else
		fprintf(2, ['pbups_psych: Do not know how to handle sessions of protocol ' protocol]);
		return;
	end;
	
	trial_types = unique(x_vals);
	sorted = sortrows(sample);
	s20 = sorted(round(numel(sorted)*0.8));
	meanP = zeros(2, numel(trial_types));
	Ntrials = zeros(1, numel(trial_types));
	for j = 1:numel(trial_types),
		meanP(1,j) = mean(went_right(x_vals == trial_types(j)));
		Ntrials(1,j) = numel(went_right(x_vals == trial_types(j)));
		meanP(2,j) = mean(went_right(x_vals == trial_types(j) & sample > s20));
	end;
	if inverted,
		meanP = 1 - meanP;
		yaxis_label = 'Probability of going left';
	else
		yaxis_label = 'Probability of going right';
	end;

	if isempty(axes_in),
		if isempty(fignum_in);
			figure; fignum = gcf;
		elseif ~ishandle(fignum_in),
			figure(fignum_in+rat_i);
			fignum = gcf;
		end;

		ch = get(fignum, 'Children');
		if ~isempty(ch), delete(ch); end;
		ax = axes('Parent', fignum);
	else
		fignum = fignum_in(rat_i);
		ax = axes_in(rat_i);
	end;
	
	myaxes(rat_i) = ax;
	myfigures(rat_i) = fignum;

	hold on;
	if use_nbups,
		s = (Ntrials - min(Ntrials))/max(Ntrials);
		s = (s*10).^2 + 5;
		scatter(ax, trial_types, meanP(1,:), s, dotclr, 'filled');
	else
		plot(ax, trial_types, meanP(1,:), [dotclr '.'], 'MarkerSize', 20);
	end;
%  	plot(ax, trial_types, meanP(2,:), 'r*', 'MarkerSize', 10);
	set(ax, 'YLim', [0 1]);
	if use_nbups, xaxis_label = 'n(right bups) - n(left bups)';
	else          xaxis_label = 'gamma'; end;
	set(get(ax, 'XLabel'), 'String', xaxis_label);
	set(get(ax, 'YLabel'), 'String', yaxis_label);
	
	if fit_psycho,
		[beta,resid,jacob,sigma,mse] = nlinfit(x_vals,went_right,@sig4,[meanP(1,1), range(meanP(1,:)), nanmean(x_vals), 0.1*range(x_vals)]);

		x_s=linspace(min(x_vals), max(x_vals), 100);
		[y_s,delta] = nlpredci(@sig4,x_s,beta,resid,'covar',sigma);
		betaci = nlparci(beta,resid,'covar',sigma);

		S.beta=beta;
		S.betaci=betaci;
		S.resid=resid;
		S.mse=mse;
		S.sigma=sigma;
		S.ypred=y_s;
		S.y95ci=delta;	
		if nargout > 1,
			cf{rat_i} = S;
		end;

		hold on

		if show_fit,
			if inverted,
				y_s = 1-y_s;
				text(x_s(2), 0.2, sprintf('bias=%f \n slope=%f', beta(3), beta(4)));
			else
				text(x_s(2), 0.8, sprintf('bias=%f \n slope=%f', beta(3), beta(4)));
			end;
		end;
		
		plot(ax, x_s, y_s, dotclr);
		plot(ax, x_s,y_s-delta',[dotclr ':']);
		plot(ax, x_s,y_s+delta',[dotclr ':']);
	end;
	
	set(fignum, 'Name', [ratname ' -  ' sdate{1} ' to ' sdate{end} ', ' num2str(numel(x_vals)) ' trials']);
	if arrange_plots == 1,
	    set(fignum, 'Position', figP(rat_i,:));
	end;
	
	a.fit = S;
	a.x_vals = x_vals;
	a.went_right = went_right;
	a.n = numel(x_vals);
	aa{rat_i} = a;
end;

function y=sig4(beta,x)

y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));
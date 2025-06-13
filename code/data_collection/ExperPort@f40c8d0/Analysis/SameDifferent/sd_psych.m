% [aa cf] = sd_psych(ratstr, daterange, {'fignum_in', []}, {'dimension', 'S1Freq1'})
%
% plots psychometric curves for rats run on SameDifferent protocol
% daterange can be a vector of start and end dates from today, or it can be
% a specific date, like 'yyyy-mm-dd'
%
% varagins:
% fignum_in     specifes the figure number of the first figure to be used;
%               subsequent plots will be numbered sequentially from
%               fignum_in
%
% fit_psycho    if 1, fit and plot a sigmoid psychometric function to the 
%               data; otherwise, just display the data
%
% logplot       if 1, plot in semilogx; otherwise, do a regular plot
%
% inverted      if 0, the y axis is probability of choosing left
%               if 1, the y axis is the probability of choosing right
%
% dimension     the dimension along which to plot the psychometric curve,
%               in the soloparam variable names of soundui, which is how
%               these values are stored in soundtable.
%               for example, if we want to plot along the freq1 of the
%               first sound (S1), we would say {'dimension', 'S1Freq1'}
%
% skip_first    if this argument is n, ignores the first n trials in every
%               session in computing the psychometric curve
%
% arrange_plot  if 1, then plots will be placed on the screen according to
%               fig_place and the number of rats; if 0, then all the plots
%               will be the default size and lay on top of each other
%
% screensize    a 1x4 vector specifying the size of the area the plots will
%               be arranged on the screen
%
% Examples:


function [aa cf] = sd_psych(ratstr, daterange, varargin)

pairs = { ...
    'fignum_in'     []  ; ...
	'fit_psycho'    1   ; ...
    'logplot'       0   ; ...
	'inverted'      1   ; ...
    'dimension'     ''  ; ...
    'skip_first'    0   ; ...
	'arrange_plots' 1   ; ...
	'screensize'    get(0, 'ScreenSize'); ...
}; parseargs(varargin, pairs);


% Get appropriate daterange
if ischar(daterange),
    date_str = ['sessiondate="' daterange '"'];
else
    if length(daterange) == 1,
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(0) ' day)']);
    else
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(1)) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(2)) ' day)']);
    end

    date_str = ['sessiondate>"' startdate{1} '" and sessiondate<= "' enddate{1} '"'];
end

% Get rats
if strfind(ratstr,'%')
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and ' date_str ' order by ratname']);
else
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and ' date_str ' order by ratname'], ratstr);
end

if numel(screensize) < 4, %#ok<NODEF>
	screensize = get(0, 'ScreenSize');
end;
figP = fig_place(numel(all_rats), 'ss', screensize);

aa = cell(numel(all_rats),1);

for rat_i = 1:numel(all_rats)
    ratname = all_rats{rat_i};
    
    [sdate, pd] = bdata(['select sessiondate, protocol_data from bdata.sessions where ratname="' ratname '" and ' date_str ' and protocol="SameDifferent" order by sessiondate']);

    X     = [];  % values on X axis
    L     = [];  % a vector of 1's and 0's the same size as X containing whether the correct answer was Left or not
    all_hits = cell(0);  % will hold consolidated hits, where each cell corresponds to a row in X and contains the hits for that X
    
	% these are used to compute the psychometric function fit
	x_vals = [];      % value along experimentally controlled dimension
	went_right = [];  % a vector of 0's and 1's the same size as x_vals, whether of not the rat went right
	
    % consolidate over days
    for i = 1:numel(pd)
        if ~strcmp(pd{i}, 'NULL'), % ignore days with no protocol_data
            hits   = pd{i}.hits;
            snd_id = pd{i}.sounds;
            stims  = pd{i}.soundtable;
            bupsdata = pd{i}.bupsdata;
			
			if isempty(bupsdata),
				soundtype = 'table';
			else
				soundtype = 'bups';
			end;
			
			% organize the relevant dimensions
			switch soundtype,
				case 'table',
					trial_types = unique(snd_id);
					ntypes      = size(trial_types, 1);
					if isempty(dimension),
						trial_type_map = trial_types;  % if no dimension is supplied, use the sound id's as independent dimension
					else
						trial_type_map = zeros(size(trial_types));
						if strcmp(dimension(1:2), 'S1'),
							scol = 4;
						elseif strcmp(dimension(1:2), 'S2'),
							scol = 5;
						else
							error('sd_psych: the input dimension %s cannot be interpreted', dimension);
						end;

						for i = 1:ntypes,
							try
								trial_type_map(i) = stims{trial_types(i),scol}.(dimension(3:end));
							catch
								error('sd_psych: the input dimension %s cannot be found in the soundtable', dimension);
							end;
						end;
					end;
				case 'bups',
					g = zeros(size(hits));
					for i = 1:length(g),
						g(i) = bupsdata{i}.gamma;
					end;
					snd_id = g;
					trial_types = unique(snd_id);
					ntypes = size(trial_types,1);
					trial_type_map = trial_types;
					dimension = 'gamma';
			end;
			
			% bin performance data for each trial type
            for j = 1:ntypes,
                us = find(snd_id == trial_types(j));
                us = setdiff(us, 1:skip_first);  % ignore the first skip_first trials in this session
                
                if ~isempty(us),
                    if ismember(trial_type_map(j), X),
                        ind           = find(X == trial_type_map(j), 1);
                        all_hits{ind} = [all_hits{ind}; hits(us)];
                    else
                        X = [X; trial_type_map(j)];
						switch soundtype,
							case 'table',
								if (stims{trial_types(j),2} == 'l'),
									L = [L; 1]; 
								else
									L = [L; 0];
								end;
							case 'bups',
								if trial_types(j) < 0,
									L = [L; 1];
								else
									L = [L; 0];
								end;
						end;
                        ind = size(X, 1);
                        all_hits{ind} = hits(us);
                    end
				end
			end % end 1:ntypes
			
			
			% accounting for psycho plot
            goods = ~isnan(hits);
			h     = hits(goods);
			snds  = snd_id(goods);
			switch soundtype,
				case 'table',
					% fill this in
					x_vals = [x_vals; snds];
					went_right = zeros(size(x_vals));
				case 'bups',
					r = (h == 1 & snds > 0) | (h == 0 & snds < 0);
					x_vals = [x_vals; snds];
					went_right = [went_right; r];
			end;   
			
		end 
	end % end counting over days
	
    meanP = zeros(size(X));
    for i = 1:numel(X),
        meanP(i) = nanmean(all_hits{i});
        if ~L(i),
            meanP(i) = 1 - meanP(i);
        end;
    end;
	
	if inverted,
		meanP = 1 - meanP;
		yaxis_label = 'Probability of choosing right';
	else
		yaxis_label = 'Probability of choosing left';
	end;
    
    if isempty(fignum_in);
        figure; fignum = gcf;
    elseif ~ishandle(fignum_in),
        figure(fignum_in+rat_i);
        fignum = gcf;
    end;
    
    ch = get(fignum, 'Children');
    if ~isempty(ch), delete(ch); end;
    ax = axes('Parent', fignum);

    
    % plot psychometric curve
    if logplot,
        semilogx(ax, X, meanP, '.', 'MarkerSize', 20);
        set(ax, 'XLim', [0.9*min(X) 1.1*max(X)]);
    else
        plot(ax, X, meanP, '.', 'MarkerSize', 20);
    end;
    set(ax, 'YLim', [0 1]);
    set(get(ax, 'XLabel'), 'String', dimension);
    set(get(ax, 'YLabel'), 'String', yaxis_label);
    
	% for the psycho plot
	if fit_psycho,
		[beta,resid,jacob,sigma,mse] = nlinfit(x_vals,went_right,@sig4,[0.1 .8 nanmean(x_vals) 0.1]);

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

		if ~inverted,
			y_s = 1-y_s;
			text(x_s(2), 0.2, sprintf('bias=%f \n slope=%f', beta(3), beta(4)));
		else
			text(x_s(2), 0.8, sprintf('bias=%f \n slope=%f', beta(3), beta(4)));
		end;
			
		plot(x_s, y_s,'k');
		plot(x_s,y_s-delta','k:');
		plot(x_s,y_s+delta','k:');
	end;
	
    set(fignum, 'Name', [ratname ' -  ' sdate{1} ' to ' sdate{end}]);
	if arrange_plots == 1,
	    set(fignum, 'Position', figP(rat_i,:));
	end;
	
	% ---- set output
	aa{rat_i}.ratname = all_rats{rat_i};
    aa{rat_i}.X     = X;
    aa{rat_i}.meanP = meanP;
	

	
end % end rat_i

function y=sig4(beta,x)

y0=beta(1);
a=beta(2);
x0=beta(3);
b=beta(4);

y=y0+a./(1+ exp(-(x-x0)./b));
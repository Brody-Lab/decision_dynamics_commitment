% [a]= es_analyzeDB(ratstr, daterange, {'tau' 30}, {'fignum_in', []}, {'daily' 0})
%
% Runs a trial-type-by-trial-type hit_history analysis on a rat in the
% ExtendedStimulus protocol. Brings up a
% new figure and displays the results of the analysis.
%
%
% EXAMPLE:
% --------
%
% >> es_analyzeDB('B0%', -15, 'tau', 30);
% >> es_analyzeDB('B01[0-4]', -20, 'daily', 1);
% >> es_analyzeDB('B009|C033', [-20 -10]);

function [aa]= es_analyzeDB(ratstr, daterange, varargin)

pairs = { ...
  'tau'         30  ; ...
  'fignum_in'   []  ; ...
  'daily'       0   ; ...
}; parseargs(varargin, pairs);

% Get Rats
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


if strfind(ratstr,'%')
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and ' date_str ' order by ratname']);
else
    all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and ' date_str ' order by ratname'], ratstr);
end

figP = fig_place(numel(all_rats));

for rat_i = 1:numel(all_rats)
    ratname = all_rats{rat_i};
    
    [sdate, pd] = bdata(['select sessiondate, protocol_data from bdata.sessions where ratname="' ratname '" and ' date_str ' and protocol="ExtendedStimulus" order by sessiondate']);

    pair_id = []; f1s = []; f2s = []; sides = []; hit_history = [];
    avg = [];

    day_separators = 0.5;
    
    % consolidate over days
    for i = 1:numel(pd),
        if ~strcmp(pd{i}, 'NULL'),  % ignore days when there was no protocol_data
            ntrials = numel(pd{i}.hits);
            
            hit_history = [hit_history ; pd{i}.hits];
            pair_id     = [pair_id     ; pd{i}.pairs];
            sides       = [sides       ; pd{i}.sides];
            f1s         = [f1s         ; pd{i}.freqs(:,1)];
            f2s         = [f2s         ; pd{i}.freqs(:,2)];
            
            day_separators = [day_separators; length(hit_history)+0.5];
            avg = [avg; sum(pd{i}.hits)/ntrials];
        end;
    end;
    
    % make figures
    trial_types = unique(pair_id);
    ntypes = size(trial_types, 1);
    us    = cell(ntypes,1);
    perfs = cell(ntypes,1);
    leg   = cell(ntypes,1);
    handles = [];

    colors  = [0.2 0.2 1 ; ...
               1 0 1 ;     ...
               1 0 0 ;     ...
               0 1 0 ;     ...
               0 1 1 ;     ...
               1 1 0 ;     ...
               0.6 0.2 0.8;  ...
               1   0.5 0  ;  ...
               0.5 1   0  ;  ...
               0   1   0.5;  ...
               1   0   0.5;  ...
               0   0.5 1  ;  ...
               ]; 
    
    if isempty(fignum_in),
        figure; fignum = gcf;
    elseif ~ishandle(fignum_in),
        figure(fignum_in);
        fignum = gcf;
    else
        figure(fignum_in);
        clear gcf;
        fignum = gcf; 
    end;

    ch = get(fignum, 'Children');
    if ~isempty(ch), delete(ch); end;
    ax = axes('Parent', fignum); 

    if ~daily,
        for i=1:ntypes,
          us{i} = find(pair_id==trial_types(i));
          if ~isempty(us{i}),
            if sides(us{i}(1))=='l', leg{i} = 'Left ';
            else                     leg{i} = 'Right ';
            end;
          end;
          leg{i} = [leg{i} sprintf(' (%g, %g)', mean(f1s(us{i})), mean(f2s(us{i})))];

          guys = hit_history(us{i}); newguys = zeros(size(guys));
          e = exp(-(0:tau*4)/tau); e = e(end:-1:1);
          for j=1:length(guys),
            mye = e(end-min(length(e), j)+1:end); mye = mye/sum(mye);
            newguys(j) = sum(guys(j-length(mye)+1:j).*mye');
          end;
          perfs{i} = newguys;
          l = plot(ax, us{i}, perfs{i}, '.-'); hold(ax, 'on'); handles = [handles;l];
          set(l, 'Color', colors(i,:));
          u = find(hit_history(us{i})==0);
          l2 = plot(ax, us{i}(u), perfs{i}(u), '.'); hold(ax, 'on');
          set(l2, 'Color', 0.6*colors(i,:));
        end;

        set(ax, 'Layer', 'top');
        set(vlines(ax, day_separators), 'Color', 'k');
        yl = get(ax, 'Ylim');
        set(ax, 'Ylim', [yl(1), 1.03]);
        set(ax, 'xlim', [0 length(hit_history)*1.01]);

        ntrials = diff(day_separators);
        for i=1:length(ntrials),
          yl = get(ax, 'ylim'); 
          t = text(day_separators(i)+ntrials(i)/2, yl(2)+0.05*diff(yl), ...
            {sprintf('n=%d', ntrials(i)) ; sprintf('%d%%', round(avg(i)*100))}, 'Parent', ax);
          set(t, 'HorizontalAlignment', 'Center');
        end;
    elseif daily,
        for i = 1:ntypes,
            us{i} = find(pair_id==trial_types(i));
            if ~isempty(us{i}),
                if sides(us{i}(1))=='l', leg{i} = 'Left ';
                else                     leg{i} = 'Right ';
                end;
            end;
            leg{i} = [leg{i} sprintf(' (%g, %g)', mean(f1s(us{i})), mean(f2s(us{i})))];
            
            daily_avg = [];
            for k = 2:length(day_separators),
                guys = hit_history(us{i}(find((us{i} > day_separators(k-1)) & (us{i} < day_separators(k)))));
                if ~isempty(guys),
                    daily_avg = [daily_avg mean(guys)];
                else
                    daily_avg = [daily_avg 0];
                end;
            end;
            perfs{i} = daily_avg;
            l = plot(ax, 1:length(day_separators)-1, perfs{i}, '.-', 'MarkerSize', 25); 
            hold(ax, 'on'); handles = [handles;l];
            set(l, 'Color', colors(i,:));
        end;
        
        set(ax, 'Layer', 'top');
        yl = get(ax, 'Ylim');
        set(ax, 'Ylim', [yl(1), 1.03]);
        set(ax, 'Xlim', [0 length(day_separators)]);
    end;

    legend(ax, handles, leg, 'Location', 'Best');
    legend(ax, 'boxoff');

    set(ax, 'YGrid', 'on', 'YAxisLocation', 'right');

    set(fignum, 'Name', ratname);
    set(fignum, 'Position', figP(rat_i,:));

    if nargout>0, aa = a; end;
end;


% [aa] = es_psychDB(ratstr, daterange, {'fignum_in', []})
%
% plots psychometric curves for rats run on ExtendedStimulus
% daterange can be a vector of start and end dates from today, or it can be
% a specific date, like 'yyyy-mm-dd'
%
% Examples:
% es_psychDB('C021', -90);
% es_psychDB('J04[6-9]', [-20 -10]);
% es_psychDB('C022', '2008-07-29');


function [aa] = es_psychDB(ratstr, daterange, varargin)

pairs = { ...
    'fignum_in'     []  ; ...
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

%figP = fig_place(numel(all_rats));

aa = cell(numel(all_rats),1);

for rat_i = 1:numel(all_rats)
    ratname = all_rats{rat_i};
    
    [sdate, pd] = bdata(['select sessiondate, protocol_data from bdata.sessions where ratname="' ratname '" and ' date_str ' and protocol="ExtendedStimulus" order by sessiondate']);

    F1    = [];  % x axis
    Pleft = cell(0);  % Pleft over days; each cell element is a vector of daily averages
    
    % consolidate over days
    for i = 1:numel(pd)
        if ~strcmp(pd{i}, 'NULL'), % ignore days with no protocol_data
            ntrials = numel(pd{i}.hits);
            
            hits    = pd{i}.hits;
            pair_id = pd{i}.pairs;
            sides   = pd{i}.sides;
            f1s     = pd{i}.freqs(:,1);  % for psychometric curves, assume f1 = f2
            
            trial_types = unique(f1s);
            ntypes      = size(trial_types, 1); 
            for j = 1:ntypes,
                us = find(f1s == trial_types(j));
                perf = mean(hits(us));
                if ~isempty(us),
                    if(sides(us(end)) == 'l'), 1;
                    else                     perf = 1 - perf;  % if correct answer is right, flip the performance
                    end;
                end;
                
                if ismember(trial_types(j), F1),
                    ind        = find(F1 == trial_types(j), 1);
                    Pleft{ind} = [Pleft{ind} perf];
                else
                    F1 = [F1 trial_types(j)];
                    ind = size(F1, 2);
                    Pleft{ind} = [perf];
                end;
            end
        end
    end
    
    for i = 1:numel(F1),
        meanP(i) = mean(Pleft{i});
        stdP(i)  = std(Pleft{i});
    end;
    
    if isempty(fignum_in);
        figure; fignum = gcf;
    elseif ~ishandle(fignum_in),
        figure(fignum_in);
        fignum = gcf;
    end;
    
    ch = get(fignum, 'Children');
    if ~isempty(ch), delete(ch); end;
    ax = axes('Parent', fignum);
    
    % ---- set output
    aa{rat_i}.F1=F1;
    aa{rat_i}.meanP=meanP;
    
    plot(ax, F1, meanP, '.', 'MarkerSize', 20);
    set(ax, 'Ylim', [0 1]);
    
    set(fignum, 'Name', [ratname '  ' sdate{1} ' to ' sdate{end}]);
    %set(fignum, 'Position', figP(rat_i,:));
end
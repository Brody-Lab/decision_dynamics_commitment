% [a]= pa_analyzeDB(ratstr, daterange, {'tau', 30}, {'fignum', []})
%
% Runs a trial-type-by-trial-type hit_history analysis on a rat in the
% ProAnti2 protocol. Brings up a new figure and displays the results of the
% analysis.
%
% e.g. pa_analyzeDB('C%', -10,'tau', 30)
%

% Modified to use  mysql data.  -JCE 1/1/08


%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'tau'     By default 30, it is the trial constant of the exponential
%           smoothing kernel.
%
% 'fignum'  By default empty. If empty, a new figure is created to plot the
%           analysis. If non-empty, figure fignum is cleared, and the data
%           is plotted on that figure. Does not make fignum the current
%           figure, so can run in background.
%
% EXAMPLE:
% --------
%
% >> pa_analyze('J001', 'Jeff', -15);
%


function [aa]= pa_analyzeDB(ratstr, daterange, varargin)

pairs = { ...
    'tau'        30  ; ...
    'fignum_in'     []  ; ...
    'protocol',  'ProAnti2'  ; ...
    }; parseargs(varargin, pairs);


%% get rats

startdate=bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
if strfind(ratstr,'%')
all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname like "' ratstr '" and sessiondate>"' startdate{1} '" order by ratname']);
else
all_rats=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "{S}" and sessiondate>"' startdate{1} '" order by ratname'], ratstr);
end    

% Eliminate any rats whose names have commas in them, they're a mistake:
keeps = zeros(size(all_rats));
for i=1:length(all_rats), keeps(i) = isempty(strfind(all_rats{i}, ',')); end;
all_rats = all_rats(find(keeps)); %#ok<FNDSB>

%% rat loop

figP=fig_place(numel(all_rats));


for ri=1:numel(all_rats)
    ratname=all_rats{ri};




    [sdate, pd]=bdata(['select sessiondate, protocol_data from bdata.sessions where ratname="' ratname '" and sessiondate>"' startdate{1} '" and protocol like "ProAnti%" order by sessiondate']);




    pro_trial = []; goodPoke3 = []; gotit_history = []; current_block = [];
    hit_history = []; avg = []; avgp = [];  avga = [];

    day_separators = 0.5;


    % Eliminate any NULL entries
    keeps = ones(size(pd));
    for kk=1:length(pd), if strcmp(pd{kk}, 'NULL'), keeps(kk)=0; end; end;
    pd = pd(keeps==1);


%% For each rat consolodate across days
    for i=1:numel(pd)
        ntrials = numel(pd{i}.hit);

        gotit_history = [gotit_history ; pd{i}.gotit(:)];
        hit_history   = [hit_history   ; pd{i}.hit(:)];
        pro_trial     = [pro_trial     ; pd{i}.context(:)];
        goodPoke3     = [goodPoke3     ; pd{i}.sides(:)];
        current_block = [current_block ; pd{i}.blocks(:)];

        day_separators = [day_separators ; length(hit_history)+0.5];

        u     = find(~isnan(hit_history(end-ntrials+1:end)));
        guys  = gotit_history(end-ntrials+1:end);
        pmark = pro_trial(end-ntrials+1:end);
        avg   = [avg ; sum(guys(u))/length(u)];

        up   = u(pmark(u)==1);
        ua   = u(pmark(u)==-1);
        avgp = [avgp ; sum(guys(up))/length(up)];
        avga = [avga ; sum(guys(ua))/length(ua)];
    end;



%% make figures
    
    trial_types = unique([pro_trial goodPoke3], 'rows');
    ntypes = size(trial_types,1);
    us      = cell(ntypes,1);
    perfs   = cell(ntypes,1);
    leg     = cell(ntypes,1);
    handles = [];

    colors  = [0 0 1 ; 1 0 1 ; 1 0 0 ; 0 1 0];

    if isempty(fignum_in),  %#ok<NODEF>
        figure; fignum = gcf;
    end;
    if ~ishandle(fignum_in),
        figure(fignum);
    end;


    ch = get(fignum, 'Children');
    if ~isempty(ch), delete(ch); end;
    ax = axes('Parent', fignum);

    for i=1:ntypes,
        if trial_types(i,1)==1, leg{i} = 'Pro ';           else leg{i} = 'Anti ';         end;
        if trial_types(i,2)==1, leg{i} = [leg{i} 'Right']; else leg{i} = [leg{i} 'Left']; end;

        us{i} = find(pro_trial==trial_types(i,1) & goodPoke3 == trial_types(i,2) & ~isnan(hit_history));

        guys = gotit_history(us{i}); newguys = zeros(size(guys));
        e = exp(-(0:tau*4)/tau); e = e(end:-1:1);
        for j=1:length(guys),
            mye = e(end-min(length(e), j)+1:end); mye = mye/sum(mye);
            newguys(j) = sum(guys(j-length(mye)+1:j).*mye').*100;
        end;
        perfs{i} = newguys;

        l = plot(ax, us{i}, perfs{i}, '.-'); hold(ax, 'on'); handles = [handles;l];
        set(l, 'Color', colors(i,:));
        u = find(gotit_history(us{i})==0);
        l2 = plot(ax, us{i}(u), perfs{i}(u), '.'); hold(ax, 'on');
        set(l2, 'Color', 0.6*colors(i,:));
    end;

    yl = get(ax, 'ylim'); set(ax, 'ylim', [yl(1) 103]);
    xl = get(ax, 'xlim'); set(ax, 'xlim', [0 length(hit_history)*1.01]);

    S = msegment_finder(current_block);
    yl = get(ax, 'ylim');
    for i=1:size(S,1),
        if S(i,3)==1,
            p = patch([S(i,1), S(i,2), S(i,2), S(i,1), S(i,1)], [yl(1) yl(1) yl(2) yl(2) yl(1)], ...
                -100*ones(1,5), 0.9*[1 1 1], 'Parent', ax);
            set(p, 'EdgeColor', 'none');
        end;
    end;

    set(ax, 'Layer', 'top');
    set(vlines(ax, day_separators), 'Color', 'k');

    ntrials = diff(day_separators);
    for i=1:length(ntrials),
        yl = ylim(ax);
        t = text(day_separators(i)+ntrials(i)/2, yl(2)+0.05*diff(yl), ...
            {sprintf('n=%d', ntrials(i)) ; sprintf('%d%% [%d %d]', round(avg(i)*100), ...
            round(avgp(i)*100), round(avga(i)*100))}, 'Parent', ax);
        set(t, 'HorizontalAlignment', 'Center');
    end;

    legend(ax, handles, leg, 'Location', 'Best');
    legend(ax, 'boxoff');
    set(ax, 'YAxisLocation', 'right', 'YGrid', 'on')

    set(fignum, 'Name', ratname);
    set(fignum,'Position',figP(ri,:));


    if nargout>0, aa = a; end;

end


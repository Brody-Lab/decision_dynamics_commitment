function [hrates overallhrate] = session_hrate_oversessions(ratname, fromdate, todate, varargin)
% get session "% correct" average over a range of dates

pairs = { ...
    'use_dateset', 'range' ; ... % range or given
    'given_dateset', {} ; ... % list of dates is use_dateset = range 
    'mark_manips', 1 ; ...
    'graphic', 1 ; ...
    };
parse_knownargs(varargin,pairs); % 

switch use_dateset
    case 'range'
    get_fields(ratname,'from',fromdate,'to',todate,'datafields',{});
    case 'given'
        % do nothing
        get_fields(ratname, 'use_dateset','given', 'given_dateset', ...
            given_dateset);
    otherwise
        error('invalid value for use_dateset');
end;
    
cumtrials = cumsum(numtrials);
hrates = NaN(size(numtrials));
sdh = NaN(size(numtrials));
for i = 1:length(cumtrials)
    if i == 1, sidx = 1; else sidx = cumtrials(i-1)+1;end;
    eidx =cumtrials(i);    
    hrates(i) = mean(hit_history(sidx:eidx));
    sdh(i) = std(hit_history(sidx:eidx));
end;

overallhrate = mean(hrates);

fprintf(1,'Avg session hrate=%2.1f%% +/- %2.1f \n', mean(hrates)*100, std(hrates*100)/sqrt(length(hrates)));
2;

if graphic == 0, return; end;

% now plot ---------------------------------

figure;

% ymax = (floor(max(hrates)/50)+1)*50;
% for y = 50:50:ymax
%     line([0 length(numtrials)], [y y],'Color',[1 1 1]*0.7, 'LineWidth',2,'LineStyle',':');
%     hold on;
% end;
msize = 24;
% errorbar(1:length(hrates), hrates, sdh, sdh, 'Color',[1 1 1]*0.3); hold on;
 plot(hrates, '.k', 'MarkerSize',msize,'Color',[1 1 1]*0.3); hold on;
 
 

if mark_manips > 0    
    can = rat_task_table(ratname, 'action', 'cannula__muscimol');
    tmparray = sub__markmanips(can, dates, hrates);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [1 0 0]);
    end;

    can = rat_task_table(ratname, 'action', 'cannula__saline');
    tmparray = sub__markmanips(can, dates, hrates);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [0 1 0]);
    end;
end;


set(gca,'XTickLabel', sub__trimdates(dates),'XTick', 1:1:length(dates), 'XLim', [0 length(dates)+1]);
set(gca,'YTick', 0.70:0.1:1,'YTickLabel',70:10:100,'FontSize',16,'FontWeight','bold','YLim',[0.7 1]);
xlabel('Session');
ylabel('% Correct');
title(sprintf('%s: %% Correct from %s to %s', ratname, dates{1}, dates{end}));
set(gcf,'Position',[ 124          30        1037         302]);

axes__format(gca);
set(gca,'FontSize', 14);
sign_fname(gcf, mfilename);

% ------------------------------------------------------------------------
% Subroutines

% returns d-by-2 array of
% 1) index # of dates with manipulation of interest
% 2) # trials in 90 minutes on that day
function [tmparray] = sub__markmanips(maniparray, dates, numt)
tmparray=[];
    if isempty(maniparray),return;end;
tmpd =maniparray(:,1);

for k = 1:length(tmpd)
    idx = find(strcmpi(dates, tmpd{k}));
    if ~isempty(idx)
        tmparray = vertcat(tmparray, [idx, numt(idx)]);
    end;
end;

function [trm] = sub__trimdates(dates)
trm = {};
sidx = 3; if length(dates) > 20, sidx = 4;end;
for k = 1:length(dates)
    
    trm{end+1} = [dates{k}(sidx:4) '/' dates{k}(5:6)];
end;
function [hrates] = session_hrate_oversessions(ratname, fromdate, todate, varargin)
% get session "% correct" average over a range of dates

pairs = { ...
    'mark_manips', 1 ; ...
    };
parse_knownargs(varargin,pairs); % 

get_fields(ratname,'from',fromdate,'to',todate,'datafields',{});

cumtrials = cumsum(numtrials);
hrates = NaN(size(numtrials));
for i = 1:length(cumtrials)
    if i == 1, sidx = 1; else sidx = cumtrials(i-1)+1;end;
    eidx =cumtrials(i);    
    hrates(i) = mean(hit_history(sidx:eidx));
end;


% now plot ---------------------------------

figure;

% ymax = (floor(max(lasttnum)/50)+1)*50;
% for y = 50:50:ymax
%     line([0 length(numtrials)], [y y],'Color',[1 1 1]*0.7, 'LineWidth',2,'LineStyle',':');
%     hold on;
% end;
 plot(lasttnum, '.k', 'MarkerSize',msize,'Color',[1 1 1]*0.3); hold on;

if mark_manips > 0    
    can = rat_task_table(ratname, 'action', 'cannula__muscimol');
    tmparray = sub__markmanips(can, dates, lasttnum);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [1 0 0]);
    end;

    can = rat_task_table(ratname, 'action', 'cannula__saline');
    tmparray = sub__markmanips(can, dates, lasttnum);
    if ~isempty(tmparray)
        l=plot(tmparray(:,1), tmparray(:,2),'.b','MarkerSize',msize,'Color', [0 1 0]);
    end;
end;


set(gca,'XTickLabel', sub__trimdates(dates),'XTick', 1:1:length(dates), 'XLim', [0 length(dates)+1]);
%set(gca,'YTick', 0:50:max(numtrials),'FontSize',16,'FontWeight','bold','YLim',[0 ymax]);
xlabel('Session');
ylabel('# trials in 90 minutes');
title(sprintf('%s: # trials in %i minutes\n%s to %s', ratname, normal_session_length, dates{1}, dates{end}));
set(gcf,'Position',[ 124          30        1037         302]);

axes__format(gca);
set(gca,'FontSize', 14);
sign_fname(gcf, mfilename);


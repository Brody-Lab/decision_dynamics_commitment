function [] = triallen_influence_global(varargin)
% Tool to look at influence of trial length on side choice.
% Works with summary data of rats (outdata matrix).
% To generate the outdata matrix, use triallen_influence_run.
% 

pairs = { ...
    'graphic' , 1 ; ...
    };
parse_knownargs(varargin,pairs);

global Solo_datadir;

load([Solo_datadir filesep 'Data' filesep 'triallen.mat']);

outdata = vertcat(outdata(1:8,:), outdata(10:end,:));

filt = outdata; %ratdata(outdata,'Hare');
displaydata(filt,1);




% filters by rat
function [r] = ratdata(outdata,rattie)
r = find(strcmpi(outdata(:,1),rattie));
r = outdata(r,:);
return;

% filters by logdiff
function [r] = logdiff(outdata, l)

function [] = displaydata(filt,header)
% plot corrcoef
figure;
start_idx = 1; if header > 0, start_idx = 2; end;

set(gcf,'Position', [3   200   389   237]);
    currd = cell2mat(filt(start_idx:end,3));
    plot(ones(size(currd))*3, currd,'ob'); hold on;
    currd = cell2mat(filt(start_idx:end,4));  
    plot(ones(size(currd))*4, currd,'or'); hold on;

set(gca,'XTickLabel', {'SHORT','LONG'}, 'XTick', [3 4],'XLim',[2 5],'YLim',[-1 1]); 
t=title(sprintf('Association of trial length with p(reporting "Short")\nCorrelation coefficient'));
set(t,'FontSize',14,'FontWeight','bold');
line([2 5], [0 0],'LineStyle',':','Color','k');
    
lbls = {};
figure;
set(gcf,'Position',  [401   200   832   244]);
subplot(1,2,1);
for c = [5 7]
    currd = cell2mat(filt(start_idx:end,c));
    lbls{end+1} = filt{1,c};
    style ='ob'; if c>5, style='or';end;
    plot(ones(size(currd))*c, currd,style); hold on;
end;
set(gca,'XLim', [4 8], 'XTick', [5 7], 'XTickLabel',{'SHORT','LONG'});
t=title('Slope of linear fit, y=mx+b');
set(t,'FontWeight','bold','FontSize',14);

lbls={};
subplot(1,2,2);
for c = [6 8]
    currd = cell2mat(filt(start_idx:end,c));
    lbls{end+1} = filt{1,c};
     style ='ob'; if c>7, style='or';end;
    plot(ones(size(currd))*c, currd,style); hold on;
end;
line([5 9], [2 2], 'LineStyle',':','Color','r');
set(gca,'XLim', [5 9], 'XTick', [6 8], 'XTickLabel',{'SHORT','LONG'});
t=title('Statistic from Monte Carlo sim');
set(t,'FontWeight','bold','FontSize',14);

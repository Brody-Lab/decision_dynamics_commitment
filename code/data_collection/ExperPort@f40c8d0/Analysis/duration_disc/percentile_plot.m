function [] = percentile_plot(x,varargin)
% plots data for x against data for normal distribution

if nargin > 1
    t=varargin{1};
end;
figure;

x=sort(x);
plot(x,x,'-k');
hold on;
mu=mean(x); sigma=std(x);

if sigma == 0,
    warning('zero error: data not normal');
end;

probs=(1:length(x))/length(x);
normx = norminv(probs, mu, sigma); % samples from normal distribution with mu/sigma equal to that of our dataset
fset = normx(isfinite(normx));

% annotate graph with key points in norm distribution
line([min(fset) max(fset)], [mu mu],'Color','r','LineStyle',':');
line([min(fset) max(fset)], [mu+sigma mu+sigma],'Color','r','LineStyle',':');
line([min(fset) max(fset)], [mu-sigma mu-sigma],'Color','r','LineStyle',':');

text(x(end-1),mu+sigma, '+1s','FontAngle','italic','FontSize',14);
text(x(end-1),mu-sigma,'-1s','FontAngle','italic','FontSize',14);
text(x(end-1),mu,'mu','FontAngle','italic','FontSize',14);


plot(normx,x,'.b','MarkerSize',20);
hold on;

xlabel('Points from normal distribution');
ylabel('Data set');

set(gca,'YLim',[x(1) x(end)], 'XLim',[fset(1) fset(end)]);
df=length(normx)-length(fset);
if df>0
    text(x(2), fset(end),...
        sprintf('normx has %i inf values',df), ...
        'FontWeight','bold','Color','r','FontSize',12);
end;


if cols(x)>1, x=x';end;
h=kstest2(x, normx);

if h>0, txt='NOT Normal'; else txt='Normal'; end;
text(x(end-1), max(x)*0.9, txt,'FontWeight','bold');


if nargin >1
title(t);
end;
axes__format(gca);
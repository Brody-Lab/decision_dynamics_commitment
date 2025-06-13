function [] = examine_logistic()


x = [       5.2983    5.3982    5.5013    5.6021    5.7071    5.8081    5.9081    6.0113    6.1137];
replong =[ 1     2     2     6     5     7     7     3     8];
greatrep =[ 1     1     2     4     5     7     7     7    8];


tally=[6     8     8    12     8     8     7     7     8];

[xx,yy] = sub__makefit(x, greatrep,tally);
[xx2,yy2] = sub__makefit(x, replong,tally);


figure;
%plot(x, replong./tally, 'or'); hold on;
plot(xx,yy,'-r','LineWidth',2);
hold on;
plot(xx2,yy2,'-k','LineWidth',2);

set(gca,'XLim',[ min(xx), max(xx)], 'YTick', 0:0.25:1,'YTickLabel', 0:25:100, ...
    'XTick',[]);

axes__format(gca);

plus_sd = normcdf(1); minus_sd = normcdf(-1);
comm = find(abs(yy - minus_sd) == min(abs(yy-minus_sd)));
fin = find(abs(yy - plus_sd) == min(abs(yy-plus_sd)));
mid = find(abs(yy - 0.5) == min(abs(yy-0.5)));


xfin = xx(fin) - xx(mid); xcomm = xx(mid)-xx(comm);
xmid = xx(mid);  

weber = ((xcomm+xfin)/2)/xmid;
mp = log(sqrt(200*500));

function [xx,yy] = sub__makefit(x, replong,tally)
b = glmfit(x', [replong; tally]', 'binomial'); bfit = b;

    minx = min(x)-0.3; maxx=max(x)+0.3;
xx = minx:(maxx-minx)/100:maxx;

% running glmval is the same as doing
% xs = [ones(size(xx)); xx];
% ys = exp(xs' * b) ./ (1 + exp(xs' * b)); ----> logit link function
yy = glmval(b, xx, 'logit'); 
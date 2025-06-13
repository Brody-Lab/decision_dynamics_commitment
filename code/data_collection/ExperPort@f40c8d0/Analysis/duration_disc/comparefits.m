function [s qlin qsig betahat yy] = comparefits(bins, p, sigma, sigmoidfit, linearfit,graphic, xrange, varargin)
% fits psychometric data to either a line or sigmoid and compares Q-values
% to see which is the better fit.
% returns s=slope from best fit and q-values for each type of fit.

idx=union(find(p==1), find(p==0));
if ~isempty(idx)
    warning('Found bin with perfect value. Will lead to NaN Q-value');
end;


if ~isstruct(sigmoidfit)
    s=NaN;
    qlin=NaN;
    qsig=NaN;
    betahat=NaN(4,1);
    yy=NaN;
    return; 
end;
ylin = linear(linearfit.betahat,bins);
qlin = logistic_fitter('goodness_of_fit', p, ylin, sigma, 'linear');

ysig = sigmoid4param(sigmoidfit.betahat, bins);
qsig = logistic_fitter('goodness_of_fit', p, ysig, sigma, 'sigmoid');

myq = qsig;
if qlin == -1 
    warning('Uh oh; why does this rat have an invalid Q-value for a line fit?');    
elseif qsig == -1
    s=linearfit.betahat(1);
    betahat=linearfit.betahat;
    yy=linearfit.yy;
elseif qlin > qsig % picked linear fit
    s=linearfit.betahat(1);
    betahat=linearfit.betahat;
    yy=linearfit.yy;
elseif (p(1) >=0.5 || p(end) <= 0.5) % use linear fit if responses are absurdly off on the endpoints
    qlin=NaN; qsig=NaN;
    s=linearfit.betahat(1);
    betahat=linearfit.betahat;
    yy=linearfit.yy;
else    
    betahat=sigmoidfit.betahat;
    yy=sigmoidfit.yy;
    try
    s=sigmoidslope(betahat, xrange);
    catch
        2;
    end;
end;
  %s=atan(s)/(pi/2); % normalize slope  
    
if graphic==0
    return;
end;
    
xx=varargin{1};
yy=varargin{2};

% plot expected-lin/sigmoid versus observed.
figure;
fsize=18;
subplot(1,2,1);
plot(xx,yy,'-k','Color',[1 1 1]*0.5);
hold on;
errorbar(bins, p,sigma, sigma, '.k','MarkerSize',10,'Marker','o');
plot(bins, ylin,'.r','MarkerSize',20);
set(gca,'YLim',[0 1]);
text(bins(1), 0.9, sprintf('Q=%2.3f', qlin),'FontSize',fsize,'FontWeight','bold');
title('Linear');

subplot(1,2,2);
plot(xx,yy,'-k','Color',[1 1 1]*0.5);
hold on;
errorbar(bins, p,sigma, sigma,'.k','MarkerSize',10,'Marker','o');
plot(bins, ysig,'.b', 'MarkerSize',20);
set(gca,'YLim',[0 1]);
text(bins(1), 0.9, sprintf('Q=%2.3f', qsig),'FontSize',fsize,'FontWeight','bold');
title('Sigmoidal');

set(gcf,'Position',[124   501   888   363]);
% 
% fig=figure;
% subplot(1,2,1);
% sub__pp_plot(ylin-p,fig);
% title('linear');
% 
% subplot(1,2,2);
% sub__pp_plot(ysig-p,fig);
% title('sigmoid');

function [] = sub__pp_plot(x,fig)
set(0,'CurrentFigure',fig);

x=sort(x);
plot(x,x,'-k');
hold on;
mu=mean(x); sigma=std(x);

probs=(1:length(x))/length(x);
normx = norminv(probs, mu, sigma);
plot(x,normx,'.b','MarkerSize',20);

if cols(x)>1, x=x';end;
h=kstest(x, [x probs']);

if h>0, txt='NOT Normal'; else txt='Normal'; end;
text(mean(x(1:2)), max(x)*0.9, txt,'FontWeight','bold');

set(gca,'XLim',[min(x)-(0.1*min(x)) max(x)+(0.1*max(x))]);
set(gca,'YLim', get(gca,'XLim'));
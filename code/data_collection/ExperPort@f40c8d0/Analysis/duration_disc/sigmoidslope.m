function [s] = sigmoidslope(betahat, xrange)
% computes highest slope of sigmoid in the stimulus range specified by
% xrange
% betahat 1x4 vector specifying the 4-parameter sigmoid.
% xrange 1x2 vector of stimulus endpoints

 graphic=0;

numsteps=20;
stp=(xrange(2)-xrange(1))/numsteps;
xx=xrange(1):stp:xrange(2);

yy=sigmoid4param(betahat,xx); % y values
slps=diff(yy);


s=max(slps);
tmp=find(slps==s);

% now convert to change in y per unit x
multfac = numsteps / (xrange(2)-xrange(1));
s= s / stp;

if graphic == 0, return;end;

figure;
subplot(1,2,1);
plot(xx,yy,'.b'); hold on;
set(gca,'YLim',[0 1]);
plot(xx(tmp:tmp+1), yy(tmp:tmp+1),'.r');
text(xx(5), 0.9, sprintf('%f',s),'FontSize',14);

% convert before plotting
slps = slps * multfac;
subplot(1,2,2);
plot(xx(2:end),slps,'.k'); hold on;
plot(xx(tmp+1),slps(tmp),'.r');



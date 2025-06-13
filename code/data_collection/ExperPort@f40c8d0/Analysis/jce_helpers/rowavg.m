function y=rowavg(x)
% % 
% m=avg(x');
% m=repmat(m',1, size(x,2));
% y=x./m;

m=avg(x');
m=repmat(m',1, size(x,2));
y=avg(x./m);
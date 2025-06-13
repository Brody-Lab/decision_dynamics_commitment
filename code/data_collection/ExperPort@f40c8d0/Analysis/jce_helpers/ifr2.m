function y=ifr(x, res,pad)
% Assume x in ms and res in ms.
% ifr instantaneous firing rate
% x is timestamps in ms
% res is the resolution in ms of the ifr
if isempty(x)
    y=0;
    return;
end

x=round(x/res);

isi=x(2:end)-x(1:end-1);
y=zeros(1,x(1));
for i=1:length(isi)
    br=zeros(1,isi(i))+(1/res/isi(i));
    y=[y br];
end


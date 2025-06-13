function y=ifr(x, res, st, ed)
% Assume x in ms and res in ms.
% ifr instantaneous firing rate
% x is timestamps in ms
% res is the resolution in ms of the ifr
if isempty(x)
    y=[];
    return;
end

x=round(x/res);

isi=diff(x);

%y=zeros(1,x(1));
%y=zeros(1,sum(isi));
y=zeros(st:res:ed);

yind=x(1)+1;
for i=1:numel(isi)
    br=zeros(1,isi(i))+(1/res/isi(i));
    y(yind:(yind+numel(br)-1))=br;
    yind=yind+numel(br);
end

y=y*1E3;
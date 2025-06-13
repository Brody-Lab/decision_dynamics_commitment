function [red_px, green_px,blue_px]=vid_bitfield(points,tsidx)

n_samp=size(points,2);

if nargin==1
    tsidx=1:n_samp;
else
    n_samp=numel(tsidx);
end

bi=1;
ri=1;
gi=1;


totB=0;
totR=0;
totG=0;
tic
for tx=1:n_samp
    px=tsidx(tx);
    
    totB=totB+sum(bitand(2^28, points(:,px))>0);
    totR=totR+sum(bitand(2^30, points(:,px))>0);
    totG=totG+sum(bitand(2^29, points(:,px))>0);
end
x=toc;

blue_px=zeros(totB,3);
green_px=zeros(totG,3);
red_px=zeros(totR,3);
fprintf('Determined memory requirments in %d seconds\n\tStarting extraction\n',round(x));

for tx=1:n_samp
    px=tsidx(tx);
    
    x=bitand(2^12-1, points(:,px));
    y=bitand((2^28-1)-(2^16-1), points(:,px));
    y=bitshift(y,-16);
    blue=bitand(2^28, points(:,px))>0;
    red=bitand(2^30, points(:,px))>0;
    green=bitand(2^29, points(:,px))>0;
    
    nb=sum(blue);
    ng=sum(green);
    nr=sum(red);
    
    tB=[px+zeros(nb,1), x(blue), y(blue)];
    tR=[px+zeros(nr,1), x(red), y(red)];
    tG=[px+zeros(ng,1), x(green), y(green)];
    
    blue_px(bi:(bi+nb-1),:)=tB;
    bi=nb+bi;
    red_px(ri:(ri+nr-1),:)=tR;
    ri=nr+ri;
    green_px(gi:(gi+ng-1),:)=tG;
    gi=ng+gi;
    
    
    
    if mod(px,50000)==0
        tt=toc;
        fprintf('%d %% done, %d sec elapsed\n',round(100*px/n_samp),round(tt))
        tic;
    end
end


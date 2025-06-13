function [yM,xM,h]=tsraster2(r,t,pre,post, plotthis)
% [yM,xM,h]=tsraster2(r,t,pre,post,bin, plotthis)
% Computes the cross-correlation of 2 point processes, r(ef) and t(arget)
% using a time w(indow) in ms.
% either provide one window input and it will use +/- w or provide pre and
% post.
% r and t should be vectors of timestamps in seconds
% if would be way faster if i find the smaller of r and t and run through
% r.  but i'm not using this for the bootstrap anyway.

%% SETUP

r=r*1000;
t=t*1000;

if nargin<5
    plotthis=1;
end

if nargin<4
    post=pre;
end


% if either are empty return empty

if isempty(r) 
    yM=[]; xM=[];
     return
end

if isempty(t)
    t=r(1)-pre-1;
end

% if w is zero or negative, complain

if (post+pre)<=0
    y=[];
    display('window is negative in size')
    return
end

% make sure r and t are column vectors.

r=col(r);
t=col(t);

% Note: i wrote this without a for loop and it was slower.  this code is
% quite fast.  the autocorrelation with 4000 spikes takes around 2 seconds.

%% The meat of the code.  Really brain dead simple.


spks=zeros(numel(t),2);
spk_ind=1;
for i=1:numel(r)
    s=r(i)-pre;
    f=r(i)+post;
    cc=qbetween(t, s,f)-r(i);
    if isempty(cc)
        cc=nan;
    end
    s_inc=numel(cc);
    %spks=[spks; cc(:), zeros(size(cc(:)))+i];
    spks(spk_ind:spk_ind+s_inc-1,:)=[cc, zeros(s_inc,1)+i];
    spk_ind=spk_ind+s_inc;

end

spks=spks(1:spk_ind-1,:);
    

xM=zeros(size(spks,1)*3,1);
yM=xM;

xM(1:3:end)=spks(:,1);
xM(2:3:end)=spks(:,1);
xM(3:3:end)=nan;

yM(1:3:end)=spks(:,2);
yM(2:3:end)=spks(:,2)+.8;
yM(3:3:end)=nan;

if plotthis
    h=plot(xM/1000,yM,'k');
end




%% it might be worth returning an unbinned vector


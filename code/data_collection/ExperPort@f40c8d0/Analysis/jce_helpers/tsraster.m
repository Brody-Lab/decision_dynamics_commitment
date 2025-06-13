function [y,varargout]=tsraster(r,t,pre,post,bin,isPP)
% [y,x]=tsraster(r,t,pre,post,bin,isPointProcessWanted)
% Computes the cross-correlation of 2 point processes, r(ef) and t(arget)
% using a time w(indow) in sec.
% either provide one window input and it will use +/- w or provide pre and
% post.
% r and t should be vectors of timestamps in sec
% if would be way faster if i find the smaller of r and t and run through
% r.  but i'm not using this for the bootstrap anyway.
% UPDATED 2010.06.14 by JKJ
% added a boolean variable isPointProcessWanted.  Setting this to true, 
% will make the output y a cell with one row per referernce entry.  Each 
% row carries the time steps of a point process.  That is, no binning is 
% performed. Default for isPP is false.

%% SETUP

if nargin<4
    post=pre;
end

if nargin<5
    bin=10E3;
end

if nargin<6
    isPP=false;
end

% if either are empty return empty

if isempty(r) 
    y=[];
    return
end

if isempty(t)
    t=r(1)-pre-bin-1;
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
if ~isPP
    y=zeros(length(r),length(-pre:bin:post)-1);
    for i=1:length(r)
        % old slow way
        %    cc=t-r(i);
        %    cc=cc((cc>-pre)&(cc<post));
        s=r(i)-pre;
        f=r(i)+post;
        cc=qbetween(t, s,f)-r(i);
        if ~isempty(cc)
            cc=histc(cc,-pre:bin:post);
            cc=row(cc);
            y(i,:)=cc(1:end-1);
        end
        
    end
else
    y=cell(length(r),1); % one cell row for each reference time (e.g. trial)
    for i=1:length(r)
        y{i}=qbetween(t,r(i)-pre,r(i)+post)-r(i);
    end
end
if nargout==2;
x=-pre:bin:post;
varargout{1}=x(1:end-1);
end

%% it might be worth returning an unbinned vector


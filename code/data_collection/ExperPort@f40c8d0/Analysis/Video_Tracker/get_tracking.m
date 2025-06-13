function [ts a] = get_tracking(sessid,varargin)

%
% function [ts a] = get_tracking(sessid,varargin)
% pairs = { ...
%   'mints',     [];    ...
%   'isdec',     false; ...
%   'maxdtheta', [];    ...
%   'isconv',    false; ...
%   'kernel',    [];    ...
%   };
% a contains: a.x, a.y, a.theta, and a.dtheta
%

pairs = { ...
  'mints',     [];    ...
  'isdec',     false; ...
  'maxdtheta', [];    ...
  'isconv',    false; ...
  'kernel',    [];    ...
  't_data',      []; ...
  };
parseargs(varargin,pairs);

if isempty(t_data)
    [ts x y theta] = bdata('select ts,x,y,theta from tracking where sessid="{S}"',sessid);
    
    if isempty(ts),
        ts = [];
        a = [];
        return;
    end;
    
    ts  = ts{1};
    a.x = x{1};
    a.y = y{1};
    a.theta = theta{1};
else
    ts=t_data.ts;
    a.x=t_data.x;
    a.y=t_data.y;
    a.theta=t_data.theta;
end
%     
% if isempty(mints)
%     mints=0.1*median(diff(ts));
% end
% 
% 
% % --------- assume that all timestamps are good, but out of order
% [ts inds]=sort(ts);
% a.x = a.x(inds);
% a.y = a.y(inds);
% a.theta = a.theta(inds);
% inds=1:numel(ts);
% if ~isempty(mints)
%   while sum(diff(ts)<mints)>0
%     dts=diff(ts);
%     isgood=[true dts>mints];
%     ts=ts(isgood);
%     inds=inds(isgood);
%   end
%   a.x = a.x(inds);
%   a.y = a.y(inds);
%   a.theta = a.theta(inds);
% end


goodts=ts>0;
ts=ts(goodts);
a.x=a.x(goodts);
a.y=a.y(goodts);
a.theta=a.theta(goodts);

[ts inds]=sort(ts);
 a.x = a.x(inds);
 a.y = a.y(inds);
 a.theta = a.theta(inds);

%ss=median(diff(ts));
%goodts=abs(diff(ts)-ss)<ss;



% --------- decimate based on bad time stamps and spikelets in theta, then
%             repopulate using spline fitting.
if isdec  
  [ts2,a.theta,isgood]=remove_headspikes(ts,a.theta,maxdtheta,10000);
  a.x=a.x(isgood);
  a.y=a.y(isgood);
  a.theta=interp1(ts2,a.theta,ts,'linear');
  a.x=interp1(ts2,a.x,ts,'linear');
  a.y=interp1(ts2,a.y,ts,'linear');
end

% -------- get head angle velocity
a.dtheta=calc_dtheta(ts,a.theta);

% -------- convolve
if isconv
  if isempty(kernel)
    dt=0.05;
    kamp=12;
    sig=3;
    kernel=dt*pdf('norm',-kamp:dt:kamp,0,sig*dt); 
  end
  % conv can take three inputs starting from v.2009a.
  if any(version('-release')<'2009a')
    a.x      = convn(a.x,kernel,'same');
    a.y      = convn(a.y,kernel,'same');
    a.theta  = convn(a.theta,kernel,'same');
    a.dtheta = convn(a.dtheta,kernel,'same');
  else
    a.x      = conv(a.x,kernel,'same');
    a.y      = conv(a.y,kernel,'same');
    a.theta  = conv(a.theta,kernel,'same');
    a.dtheta = conv(a.dtheta,kernel,'same');
  end
%   snipsize=10;
%   a.x=a.x((1+snipsize):(end-snipsize));
%   a.y=a.y((1+snipsize):(end-snipsize));
%   a.theta=a.theta((1+snipsize):(end-snipsize));
%   ts=ts((1+snipsize):(end-snipsize));
end


  

function [VV errstat]=combine_trackers(V)

% VV=combine_trackers(V)
% Takes a struct array V of trackers and returns a single tracker struct which combines the data from the n trackers

interp_bin=0.025;

num_trackers=numel(V);

if num_trackers~=2
    'sorry can only handle 2 trackers for now'
    return
end

errstat=0;

start_time=max(V(1).TimeStamps(1), V(2).TimeStamps(1))/1e6;
end_time=min(V(1).TimeStamps(end), V(2).TimeStamps(end))/1e6;
iTS= start_time:interp_bin:end_time;
%% Nan out the bad data and then do a linear interp of both data sets.
for tx=1:num_trackers
    
    theta=V(tx).Theta;
    ts=V(tx).TimeStamps/1e6;
    X=V(tx).X;
    Y=V(tx).Y;
    
    
    
    bad_ts=theta==0;
    X(bad_ts)=nan;
    Y(bad_ts)=nan;
    theta(bad_ts)=nan;
    
    
    X=X-nanmean(X);
    Y=Y-nanmean(Y);
    
    Z=[X(:) Y(:) theta(:)];
    
    % This should maybe get taken out.
    Z=medfilt1(Z,3);  % get rid of spikelets first.  NOTE: this expands the areas with NaNs.  Maybe should do before Naning.
    
    iZ{tx}=interp1(ts, Z,iTS);
       
end

num_frames=numel(iTS);
bad_ts=zeros(num_frames, num_trackers);
all_good=ones(num_frames,1);


for tx=1:num_trackers
    % get the frames where each tracker is bad.
    bad_ts(:,tx)=isnan(iZ{tx}(:,3));
    % Get the frames where both trackers are good.
    all_good=all_good & ~bad_ts(:,tx);
end

[foo,mt] = min(sum(1==bad_ts));  % the master tracker is the one with the best data

%% Find the transfer function from the two other trackers to the master

X=zeros(num_frames ,5);

for tx=1:num_trackers
    
    tCos=cos(d2r(iZ{tx}(:,3)));
    tSin=sin(d2r(iZ{tx}(:,3)));
    tX=iZ{tx}(:,1);
    tY=iZ{tx}(:,2);
    
    tC=ones(size(tY));
    if tx==mt
        B=[tCos(:) tSin(:) tX tY tC(:)];
    else
        A=[tCos(:) tSin(:) tX tY tC(:)];
    end
end

% compute the transfer function from the good samples
T = A(all_good,:)\B(all_good,:);

% compute Y' from the transer function.
Bp= A*T;

% how's our error rate?

fprintf('MSE is %f\n',nanmean(B.^2-Bp.^2));


cTheta=atan2(B(:,2),B(:,1))*180/pi;
cX=B(:,3);
cY=B(:,4);

nTheta=atan2(Bp(:,2),Bp(:,1))*180/pi;
nX=Bp(:,3);
nY=Bp(:,4);

cTheta(bad_ts(:,mt)==1)=nTheta(bad_ts(:,mt)==1);
cX(bad_ts(:,mt)==1)=nX(bad_ts(:,mt)==1);
cY(bad_ts(:,mt)==1)=nY(bad_ts(:,mt)==1);

VV.TimeStamps=iTS(:)*1e6';
VV.Theta=cTheta';
VV.X=cX';
VV.Y=cY';
VV.Header=V(mt).Header;


function y = d2r(x)
y = x * pi/180;



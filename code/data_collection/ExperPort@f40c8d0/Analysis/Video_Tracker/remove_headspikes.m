function [newts,newth,isgood]=remove_headspikes(ts,theta,thresh,maxiter)

%
% [newts,newtheta,isgood]=remove_headspikes(ts,theta,thresh,maxdecimations)
%   Decimates ts and theta based on change in theta on successive bins,
%   i.e. abs(diff(theta)./diff(ts))>thresh are thrown out.  Repeats
%   decimation until no successive points are above thresh or until max
%   number of decimations is reached.
%   default thresh is 1000
%   default maxdecimations is 20
%   newts is the decimated ts
%   newtheta is the decimated theta
%   isgood is a boolean vector the same size as the original ts such that
%   newts=ts(isgood) and newtheta=theta(isgood)
%

if ~exist('maxiter','var'), maxiter=20; end



newts=ts;
newth=theta;

niter=0;
v=abs(diff(newth)./diff(newts));

if isempty(thresh)
       thresh=prctile(abs(v(:)),99.5);
       if thresh < 200 || thresh > 1500
           fprintf(2,'Threshold set at %d degress/sec.  This is unusual\n',thresh);
       end
end
       
       
       
binsrem=[0 v>thresh] | [v>thresh 0];
igoodbins=1:numel(ts);

while sum(binsrem)>0 && niter<maxiter
  niter=niter+1;
  newts=newts(~binsrem);
  newth=newth(~binsrem);
  igoodbins=igoodbins(~binsrem);
  v=abs(diff(newth)./diff(newts));
  binsrem=[0 v>thresh] | [v>thresh 0];
end

isgood=false(1,numel(ts));
isgood(igoodbins)=true;

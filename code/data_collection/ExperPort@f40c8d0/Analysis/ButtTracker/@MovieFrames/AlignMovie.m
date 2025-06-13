function stats=AlignMovie(obj,bv,bvt,peh,pd,state_name,varargin)

%
% [bv,bvt,stats.rew,stats.ts]=PrepareAlignmentVectors(bv,bvt,peh,varargin)
%   Function digitizes blocked pixel values (via threshold) and rewards
%

pairs={...
  'ntsbuffer',   100;                      ...
  'thresh',      5;                        ... % this value is in terms of multiples of standard deviation of blocked pixel values.  The reason for this method is to avoid errors in setting thresholds.
  'kernel',      100*normpdf(-60:60,0,20); ...
  'delay',       0;                        ...
  'lrfieldname', 'sides';                  ...
  'maxthresh',   252;                      ...
  };
parseargs(varargin,pairs);

npixels=size(bv,1);
dt=mean(diff(bvt));
stats.bvt=bvt(1):dt:bvt(end);
stats.bv=interp1(bvt,double(bv'),stats.bvt)';
threshmat=repmat(mean(stats.bv,2)+thresh*std(double(stats.bv),1,2),1,size(stats.bv,2));
threshmat(threshmat>maxthresh)=maxthresh;
stats.bv=double(stats.bv>threshmat);
for k=1:npixels
  tmpinds=chunk_scores(stats.bv(k,:),0.5,'max'); 
  stats.bv(k,:)=0;
  stats.bv(k,tmpinds)=1;
end
stats.ts=((-ntsbuffer*dt+stats.bvt(1)):dt:(ntsbuffer*dt+stats.bvt(end)))+peh(1).states.sending_trialnum(1,1);
stats.rew.L=reward_function(stats.ts,peh,state_name,...
  'statevalues',ones(size(state_name,1),1),'delay',delay,'isinclude',pd.(lrfieldname)=='l');
stats.rew.R=reward_function(stats.ts,peh,state_name,...
  'statevalues',ones(size(state_name,1),1),'delay',delay,'isinclude',pd.(lrfieldname)=='r');
stats.rew.L=conv(stats.rew.L,kernel,'same');
stats.rew.R=conv(stats.rew.R,kernel,'same');
for k=1:npixels, stats.bv(k,:)=conv(double(stats.bv(k,:)),kernel,'same'); end

stats.minnorm=struct('L',zeros(npixels,1),'R',zeros(npixels,1));
stats.iminnorm=struct('L',zeros(npixels,1),'R',zeros(npixels,1));
stats.allnorms=struct('L',zeros(npixels,2*ntsbuffer+1),'R',zeros(npixels,2*ntsbuffer+1));
for k=1:npixels
  [stats.iminnorm.L(k),stats.minnorm.L(k),stats.allnorms.L(k,:)]=...
    align_twovectors(stats.bv(k,:),stats.rew.L,1,2*ntsbuffer+1,3);
  [stats.iminnorm.R(k),stats.minnorm.R(k),stats.allnorms.R(k,:)]=...
    align_twovectors(stats.bv(k,:),stats.rew.R,1,2*ntsbuffer+1,3);
end
[garb.L stats.bestpix.L]=min(stats.minnorm.L);
[garb.R stats.bestpix.R]=min(stats.minnorm.R);
stats.t0.L=stats.ts(stats.iminnorm.L(stats.bestpix.L))-stats.bvt(1);
stats.t0.R=stats.ts(stats.iminnorm.R(stats.bestpix.R))-stats.bvt(1);

if garb.L<garb.R, obj.T0=stats.t0.L; else obj.T0=stats.t0.R; end

obj.Settings.AlignMovie.ntsbuffer=ntsbuffer;
obj.Settings.AlignMovie.thresh=thresh;
obj.Settings.AlignMovie.kernel=kernel;

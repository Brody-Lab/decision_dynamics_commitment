function psth=calc_psth(event_times,timebins,kernel,tau,t0)

%
% psth=calc_psth(event_times,timebins,kernel_name,tau,t0)
%
%   event_times is a cell vector, with each element holding a sample of
%     time stamps of a point process as a vector.  Can also be input as a
%     single vector of time stamps.
%   timebins is a vector containing the times of the RIGHT EDGE of each bin
%     calculated in the psth
%   kernel_name can take on the values (case insensitive):
%     'GAUSS'  - gaussian centered on each timebin
%     'LGAUSS' - causal gaussian with peak value at each timebin
%     'LEXP'   - causal exponential with peak value at each timebin
%     'LBINS'  - causal rectangular bin with right edge at each timebin
%   tau is the width of the kernel, can be a scalar or a vector with the
%     same number of elements as time bins (allows for time varying kernel)
%   (OPTIONAL) t0 are event zeroing times, can be a scalar or a vector with
%     the same number of samples as event_times with one exception: using a
%     single sample of event_times (1 element cell or simply a vector) with
%     a vector for t0 creates a psth with as many rows as elements as t0.
%     This allows a psth for a single sample of timestamps to be calculated
%     at different centering times.  For example, if you wanted to
%     calculate the psth of a spike train relative to the time of cpoke
%     entry and relative to cpoke exit.    
%   
%   psth will be a nsamples x ntimebins matrix, each sample is a row each
%     time bin is a column
%
%   This function uses repmat to make accurate and relatively fast psths.
%   If the product of time stamps in any sample with the number of time
%   bins is large this function may crash and burn.  Future implementation
%   might switch to for loop in this case.
%

% ensure rows
timebins=timebins(:)';
tau=tau(:)';

% single samples are allowed, but need to be converted to cells if not
% already
if ~iscell(event_times), event_times={event_times}; end

% if t0 exists, use it as a centering time, but check the different cases
% of sizes of event_times and t0
if exist('t0','var')
  if numel(event_times)==1
    nsamples=numel(t0);
    is_reuse_ets=true;
  else
    nsamples=numel(event_times);
    if isscalar(t0), t0=t0*ones(numel,1); end
    is_reuse_ets=false;
  end
else
  nsamples=numel(event_times);
  t0=zeros(nsamples,1);
  is_reuse_ets=false;
end

% preallocate
ntime=length(timebins);
psth=zeros(nsamples,ntime);

% go calculate psth
for k=1:nsamples
  if is_reuse_ets, tmp_ets=event_times{1}-t0(k);
  else             tmp_ets=event_times{k}-t0(k);
  end
  nevents=numel(tmp_ets);
  if nevents==0, psth(k,:)=0; continue; end
  tmp_ets=tmp_ets(:); % ensure columns
  events2=repmat(tmp_ets,1,ntime);
  time2=repmat(timebins,nevents,1);
  if ~isscalar(tau), tau2=repmat(tau,nevents,1); else tau2=tau; end
  switch upper(kernel)
    case 'GAUSS'
      psth(k,:)=sum( exp( -((time2-events2)./(sqrt(2)*tau2)).^2 )./(tau2*sqrt(2*pi)), 1);
    case 'LGAUSS'
      events2(events2>time2)=NaN;
      psth(k,:)=nansum( sqrt(2)*exp( -((time2-events2)./(sqrt(2)*tau2)).^2 )./(tau2*sqrt(pi)), 1);  
    case 'LEXP'
      events2(events2>time2)=NaN;
      psth(k,:)=nansum( exp( -(time2-events2)./tau2 )./tau2, 1);
    case 'LBINS'
      psth(k,:)=sum( step_pulse( time2-events2, 0, tau2 ), 1 )./tau2;
    otherwise
      error(['I do not recognize the kernel ' kernel '.'])
  end
    
end
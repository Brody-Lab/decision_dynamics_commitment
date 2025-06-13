function [rew,last_trial]=reward_function(ts,peh,state_names,varargin)

%
% [rew,last_trial]=reward_function(ts,peh,state_names,varargin)
%
% pairs={ ...
%   'statevalues', 1;                ...
%   'dt',          [];               ...
%   'isinclude',   [];               ...
%   'delay',       zeros(size(peh)); ...
%   };
%

pairs={ ...
  'statevalues', 1;                ...
  'dt',          [];               ...
  'isinclude',   true(size(peh));  ...
  'delay',       zeros(size(peh)); ...
  };
parseargs(varargin,pairs);

if ~iscell(state_names), state_names={state_names}; end                         % state_names might not be a cell
nstates=size(state_names,1);
ntrials=numel(peh);
rew=ts*0;
last_trial=0;    
t2=-Inf;
if numel(delay)==1, delay=repmat(delay,ntrials,1); end

for k=1:ntrials
  if ~isinclude(k), continue; end
  if nstates==1, cs=1;
  else
    if isempty(peh(k).(state_names{1,1}).(state_names{1,2})), cs=2;             % if two states requested, assumed mutually exclusive
    else                                                      cs=1;
    end
  end
  nrows=size(peh(k).(state_names{cs,1}).(state_names{cs,2}),1);                 % state may have multiple entries per trial
  for irow=1:nrows
    t1=peh(k).(state_names{cs,1}).(state_names{cs,2})(irow,1)+delay(k);         % shorthands
    if isempty(dt), t2=peh(k).(state_names{cs,1}).(state_names{cs,2})(irow,2);
    else            t2=t1+dt;
    end
    isin = ts>=t1 & ts<=t2;                                                     % all times inbetween this state entry and exit 
    if sum(isin)>0                                                              % check that there are times inbetween
      rew(isin)=statevalues(cs);
      last_trial=k;
    else                                                                        % if not, either we are outside of ts or ts is undersampled
      if t1>ts(end)                                                             % if entry is past last timestamp, then, given trials are in time order and ts is sorted, quit
        if irow==1, last_trial=k-1;
        else        last_trial=k;
        end
        return
      end
      if t2<ts(1), continue; end
      [garb,ind]=min(abs(ts-t1));
      rew(ind)=statevalues(cs);
      last_trial=k;
    end
  end
  if t2>ts(end); return; end
end

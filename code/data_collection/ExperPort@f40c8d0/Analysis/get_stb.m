function varargout=get_stb(ratname,datestr,varargin)

%
% varargout=get_stb(ratname,datestr,kernel_track)
%   gets spike, tracking, and behavioral data for one session given a
%   ratname and date string.
% varargin
%   pairs={ ...
%     'mints',[];        ...
%     'isdec',false;     ...
%     'maxdtheta',[];    ...
%     'isconv',false;    ...
%     'kernel_track',[]; ...
%     };
% parseargs(varargin,pairs);
% varargout:
%   {1} protocol data
%   {2} parsed events history
%   {3} spikes, i.e. ts in spktimes table
%   {4} tracking, i.e. from get_tracking---decimated, interpolated, and smoothed
%   {5} sessid
%   {6} cellid
%
% EXAMPLE:
% [pd,peh,spikes,tr,sessid,cellid]=get_stb('B068','2009-08-08');
%

pairs={ ...
  'mints',[];        ...
  'isdec',false;     ...
  'maxdtheta',[];    ...
  'isconv',false;    ...
  'kernel_track',[]; ...
  };
parseargs(varargin,pairs);

% -------- sessid
sessid=bdata('select sessid from sessions where ratname="{S}" and sessiondate="{S}"',ratname,datestr);
if isempty(sessid), disp('session does not exist.'); return; end

% -------- spikes
[spikes,cellid]=bdata('select ts,cellid from spktimes where sessid="{S}"',sessid);
if isempty(spikes)
  warning('MATLAB:get_stb','no spikes in session %d.',sessid); 
  isspikes=false;
else
  isspikes=true;
end

% -------- pd
pd=bdata('select protocol_data from sessions where sessid="{S}"',sessid);
pd=pd{1};
if ischar(pd)
  warning('MATLAB:get_stb','no protocol data in session %d.',sessid); 
  ispd=false;
else
  ispd=true;
  
  ntrials.pd=numel(pd.hits);
end

% -------- peh
peh=get_peh(sessid);
if isempty(peh)
  warning('MATLAB:get_stb','no parsed events history in session %d.',sessid); 
  ispeh=false;
else
  ispeh=true;
  ntrials.peh=numel(peh);
end

% -------- head tracking
[ts tr]=get_tracking(sessid,'mints',mints,'isdec',isdec,'maxdtheta',maxdtheta,...
  'isconv',isconv,'kernel',kernel_track);
if isempty(ts)
  warning('MATLAB:get_stb','no head tracking in session %d.',sessid); 
  istrack=false;
else
  istrack=true;
  tr.ts=ts;
end

% -------- ensure trial numbers are same for peh and pd
if ispd && ispeh
  mintrials=min([ntrials.peh ntrials.pd]);
  keepers=1:mintrials;
  if ntrials.peh>mintrials, peh=peh(keepers); end
  if ntrials.pd>mintrials
    pd.hits=pd.hits(keepers);
    pd.sounds=pd.sounds(keepers);
    pd.sides=pd.sides(keepers);
    pd.fsd=pd.fsd(keepers);
    pd.ssd=pd.ssd(keepers);
    pd.side_lights=pd.side_lights(keepers);    
  end
end

% -------- set outputs
if nargout>0 && ispd,     varargout{1}=pd;      end
if nargout>1 && ispeh,    varargout{2}=peh;     end
if nargout>2 && isspikes, varargout{3}=spikes;  end
if nargout>3 && istrack,  varargout{4}=tr;      end
if nargout>4,             varargout{5}=sessid;  end
if nargout>5 && isspikes, varargout{6}=cellid;  end










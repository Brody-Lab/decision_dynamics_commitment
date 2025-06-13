function [ptr pspikes psth]=parse_headdata(tr,spikes,varargin)

%
% function [ptr pspikes psth]=parse_headdata(tr,spikes,varargin)
%   calls cdraster on tracking data tr, calls qbetween on spikes data, and
%   calculates psth on spikes data.  Use varargin to change the centering
%   event time or the event name.  Can also adjust time limits to record
%   data around each event independently for each output variable
%   varargin:
%   pairs={ ...
%     'peh',[];                      ... % parsed events history
%     'event_name','cpoke(end,end)'; ... % centering event name
%     't0',[];                       ... % center times for parsed data, if ~empty overrides event_name
%     'tlims_track',[3 6];           ... % amount of time before and after t0 to record tracking for each event
%     'dt_track',0.1;                ... % width of time bins for tracking
%     'tlims_spike',[3.5 6.5];       ... % amount of time before and after t0 to record spikes for each event
%     'kernel_name','gauss';         ... % name of kernel to use for making psths
%     'tau',0.1;                     ... % width of kernel in seconds
%     'anglec',180;                  ... % critical angle where modulo 360 shows discontinuity, this angle is defined to be 0 at "3'oclock" and is positive going counterclockwise
%     'maxdisc',270;                 ... % maximum (absolute) discontinuity allowed in mod 360 angles before tracking for that event is flagged
%   };
%  

pairs={ ...
  'peh',[];                      ... % parsed events history
  'event_name','cpoke(end,end)'; ... % centering event name
  't0',[];                       ... % center times for parsed data, if ~empty overrides event_name
  'tlims_track',[3 6];           ... % amount of time before and after t0 to record tracking for each event
  'dt_track',0.1;                ... % width of time bins for tracking
  'tlims_spike',[3.5 6.5];       ... % amount of time before and after t0 to record spikes for each event
  'kernel_name','gauss';         ... % name of kernel to use for making psths
  'tau',0.1;                     ... % width of kernel in seconds
  'anglec',180;                  ... % critical angle where modulo 360 shows discontinuity, this angle is defined to be 0 at "3'oclock" and is positive going counterclockwise
  'maxdisc',270;                 ... % maximum (absolute) discontinuity allowed in mod 360 angles before tracking for that event is flagged
};
parseargs(varargin,pairs);

% -------- get centering times
if isempty(t0), t0=extract_event(peh,event_name); end

% -------- parse headtracking
if ~isempty(tr)
  fnames=fields(tr);
  fnames=fnames(~strcmp(fnames,'ts'));
  for k=1:numel(fnames)
    eval(['[ptr.' fnames{k} ' ptr.ts]=cdraster(t0,tr.ts,tr.' fnames{k} ...
      ',tlims_track(1,1),tlims_track(1,2),dt_track);']);
  end
  % ---- move discontinuity in theta, flag any events that show too large of a discontinuity
  ptr.theta=move_anglediscontinuity(ptr.theta,anglec);
  ptr.isdisc=any(abs(diff(ptr.theta,1,2))>maxdisc,2);
end

% -------- parse spikes
ncells=numel(spikes);
for n=1:ncells
  pspikes{n,1}=qbetween(spikes{n},t0-tlims_spike(1),t0+tlims_spike(2),t0)'; 
end

% -------- psths
psth=cell(ncells,1);
psth(:)={zeros(numel(pspikes{1}),numel(ptr.ts))};
for n=1:ncells, psth{n}=calc_psth(pspikes{n},ptr.ts+dt_track/2,kernel_name,tau); end




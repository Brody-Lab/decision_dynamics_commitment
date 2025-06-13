% ret = cpoke_reporter(obj, ratname, daterange, {'experimenter', 'Carlos'}, {'figum', []}, ...
%           {'anchor_at_start', 0}, {'doplot', 1})
%
% Runs a variety of diagnostics on a rat's behavior, focusing on its center
% poking behavior. Produces plots of day-by-day measures.  To see it in
% action, simply try something like
%   >> cpoke_reporter(SameDifferent, 'J089', -10, 'experimenter', 'Jeff');
%
% PARAMETERS:
% -----------
%
% obj     Must be a SameDifferent object. Not used at all, merely here so
%         that this m-file is a method of @SameDifferent
%
% ratname  A string, e.g., 'C062'
%
% daterange  An integer or a 1x2 vector of integers. If a single integer,
%          the daterange is assumed to go from this integer to today. If
%          two integers, the first is the startdate and the second is the
%          enddate.
%             For each integer, if it is a number of magnitude less than
%          1000, it is interpreted as days relative to today (e.g., -10
%          means ten days ago). If it is anumber greater than 1000 but less
%          than 1e6, then it is interpreted as "yymmdd", relative to the
%          year 2000 (e.g., 81203 means 2008-December-03). If it is a
%          number greater than a million, it is interpreted as "yyyymmdd"
%          (e.g., 200904012 means 2009-Apr-12).
%             See also 'anchor_at_start'' optional parameter below.
%
% RETURNS:
% --------
%
% ret, a structure that contains:
%
%   days  A vector that can serve as the x-axis for each plot, in units of
%         "days from today"
%
%   hit   Fraction of corrects on each day
%
%   nic   Mean value of nose_in_center for that day
%
%   nicsd Standard deviation of nose_in_center for that day
%
%   fsd   Mean value of fixed_stim_dur for that day
%
%   fsdsd    Standard deviation of fixed_stim_dur for that day 
%
%   cviol    Fraction of cpoke1 states that ended in violation
%
%   tpd      Length in secs of the punishment for a temporary violation on cpoke1
%
%   wriggle  Mean duration of interruptions in center pokes during cpoke1.
%            Only breaks shorter than legal_cbreak are considered, i.e.,
%            a break that terminates cpoke1 is not used here (all kinds of
%            other stuff might happen if cpoke1 ends, here we're just
%            trying to quantify small wriggles.
%
%   wrigfrac Fraction of cpoke1 states that had a break in them.
%
%   saveable Fraction of cpoke1 states that ended in violation that would
%            not have ended in violation if legal_cbreak were extended by
%            savetau secs.
%   
%   unsaveable  Fraction of cpoke1 states that could definitely *not* have
%            been saved, because there was a side poke within unsavetau
%            secs.
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
%  'doplot'    By default 1, if this is 0 no plot is produced.
%
%  'fignum'    An integer, by default empty. If passed, this figure num is
%              cleared and used for the plotting.
%
%  'anchor_at_start'  By default 0. If passed as 1, then 0 in the daterange
%              corresponds to the first day there is data for this rat in
%              SameDifferent.
%
%  'experimenter'   A string, default 'Carlos'.
%
%  'savetau'  'unsavetau'    See @SameDifferent/cpoke_diagnostics.m
%
%

function [rret] = cpoke_reporter(obj, ratname, daterange, varargin)

fignum = '';
pairs = { ...
  'experimenter'     'Carlos'   ;   ...
  'fignum'           ''         ;   ...
  'anchor_at_start'  0          ;   ...
  'doplot'           1          ;   ...
  'savetau'         0.05        ;   ...
  'unsavetau'       0.15        ;   ...
}; parseargs(varargin, pairs);

if anchor_at_start,
  [sessiondate]=bdata(['select sessiondate from sessions where ratname="' ratname ...
    '" and experimenter="' experimenter '" and protocol="SameDifferent"']);
  days_since_first_sess = floor(now - min(datenum(sessiondate)));
  
  daterange = daterange - days_since_first_sess;
end;

if length(daterange)==1
  daterange = [daterange 0];
end;

daterange = to_string_date(daterange);
date_str = ['sessiondate>="' daterange{1} '" and sessiondate<= "' daterange{2} '"'];

[sessid]=bdata(['select sessid from sessions where ratname="' ratname ...
  '" and experimenter="' experimenter '" and ' date_str]);
sess_str = sprintf('%d, ', sessid); sess_str = sess_str(1:end-2);

% Get all the sql entries to the summaries: easiest way to find hit/miss
[summaries, summary_sessids] = bdata(['select protocol_data,sessid from sessions where sessid in  (' sess_str ')']);
% Get all the sql entries to the parsed_event_history ("pevh") for each day 
[pevhs, nics, fsds, cpvs, hits, tpdurs, pev_sess_ids] = bdata(['select ProtocolsSection_parsed_events, '  ...
  'StimulusSection_nose_in_center, StimulusSection_fixed_stim_dur, RewardsSection_cpoke_violations, ' ...
  'RewardsSection_mean_hitfrac, SoundInterface_TempPunDur1, ' ...
  'p.sessid from protocol.SameDifferent as p where p.sessid in (' sess_str ')']) ;

% Make sure we only look at days that were entered into both data tables:
sessid = unique(intersect(summary_sessids, pev_sess_ids)); 
sess_str = sprintf('%d, ', sessid); sess_str = sess_str(1:end-2);
[sessid, sessiondates] = bdata(['select sessid,sessiondate from sessions where sessid in (' sess_str ')']);

daysvector       = zeros(size(sessid));
hitvector        = zeros(size(sessid));
wrigglevector    = zeros(size(sessid));
wrigfracvector   = zeros(size(sessid));
cviolvector      = zeros(size(sessid));
nicvector        = zeros(size(sessid));
nicsdvector      = zeros(size(sessid));
fsdvector        = zeros(size(sessid));
fsdsdvector      = zeros(size(sessid));
tpdvector        = zeros(size(sessid));
saveablevector   = zeros(size(sessid));
unsaveablevector = zeros(size(sessid));

for i=1:numel(sessid),
  daysvector(i) = floor(datenum(sessiondates{i})-now);

  u = find(pev_sess_ids == sessid(i));
  cviolvector(i) = cpvs(max(u))/length(u);
  hitvector(i)   = hits(max(u));
  nicvector(i)   = nanmean(nics(u));
  nicsdvector(i) = nanstd(nics(u));
  fsdvector(i)   = nanmean(fsds(u));
  fsdsdvector(i) = nanstd(fsds(u));
  tpdvector(i)   = nanmean(tpdurs(u));

  mypevhs = cell(size(u)); for j=1:length(u), mypevhs{j} = pevhs{u(j)}{1}; end;
  [isbroken, breaklen, sav, unsav] = cpoke_diagnostics(SameDifferent, mypevhs, ...
    'savetau', savetau, 'unsavetau', unsavetau);
  
  wrigglevector(i)    = nanmean(breaklen);
  wrigfracvector(i)   = nanmean(isbroken);
  saveablevector(i)   = nanmean(sav);
  unsaveablevector(i) = nanmean(unsav);
end;



%% Make the return structure if asked for
if nargout > 0,
  components = {'hit' 'nic' 'nicsd' 'fsd' 'fsdsd' 'cviol' 'tpd' 'wriggle' 'wrigfrac' 'saveable' 'unsaveable'};
  str = 'struct(''days'', daysvector';
  for i=1:length(components),
    str = sprintf('%s, ''%s'', %svector', str, components{i}, components{i});
  end;
  str = sprintf('%s);', str);

  rret = eval(str);
end;


%% Only plotting code from here
if ~doplot,
  return;
end;

if isempty(fignum),
  fignum = figure; clf; %#ok<NASGU>
else
  figure(fignum); clf;
end;
plots = {'hit' 'nic-fsd' 'cviol' 'tpd', 'wriggle', 'wrigfrac', 'sav-unsav'};
nplots = length(plots);

for i=1:nplots,
  subplot(nplots, 1, i);
  if strcmp(plots{i}, 'nic-fsd'),
    myvec1 = nicvector; mysd1 = nicsdvector;
    myvec2 = fsdvector; mysd2 = fsdsdvector;
    plot(daysvector, myvec1, 'r.-', daysvector, myvec2, 'b.-');
    l = line([daysvector' ; daysvector'], [(myvec1-mysd1)' ; (myvec1+mysd1)']);
    set(l, 'Color', [0.5 0 0]);
    l = line([daysvector' ; daysvector'], [(myvec2-mysd2)' ; (myvec2+mysd2)']);
    set(l, 'Color', 'k');
    if i~=1, title('nic (red) : fsd (blue)'); else title([ratname 'nic (red) : fsd (blue)']); end;
  elseif strcmp(plots{i}, 'sav-unsav'),
    myvec1 = unsaveablevector; 
    myvec2 = saveablevector; 
    plot(daysvector, myvec1, 'r.-', daysvector, myvec2, 'b.-');
    if i~=1, title('unsaveable (red) : saveable (blue)'); 
    else     title([ratname 'unsaveable (red) : saveable (blue)']); 
    end;
  else
    myvec = eval([plots{i} 'vector']);
    plot(daysvector, myvec, '.-');
    if i~=1, title(plots{i});
    else     title([ratname ' ' plots{i}]);
    end;
  end;
  if i<nplots, set(gca, 'XTickLabel', ''); end;
  if i==nplots, xlabel('days from today'); end;
  grid on;
  xlim([min(daysvector)-0.5, max(daysvector)+0.5]);
end;
set(gcf, 'Name', ratname);

drawnow;






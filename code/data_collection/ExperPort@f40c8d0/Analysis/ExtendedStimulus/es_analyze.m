% [a]= es_analyze(rat, experimenter, daterange, {'tau' 30}, {'fignum', []})
%
% Runs a trial-type-by-trial-type hit_history analysis on a rat in the
% ExtendedStimulus protocol. Brings up a
% new figure and displays the results of the analysis.
%
%
% EXAMPLE:
% --------
%
% >> es_analyze('Cantaloupe', 'Bing', -15);
%

function [aa]= es_analyze(rat, experimenter, daterange, varargin)

pairs = { ...
  'tau'         30  ; ...
  'fignum'      []  ; ...
  'datadir'     '../SoloData' ; ...
}; parseargs(varargin, pairs);


a = recall(rat, experimenter, {'hit_history', 'CurrentPair', 'Frequencies', 'Durations', ...
  'ThisTrial'}, 'daterange', daterange, 'protocol', 'ExtendedStimulus', 'history', 1, ...
  'default_dir', datadir);

pair_id = []; f1s = []; f2s = []; sides = []; hit_history = [];
avg = [];

day_separators = 0.5;

for i=1:size(a(:,1,1),1),
  ntrials = length(a{i,1,1});

  hit_history   = [hit_history   ; cell2mat(a{i,1,1}')];
  pair_id       = [pair_id       ; cell2mat(a{i,1,2}(end-ntrials:end-1))];

  frequs = a{i,1,3}(end-ntrials:end-1);
  newf1s = zeros(length(frequs),1); newf2s = zeros(length(frequs),1);
  if ~isempty(frequs) && isnumeric(frequs{1}),
      frequs_mat = cell2mat(frequs);
      newf1s = frequs_mat(:,1);
      newf2s = frequs_mat(:,2);
  else
      for j=1:length(frequs), 
        newfs = sscanf(frequs{j}, '[%f %f]'); newf1s(j) = newfs(1); newf2s(j) = newfs(2); 
      end;
  end;
  f1s = [f1s ; newf1s];
  f2s = [f2s ; newf2s];
  
  longsides = a{i,1,5}(end-ntrials:end-1);
  newsides  = zeros(size(longsides));
  newsides(strcmp(longsides, 'LEFT'))  = 'l';
  newsides(strcmp(longsides, 'RIGHT')) = 'r';
  sides = [sides ; newsides];
  
  day_separators = [day_separators ; length(hit_history)+0.5];
  
  guys = hit_history(end-ntrials+1:end);
  avg  = [avg ; sum(guys)/length(guys)];
end;

% trial_types = unique([f1s f2s], 'rows');
trial_types = unique(pair_id);
ntypes = size(trial_types,1);
us    = cell(ntypes,1);
perfs = cell(ntypes,1);
leg   = cell(ntypes,1);
handles = [];


% colors  = [0.2 0.2 1 ; 1 0 1 ; 1 0 0 ; 0 1 0; 0 1 1; 1 1 0; 0.5 0.5 1; 0.7 0.4 0.7]; 
    colors  = [0.2 0.2 1 ; ...
               1 0 1 ;     ...
               1 0 0 ;     ...
               0 1 0 ;     ...
               0 1 1 ;     ...
               1 1 0 ;     ...
               0.6 0.2 0.8 ; ...
               1 0.5 0;    ...
               ]; 

if isempty(fignum),  %#ok<NODEF>
  figure; fignum = gcf;
elseif ~ishandle(fignum),
  figure(fignum);
end;

ch = get(fignum, 'Children');
if ~isempty(ch), delete(ch); end;
ax = axes('Parent', fignum);

for i=1:ntypes,
  us{i} = find(pair_id==trial_types(i));
  if ~isempty(us{i}),
    if sides(us{i}(1))=='l', leg{i} = 'Left ';
    else                     leg{i} = 'Right ';
    end;
  end;
  leg{i} = [leg{i} sprintf(' (%g, %g)', mean(f1s(us{i})), mean(f2s(us{i})))];
  
  guys = hit_history(us{i}); newguys = zeros(size(guys));
  e = exp(-(0:tau*4)/tau); e = e(end:-1:1);
  for j=1:length(guys),
    mye = e(end-min(length(e), j)+1:end); mye = mye/sum(mye);
    newguys(j) = sum(guys(j-length(mye)+1:j).*mye');
  end;
  perfs{i} = newguys;
  l = plot(ax, us{i}, perfs{i}, '.-'); hold(ax, 'on'); handles = [handles;l];
  set(l, 'Color', colors(i,:));
  u = find(hit_history(us{i})==0);
  l2 = plot(ax, us{i}(u), perfs{i}(u), '.'); hold(ax, 'on');
  set(l2, 'Color', 0.6*colors(i,:));
end;

% S = msegment_finder(current_block);
% yl = ylim;
% for i=1:size(S,1),
%   if S(i,3)==1,
%     p = patch([S(i,1), S(i,2), S(i,2), S(i,1), S(i,1)], [yl(1) yl(1) yl(2) yl(2) yl(1)], ...
%       -100*ones(1,5), 0.9*[1 1 1]);
%     set(p, 'EdgeColor', 'none');
%   end;
% end;

set(ax, 'Layer', 'top');
set(vlines(ax, day_separators), 'Color', 'k');
yl = get(ax, 'Ylim');
set(ax, 'Ylim', [yl(1), 1.03]);
set(ax, 'xlim', [0 length(hit_history)*1.01]);

ntrials = diff(day_separators);
for i=1:length(ntrials),
  yl = get(ax, 'ylim'); 
  t = text(day_separators(i)+ntrials(i)/2, yl(2)+0.05*diff(yl), ...
    {sprintf('n=%d', ntrials(i)) ; sprintf('%d%%', round(avg(i)*100))}, 'Parent', ax);
  set(t, 'HorizontalAlignment', 'Center');
end;

legend(ax, handles, leg, 'Location', 'Best');
legend(ax, 'boxoff');

set(ax, 'YGrid', 'on', 'YAxisLocation', 'right');

set(fignum, 'Name', rat);

if nargout>0, aa = a; end;


% [a]= pa_analyze(rat, experimenter, daterange, {'tau', 30}, {'fignum', []}, {'usedb', 1})
%
% Runs a trial-type-by-trial-type hit_history analysis on a rat in the
% ProAnti2 protocol. Brings up a new figure and displays the results of the
% analysis.
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'tau'     By default 30, it is the trial constant of the exponential
%           smoothing kernel.
%
% 'fignum'  By default empty. If empty, a new figure is created to plot the
%           analysis. If non-empty, figure fignum is cleared, and the data
%           is plotted on that figure. Does not make fignum the current
%           figure, so can run in background.
%
% 'usedb'   Default value is 1. If usedb is 1, the pa_over_days uses the
%           MySQL database; if 0, it reads raw data files instead.
%
% EXAMPLE:
% --------
%
% >> pa_analyze('J001', 'Jeff', -15);
%


function [aa]= pm_analyze(rat, experimenter, daterange, varargin)

pairs = { ...
  'tau'        30  ; ...
  'fignum'     []  ; ...
  'protocol',  'ProAnti2'  ; ...
  'usedb',      1  ; ...
}; parseargs(varargin, pairs);

olddir=pwd;
ddir=bSettings('get','GENERAL', 'Main_Code_Directory');
cd(ddir)

if ~usedb,
  a = recall(rat, experimenter, {...
    'pro_trial', ...
    '', ...
    'goodPoke3', ...
    'current_block', ...
    'gotit_history',...
    'hit_history'}, ...
    'daterange', daterange, 'protocol', protocol, 'history', 1);
else
  % this just uses mysql's built in date/time arithmetic instead of doing it in matlab.
  startdate=bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);

  
  [pd]=bdata(['select protocol_data from bdata.sessions where ratname="' rat '" and sessiondate>="' startdate{1} '" and protocol like "ProAnti%" order by sessiondate']);
  
  % Translate db-obtained data into what it would look like when read from
  % raw data files:
  a = cell(length(pd), 1, 5);
  for i=1:length(pd),
    a{i,1,1} = num2cell([pd{i}.context(:); 0]);  % Pad it with dummy final value to match raw data files
    a{i,1,2} = num2cell([pd{i}.sides(:)  ; 0]);  % Pad it with dummy final value to match raw data files
    a{i,1,3} = num2cell([pd{i}.blocks(:) ; 0]);  % Pad it with dummy final value to match raw data files
    a{i,1,4} = num2cell(pd{i}.gotit(:)')      ;
    a{i,1,5} = num2cell(pd{i}.hit(:)')        ;
  end;  

end;

cd(olddir);

pro_trial     = [];
goodPoke3     = [];
gotit_history = [];
current_block = [];
hit_history   = [];
avg           = [];
savg          = [];
lavg          = [];
vavg          = [];
iavg          = [];

day_separators = 0.5;

for i=1:size(a(:,1,1),1),
  ntrials = length(a{i,1,4});

  pro_trial      = [pro_trial     ; cell2mat(a{i,1,1}(end-ntrials:end-1))]; %#ok<AGROW>
  goodPoke3      = [goodPoke3     ; cell2mat(a{i,1,2}(end-ntrials:end-1))]; %#ok<AGROW>
  current_block  = [current_block ; cell2mat(a{i,1,3}(end-ntrials:end-1))]; %#ok<AGROW>
  gotit_history  = [gotit_history ; cell2mat(a{i,1,4}')];                   %#ok<AGROW>
  hit_history    = [hit_history   ; cell2mat(a{i,1,5}')];                   %#ok<AGROW>

  day_separators = [day_separators ; length(hit_history)+0.5];              %#ok<AGROW>

  nonnan = find(~isnan(hit_history(end-ntrials+1:end)));
  good   = gotit_history(end-ntrials+1:end);
  avg    = [avg ; sum(good(nonnan))/length(nonnan)];                        %#ok<AGROW>
  lmark  = bitget(current_block, 1);
  vmark  = bitget(current_block, 2);

  sact = nonnan(lmark(nonnan) ==-1);
  lact = nonnan(lmark(nonnan) == 1);
  vact = nonnan(vmark(nonnan) == 1);
  iact = nonnan(vmark(nonnan) ==-1);
  
  savg = [savg  ; sum(good(sact))/length(sact)];                            %#ok<AGROW>
  lavg = [lavg  ; sum(good(lact))/length(lact)];                            %#ok<AGROW>
  vavg = [vavg  ; sum(good(vact))/length(vact)];                            %#ok<AGROW>
  iavg = [iavg  ; sum(good(iact))/length(iact)];                            %#ok<AGROW>
  
end;

trial_types = unique([bitget(current_block,1) bitget(current_block,2) bitget(current_block,3) goodPoke3 ], 'rows');
ntypes  = size(trial_types,1);
thiskind = cell(ntypes,1);
perfs    = cell(ntypes,1);
leg      = cell(ntypes,1);
handles  = [];

colors  = [0 0 1 ; 1 0 1 ; 1 0 0 ; 0 1 0; 1 1 0; 0 1 1; 0 0 0; 0.5 0.5 0.5]; 

if isempty(fignum),                                                         %#ok<NODEF>
  figure; fignum = gcf;
end;
if ~ishandle(fignum), 
  figure(fignum); 
end;

ch = get(fignum, 'Children');
if ~isempty(ch), delete(ch); end;
ax = axes('Parent', fignum);

for i=1:ntypes,
  if trial_types(i,1)== 1, leg{i} = 'Light ';            else leg{i} = 'Sound ';            end;
  if trial_types(i,2)== 1, leg{i} = [leg{i} 'Valid '];   else leg{i} = [leg{i} 'Invalid ']; end;
  if trial_types(i,3)== 1, leg{i} = [leg{i} 'No Info ']; else leg{i} = leg{i};              end;
  if trial_types(i,4)== 1, leg{i} = [leg{i} 'Right'];    else leg{i} = [leg{i} 'Left'];     end;

  itypetrials = find(bitget(current_block,1)==trial_types(i,1) & ...
                     bitget(current_block,2)==trial_types(i,2) & ...
                     bitget(current_block,3)==trial_types(i,3) & ...
                     goodPoke3 == trial_types(i,2)             & ...
                     ~isnan(hit_history));   %#ok<AGROW>
 
  thiskind{i} = itypetrials;
  
  gots = gotit_history(thiskind{i}); newgots = zeros(size(gots));
  
  e = exp(-(0:tau*4)/tau); e = e(end:-1:1);
  
  for j=1:length(gots),
    mye = e(end-min(length(e), j)+1:end); mye = mye/sum(mye);
    newgots(j) = sum(gots(j-length(mye)+1:j).*mye');
  end;

  perfs{i} = newgots;

  l = plot(ax, thiskind{i}, perfs{i}, '.-'); hold(ax, 'on'); handles = [handles;l]; %#ok<AGROW>
  set(l, 'Color', colors(i,:));
  tries = find(gotit_history(thiskind{i})==0);
  l2 = plot(ax, thiskind{i}(tries), perfs{i}(tries), '.'); hold(ax, 'on');
  set(l2, 'Color', 0.6*colors(i,:));
end;

yl = get(ax, 'ylim'); set(ax, 'ylim', [yl(1) 1.03]);
xl = get(ax, 'xlim'); set(ax, 'xlim', [0 length(hit_history)*1.01]);        %#ok<NASGU>

S = msegment_finder(current_block);
yl = get(ax, 'ylim');
for i=1:size(S,1),
  if S(i,3)==1,
    p = patch([S(i,1), S(i,2), S(i,2), S(i,1), S(i,1)], [yl(1) yl(1) yl(2) yl(2) yl(1)], ...
      -100*ones(1,5), 0.9*[1 1 1], 'Parent', ax);
    set(p, 'EdgeColor', 'none');
  end;
end;

set(ax, 'Layer', 'top');
set(vlines(ax, day_separators), 'Color', 'k');

ntrials = diff(day_separators);
for i=1:length(ntrials),
  yl = ylim(ax); 
  t = text(day_separators(i)+ntrials(i)/2, yl(2)+0.05*diff(yl), ...
    {sprintf('n=%d', ntrials(i)) ; sprintf('%d%% [%d %d]', round(avg(i)*100), ...
    round(vavg(i)*100), round(iavg(i)*100))}, 'Parent', ax);
  set(t, 'HorizontalAlignment', 'Center');
end;

legend(ax, handles, leg, 'Location', 'Best');
legend(ax, 'boxoff');
set(ax, 'YAxisLocation', 'right', 'YGrid', 'on')

set(fignum, 'Name', rat);

if nargout>0, aa = a; end;


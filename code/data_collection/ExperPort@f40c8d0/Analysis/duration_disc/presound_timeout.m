function [] = presound_timeout(rat, task, date, varargin)
  
  % Shows poke interaction as a function of presound time.
  % Increasing pre-sound time leads to an increase in timeout rate; the
  % timeout (premature withdrawal) rate is an indicator of the ability of
  % the animal to associate the GO signal with the permission to withdraw
  % from the center poke. 
  % This tool shows three measures of interaction as a function of
  % presound time change:
  % 1. Timeout rate -- how many timeouts in a trial?
  % 2. Timeout duration -- total time spent in timeout state; is a
  % measure of association of timeout sound and abstention from poking
  % 3. Start time -- how long from start of trial till Cin? Measure of
  % animal's satiation and/or frustration with increasingly demanding task.
  
  pairs = { ...
      'presound', 1; ...
      };
  parse_knownargs(varargin, pairs);

load_datafile(rat, task, date);

rts = eval(['saved_history.' task '_RealTimeStates']);
evs = eval(['saved_history.' task '_LastTrialEvents']);

if length(rts) > length(evs), rts = rts(1:end-1); end;
if length(rts) ~= length(evs), error('RTS and EVS must match dimensions!'); ...
      end;
  
p = parse_trial(evs, rts);

if presound > 0
pst = cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
pst_idx = find(diff(pst) ~= 0); pst_changes = pst(pst_idx+1);
end;

% Making timeout arrays

to_count = zeros(1,rows(p)); to_length = zeros(1,rows(p)); cpoke_length = ...
    zeros(1,rows(p));
for k = 1:rows(p)
  to_count(k) = rows(p{k}.timeout);
  if to_count(k) > 0,
    to_length(k) = sum(p{k}.timeout(:,2)-p{k}.timeout(:,1));
  end;
  
  cpoke_length(k) = mean(p{k}.wait_for_cpoke(:,2)-p{k}.wait_for_cpoke(:,1));
end;

% rate of TO counts (15-trial lookback window)
% avg. of TO duration (15-trial lookback window)
lb = 15;
 to_ct_rate = zeros(1,rows(p)-lb); to_dur_rate = zeros(1,rows(p)-lb);
 cpoke_rate = zeros(1,rows(p)-lb);
for k = 16:length(to_count)+1
  to_ct_rate(k-lb) = mean(to_count(k-lb:k-1));
  to_dur_rate(k-lb) = mean(to_length(k-lb:k-1));
  cpoke_rate(k-lb) = mean(cpoke_length(k-lb:k-1));
end;
 

% %%%%%%%%%%%%%%%%%%%%%
% Plotting begins here
% %%%%%%%%%%%%%%%%%%%%%%

 basetitle = sprintf('%s: %s: %s\n', make_title(rat), make_title(task), date);
figure;
set(gcf,'Menubar','none', 'Toolbar','none', 'Position', [100 100 1100 ...
                    400]);

% Timeout rate
subplot(2,2,1);
plot(1:length(to_ct_rate), to_ct_rate, '-r');
if presound > 0
  hold on;
  for c = 1:length(pst_changes)
    line([pst_idx(c)+1 pst_idx(c)+1], [0 max(to_ct_rate)], 'LineStyle', ...
         ':');
   t = text(pst_idx(c)-5, 0.3, sprintf('%1.2f', pst_changes(c)), 'FontSize', ...
            12);
  end;
end;
title([basetitle 'Timeout Rate (Lookback 15 trials)']);
xlabel('Trials'); ylabel('# Timeouts -- Avg. 15 trials');
set(gca,'XLim', [1 rows(p)], 'YLim', [0 max(2, max(to_ct_rate))]);

% Timeout Duration
subplot(2,2,2);
plot(1:length(to_dur_rate), to_dur_rate, '-b');
if presound > 0
  hold on;
  for c = 1:length(pst_changes)
    line([pst_idx(c)+1 pst_idx(c)+1], [0 max(to_dur_rate)], 'LineStyle', ...
         ':');
    t = text(pst_idx(c)-5, 1, sprintf('%1.2f', pst_changes(c)), 'FontSize', 12);
  end;
end;
title([basetitle 'Avg. total Timeout Duration (Lookback 15 trials)']);
xlabel('Trials'); ylabel('Total time spent in Timeout (s) -- Avg. 15 trials');

% Wait for cpoke rate
subplot(2,2,3);
plot(1:length(cpoke_rate), cpoke_rate, '-g');
if presound > 0
  hold on;
  for c = 1:length(pst_changes)
    line([pst_idx(c)+1 pst_idx(c)+1], [0 max(to_dur_rate)], 'LineStyle', ...
         ':');
    t = text(pst_idx(c)-5, 1, sprintf('%1.2f', pst_changes(c)), 'FontSize', 12);
  end;
end;
title([basetitle 'Avg. Duration of Lag till first Cin (Lookback 15 trials)']);
xlabel('Trials'); ylabel(' Time (s) -- Avg. 15 trials');

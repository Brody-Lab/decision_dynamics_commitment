function [] = plot_logdiff_perf(rat, task, date, varargin)

pairs = { ...
  'multiday', 0 ; ...
   'nofig', 0 ; ...
  'fsize', 12; ...
  'fwt', 'bold' ; ...
   'bout_size', 20 ; ...
  'dur_logdiff_max', 1 ; ...
  'dur_logdiff_min', 0.2 ; ...
  'pitch_logdiff_max', 4 ; ...
  'pitch_logdiff_min', 0.5 ; ...
    };
parse_knownargs(varargin, pairs);
  
if ~strcmpi(computer,'MAC'), fsize = 9; end;
if strcmp(task(1:3), 'dur'), 
    logdiff_min = dur_logdiff_min; logdiff_max = dur_logdiff_max;
elseif strcmp(task(1:3), 'dua'),
    logdiff_min = pitch_logdiff_min; logdiff_max = pitch_logdiff_max;
end;

  if ~multiday & (nofig < 1), figure;end;
  hit_rates(rat, task, date, 'multiday', multiday, 'show_to_zero', 1);
  load_datafile(rat, date);
   
  logdiff = saved_history.ChordSection_logdiff;
  logdiff = cell2mat(logdiff);
  
  blah = find(diff(logdiff) ~= 0 );
  changes = logdiff(blah+1);
  
  hold on;
  for k = 1:length(changes)
   line([blah(k)+1 blah(k)+1], [0 1], 'LineStyle', ':');

   % logdiff value is plotted on a scaled mini-axis that occupies 0-50% of
   % the y-axis.
   y_pos = 0.5 * ((changes(k)-logdiff_min)/(logdiff_max - logdiff_min));
   t = text(blah(k)-5, y_pos, sprintf('%1.2f', changes(k)), 'FontSize', fsize);
   if k > 1,
     if changes(k) - changes(k-1) < 0, 
       set(t, 'Color', [0 0.2 0], 'FontWeight', fwt);
     else
       set(t, 'Color', [0.2 0 0], 'FontWeight', fwt);
     end;
     
     text(blah(k)+3, 0.95, sprintf('%1.1f',changes(k)), 'Color', [0 0 0.5], 'FontWeight','bold');
     text((blah(k)+blah(k-1))/2, 0.55, sprintf('%i', blah(k)-blah(k-1)), ...
          'FontWeight', 'bold', 'FontSize', fsize);
   else
       set(text, 'Position', [blah(k)-5, 0.35 0]);
    end;
  end;
  
if ~multiday,  set(gcf,'Menubar','none','Toolbar', 'none');end;
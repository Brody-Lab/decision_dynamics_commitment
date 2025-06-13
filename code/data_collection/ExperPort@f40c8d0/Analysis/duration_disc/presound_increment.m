function  [] = presound_increment(rat, task, date, varargin);
  
  % Shows the parameter values of minimum and maximum pre-sound time as a
  % function of session progress
  % Used to validate and perhaps debug the type of automated increment desired.
  
    pairs = { ...
        'newfig', 1; ...% plot on new figure?
        'from', 1; ...  % from which trial to start plotting; used to
                        % align with plots that use lookahead sliding
                        % windows to measure averages
        };
    
    parse_knownargs(varargin, pairs);
    
  load_datafile(rat, task, date);
  
  minvpd = cell2mat(saved_history.VpdsSection_MinValidPokeDur);
  maxvpd = cell2mat(saved_history.VpdsSection_MaxValidPokeDur);
  

  if newfig > 1, figure; set(gcf,'Menubar','none','Toolbar','none'); end;
  
  plot(from:length(minvpd), minvpd(from:end), '-r', from:length(maxvpd), maxvpd(from:end), '.b');
  legend('MinPST', 'MaxPST');
  set(gca,'XLim', [from length(minvpd)]);
  
  s = sprintf('%s: %s (%s)\n', make_title(rat), make_title(task), date);
  title([s 'Automated increment of pre-sound time']);
  xlabel('Trials'); ylabel('Pre-sound time (s)');
  
  
function [output_txt] = show_numtrials(rat, task, varargin)
  
    pairs =  { ...
      'from', '000000'; ...
      'to', '999999';  ...
      'action', 'init'; ... 
      'showpsych', 1  ; ...
    };
     parse_knownargs(varargin, pairs);
     
     persistent dates;
     persistent numt;     % records # trials in sessions
     persistent secs;     % records duration (in seconds) of sessions
     persistent avg_wait; % records average duration of wait_for_cpoke
                          % state (motivation)
     persistent numpsych; % # psychometric samplings in the session
     
     switch action
       case 'init'
     
     
      dates = get_files(rat, 'fromdate', from, 'todate', to);
      
      numt = []; secs = []; avg_wait=[]; numpsych = [];
      for d = 1:rows(dates)
        load_datafile(rat, task, dates{d});
        % get number of trials
        numt = [numt eval(['saved.' task '_n_done_trials'])];
        % get duration of session
         evs = eval(['saved_history.' task '_LastTrialEvents']);
        efirst = evs{1}; elast = evs{end};
        efirst = efirst(1,3); elast = elast(end,3); % start and end of
                                                    % session
        secs = [secs elast-efirst];
        % get average duration of wait_for_cpoke state -- indicator of
        % motivation -- NOTE: using only first wait_for_cpoke per trial
        cpoke = 0;
        rts = eval(['saved_history.' task '_RealTimeStates;']);
        pstruct = parse_trial(evs, rts(1:end-1));
        for e = 1:rows(pstruct),          
          cpoke = [cpoke pstruct{e}.wait_for_cpoke(1,2)-pstruct{e}.wait_for_cpoke(1,1)];
        end;  
        avg_wait = [avg_wait mean(cpoke)];
        
        % get number of trials with psychometric sampling
        if strcmpi(task(1:3), 'dur')
          psych_on = cell2mat(saved_history.ChordSection_psych_on);
        else          
        psych_on = cell2mat(saved_history.ChordSection_pitch_psych);
        end;
        numpsych = [ numpsych sum(psych_on(2:end)) ]; 
        
      end;
      
      %%%%%%%%%%
      % Now plot
      %%%%%%%%%%
      figure;
      set(gcf,'Menubar','none','Toolbar','none');
      set(gcf,'Position', [360   506   763   364]);
      
      % Plot 1: # trials
      subplot(2,1,1);
      plot(1:length(numt), numt, '.r', 'MarkerSize', 24);
      
      s = sprintf('%s: # trials in a session\n (%s to %s)', rat, from, ...
                  to);
      title(s);
      
      line([1 length(dates)], [100 100], 'LineStyle', ':', 'Color', 'k');
      line([1 length(dates)], [200 200], 'Linestyle', ':', 'Color', [0.8 ...
                          0.8 0.8]);
      datacursormode on;
  dcm_obj = datacursormode(gcf);
  set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
  set(dcm_obj, 'Updatefcn', {@show_numtrials,'action', 'update'})  
  
      if showpsych>0
        hold on; 
        plot(1:length(numpsych), numpsych, '.k', 'MarkerSize', 14);
        end; 
  
      % Plot 2: Duration of session
      subplot(2,1,2);
      plot(1:length(secs), secs, '.b', 'MarkerSize', 18);
      
      s = sprintf('%s: Duration of sessions\n (%s to %s)', rat, from, ...
                  to);
      title(s);
      
      hour = 60*60;

      line([1 length(dates)], [hour hour], 'LineStyle', ':', 'Color', 'k');
      line([1 length(dates)], [2*hour 2*hour], 'Linestyle', ':', 'Color', [0.8 ...
                          0.8 0.8]);
      
      set(gca, 'YTick', 0.5*hour:0.5*hour:4*hour, ...
               'YTickLabel', {'1/2', '1hr', '1.5' '2hr', '2.5', '3hr', ...
                          '3.5', '4hr'});
      xlabel('Session #');
      ylabel('Session duration (hrs)');
      
      set(gcf,'Name',sprintf('%s: Session parameters', rat));
 
  output_txt = 1;
 
  
      case 'update',
     evt_obj = task;
     pos = get(evt_obj, 'Position'); 
     
     d = datestr(datenum(dates{pos(1)}, 'yymmdd'), 'dd-mmm-yyyy');
     output_txt = sprintf(['%s: %i trials  in %1.1f hours\n' ...
     'lag = %2.1fs'], d, numt(pos(1)), ...
                          secs(pos(1))/3600, avg_wait(pos(1)));  
     
       
      otherwise
       error('Unknown action');
     end;
     
  
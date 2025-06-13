function [out1, out2, out3] = rxn_time_by_side(rat, task, varargin)
  
  % For a specified range of dates, this script shows the mean reaction
  % time for LHS and RHS trials as two distinct plots. The reaction time
  % is defined as the time (ms) between a center withdrawal and a side
  % poke. Only withdrawals for legal pokes are considered. Correct trials
  % have not been separated from incorrect trials.
    
    % output args are:
      % 1: out1: can be used to set datacursor text or return the
      % difference between mean reaction times for LHS and RHS trials
      
      % 2: out2: mean bias / session
      % 3: out3: mean center poke length (valid pokes only) / session
  
  pairs = { ...
      'from', '000000'; ...
      'to',  '999999'; ... 
      'no_plot', 0   ; ...
      'save_me', 0 ; ...
      'action', 'plot_me'};
  parse_knownargs(varargin, pairs);
  
  persistent dates;
  
  switch action
    
    case 'plot_me', 
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  ddir = Shraddha_filepath(rat, 'd');
  
  % currently plots average reaction times for the left and right trials
  % across different days.
  rl = []; rr = []; bs= []; clen = [];
  for k  = 1:length(dates)
    [rleft, rright, b, c] = rxn_time(rat, task, dates{k});
    rl = [rl rleft]; rr = [rr rright]; bs = [bs b]; clen = [clen; c];
  end;
  
  if no_plot < 1
  figure; 
  set(gcf,'Position', [200 200 500 600], 'Menubar','none','Toolbar', ...
          'none');
  subplot(2,1,1);
  k = plot(1:length(rl), rl*1000, '.b'); set(k, 'Tag', 'leftie');hold on;
  k = plot(1:length(rr), rr*1000, '.r'); set(k, 'Tag', 'rightie');
  xlabel('Session #');
  ylabel('Reaction time (milliseconds)'); 
  s = sprintf('%s: %s (%s)\nMean reaction time categorised by trial side', ...
          make_title(rat), make_title(task), date);
  title(s);
  
  subplot(2,1,2);
  k = plot(1:length(bs), bs, '.k'); set(k, 'Tag', 'bias');
  xlabel('Session #');
  ylabel('Session-wide bias (LHS hitrate - RHS hitrate)');
   s = sprintf('%s: %s (%s)\nSession-wide bias', ...
          make_title(rat), make_title(task), date);
  title(s);
    
  datacursormode on;
  dcm_obj = datacursormode(gcf);
set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
set(dcm_obj, 'Updatefcn', {@rxn_time_by_side, 'action', 'update_me'});
end;
out1 = rl - rr;
out2 = bs;
out3 = clen;

if save_me > 0
  
  ddir = Shraddha_filepath(rat, 'd'); fname = ['rxn_time_by_side_' from '_' to ...
                      '.mat'];
 ['Saving to ' ddir fname '\n']
  eval(['save ' ddir fname ' dates out1 out2 out3;']);  
  end;

   case 'update_me'
    evt_obj = task;
    caller = get(evt_obj, 'Target');
    pos = get(evt_obj, 'Position');
    
    switch get(caller,'Tag')
     case 'leftie',out1 = sprintf('%s: Leftie', dates{pos(1)});
     case 'rightie',out1 = sprintf('%s: Rightie', dates{pos(1)});
     case 'bias', out1 = sprintf('%s: Bias', dates{pos(1)});
     otherwise, out1t = 'No idea who you are';
    end;
    
  
   otherwise
    error(['Invalid action; only possible two actions are ''plot_me'' and ' ...
         '''update_me''. ']);  
  end;
  
  out2 = bs;
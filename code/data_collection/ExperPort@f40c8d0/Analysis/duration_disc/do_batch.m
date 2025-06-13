function [output_txt] = rxn_times_by_side(rat, task, varargin)
  
  % For a specified range of dates, this script shows the mean reaction
  % time for LHS and RHS trials as two distinct plots. The reaction time
  % is defined as the time (ms) between a center withdrawal and a side
  % poke. Only withdrawals for legal pokes are considered. Correct trials
  % have not been separated from incorrect trials.
  % 
    
  pairs = { ...
      'from', '000000'; ...
      'to',  '999999'; ... 
      'action', 'plot_me'};
  parse_knownargs(varargin, pairs);
  
  persistent dates;
  
  switch action
    
    case 'plot_me', 
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  ddir = Shraddha_filepath(rat, 'd');
  
  % currently plots average reaction times for the left and right trials
  % across different days.
  rl = []; rr = [];
  for k  = 1:length(dates)
    [rleft, rright] = rxn_time(rat, task, dates{k});
    rl = [rl rleft]; rr = [rr rright];
  end;
  
  figure; 
  set(gcf,'Position', [200 200 500 300], 'Menubar','none','Toolbar','none');
  k = plot(1:length(rl), rl*1000, '.b'); set(k, 'Tag', 'leftie');hold on;
  k = plot(1:length(rr), rr*1000, '.r'); set(k, 'Tag', 'rightie');
  xlabel('Session #');
  ylabel('Reaction time (milliseconds)'); 
  s = sprintf('%s: %s (%s)\nMean reaction time categorised by trial side', ...
          make_title(rat), make_title(task), date);
  title(s);
    
  datacursormode on;
  dcm_obj = datacursormode(gcf);
set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
set(dcm_obj, 'Updatefcn', {@do_batch, 'action', 'update_me'});

   case 'update_me'
    evt_obj = task;
    caller = get(evt_obj, 'Target');
    pos = get(evt_obj, 'Position');
    
    if strcmp(get(caller,'Tag'), 'leftie'),       
    output_txt = sprintf('%s: Leftie', dates{pos(1)});
    elseif strcmp(get(caller,'Tag'), 'rightie'),
      output_txt = sprintf('%s: Rightie', dates{pos(1)});
    else
      output_txt = 'No idea who you are';
    end;
    
   otherwise
    error(['Invalid action; only possible two actions are ''plot_me'' and ' ...
         '''update_me''. ']);  
    end;
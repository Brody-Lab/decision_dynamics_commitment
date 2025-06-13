function [output_txt] = session_stims(rat, task, varargin)
  % function [output_txt] = session_stims(rat, task, varargin)
  % Shows a graph of all unique stimulus pairs encountered in a given
  % session -- it is intended to be seen for a large number of sessions
  % to answer questions like
  % - Has this rat ever been at one octave?
  % - Is he more frequently at 1.4 octaves two weeks after training?
   
      
   pairs =  { ...
      'from', '000000'; ...
      'to', '999999';  ...
       'showgood', 1; ...  % indicates pairs with good hit rate and bias
                           % < max_bias
       'good_hrate', 0.8 ; ...
       'max_bias', 0.5 ; ...
       'valid_set', 20 ; ... % threshold # trials/logdiff to validate its use
       'pitch_xlabel', 'Octave Separation' ; ...
       'duration_xlabel', 'Log-distance' ; ...
       'action', 'init' ; ...
       'output_txt', 1;  ...
   };
  parse_knownargs(varargin, pairs);
  
  persistent dates;  
   
  switch action,
  case 'init',
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  
  master_ld = [];  % keeps all unique stimulus pairs ever seen
  session_lds = {};
  
  for d = 1:rows(dates)
    load_datafile(rat, task, dates{d});
    ld = cell2mat(saved_history.ChordSection_logdiff); ld = ld(2:end);
    leftrew = saved.RewardsSection_LeftRewards;
    rightrew = saved.RewardsSection_RightRewards;
    sides = saved.SidesSection_side_list;
    u = unique(ld)';
    newones = setdiff(u, master_ld); master_ld = [master_ld newones];
    session_lds{d,1} = u;
    session_lds{d,2} = get_good(u, ld, leftrew, rightrew, sides, good_hrate, ...
                                   max_bias, valid_set);
    2;
  end;
  
  master_ld = sort(master_ld);
  master_matrix = zeros(rows(d), length(master_ld));
  master_good = zeros(rows(d), length(master_ld));
  
  for d = 1:rows(dates)
    master_matrix(d,:) = ismember(master_ld, session_lds{d,1});
    goodie = session_lds{d,1} .* session_lds{d,2}; 
    master_good(d,:) = ismember(master_ld, goodie); 
  end; 
  
  master_matrix = master_matrix + master_good;
 % master_matrix = [ master_matrix ; master_ld ]; 
  
  figure;
  set(gcf,'Menubar','none','Toolbar','none', 'Position', [100 100 400 500]);
  
  for k = 1:rows(master_matrix)
    curr = master_matrix(k,:); present = find(curr == 1);
    if ~isempty(present), 
    plot(present, (rows(dates)-k)+1, '.r', 'MarkerSize', 20);
    end;
    
    good = find(curr == 2);
    hold on;
    if ~isempty(good),
    plot(good, (rows(dates)-k)+1, '.g', 'MarkerSize', 20);
    end;
    
  end;

  xlbl = pitch_xlabel;
  if strcmpi(task(1:3), 'dur'), xlbl = duration_xlabel; end;

  xlabel(xlbl);
  ylabel('Session #');
  set(gca, 'XLim', [0 length(master_ld)+1], 'YLim', [0 rows(dates)+1], ...
           'XTick', 1:length(master_ld), 'XTickLabel', num2cell(master_ld), ...
           'YTick', 1:rows(dates), 'YTickLabel', rows(dates):-1:1, ...
           'Position', [0.1 0.15 0.8 0.75]);
  
  
  
  s = sprintf('%s (%s to %s):\nStimulus pairs encountered in a given session', ...
  rat, from, to);
  title(s);
  
   uicontrol(gcf, 'Style','text','Position', [10 15 250 30], ...
            'String', sprintf(['Green dots indicate hit rate > %2.0f%% & ' ...
                       'bias < %2.0f%%\nAny logdiff set < %i trials is marked red by default'], good_hrate*100, max_bias*100, valid_set), ...
            'FontAngle', 'italic', 'Background', [1 1 0.8]);
   
   set(gcf,'Name', sprintf('%s: Stimulus pairs',rat));
   
   
 datacursormode on;
  dcm_obj = datacursormode(gcf);
  set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
  set(dcm_obj, 'Updatefcn', {@session_stims,'action', 'show'})  
   
   case 'show',
    evt_obj = task;
     pos = get(evt_obj, 'Position'); 
  %   fprintf(1, 'Position is %i, %i', pos);
     pos = (rows(dates)-pos(2))+1;
     
     output_txt = [datestr(datenum(dates{pos}, 'yymmdd'), 'dd-mmm-yyyy') ...
                   '(' datestr(datenum(dates{pos}, 'yymmdd'), 'ddd') ')'];
     
     
   otherwise
    error('Unknown action');
    end;
  
return;    

% Returns a metric that determines whether the datapoint is printed in
% green or red.
% Returns one such metric per logdiff level by looking at the hitrate
% and bias level for trials with that log difference.
%
function [good] =  get_good(unq, ld, lrew, rrew, sidelist, ghrate, max_bias, ...
                                 vset)
  good = zeros(size(unq));
  for k = 1:length(unq)
     % Use only those trials containing our stimpair of choice
    idx = find(ld == unq(k));
    if ~isempty(idx)
      if length(idx) < vset, good(k) = 0;
      else  
        % Measure: left hit rate and right hit rate
        if sum(sidelist(idx)) == 0 | length(find(sidelist(idx)==0)) == 0
          good(k) = 0;
        else
          lrate = sum(lrew(idx))/sum(sidelist(idx));     
          rrate = sum(rrew(idx))/length(find(sidelist(idx) == 0));
      
          if abs(lrate-rrate) < max_bias, bias = 0; else bias=1; end;
      
          hrate = (sum(lrew(idx))+sum(rrew(idx)))/length(idx);
          if hrate > ghrate & bias == 0, good(k) = 1;end; % 'good' stimpair
        end;
      end;; 
    end;   
    
  end;
return;
  

  
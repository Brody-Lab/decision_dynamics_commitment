function [output_txt] = biasview(rat, task, varargin)
  
  % Indicates leftward/rightward bias for first and second half of session
  % for a multitude of sessions.
    
  pairs = { ...
      'from', '000000' ; ...
      'to', '999999'; ...
      'action', 'init' ; ...
      'min4bias', 0.2 ; ...
      'max4bias', 0.5 ; ...
      };
  parse_knownargs(varargin, pairs);

  persistent dates;
  
  
  switch action
    case 'init'
  dates = get_files(rat, 'fromdate', from, 'todate', to);
     
  lrates = []; % row - session #; columns: two, one for each half of the session
  rrates = [];
  lprobs = []; % row - session #; columns: left probability for each half
               % of session
  for d = 1:rows(dates)
     load_datafile(rat, task, dates{d});
     
     leftrew = saved.RewardsSection_LeftRewards;
     rightrew = saved.RewardsSection_RightRewards;
     sides = saved.SidesSection_side_list;     
     leftprob = cell2mat(saved_history.SidesSection_LeftProb);
     nt = eval(['saved.' task '_n_done_trials']);
     
     % first third
     idx = 1:floor(nt/3);
     lt = sum(sides(idx));
     rt = floor(nt/3)-lt;
     
     lrates(d,1) = sum(leftrew(idx))/lt;
     rrates(d,1) = sum(rightrew(idx))/rt;
     lprobs(d,1) = mean(leftprob(idx));
     
    % second third
    if mod(nt,3) > 0 
      idx = ceil(nt/3):floor(nt *(2/3));
    else
      idx = (nt/3)+1:(nt*(2/3));
    end; 
    lt = sum(sides(idx));
    rt = length(idx)-lt;
    
    lrates(d,2) = sum(leftrew(idx))/lt;
    rrates(d,2) = sum(rightrew(idx))/rt;
    lprobs(d,2) = mean(leftprob(idx));
  
    % last third
    if mod(nt,3) > 0 
      idx = ceil(nt *(2/3)):nt;
    else
      idx = (nt*(2/3))+1:nt;
    end; 
     lt = sum(sides(idx));
    rt = length(idx)-lt;
    
    lrates(d,3) = sum(leftrew(idx))/lt;
    rrates(d,3) = sum(rightrew(idx))/rt;
    lprobs(d,3) = mean(leftprob(idx));
    
    
  end;
  
  bias = abs(lrates - rrates);
  
 
  
  %%%%%%%%%%%
  % Now plot
  % %%%%%%%%%
  
  % Different bias levels are assigned different colours
  % Black: 0 - 20%
  % Orange: 20 - 50% 
  % Red: > 50%
  figure;
  set(gcf,'Menubar','none','Toolbar','none', 'Position', [360   138   341 ...
                      550], 'Name', sprintf('%s: Multi-session bias view', ...
                                            rat));
 
  % lower range
  for  col = 1:3   
  idx = find(bias(:,col) < min4bias);   pos = (rows(dates)-idx)+1;
  plot(col .* ones(length(pos),1), pos, '.k', 'MarkerSize', 18);
  hold on;
  end;
  
  % mid-range
  for col = 1:3
  idx = find(bias(:,col) >= min4bias & bias(:,col) < max4bias); pos = (rows(dates)-idx)+1;
  l = plot(col .* ones(length(pos),1), pos, '.r', 'MarkerSize', 18); set(l, ...
                                                    'Color', [1 0.7 0]);
  end;
  
  % upper 
  for col=1:3
  idx = find(bias(:,col) >= max4bias);  pos = (rows(dates)-idx)+1;
  l= plot(col .* ones(length(pos),1), pos, '.r', 'MarkerSize', 18);
  end;
  
  set(gca, 'XLim', [0 4], 'YLim', [0 rows(dates)+1], 'XTick', 0:1:4);
  
  s = sprintf('%s: Bias for each third of session\n(%s to %s)', rat, from, ...
              to);
  title(s);
  
  datacursormode on;
  dcm_obj = datacursormode(gcf);
  set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
  set(dcm_obj, 'Updatefcn', {@biasview,'action', 'update'})  
  
  uicontrol(gcf, 'Style','text', 'BackgroundColor', [1 1 0], 'String', ...
            'Black: <20% bias, Red: 20-49%bias, Blue: >=50%bias', 'Position', ...
            [10 10 200 30]);
  
  
  tempo = dates;
  for k = 1:rows(dates)
    tempo{k, 2} = bias(k,:)
    end;
  
% $$$   % Plot LeftProbability
% $$$   figure;
% $$$   set(gcf,'Menubar','none','Toolbar','none', 'Position', [860   138   341   550]);
% $$$   
% $$$   curr = lprobs(:,1);  
% $$$   for k = 1:length(curr)
% $$$     pos = (rows(dates)-k)+1;
% $$$     l = plot(1, pos, '.k','MarkerSize', 24);
% $$$     hold on;
% $$$     set(l, 'Color', [1 1 0] .* curr(k));
% $$$   end;
% $$$   
% $$$   curr = lprobs(:,2);
% $$$   for k = 1:length(curr)
% $$$     pos = (rows(dates)-k)+1;
% $$$     l = plot(2, pos, '.k','MarkerSize', 24);
% $$$     set(l, 'Color', [1 0 1] .* curr(k));
% $$$   end;
% $$$  
% $$$   set(gca, 'XLim', [0 3], 'YLim', [0 rows(dates)+1], 'XTick', 0:1:3);
% $$$   
  output_txt = tempo;
   case 'update'
     evt_obj = task;
     pos = get(evt_obj, 'Position'); 
     pos = (rows(dates)-pos(2))+1;
     d = datestr(datenum(dates{pos}, 'yymmdd'), 'dd-mmm-yyyy');  
     output_txt =d;
   otherwise
    error 'Invalid action';
  end;
  
  
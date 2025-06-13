function [] = examine_each_stimpair(rat, task, idxlist, varargin)
  
  % Shows daily performance measures for individual stimpairs of a given
  % rat.
  % Performs the calculation in examine_stimpair for each index in
  % "idxlist" and presents a composite graph, where each subplot is dedicated to one index.
  % See examine_stimpair for details on the input params
    
   pairs =  { ...
      'from', '000000'; ...
      'to', '999999'; 
      'pitch_tag', '%1.1f octaves' ; ...
      'duration_tag', '%1.1f logD'   ; ...
   };
  parse_knownargs(varargin, pairs);
  
  dates = get_files(rat, 'fromdate', from, 'todate', to);
  
  % An i-by-4 cell array, where each row contains information for the
  % corresponding index.
  % Columns are: 1) index, 2) leftrates, 3) rightrates, 4) bias (leftrate-rightrate) --- when more calculations
  % are performed, more columns will be added.
  idx_data = {};  
  % init
    for i = 1:length(idxlist), 
      idx_data{i,1} = idxlist(i);
      idx_data{i,2} = []; idx_data{i,3} = [];
    end;
    
  for d = 1:rows(dates)
     load_datafile(rat, task, dates{d});
     ld = cell2mat(saved_history.ChordSection_logdiff);
    numtrial = eval(['saved.' task '_n_done_trials']);
    sides = saved.SidesSection_side_list;
    lrew = saved.RewardsSection_LeftRewards;
    rrew = saved.RewardsSection_RightRewards;
    
    for i = 1:length(idxlist)
       idx = find(ld == idxlist(i));
       if ~isempty(idx)
         % Measure: left hit rate and right hit rate
         lrate = sum(lrew(idx))/sum(sides(idx));
         idx_data{i,2} = [ idx_data{i,2} lrate ];
         % leftstd = [ leftstd sqrt(lrate*(1-lrate)) ];
      
         rrate = sum(rrew(idx))/length(find(sides(idx) == 0));
         idx_data{i,3} =[ idx_data{i,3} rrate ];
         % rightstd = [ rightstd sqrt(rrate * (1-rrate))];
       end;   
       
    end;
    
  end;
  
  % Now calculate biases
  
  for k = 1:rows(idx_data)
    idx_data{k, 4} = idx_data{k,2} - idx_data{k,3};
  end;
  
  %%%%%%%%%%
  % Begin plotting
  %%%%%%%%%%
  
  % piece of the title needs to indicate what the index means
  title_tag = pitch_tag;
  if strcmpi(task(1:3), 'dur'), title_tag = duration_tag; end;
  
  % Figure 1: Raw left and right hit rates across several sessions.
  figure;
  set(gcf,'Menubar','none','Toolbar','none', 'Position', [200 200 900 ...
                      600]);
  set(gcf,'Name', ...
          sprintf('%s - Left/right hit rates for different stimulus pairs', ...
                  rat));
  
  if length(idxlist) == 1,
    r = 1; c = 1;
  elseif length(idxlist) ==2,
    r = 2; c = 1;
  else 
    r = 2; c = 2;
  end;
  if length(idxlist) > 4,
    fprintf(1, ['Too many stimulus pairs! Only data for the first 4 ' ...
                'will be shown\n']);
  end;
  
  for k = 1:min(4, length(idxlist))
    subplot(r,c,k);
    s = sprintf('%s (%s to %s)\nPerformance for idx: %1.1f', rat, from, to, ...
    idxlist(k));
  
    leftrates=idx_data{k,2};
    rightrates= idx_data{k,3};
    fprintf('Left = %i, Right = %i\n', length(leftrates), length(rightrates));
    if length(leftrates) > 0 & length(rightrates) > 0
      bar(leftrates, 0.1, 'b');
      hold on;
  
      % draw error bars
      plot(1:length(leftrates), leftrates, '-b');
      % errorbar(1:length(leftrates), leftrates, leftstd, leftstd);
  
      plot(1:length(leftrates), rightrates, '-hr', 'MarkerSize', 10);
      % errorbar(1:length(leftrates), rightrates, rightstd, rightstd);
  
      xlabel('Session #');
      ylabel('Left or right hit rate');
    %  legend({'Left', '', 'Right'}, 'Location', 'NorthWest'); legend('boxoff');
      set(gca, 'Xlim', [ 0 length(leftrates)+1 ], ...
               'YLim', [min(min(leftrates), min(rightrates))-0.1 1.1]);
      title(s);
    end;
  end;
  
  uicontrol(gcf, 'Style','text','Position', [10 20 250 15], ...
            'String', 'Not all indices may be visited in every session', ...
            'FontAngle', 'italic', 'Background', 'white');
  uicontrol(gcf, 'Style', 'text', 'Position', [10 10 250 15], ...
          'String', 'Each plot may have a different minimum X tick', ...
            'FontAngle','italic','Background','white');
  
  
  % Figure 2 --- Bias or (Leftrate - Rightrate) for multiple sessions
  figure;
  set(gcf,'Menubar','none','Toolbar','none', 'Position', [200 200 900 ...
                      600]);
  set(gcf,'Name', ...
          sprintf('%s - Bias for different stimulus pairs', ...
                  rat));
  
  if length(idxlist) == 1,
    r = 1; c = 1;
  elseif length(idxlist) ==2,
    r = 2; c = 1;
  else 
    r = 2; c = 2;
  end;
  if length(idxlist) > 4,
    fprintf(1, ['Too many stimulus pairs! Only data for the first 4 ' ...
                'will be shown\n']);
  end;
  
  for k = 1:min(4, length(idxlist))
    subplot(r,c,k);
    s = sprintf(['%s (%s to %s): Bias for ' title_tag], rat, from, to, ...
    idxlist(k));
    
    plot(1:length(idx_data{k,4}), idx_data{k,4}*100, 'pk','MarkerSize',6);
    
    xlabel('Session #');
    ylabel('Bias (Left rate - Right rate)');  
    set(gca, 'XLim', [ 0 length(idx_data{k,4})+1 ], ...
             'YLim', [min(idx_data{k,4})-10 max(idx_data{k,4})+10]);
    xl = get(gca,'XLim');  yl = get(gca,'YLim');
    hold on; line(xl, [0 0], 'LineStyle', ':', 'Color', 'r');
    title(s); 
    
    text(xl(2)-10, yl(1)+2, sprintf('mean bias = %2.1f%%', ...
                                       mean(idx_data{k,4}*100)));
    legend('Bias', 'Location','NorthWest');
    
 end;
function [] = weber_info(rat, fname)
  
  global Solo_datadir;
  if isempty(Solo_datadir), mystartup; end;
  try,
    load([Solo_datadir filesep 'Data' filesep rat filesep fname]);
  catch
    error('Unable to find file!');
  end;
  
  % Data structure is a d-by-7 cell array where the columns are:
  % date
  % weber ratio
  % binomial fit params (2-by-1)
  % bias (Difference of bisection point from geometric mean of end
  % points)
  % bisection point - 50% according to fit curve
  % -1sigma point - 16% according to fit curve
  % +1sigma point - 84% according to fit curve
  
  wb = cell2mat(vals(2:end, 2));
  
  figure;
  set(gcf,'Menubar', 'none','Toolbar','none', 'Position', [100 100 600 ...
                      400], 'Name', 'Psychometric Data Summary');
 
  
  % Plot 1 - raw plot
  axes('Position',[0.1 0.5 0.35 0.4]); 
  plot(1:length(wb), wb, '.b', 1:length(wb), wb, '-r');
  lims = get(gca, 'XLim');
  hold on; line([0 lims(2)], [mean(wb)-std(wb) mean(wb)-std(wb)], 'Color','k', ...
                'LineStyle', ':');
  
  hold on; line([0 lims(2)], [mean(wb)+std(wb) mean(wb)+std(wb)], 'Color','k', ...
                'LineStyle', ':');
  title('Session Weber Ratio');
  xlabel('Session #'); ylabel('Weber ratio');
  
  % Plot 2 - differences
  axes('Position', [0.55 0.5 0.35 0.4]); dwb = abs(diff(wb));
  plot(1:length(wb)-1, dwb, '.b', 1:length(wb)-1, dwb, ...
       '-r');
  lims = get(gca, 'XLim');
  hold on; line([0 lims(2)], [mean(dwb)-std(dwb) mean(dwb)-std(dwb)], 'Color','k', ...
                'LineStyle', ':');
  
  hold on; line([0 lims(2)], [mean(dwb)+std(dwb) mean(dwb)+std(dwb)], 'Color','k', ...
                'LineStyle', ':');
  title('abs(Day-to-day differences)');
  xlabel('Session #'); ylabel('|Weber tomorrow - Weber today|');
  

  % 5-set averages & ranges
  meanie = [];
  rangie = [];
  for k=1:floor(length(wb)/5),
    curr = wb((5*(k-1))+1:5*k);
    meanie = [meanie mean(curr)];
    rangie = [rangie max(curr)-min(curr)];
  end;
  if length(wb) > k*5,
    curr = wb((5*(k-1))+1:end);
    meanie = [meanie mean(curr)];
    rangie = [rangie max(curr)-min(curr)];
  end;
  

  % 5-session summary
  axes('Position', [0.1 0.08 0.35 0.3]);
  plot(1:length(meanie), meanie,'.b');
  hold on;
  errorbar(1:length(meanie), meanie, rangie, rangie);
  xlabel('5-session chunks');
  ylabel('Mean Weber (+/- RANGE)');
  title('5-session summary');
  
    % Textual data - statistical summary
  textset = [];
  top = 0.35; left = 0.6; w = 0.3; h = 0.04;
  textset(1) = uicontrol('Style', 'text', 'Units', 'normalized', 'String', ...
                'Statistical summary', 'Position', [left top w h],'FontWeight','bold');
  top = top-h;
  % Average & std.dev.
  avg = mean(wb); sd =std(wb); s=sprintf('Overall Mean: %1.2f (+/- %1.2f)', avg, sd); 
  textset(2) = uicontrol('Style', 'text', 'Units', 'normalized', 'String', ...
                s, 'Position', [left top w h]);
  
  % Title
 s = sprintf('%s: %i sessions\n', make_title(rat), rows(wb));
 t = uicontrol('Style', 'text', 'Units', 'normalized', 'String', ...
                s, 'Position', [0.1 0.94 0.8 0.05],'BackgroundColor','y','FontWeight','bold','FontSize',10);
  
  
  
    for k = 1:length(textset)
    set(textset(k), 'BackgroundColor','w','HorizontalAlignment','right');
    end;
  
  
 
  
  
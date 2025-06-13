function [tally p] = pool_psychometric_pitches(rat, varargin)

pairs = { ...
    'task', 'dual_discobj'; ...
    'binmin', 1     ; ...
    'binmax', 15     ; ...
    'from', '000000' ; ...
    'to', '999999'; ...
    'num_bins', 8   ; ...
    'drop_last', 0  ; ...
    'nodist', 0 ;  ...
    'pitches', 1 ; ...
    };
parse_knownargs(varargin, pairs);

 date_set = get_files(rat,'fromdate', from, 'todate', to);

 
[dummy bins] = generate_bins(binmin, binmax, num_bins, 'pitches', 1);
replong = zeros(1,cols(bins)-1); tally = zeros(1, cols(bins)-1);

total_trials = 0;
for d = 1:rows(date_set)
    date = date_set{d};
    fprintf(1, '%s\n', date);
    load_datafile(rat, task, date);

    % Set up tones array
    t1 = saved.ChordSection_pitch1_list;
    t2 = saved.ChordSection_pitch2_list;

    left = 1; right = 1-left;
    tones = zeros(size(t1));

    sides = saved.SidesSection_side_list;
    tones(find(sides == left)) = t1(find(sides == left));
    tones(find(sides == right)) = t2(find(sides == right));

    % Set up "reported long array"
    left_t = find(sides == left);
    hh = eval(['saved.' task '_hit_history']); rep_long = hh;
    rep_long(intersect(left_t, find(hh == 0))) = 1;
    rep_long(intersect(left_t,find(hh==1))) = 0;

    % now get psychometric trials
    psych_on = saved_history.ChordSection_pitch_psych;
    psych = find(cell2mat(psych_on) == 1);
    contigs = make_contigs(psych);
    if cols(contigs) >1
        sprintf('Found > 1 contig of randomised trials; taking only the last one')
        trials = contigs{cols(contigs)};
    else
        trials = contigs{1};
    end;
    
    if length(trials) > 0
    
    i = find(trials > saved.dual_discobj_n_done_trials);
    if ~isempty(i)
        trials = trials(1:i(1)-1);
    end;
    % this piece of code is needed for crashed Matlab code where
    % n_done_trials is off by 1 compared to the data stored
    if isnan(hh(trials(end)))
        trials = trials(1:end-1);
    end;
    total_trials = total_trials + length(trials);

    % Analyse only psychometric trials
    rep_long = rep_long(trials);
    tones = tones(trials);

    % need to do this for LHS endpoint; everything else is taken care of
    idx = find(tones == bins(1));
    tally(1) = tally(1) + length(idx);
    if length(idx) > 0
        replong(1) = replong(1) + sum(rep_long(idx));
    end;

    for k = 2:length(bins)
        idx = intersect(find(tones > bins(k-1)), find(tones <= bins(k)));
        tally(k-1) = tally(k-1) + length(idx);
        replong(k-1) = replong(k-1) + sum(rep_long(idx));
    end;
    end;
    
end;

p = replong ./ tally;
variance = (p .* (1-p)) ./ tally;
stdev = sqrt(variance);

% perform logistic regression and calculate Weber ratio
x = log2(bins(1:end-1)); if x(1) == 0, x(1) = 0.0001; end;
b = glmfit(x', [replong; tally]', 'binomial');
minx = min(x) - 1;
maxx = max(x) + 1;
xx = minx:(maxx-minx)/100:maxx;
yy = glmval(b, xx, 'logit');
[xcomm, xfin, xmid, weber] = get_weber(xx,yy, 'pitches', 1);
minus_sd = normcdf(-1); plus_sd = normcdf(1);
mp = log2(sqrt(binmin*binmax));
bias = 2^(xmid)-2^(mp);


% Plotting begins here ---------------------------
fig = figure;
%set(gcf,'Menubar','none', 'Toolbar','none');
curr_x = 0.05; curr_width = 0.4;
if nodist == 0
    axes('Position', [curr_x 0.3 curr_width 0.6]);
    bar(log2(bins(1:end-1)), tally, 'stacked');
    for k = 1:length(bins)-1
        h = text(log2(bins(k)), tally(k)+2, int2str(tally(k)));
        set(h, 'FontSize',12,'FontWeight','bold');
    end;
    xlabel('Bins of tone pitches (KHz)');
    ylabel('Sample size (n)');
    t= title(sprintf('%s: %s (%s to %s): \nTone sampling distribution (n=%i)', make_title(rat), make_title(task), date_set{1}, date_set{end}, total_trials));
    set(t, 'FontSize', 12, 'FontWeight','bold');
    temp = log2(bins(1:end-1));
    axis([min(temp)-0.5 max(temp)+0.5 0 max(tally)+3]);
    curr_x = curr_x + 0.5;
else
    curr_x = 0.1; curr_width = 0.85;
end;

% Plotting psychometric curve begins here -------------------

axes('Position', [curr_x 0.3 curr_width 0.6]);
graf = plot(xx, yy, '-r'); hold on;
set(graf,'LineWidth',2);

% plotting 16, 50, 80% points
%line([xcomm xcomm], [0 1], 'LineStyle', '--', 'Color', 'b');

rng = max(x)-min(x);
%t= text(max(x)-(rng/10), 0.2, sprintf('%2.0f%%, %2.0f%%, %2.0f%%', minus_sd*100, 50, plus_sd*100));
pos = get(t,'Position');
%line([pos(1)+pos(3) pos(1)+pos(3)+(rng/10)], [0.23 0.23], 'Linestyle','--', 'Color','b');

%t= text(max(x)-(rng/10), 0.1, 'Standard interval');
pos = get(t,'Position');
%line([pos(1)+pos(3) pos(1)+pos(3)+(rng/10)], [0.12 0.12], 'Linestyle','--', 'Color','r');

%line([xfin xfin], [0 1], 'LineStyle', '--', 'Color', 'b');
%line([xmid xmid], [0 1], 'LineStyle', '--', 'Color', 'b');

%line([mp mp], [0 1], 'LineStyle','--', 'Color','r', 'LineWidth', 1);


graf = errorbar(log2(bins(1:end-1)), p, stdev, stdev, '.r');
set(graf, 'MarkerSize',10, 'LineWidth',2);
lbl = cell(0,0);
for k = 1:length(bins)-1
    ypos = p(k)+stdev(k)+0.04;
    h = text(log2(bins(k))-0.03, ypos, sprintf('%i%%',round(p(k)*100)));
    set(h, 'FontSize',12, 'FontWeight','bold');
    if nodist > 0
        h = text(log2(bins(k))-0.03, ypos+0.05, sprintf('(%i)', tally(k)));
        set(h, 'FontSize',12, 'FontWeight','bold');
    end;
    lbl{k} = sprintf('%2.1f', bins(k));
end;

axis([log2(binmin)-0.1 log2(binmax)+0.1 0 1.1])
set(gca,'XTick', log2(bins(1:end-1)),'YTick', 0:0.2:1, 'YTickLabel',[0,20,40,60,80,100]);
set(gca, 'XTickLabel',lbl);

t = xlabel('Tone frequency (KHz)'); set(t,'FontSize',16,'FontWeight','bold');
t = ylabel('freqency of reporting "High" (%)'); set(t,'FontSize',16,'FontWeight','bold');
t = title(sprintf('%s: %s (%s to %s): \n[Min,Max] = [%1.1f,%1.1f]ms', make_title(rat), make_title(task), date_set{1}, date_set{end}, binmin, binmax));
set(t, 'FontSize', 12, 'FontWeight', 'bold');

if nodist > 0
    set(fig,'Position', [225 279 485 435]);
else
    set(fig, 'Position', [225 279 800 419]);
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOOTER DATA %%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warm_red = [0.96 0.25 0.16];
t = []; t_height = 15; t_width = 200; x = 3; y = 6;
% Stats at the bottom
t = [t uicontrol('Style', 'text', 'String', sprintf('Weber ratio:%1.3f', weber), 'Position', [x y t_width t_height], 'FontWeight', 'bold')]; y = y + t_height;
t = [t uicontrol('Style', 'text', 'String', sprintf('Standard pitch (I)= %1.1fKHz (%1.2f)', 2^(mp), mp), 'Position', [x y t_width t_height])]; y = y+t_height;
uicontrol('Style', 'text', 'String', 'Pitch Discrimination Parameters', ...
    'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', warm_red, 'ForegroundColor', 'w', 'Position', [x y t_width t_height*2]);

x = x + t_width+5; t_width = t_width*1.3; y = 6;
t = [t uicontrol('Style', 'text', ...
    'String', [ 'Bias (Bisection point - I) = ' sprintf('%3.1fms (%1.2f)', bias, (xmid-mp))], 'Position', [x y t_width t_height])]; y = y+t_height+5;
t = [t uicontrol('Style', 'text', 'String', sprintf('50%%: %1.1fKHz (%1.2f)', 2^(xmid), xmid), 'Position', [x y t_width t_height])]; y = y+t_height;
t = [t uicontrol('Style', 'text', 'String', sprintf('(16, 84)%%: (%1.1f, %1.1f)KHz (%1.2f, %1.2f)', 2^(xcomm), 2^(xfin), xcomm, xfin), 'Position', [x y t_width t_height])]; y = y+t_height;

    u = uicontrol('Style', 'text', 'String', 'Data: Center and Spread Measures', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor',warm_red, 'ForegroundColor', 'w', 'Position', [x y t_width t_height]);

for k = 1:length(t)
    set(t(k), 'FontSize',12, 'BackgroundColor','w');
end;

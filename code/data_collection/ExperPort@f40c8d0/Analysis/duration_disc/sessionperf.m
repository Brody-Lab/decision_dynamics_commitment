function [] = sessionperf(rat, task, date, varargin)
% function [] = sessionperf(rat, task, date, varargin)
% Shows the success rate & bias of the rat for the given session.
% Returns:
% - A plot of the moving average hit rate for the session; plot  marks
% important training transitions like onset of psychometric sampling
% and the levels of boundary sharpening
% - A second plot showing the two traces of left-hand-side hit rate and
% right-hand-side hit rate; a view of animal's bias
% - A third plot showing a metric as specified by the 'third' option.
% 'third' may be:
%  * pre-go: time between stimulus offset and GO signal
%  * presound: time from Cin till stimulus onset
%  * lprob: Value of "LeftProb" param, showing probability of LHS trial
%  (indirect indicator of bias)
%  * bias: Calculated from left and right hit rate. (Left hit rate -
%  Right hit rate)


pairs = { 'third', 'bias' ; 'showloc', 1 ; 'lookahead', 0; };
parse_knownargs(varargin, pairs);

if strcmpi(task, 'd'), task = 'duration_discobj';
elseif strcmpi(task, 'p'), task = 'dual_discobj';
end;

status = load_datafile(rat, date);

if status ~= 1
    warning(sprintf('Could not find file for %s on %s',rat,date));
    figure;
    return;
end;

side = saved.SidesSection_side_list;
hh = eval(['saved.' task '_hit_history;']);
hh = hh(find(~isnan(hh)));
side = side(1:length(hh));

n = eval(['saved.' task '_n_done_trials;']);

winsize = 15;

if n < winsize
    figure;
    axes; t=text(0,0.5,'Not enough trials');
    set(t,'FontSize', 18, 'Color','r');
    s = sprintf('%s: %s (%s)\nHit rate', make_title(rat), make_title(task), date);
    title(s);

    return;
end;

lrate = [];
rrate = [];

if lookahead > 0,
    for k = 1:(length(hh)-winsize)
        idx = k:(k+winsize)-1;
        mini_s = side(idx); mini_h = hh(idx);
        leftidx = find(mini_s > 0); rightidx = find(mini_s < 1);
        lrate = [lrate sum(mini_h(leftidx))/length(leftidx)];
        rrate = [rrate sum(mini_h(rightidx))/length(rightidx)];
    end;
else
    fprintf(1,'Looking back now\n');
    for k = 1:length(hh)
        idx = max(k-winsize, 1):k;
        mini_s = side(idx); mini_h = hh(idx);
        leftidx = find(mini_s > 0); rightidx = find(mini_s < 1);
        if length(leftidx) > 0,
            lrate = [lrate sum(mini_h(leftidx))/length(leftidx)];
        else
            lrate = [lrate 0];
        end;
        if length(rightidx) > 0,
            rrate = [rrate sum(mini_h(rightidx))/length(rightidx)];
        else
            rrate = [rrate 0];
        end;
    end;
end;

figure;
nump = 2; % no. plots
ht = 680;
% if strcmpi(task(1:3), 'dua'), nump = 2; ht = 680 * (2/3); end;


set(gcf,'Menubar','none', 'Toolbar','none', 'Position', [200 100 750 ht]);

% Plot 1: Hit rates -----------
subplot(nump,1,1);
v = cell2mat(saved_history.ChordSection_vanilla_on);
if sum(v) > 1,
    plot_logdiff_perf(rat, task, date, 'nofig', 1, 'bout_size',winsize);
else
    hit_rates(rat, task, date, 'bout_size', winsize);
end;
set(gca, 'XTick', [0:20:length(hh)-winsize],'XLim', [1 length(hh)],'YLim',[0.5 1]);
axes__format(gca);

% Plot 3: Whatever your heart desires ----------
% if nump == 3,
subplot(2,1,2);
if strcmpi(third, 'pre_go')
    pre_go(rat, task,date, 'newfig',0, 'from', winsize+1);
elseif strcmpi(third, 'presound')
    presound_increment(rat, task, date, 'newfig', 0, 'from', winsize+1);
elseif strcmpi(third, 'lprob')
    lprob(rat, task, date, 'newfig', 0, 'from', winsize+1);
elseif strcmpi(third,'loc')
    % loc logic
    tone_loc = saved_history.ChordSection_Tone_Loc;
    go_loc = saved_history.ChordSection_GO_Loc;

    goloc = zeros(length(go_loc), 1);
    toneloc = zeros(length(tone_loc), 1);

    idx = find(strcmpi(go_loc, 'on'));
    goloc(idx) = 1;
    idx = find(strcmpi(tone_loc, 'on'));
    toneloc(idx) = 1;

    goloc = zeros(length(go_loc), 1);
    toneloc = zeros(length(tone_loc), 1);

    idx = find(strcmpi(go_loc, 'on'));
    goloc(idx) = 1;
    idx = find(strcmpi(tone_loc, 'on'));
    toneloc(idx) = 1;
    plot(1:length(goloc), goloc, '.g', 1:length(toneloc), toneloc, '-b');
    set(gca, 'YLim', [-1 2], 'YTickLabel', {'', 'off', 'on', ''}, 'YTick', ...
        -1:1:2, 'XLim', ...
        [1 length(hh)]);
    s = sprintf('%s: %s (%s)\nTone & GO Localisation', make_title(rat), make_title(task), date);
    title(s);


elseif strcmpi(third, 'bias'),
    temp = lrate - rrate;
    goodrun = zeros(size(temp)); goodrun(1) = 1;
    notbiased = temp < 0.2 & temp > -0.2;
    for k=2:length(temp)
        if notbiased(k),
            if ~notbiased(k-1)
                goodrun(k) = 1;
            else
                goodrun(k) = goodrun(k-1) +1;
            end;
        end;
    end;

    %  plot(1:length(goodrun), goodrun, '-b');
    plot(1:length(temp), temp, '-b');
    hold on;
    line([1 length(temp)], [0.2 0.2], 'LineStyle',':', 'Color','r');
    line([1 length(temp)], [-0.2 -0.2], 'LineStyle',':', 'Color','r');
    text(length(hh)-20, 0.22, 'b=0.2', 'Color','r');
    text(length(hh)-20, -0.22, 'b=-0.2', 'Color','r');

    set(gca,'YLim', [-0.5 0.5],'XLim',[1 length(hh)]);
    xlabel('Trial #'); ylabel('(Hit rate)L - (Hit rate)R');
    set(gca,'XTick', 0:20:length(temp));
    s = sprintf('%s: %s (%s)\nBias (trial-by-trial)', make_title(rat), ...
        make_title(task), date);
    title(s);
end;
%  end;


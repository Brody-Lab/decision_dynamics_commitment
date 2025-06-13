function [best_short, best_long, point] = poke_duration_performance(pre_min, ...
    pre_max, post_min, ...
    post_max, s1, s2, varargin)
% Considers the scenario in duration_discobj where the rat is using poke
% durations to make its 2AFC decision, rather than the duration of the
% sound stimulus.
% Treats the silent periods flanking the tone as uniform distributions,
% and thus the dist'n of a given trial as a sum of two uniforms.
%
% Answers the question: For a given poke duration threshold, how well
% can the rat do for short trials, and for long?
%
% Returns the poke duration at which the rat maximises the sum of
% p(short correct) and p(long correct) in three arguments:
% 1 -- best p(short correct)
% 2 -- best p(long correct)
% 3 -- poke duration that maximises the sum (1) + (2)

pairs = { ...
    'showplot', 1 ; ...
    'return_pdfs', 0 ; ... % when true, returns the distribution of
    % p(short correct) and p(long correct) as
    % first two arguments, and trial_length as third
    'showdiff', 1;  ...       % when true, shows plot if rat had been using solely sound duration
    'fsize', 12; ...                % and when using solely poke duration to make
    'singleuniform', 0 ; ...
    % decision;
    };
parse_knownargs(varargin, pairs);

close all;

% silent_length has value of total silent period
% silent_pdf has corresponding prob. density fn

if (post_min + post_max) > 0 % sum of 2 uniform distributions: 1 for pre-cue and one for post-cue
    [silent_lengths, silent_pdf] = pdf_sum_uni(pre_min, pre_max, post_min, ...
        post_max);
else % uniform distribution
    stepsize=0.001;
    silent_lengths=pre_min:stepsize:pre_max;
    silent_pdf=ones(size(silent_lengths))*(1/length(silent_lengths));
    singleuniform=1;
end;

short_tone = s1; % duration of short tone
long_tone = s2;  % duration of long tone

% trial length distribution
short_trials = silent_lengths + short_tone;
long_trials = silent_lengths + long_tone;

thresh_array = [];
pr_short_correct = [];
pr_long_correct = [];

% consider an overlap zone between the two trials, bounded by [o1, o2].
% For simplicity, say o1 is the min(long_trials) and o2 is
% max(short_trials).
o1 = min(long_trials); o2 = max(short_trials);

threshrange = min(short_trials): 0.05: max(long_trials);
for thresh = threshrange
    pshort = cumsum_uni(short_trials, silent_pdf, thresh);
    plong = 1 - cumsum_uni(long_trials, silent_pdf, thresh);

    pr_short_correct = [pr_short_correct pshort];
    pr_long_correct = [pr_long_correct plong];

end;

both_tog = pr_short_correct + pr_long_correct;
maxidx = find(abs((both_tog-max(both_tog))) < 0.0001);


% Figure 1 - probs of getting trials correct

shortclr=[0.4 0.4 1];
longclr=[0 0 0.5];

if showplot > 0
    figure;
    set(gcf,'Menubar','none','Toolbar','none');
    plot(threshrange, pr_short_correct,'-b', 'LineWidth', 2,'Color', shortclr); hold on;
    plot(threshrange, pr_long_correct, '-g','LineWidth',2,'Color',longclr);
    plot(threshrange, pr_short_correct,'.b', 'MarkerSize', 20,'Color', shortclr);
    plot(threshrange, pr_long_correct, '.g','MarkerSize',20,'Color',longclr);
    line([min(threshrange) max(threshrange)], [0.8 0.8], 'Color',[1 1 1]*0.5, 'LineStyle',':','LineWidth',2);
        ff=0.008;
    for k = 1:length(maxidx)
        patch([threshrange(maxidx(k))-ff threshrange(maxidx(k)) threshrange(maxidx(k))+ff], ...
             1.1-[0 0.05 0],'r', 'EdgeColor','none');
    end;
    
    title(sprintf('Best performance\n by timing solely poke duration'));
    xlabel('rat''s midpoint (s)');
    ylabel('%(correct)');
   % legend({'Short','Long'});

    set(gca,'YLim', [0 1.2], 'XLim', [min(short_trials) max(long_trials)], 'XTick',[min(short_trials):0.2:max(long_trials)]);
    set(gca,'YTick', 0:0.25:1, 'YTickLabel',0:25:100);
    axes__format(gca);
    set(gcf,'Position',[ 245   426   768   254]);
    uicontrol('Tag', 'figname', 'Style','text', 'String', 'choiceprobability', 'Visible','off');

    % Figure 2 - Graphically shows overlap and duration which maximises sum
    % of both types of trials
    figure;
    line([min(short_trials) max(short_trials)],[1 1] ,'Color', shortclr,'LineWidth',4);
    hold on;
    line([min(long_trials) max(long_trials)], [2 2],'Color', longclr,'LineWidth',4);
    set(gca,'XLim', [min(short_trials)-0.2 max(long_trials)+0.2], ...
        'YTickLabel',{},'YTick',[], ...
        'XTick', min(short_trials):0.2:max(long_trials));
    ff=0.01;
    for k = 1:length(maxidx)
        patch([threshrange(maxidx(k))-ff threshrange(maxidx(k)) threshrange(maxidx(k))+ff], ...
             2.8-[0 0.08 0],'r', 'EdgeColor','none');
    end;
    xlabel('Trial length (s)');
    set(gca,'YLim',[0 3]);
    axes__format(gca);
    set(gcf,'Position',[54    82   766   266]);
    title('Overlap of short & long trial durations');
      uicontrol('Tag', 'figname', 'Style','text', 'String', 'triallength_overlap', 'Visible','off');
    

end;

% Plot 'what if' scenarios for using poke duration and using sound
% duration to make decisions
if showdiff > 1
    figure;
    %  set(gcf,'Menubar','none','Toolbar','none');
    % first plot what happens if rat is timing sound

    line([min(threshrange)-0.5 max(threshrange)+0.5],[1.2 1.2], 'Color','k','LineWidth',2);
    line([min(short_trials) max(short_trials)],[1.4 1.4], 'Color','b','LineWidth',4);
    hold on;
    line([min(long_trials) max(long_trials)], [1.6 1.6], 'Color','g','LineWidth',4);

    short_thresh = threshrange(find(threshrange <= max(short_trials)+0.025));
    long_thresh = threshrange(find(threshrange >= min(long_trials)));
    p_goleft = zeros(size(short_thresh));
    %plot(threshrange, p_goleft, '.b','MarkerSize',8); hold on;
    plot(short_thresh, ones(size(short_thresh)), '-b','LineWidth',2); hold on;
    plot(long_thresh, zeros(size(long_thresh)), '-g', 'LineWidth', 2,'MarkerSize',10);
    t = xlabel('Trial length (s)'); set(t, 'FontSize',fsize, 'FontWeight', 'bold');
    t = ylabel('p(reporting "Short")');set(t, 'FontSize',fsize, 'FontWeight', 'bold');
    set(gca,'XLim',[min(threshrange)-0.2 max(threshrange) + 0.2], 'YLim', [-0.1 1.8], ...
        'YTick',0:0.5:1, 'YTickLabel',0:0.5:1);
    axes__format(gca);
    title('If timing SOUND duration');


    figure;    
    % set(gcf,'Menubar','none','Toolbar','none');
    % first plot what happens if rat is timing poke duration
    line([min(threshrange)-0.5 max(threshrange)+0.5],[1.2 1.2], 'Color','k','LineWidth',2);
    line([min(short_trials) max(short_trials)],[1.4 1.4], 'Color','b','LineWidth',4);
    hold on;
    line([min(long_trials) max(long_trials)], [1.6 1.6], 'Color','g','LineWidth',4);

    f = 0.95;
    p_goleft = ones(size(short_thresh)) .* 0.1;
    idx = find(short_thresh < max(short_trials) * f);
    p_goleft(idx) = 1;
    plot(short_thresh, p_goleft, '-b','LineWidth',2); hold on;

    long_thresh = find(threshrange >= min(long_trials));
    p_long = zeros(length(long_thresh),1); long_thresh = threshrange(long_thresh);
    long_left = find(long_thresh < (max(short_trials) * f));
    p_long(long_left) = 0.95;
    plot(long_thresh, p_long, '-g','LineWidth',2, 'MarkerSize',10);
    %         plot(long_thresh, p_long, '-g','LineWidth',2, 'MarkerSize',10);

    line([max(short_trials)*f max(short_trials)*f], [0 1.6], 'LineWidth',2,'LineStyle',':','Color','r');

    set(gca,'XLim',[min(threshrange)-0.2 max(threshrange) + 0.2], 'YLim', [-0.1 1.8], ...
        'YTick',0:0.5:1, 'YTickLabel',0:0.5:1);

    t = xlabel('Trial length (s)'); set(t, 'FontSize',fsize, 'FontWeight', 'bold');
    axes__format(gca);
    title('If timing TRIAL duration');
end;


if return_pdfs < 1
    point = threshrange(maxidx(1));
    best_short = cumsum_uni(short_trials, silent_pdf, ...
        point);
    best_long = 1 - cumsum_uni(long_trials, silent_pdf, ...
        point);

else
    best_short = pr_short_correct;
    best_long = pr_long_correct;
    point = threshrange;
end;
function [] = superimpose_daily_psych_over_rats(varargin)
pairs = { ...
    'show_days', 1; ... % array of post-lesion days to show
    };
parse_knownargs(varargin,pairs);

duration_rats = rat_task_table('','action','get_duration_psych');
duration_ratrows= rat_task_table(duration_rats);

figure;

bins = generate_bins(200,500, 9,0);
for d = 1:length(show_days)
    curr_day = show_days(d);
    for r = 1:5%length(duration_rats)
        ratname = duration_rats{r};
        date_set = duration_ratrows{r, rat_task_table('','action','get_postpsych_col')};
        f = get_files(ratname,'fromdate', date_set{1}, 'todate', date_set{2});
        curr_day = f{d};
        [weber bfit bias xx yy xmid xcomm xfin replong tally] = psychometric_curve(ratname,0,'usedate',curr_day, ...
            'noplot', 1, 'nodist', 1);
        pct = replong ./tally;

        l=plot(xx,yy,'-r');set(l,'Color', rand(1,3)); hold on;
    end;
end;

set(gca,'XLim', [min(bins), max(bins)]);
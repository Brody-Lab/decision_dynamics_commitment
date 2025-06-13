function [pd_chunks, dd_chunks] = timeout_dual(rat, date, f_ver, varargin)
pairs = { ...
    'task', 'dual_discobj' ; ...
    };
parse_knownargs(varargin, pairs);

load_datafile(rat, task, date, f_ver);

% STEP 1: Get timeout counts for each trial
[timeout_count] = get_timeout_count(rat, task, date, f_ver);
maxie = max(timeout_count) + 1;

figure;
plot(1:length(timeout_count), timeout_count, 'b.');
ylabel('# Timeout');
xlabel('Trial #');
title([rat ':' task ' (' date f_ver ')']);
% STEP 2: Classify trials as being pitch/duration discrimination
[t_pd, t_dd] = indicate_pd_dd_trials(saved, saved_history, 'dual_discobj', 'blah', ...
    'pd_y', maxie, 'dd_y', maxie+1);
status_y = maxie+2;
trials = length(timeout_count);
labels = cell(0,0);
for ctr = 1:maxie-1
    labels{ctr} = num2str(ctr);
end;
labels{maxie} = 'PD Trial'; labels{maxie+1} = 'DD Trial';
set(gca, 'YTick', [1:maxie+1], 'YTickLabel', labels);

% STEP 3: Get switch points to analyse chunk-by-chunk
[first_dd, first_pd] = get_task_switches(trials, t_pd);
% STEP 4: Make trial "chunks"
[pd_chunks, dd_chunks] = make_chunks(first_pd, first_dd, trials);

%figure;
for ctr = 1:size(pd_chunks,1)
    t = timeout_count(pd_chunks{ctr});
    pd_chunks{ctr,2} = t;   
    status_x = floor(mean(pd_chunks{ctr,1}));
    text(status_x, status_y, sprintf('%1.2f',mean(t)), 'FontSize',7);
%    plot(pd_chunks{ctr,1}, timeout_count(pd_chunks{ctr}), 'r.');
    hold on;
end;
for ctr = 1:size(dd_chunks,1)
    t = timeout_count(dd_chunks{ctr});
    dd_chunks{ctr,2} = t;
    status_x = floor(mean(dd_chunks{ctr,1}));
    text(status_x, status_y, sprintf('%1.2f',mean(t)), 'FontSize', 7);
%     plot(dd_chunks{ctr,1}, timeout_count(dd_chunks{ctr}), 'b.');
end;

axis([0 trials 0 maxie+4]);
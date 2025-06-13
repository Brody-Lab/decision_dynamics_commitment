function [] = plot_days_progress(ratname, date, f_ver)
% For a session (specified by combination of ratname, date, and file
% version), plots the task classified as being at levels of primary
% conditioning, secondary conditioning, or the final task.
% For the meanings of specific levels, see: classify_task_level.m
%
% Note: This version is currently only for duration_discobj, as only this
% task has the 'Tone_Loc' and 'GO_Loc' fields used by this script.

load_datafile(ratname, 'duration_discobj', date, f_ver);

num_trials = getfield(saved_history, 'private_InitWaterValves_LeftWValveTime');
num_trials = size(num_trials,1);

PRIMARY = 1; GO_ONLY = 2; SECONDARY = 3; FINAL = 4;

% get different task types
basic = classify_task_level(saved_history,'primary');
go_only = classify_task_level(saved_history,'only_go_on');
sec = classify_task_level(saved_history, 'secondary');
final = classify_task_level(saved_history, 'final');

%['Basic: ' num2str(length(basic)) ', 2:', num2str(length(sec)) , ', Final:', num2str(length(sec))]

distro = zeros(num_trials,1);
distro(basic) = PRIMARY;
distro(go_only) = GO_ONLY;
distro(sec) = SECONDARY;
distro(final) = FINAL;

%figure;
plot(1:num_trials, distro, 'b.');
title([ratname ': ' date '(' f_ver ')']); 
set(gca,'YTick', 0:5);
set(gca, 'YLim', [0 5]);
set(gca,'YTickLabel', {'0'; 'Primary'; 'Tone OFF, GO ON'; 'Secondary'; 'Final Task'; '1'});
%set(gca,'Units', 'pixels');
%p = get(gca,'Position');
%set(gca,'Position', [p(1) p(2) 150 p(4)]);
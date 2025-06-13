function UpdateProgressplot(p, handles)

axes(p); axis off; cla; hold on;

% white background
rectangle('Position', [0 0 handles.nRecords 1], ...
    'EdgeColor', 'none', ...
    'FaceColor', [1 1 1]*0.95);

% mark extracted records, khaki
rectangle('Position', [0 0 handles.extracted 1], ...
    'EdgeColor', 'none', ...
    'FaceColor', [240 230 140]/255);

% % mark tracked records, 
% line([1:length(handles.tracked) 1:length(handles.tracked], ...
%      [zeros(size(handles.tracked)) handles.tracked], ...
%      'Color', [190 200 100]/255);

% draw a line at the current frame
ind = str2num(get(handles.frameindex, 'String'));
line([ind ind], [0 1], 'Color', 'k');
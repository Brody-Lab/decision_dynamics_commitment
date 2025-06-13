function [] = Analysis_Manager(varargin)

fig_y = 50;
fig_x = 5;
fig_wd = 300;
fig_ht = 200;

fig = findobj('Tag', 'analysis_mgr');
if isempty(fig), fig = figure; else, fig = clf(fig); end;
set(0,'CurrentFigure', fig);
set(gcf, 'Position', [fig_x fig_y fig_wd fig_ht], ...
    'MenuBar', 'none', 'Toolbar', 'none', ...
    'Tag', 'analysis_mgr');


y = fig_ht-30;
r = get_ratdirs;
rat = uicontrol('Position', [1 y 100 10], 'Style', 'popupmenu', 'String', r); y = y-20;
p = get_protocolnames; 
task = uicontrol('Position', [1 y 150 10], 'Style', 'popupmenu', 'String', p); y=y-20;

dates = uicontrol('Position', [1 y 180 10], 'Style', 'popupmenu', 'String', {'-- Select a protocol --'});
set(rat, 'Callback', {@available_dates, 'cbk', dates, 'plist', task, 'rlist', rat});
set(task, 'Callback', {@available_dates, 'cbk', dates, 'plist', task, 'rlist', rat});
y=y-50;

lfile = uicontrol('Position', [1 y 100 30], 'String', 'Load Data File'); y = y-30;
set(lfile, 'Callback', {@load_datafile, 'rlist', rat, 'plist', task, 'dlist', dates});


bmin = uicontrol('Position', [1 y 100 20], 'Style', 'edit', 'BackgroundColor', [1 1 0], 'String', 'blah');
y=y-20;
bmax = uicontrol('Position', [1 y 100 20], 'Style', 'edit', 'BackgroundColor', [0 1 0], 'String', 'bloo');
psych = uicontrol('Position', [100 y 120 20], 'String', 'Get Psychometric Curve'); y=y-20;
set(psych, 'Callback', {@psychometric_curve, 'blah', 'rlist', rat, 'plist', task, 'dlist', dates, 'binmin', bmin, 'binmax', bmax});

% Other tools to put in here
% Psychometric graphall
% 

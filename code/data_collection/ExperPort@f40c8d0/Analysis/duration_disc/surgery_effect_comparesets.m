function []  = surgery_effect_comparesets
% runs surgery_effect_ratset on provided two sets

default_set = {};
default_set.area_filter = 'ACx';
default_set.array_name = '';
default_set.days_before = [1 1000];
default_set.days_after = [1 1000];
default_set.lastfew_after = 1000;
default_set.lastfew_before = 1000;
default_set.colour = [0.7 0.7 0.7];

% SET UP: Compare ACx duration to ACx pitch
ACx_dur=default_set;
ACx_dur.area_filter = 'ACx';
ACx_dur.array_name = 'duration_psych';

ACx_freq = default_set;
ACx_freq.area_filter = 'ACx';
ACx_freq.array_name = 'pitch_psych';
ACx_freq.colour = [0 0 0.5];

% SET UP: Compare mPFC duration to mPFC pitch
mPFC_dur=default_set;
mPFC_dur.area_filter = 'mPFC';
mPFC_dur.array_name = 'duration_psych';

mPFC_freq = default_set;
mPFC_freq.area_filter = 'mPFC';
mPFC_freq.array_name = 'pitch_psych';
mPFC_freq.colour = [0 0 0.5];

%surgery_effect_run(ACx_dur, ACx_freq,'ACx');
surgery_effect_run(mPFC_dur, mPFC_freq,'mPFC');


function [] = surgery_effect_run(set1,set2,fname)

eliminate_Mondays = 0; % removes sessions that happened on Monday

% first set 1
[residuals_set1 failed_dates1]= surgery_effect_ratset('action','plot_residuals', 'array_name', set1.array_name, ...
    'area_filter', set1.area_filter, 'days_before', set1.days_before, 'days_after', set1.days_after, ...
    'lastfew_before', set1.lastfew_before, 'lastfew_after', set1.lastfew_after, ...
    'curvecolour', set1.colour,'eliminate_Mondays', eliminate_Mondays);


% then superimpose set 2
[residuals_set2 failed_dates2]= surgery_effect_ratset('action','plot_residuals', 'array_name', set2.array_name, ...
    'area_filter', set2.area_filter, 'days_before', set2.days_before, 'days_after', set2.days_after, ...
    'lastfew_before', set2.lastfew_before, 'lastfew_after', set2.lastfew_after, 'curvecolour', set2.colour,...
    'usefig', gcf,'eliminate_Mondays', eliminate_Mondays);


uicontrol('Tag', 'figname', 'Style','text', 'String', sprintf('%s_and_%s_compare_residuals',set1.array_name,set2.array_name), 'Visible','off');

global Solo_datadir;
blah='inc'; if eliminate_Mondays >0, blah = 'no';end;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep];
fname=[outdir fname '_residuals_' blah 'Mondays'];

save(fname,'residuals_set1','residuals_set2');
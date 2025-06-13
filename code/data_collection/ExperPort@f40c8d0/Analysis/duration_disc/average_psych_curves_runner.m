function [] = average_psych_curves_runner()

area_filter = 'ACXallsaline';
task = 'duration';

average_psych_curves('area_filter',area_filter, ...
    'action','load','tasktype',[task '_psych'],...
    'infile', [ task '_psych_' area_filter '_psychdata_LAST7FIRST3PSYCH.mat'],'metric', 'residuals')

uicontrol('Tag', 'figname', 'Style','text', 'String', ['avgpsych_' area_filter '_' task], 'Visible','off');
saveps_figures;
% close all;


% average_psych_curves('area_filter','ACx','action','load','tasktype','duration_psych','infile', 'duration_psych_ACx_psychdata_LAST7FIRST3PSYCH.mat','metric', 'residuals')
% 
% uicontrol('Tag', 'figname', 'Style','text', 'String', 'avgpsych_ACx_dur', 'Visible','off');
% saveps_figures;
% close all;
% 
% 
% average_psych_curves('area_filter','mPFC','action','load','tasktype','duration_psych','infile', 'duration_psych_mPFC_psychdata_LAST7FIRST2PSYCH.mat','metric', 'residuals')
% 
% uicontrol('Tag', 'figname', 'Style','text', 'String', 'avgpsych_mPFC_dur', 'Visible','off');
% saveps_figures;
% close all;
% 
% average_psych_curves('area_filter','mPFC','action','load','tasktype','pitch_psych','infile', 'pitch_psych_mPFC_psychdata_LAST7FIRST2PSYCH.mat','metric', 'residuals')
% 
% uicontrol('Tag', 'figname', 'Style','text', 'String', 'avgpsych_mPFC_pitch', 'Visible','off');
% saveps_figures;
% close all;
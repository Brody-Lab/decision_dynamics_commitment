function [] = surgery_effect_runner(area_filter)
% runs surgery_effect for all rats in dataset. 
% changes tagname on before/after psych figure so subsequent calls don't
% close the figure.

ratlist = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
r2 =rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

ratlist = [ratlist r2];

if strcmpi(area_filter,'ACx')
    preflipped=1;
else
    preflipped=0;
end;

for r=1:length(ratlist)
    surgery_effect('Gryphon',...
        'ACxround1', preflipped, ...
        'psychgraph_only', 1,... 
        'postpsych',0, ...
        'ignore_trialtype',1, ...
        'preflipped', preflipped, ...
        'lastfew_before',7,'days_after',[1 2], ...
        'psychthresh',1,'daily_bin_variability',0,...
        'graphic',1, ...
        'patch_bounds',0);
    2;
end;



%fname = 'mPFC_residuals_incMondays';
%fname = 'mPFC_residuals_incMondays';
%uspos = find(fname == '_');
%sub__plot_saved_residuals(fname,'dmPFC');

% run_basic_surgery_effect('pitch_psych', 'ACx');
%  duration_curve_diff= sub__run_basic_surgery_effect('pitch_psych', 'ACx');
% pitch_curve_diff= sub__run_basic_surgery_effect('pitch_psych', 'ACx');
% 
% global Solo_datadir;
% indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep fname '.mat'];
% save([indir 'ACx_curve_sigs'],'duration_curve_diff','pitch_curve_diff');

% ---------------------------------------
% Subroutines that call analysis scripts
function [curve_diff] = sub__run_basic_surgery_effect(array_name, area_filter)

ratlist = rat_task_table('','action',['get_' array_name],'area_filter',area_filter);

%ratlist = {'Isildur','Gaffer','Proudfoot'};
curve_diff = {};
for r= 1:length(ratlist)
    ratname = ratlist{r};
    fprintf(1,'Running %s ...\n', ratname);
      surgery_effect(ratname,'psychgraph_only',1,'lastfew_before', 7, 'days_after',[1 3]);
     eval(['curve_diff.' ratname ' = [sig_curve p_curve];']);
     
  %  surgery_effect_fixedlog(ratname,'brief_title',1);
    %  uicontrol('Tag', 'fname', 'Style','text', 'String', ratname, 'Visible','off');
    set(gcf,'Tag', 'blah');
end;

function [] = overlap_hists(x1,x2)

hist(x2);
p=findobj(gca,'Type','patch'); set(p,'FaceColor', [1 0 0],'EdgeColor',[1 0 0],'facealpha',0.75);
hold on;

hist(x1);
p=findobj(gca,'Type','patch');
set(p,'facealpha',0.25, 'EdgeColor','none');


function [] = sub__plot_saved_residuals(fname,titleprfx)

global Solo_datadir;
indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep fname '.mat'];
load(indir);

f=figure;
% mini_plotter(residuals_set1,'b',f);
% mini_plotter(residuals_set2,'r',f);
include_nonpsych_days = 1; 

plot_averaged_residuals(residuals_set1, [1 0.5 0],f,include_nonpsych_days);hold on;
plot_averaged_residuals(residuals_set2, [0.8 0 1],f,include_nonpsych_days);
x=xlabel('Day of post-recovery training');
y=ylabel('Residual averaged across rats');
set(gca,'XTick', 1:1:3);
t=title(sprintf('%s-lesioned rats\nResiduals through post-lesion sessions',titleprfx));
legend({'Duration','Frequency'});

set(y,'FontSize',18,'FontWeight','bold');
set(x,'FontSize',18,'FontWeight','bold');
set(t,'FontSize',18,'FontWeight','bold');
set(gca,'FontSize',16,'FontWeight','bold');

qual = 'inc';
if include_nonpsych_days == 0, qual ='no';end;
uicontrol('Tag', 'figname', 'Style','text', 'String', [fname '_' qual 'empties'], 'Visible','off');


% plot average residuals per day for a given set of rats
function [] = sub__plot_averaged_residuals(allrat_residuals,curvecolour,usefig,inc_empties);

exclude_names = {}; %'Ron','Riddle'};
fnames = fieldnames(allrat_residuals);
fprintf(1,'Original length = %i\n', length(fnames));
for exc = 1:length(exclude_names)
if isfield(allrat_residuals, exclude_names{exc})
    allrat_residuals = rmfield(allrat_residuals,exclude_names{exc});
    
    fprintf(1,'\tExcluding %s ...\n', exclude_names{exc});
end;
end;
minsize =1000;
fnames = fieldnames(allrat_residuals);
fprintf(1,'After exclusions, length = %i\n', length(fnames));


for idx=1:length(fnames)
    minsize = min(minsize,length(eval(['allrat_residuals.' fnames{idx}])));
end;

res_matrix = zeros(length(fnames), minsize);
for idx=1:length(fnames)
    curr=eval(['allrat_residuals.' fnames{idx}]);
    res_matrix(idx,:) = curr(1:minsize);
end;

% now take average
avg_res=zeros(1,cols(res_matrix));
for days=1:cols(res_matrix)
    if inc_empties >0

        empty = find(res_matrix(:,days) == -1);
        res_matrix(empty,days) = 1; % set it to a high residual
        avg_res(days) = mean(res_matrix(:,days));
        std_res(days) = std(res_matrix(:,days));
    else
        nonempty = find(res_matrix(:,days) ~=-1);
        avg_res(days) = mean(res_matrix(nonempty,days));
        std_res(days) = std(res_matrix(nonempty,days));
    end;
end;

set(0,'CurrentFigure',usefig);
l=errorbar(1:length(avg_res), avg_res, std_res,std_res);
%l=plot(1:length(avg_res),avg_res,'-b');
set(l,'Color',curvecolour,'LineWidth',2);



2;

% plot one series of residuals, one line per rat in the series
function [] = sub__mini_plotter(allrat_residuals,curvecolour,usefig);
% plot residuals
if usefig > 0
    set(0,'CurrentFigure',usefig);
else
    figure;
end;
ratcolour={};
fnames = fieldnames(allrat_residuals);

residual_matrix=[];
for idx = 1:length(fnames)

    curr_c = curvecolour;
    currat = fnames{idx};
    eval(['ratcolour.' currat ' = curr_c;']);
    curr_res = eval(['allrat_residuals.' currat ';']);

    %   l   =   plot(find(curr_res >=0), curr_res(find(curr_res>=0)),'.b');hold on;
    l2  =   plot(find(curr_res >=0), curr_res(find(curr_res>=0)),'-b');hold on;
    % l2  =   plot(1:length(curr_res), curr_res,'-b');
    % l3  =   plot(find(curr_res<0), curr_res(find(curr_res <0)), 'xb');

    hold on;
    %            set(l,'Color',curr_c);
    set(l2,'Color',curr_c,'LineWidth',2);
    %set(l3,'Color',curr_c);

    xlim = get(gca,'XLim');
    set(gca,'XLim',[0 max(xlim(2), length(curr_res))],'XTick', 1:1:length(curr_res));
end;

x=xlabel('Day of post-recovery training'); set(x,'FontWeight','bold','FontSize',20);
y=ylabel('%'); set(y,'FontWeight','bold','FontSize',20);
set(gca,'FontSize',16,'FontWeight','bold');



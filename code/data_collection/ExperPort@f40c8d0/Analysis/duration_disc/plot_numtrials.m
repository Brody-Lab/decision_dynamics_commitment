function [] = plot_numtrials(varargin)
pairs = { ...
 %   'plot_seriesavg', 0 ; ... % when set to 1, superimposes the AVERAGE and SD of the attribute being plotted
    'plotval', 'session_numtrials'; ... % key of 'pre' and 'post' structs to plot
    'trial_filter', 'all';... [all | psych_only | nonpsych_only]    
    };
parse_knownargs(varargin,pairs);

ATTR__YLIMS = {};
ATTR__YLIMS.session_hrate = [0.5 1];
ATTR__YLIMS.session_numtrials = [0 400];
ATTR__YLIMS.hrate_numtrials = [0 400];

ATTR__YTICKS = {};
ATTR__YTICKS.session_hrate = 0.5:0.1:1;
ATTR__YTICKS.session_numtrials = 0:50:400;
ATTR__YTICKS.hrate_numtrials = 0:50:400;


area_filter='ACx';
 ratlist = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
% ratlist={'Bilbo'};
avgset={};
for r = 1:length(ratlist)
    ratname = ratlist{r};
    [pre post plf pff] = prepost__avgs(ratname, 'Shraddha','trial_filter',trial_filter);

    eval(['avgset.' ratname ' = {};']);
    eval(['avgset.' ratname '.pre = pre;']);
    eval(['avgset.' ratname '.post = post;']);
% 
%     l=plot(ones(length(post),1) * r, post,'.r'); set(l,'Color',[1 0.5 0],'MarkerSize',20);
%     l=plot(r, post(1),'.r'); set(l,'MarkerSize',20);
end;
f= findobj('Tag','plotfig');
if isempty(f)
figure;
set(gcf,'Position',[200 200 500 500],'Tag','plotfig');

figure;
set(gcf,'Tag','namefig');
end;

buff = [];
for r = 1:length(ratlist)
    prestuff= eval(['avgset.' ratname '.pre.' plotval]);
    ratname = ratlist{r};
    preidx = min(length(prestuff), plf);
    
    set(0,'CurrentFigure',findobj('Tag', 'plotfig'));
l=plot(0-preidx:1:-1,prestuff,'.-r');
c=rand(1,3);
set(l,'Color', c);

hold on;
poststuff= eval(['avgset.' ratname '.post.' plotval]);
l=plot(1:pff,poststuff,'.-r');
set(l,'Color', c);

set(0,'CurrentFigure',findobj('Tag','namefig'));
patch([1 1 2 2], [r r+1 r+1 r],c,'EdgeColor','none');
hold on;
t=text(1, r+0.5,ratname); set(t,'FontWeight','bold','FontSize',14);

end;
    set(0,'CurrentFigure',findobj('Tag', 'plotfig'));
set(gca,'YLim',eval(['ATTR__YLIMS.' plotval]), 'YTick',eval(['ATTR__YTICKS.' plotval]));
    set(0,'CurrentFigure',findobj('Tag', 'namefig'));
    set(gcf,'Position',[1050 360   164   399]);
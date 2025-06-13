function [] = superimpose_psychs_driver()

close all;

% duration pre
series1 = {};
series1.set = 'get_duration_psych';series1.area_filter = 'ACx';
series1.dates = 'psych_before';
series1.dend=3;
series1.lastfew=5;
series1.colourpos = [];
series1.colourtitle = 'Duration rats colours';
series1.figy = 600;
series1.figtitles ='Duration: Last Pre Day';
series1.bgcolor = [0.8 0.8 1];

% duration post
dur_post = series1;
dur_post.dates = 'psych_after';
dur_post.dend=4;
dur_post.figy = 200;
dur_post.figtitles = 'Duration: First post days';


% pitch pre
series2 = {};
series2.set = 'get_pitch_psych';
series2.area_filter = 'mPFC';
series2.dates = 'psych_before';
series2.dend=5;
series2.lastfew=5;
series2.colourpos = [];
series2.figy = 600;
series2.colourtitle = 'Pitch rats colours';
series2.figtitles ='Pitch: Last Pre Day';
series2.bgcolor = [1 0.8 0.8];

% pitch post
pitch_post = series2;
pitch_post.dates = 'psych_after';
pitch_post.dend=3;
pitch_post.lastfew=5;
pitch_post.figy = 200;
pitch_post.figtitles ='Pitch: First Post Day';

% Make function calls
%superimpose_series(series1,0);
ratlist = rat_task_table('','action','get_duration_psych','area_filter','ACx');
for r = 1:length(ratlist)
    ratname = ratlist{r};
%    dur_post.figy = (110 * r);
%     dur_post.figtitles = sprintf('%s: Post: Day',ratname);
%     superimpose_series(dur_post,1,'ratlist',ratname);
   dur_post.figy = (110 * r);
    dur_post.figtitles = sprintf('%s: Post: Day',ratname);
    superimpose_series(dur_post,1,'ratlist',ratname);

end;


% -------------------------------------------------------------------------
% FUNCTION THAT DOES ALL THE WORK (making figures, calling
% superimpose_psych, etc);
function [] = superimpose_series(series_cell,usefirst,varargin)
% usefirst = 1 means 'this is a plot of the first few days in the range'
% if  = 0, means '... of the last few days ...'
pairs = { ...
    'ratlist', {}; ...
    'markdate', 1 ; ... % set to 1 to see date on your graph
    };
parse_knownargs(varargin,pairs);

if isempty(ratlist)
    ratlist = rat_task_table('','action',series_cell.set,'area_filter',series_cell.area_filter);
    markdate = 0;
elseif isstr(ratlist)
    ratlist = {ratlist};
end;

dend = series_cell.dend;
lastfew = series_cell.lastfew;
figy = series_cell.figy;


% set up figures on which to superimpose graphs
f =[];
if usefirst, maxfig = dend; else maxfig=lastfew;end;
wd = 200;ht = 100;
for idx =1:maxfig
    f=horzcat(f,figure);
    xpos = 10+((idx-1)*wd);
    set(gcf,'Position',[xpos figy wd 100],'Menubar','none','Toolbar','none','Color',series_cell.bgcolor);
end;

ratcolour = {};
for r =1:length(ratlist)
    ratname = ratlist{r};

    currcolour = rand(1,3);
    eval(['ratcolour.' ratname ' = currcolour;']);
    fprintf(1,'%s...\n', ratname);
    %     superimpose_psychs(ratname,'use_dateset', 'psych_before', ...
    %         'dend',dend, 'figlist', f,'align2zero',1,'forcecurvecolour',1, ...
    %         'curvecolour', currcolour);
    if usefirst >0
        [fd dates]=superimpose_psychs(ratname,'use_dateset', 'psych_after', ...
            'dend',dend, 'figlist', f,'align2zero',1,'forcecurvecolour',1, ...
            'curvecolour', currcolour);
    else
        [fd dates]=superimpose_psychs(ratname,'use_dateset', 'psych_after', ...
            'lastfew',lastfew, 'figlist', f,'align2zero',1,'forcecurvecolour',1, ...
            'curvecolour', currcolour);
    end;
end;


% title all your figures
wbrctr=1;
for fidx = 1:length(f)
    set(0,'CurrentFigure', f(fidx));
    t=title(sprintf('%s %i', series_cell.figtitles, fidx));
    set(t,'FontWeight','bold','FontSize',12);
    c =get(gca,'Children'); 
    xlim = get(gca,'XLim');
    set(gca,'YLim',[0 1]);
    
    if markdate > 0
% uncomment this area to display weber ratios beside each psych curve
                if ismember(fidx, fd)
            txt = 'n/a';
        else
            txt = sprintf('%1.3f',weber_set1(wbrctr));
            wbrctr=wbrctr+1;
        end;
     %  txt = dates{fidx};   
        xlabel('');
        ylabel('');
        set(gcf,'Color','w');
        set(gca,'YTick',[], 'YGrid','off');
        set(gca,'XTick',[], 'XGrid', 'off');
    else
        txt = sprintf('%i', length(c));
    end;
    t=text(xlim(1)+(0.1*(xlim(2)-xlim(1))), 0.9, txt);
    set(t,'FontSize',20, 'FontWeight','bold','Color','k');%[0.7 0.7 0.7]);

    
end;
% map colours to rats
if markdate == 0
figure;set(gcf,'Position',[1200 100 100 500],'Color',series_cell.bgcolor);
fnames = fieldnames(ratcolour);
for idx=1:length(fnames)
    t=text(1, idx, fnames{idx});
    set(t,'Color', eval(['ratcolour.' fnames{idx}]) ,'FontWeight','bold','FontSize',12);
   
   
end;
t=title(series_cell.colourtitle);
set(t,'FontWeight','bold','FontSize',14);
set(gca,'XLim',[0.5 1.5],'YLim',[0 length(fnames)+1]);
end;

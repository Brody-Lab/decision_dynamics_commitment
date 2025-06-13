function [output_txt] = psych_endpoints_runner(mkover, potpos, varargin)

pairs = {...
    'action','init'; ...
    };
parse_knownargs(varargin,pairs);

persistent ratlist ratnames datelist badfits first__binnedy last__binnedy;

output_txt = '';

switch action
    case 'init'
        ratlist = {};
        ratnames ={};
        datelist = {};
        badfits = {};
        first__binnedy={};
        last__binnedy={};

        fname = 'psych_endpoints_freq';

        if mkover == 0
            load(fname);
            ratnames = {};
            for r = 1:rows(ratlist), ratnames{end+1}= ratlist{r,1}; end;
        else

            ratlist = {'Hatty', '080420','080505' ; ...
                'Rucastle', '080501','080515' ; ...
                'Beryl', '080420','080505' ; ...
                'Grimesby', '080331','080408'; ...
                'Blaze', '080414','080420' ; ...
                };

            ratnames = {};

            first__yy = {}; % each entry is for a rat
            first__binnedy = {};
             last__binnedy = {};
            datelist = {};
            badfits = {};
          
            for r = 1:rows(ratlist)
                ratname = ratlist{r,1};              
                ratnames{end+1} = ratname;
                [binnedy lastbinned dat bad]= psych_endpoints(ratname, 'from', ratlist{r,2}, 'to', ratlist{r,3},'noplot',1);

                first__binnedy{end+1} = binnedy;
                last__binnedy{end+1} = lastbinned;
                datelist{end+1} = dat;
                badfits{end+1} = bad;
                %first__yy{end+1} = yy;
            end;

            save(fname, 'ratlist', 'ratnames', 'datelist', 'badfits', 'first__binnedy','last__binnedy');
        end;

        % plot LAST
        figure;
        datacursormode on;
        dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
        datacursormode on;
            set(dcm_obj, 'Updatefcn', {@psych_endpoints_runner,'action', 'update'});


        miny = 0; maxlen = 0;
        l=line([0 20], [0.8 0.8], 'Color','r','LineStyle',':','LineWidth',2);hold on;      
        l=line([0 20], [0.9 0.9], 'Color',[0.8 0.8 0.8],'LineStyle',':','LineWidth',2);
          ratclr = {};
        for r = 1:rows(ratlist)
            clr = rand(1,3); ratclr{end+1} = clr;            
            p=plot(last__binnedy{r}, '.-r','Color', clr, 'MarkerSize', 25);           
            set(p,'Tag', ratlist{r,1},'ButtonDownFcn', {@psych_endpoints_runner, 'action','plot_psych'});
            
            miny = min(miny, min(last__binnedy{r}));
            maxlen = max(maxlen, length(last__binnedy{r}));
        end;
        xlabel('Session #');
        ylabel('Uppermost binned y''s');
        blank = { '' ,''};
        ratnames = [blank ratnames];
        legend(ratnames,'Location', 'EastOutside');
        title('HIGHEST binned y-vals - freq psych curve');
        miny = floor(miny/0.05);
%         set(gca,'YLim', [0 0.05*miny], 'YTick', 0:0.05:0.05*miny, 'YTickLabel', 0:5:5*ymax);
        set(gca,'XLim', [0 maxlen]);

        axes__format(gca);
        set(gca,'FontSize', 14);
        set(gcf,'Position',[200   100   877   302]);
        
        % plot FIRST binned        
        figure;
        datacursormode on;
        dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle','datatip');
        datacursormode on;
            set(dcm_obj, 'Updatefcn', {@psych_endpoints_runner,'action', 'update'});

        maxy = 0; maxlen = 0;
        l=line([0 20], [0.2 0.2], 'Color','r','LineStyle',':','LineWidth',2);hold on;      
        l=line([0 20], [0.1 0.1], 'Color',[0.8 0.8 0.8],'LineStyle',':','LineWidth',2);      
        for r = 1:rows(ratlist)
            clr = rand(1,3);
            if strcmpi(ratlist{r,1},'Beryl')
                2;
            end;
            p=plot(first__binnedy{r}, '.-r','Color', ratclr{r}, 'MarkerSize', 25);
            
            set(p,'Tag', ratlist{r,1},'ButtonDownFcn', {@psych_endpoints_runner, 'action','plot_psych'});
            
            maxy = max(maxy, max(first__binnedy{r}));
            maxlen = max(maxlen, length(first__binnedy{r}));
        end;
        xlabel('Session #');
        ylabel('Leftmost binned y''s');
     %   blank = { '' ,''};
    %    ratnames = [blank ratnames];
        legend(ratnames,'Location', 'EastOutside');
        title('Lowest binned y-vals - freq psych curve');
        ymax = ceil(maxy/0.05);
        set(gca,'YLim', [0 0.05*ymax], 'YTick', 0:0.05:0.05*ymax, 'YTickLabel', 0:5:5*ymax);
        set(gca,'XLim', [0 maxlen]);

        axes__format(gca);
        set(gca,'FontSize', 14);
        set(gcf,'Position',[200   427   877   302]);
        
        % figure to show any psych curves
        figure;
        set(gcf,'Position',[971    22   433   295],'Menubar','none','Toolbar','none', 'Tag','psychshow');
        

    case 'update'
  evt_obj = potpos;
  lc = get(evt_obj,'Target'); tg = get(lc,'Tag');
  pos = get(evt_obj, 'Position');

  myrow = -1;
  for k = 1:rows(ratlist), if strcmpi(ratlist{k,1},tg), myrow = k; end;end;
  dts = datelist{myrow};
  
  dt = dts{pos(1)};
  
  dstr = [dt(3:4) '-' dt(5:6) '-20' dt(1:2)];
  [dy wkd ] = weekday(dstr);
  
  
  cf = gcf;
     set(0,'CurrentFigure', findobj('Tag','psychshow'));
     clf;
     psychometric_curve(tg, dts{pos(1)}, 'nodist', 1, 'usefig', gcf);
     set(0,'CurrentFigure', cf);
 
  output_txt = [dts{pos(1)} ': ' wkd];
  
    case 'plot_psych'
%      tg =  get(mkover,'Tag');
%      xpos = get(gca,'CurrentPoint');
%      xpos = round(xpos(1,1));
%      
%       myrow = -1;
%   for k = 1:rows(ratlist), if strcmpi(ratlist{k,1},tg), myrow = k; end;end;
%   dts = datelist{myrow};
%   
%     
%      cf = gcf;
%      set(0,'CurrentFigure', findobj('Tag','psychshow'));
%      clf;
%      psychometric_curve(tg, dts{xpos}, 'nodist', 1, 'usefig', gcf);
%      set(0,'CurrentFIgure', cf);
 
    otherwise
        error('invalid option');
end;
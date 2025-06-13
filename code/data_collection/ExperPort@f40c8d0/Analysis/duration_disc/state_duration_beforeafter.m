function [bef aft] = state_duration_beforeafter(ratname,varargin)

pairs = { ...
    'action', 'plotsetdiff'; ... [ save | load ]
    'statelist', {'wait_for_cpoke','wait_for_apoke','extra_iti'}; ...
    'statedesc', {'Trial Initiation', 'Post-Offset Wait'} ; ...
    'followhh', 'all' ; ... [ all | hit | miss ] % see state_duration_sessionavg for description
    'area_filter', 'ACx2' ; ...
    'tasktype','pitch_psych'  ;...
    'use_dateset', 'range' ; ...% range or given
    'given_dateset', {} ; ...
    'drange_bef', [1 1000]; ...
    'drange_aft', [1 3] ; ...
    'lastfew_bef', 7; ...
    'lastfew_aft', 1000 ; ...
    };
parse_knownargs(varargin, pairs);

global Solo_datadir;
indir= [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis'];
infile=[indir filesep ratname '_state_duration_' followhh];

switch action
    case 'save'
        ratrow =rat_task_table(ratname);
        befdates = ratrow{1,rat_task_table('','action','get_prepsych_col')};
        aftdates = ratrow{1,rat_task_table('','action','get_postpsych_col')};

        if strcmpi(use_dateset,'given')
            bef_dateset= filterdates(ratname, 'before',drange_bef(1),drange_bef(2),lastfew_bef);
            aft_dateset= filterdates(ratname, 'after', drange_aft(1),drange_aft(2),lastfew_aft);
        else
            bef_dateset={};
            aft_dateset={};
        end;

        try
            bef=state_duration_daterange(ratname, befdates{1}, befdates{2}, ...
                'statelist', statelist, 'followhh', followhh, ...
                'use_dateset', use_dateset, 'given_dateset', bef_dateset);
        catch
            addpath('Analysis/duration_disc/Event_Analysis/');
            bef=state_duration_daterange(ratname, befdates{1}, befdates{2}, ...
                'statelist', statelist, 'followhh', followhh, ...
                'use_dateset', use_dateset, 'given_dateset', bef_dateset);
        end;
        aft=state_duration_daterange(ratname, aftdates{1}, aftdates{2}, 'statelist', statelist, 'followhh', followhh, ...
            'use_dateset', use_dateset, 'given_dateset', aft_dateset);

        save(infile, 'bef','aft');

    case 'load'
        try
            load(infile);
        catch
            fprintf(1,'%s:%s -- can''t find datafile; resaving.\n', mfilename,ratname);
            state_duration_beforeafter(ratname, 'action', 'save', 'statelist', statelist,'followhh', followhh,'use_dateset',use_dateset, ...
                'given_dateset', given_dateset);
            load(infile);
        end;

        fnames = statelist; %fieldnames(bef);

        datset=cell(length(fnames),2);

        sigp=NaN(length(fnames),2);
        for f=1:length(fnames)
            fprintf(1, '\n>>>>>>>\n%s:%s\n', ratname, fnames{f});
            datset{f,1}= eval(['bef.' fnames{f} ';']);
            datset{f,2}= eval(['aft.' fnames{f} ';']);
            [s p]= permutationtest_diff(datset{f,1}, datset{f,2});
            sigp(f,:) = [s p];
            fprintf(1,'BEF=%2.2fs (%2.2f); AFT=%2.2fs (%2.2f)\n', ...
                mean(datset{f,1}), sem(datset{f,1}), ...
                mean(datset{f,2}), sem(datset{f,2}));
            fprintf(1,'Significance (two-tailed): %i, p=%1.4f)\n', sigp(f,1), sigp(f,2));
            fprintf(1,'<<<<<<\n');

        end;

        xm=NaN(length(fnames),1);
        ysuper=0;
        for f=1:length(fnames)
            [xpos mlist slist]= makebargroups(datset(f,:), [0 0 1; 1 0 0]);
            yval=mlist+slist;
            joinwithsigline(gca,xpos(1,1),xpos(1,2),...
                yval(1,1)*1.2, yval(1,2)*1.3, ...
                max(yval(1,:))*1.3);
            p=sigp(f,2);
            if p < 0.001, stars='***';
            elseif p < 0.01, stars='**';
            elseif p < 0.05, stars='*';
            else stars='ns'; end;
            xm(f)=mean(xpos(1,:));
            if strcmpi(stars(1),'*'), ypos=1.32; else ypos=1.52; end;
            text(xm(f), max(yval(1,:))*ypos, stars,'FontSize',20,'FontWeight','bold');
            
            set(gcf,'Position',  [440   358   560   420]);
            ysuper=max(ysuper, max(yval(1,:))*ypos);
            
            set(gca,'XTick',[]);
            ylabel('seconds');
            title(sprintf('%s:%s', ratname, statedesc{f}));
            axes__format(gca);

        set(gca,'XLim',[xpos(1)-1 xpos(end)+1]);
        set(gca,'YLim',[0 ysuper+0.5]);
        uicontrol('Tag', 'figname', 'Style','text', 'String', ...
            sprintf('%s_%s_statedur', ratname,statelist{f}), 'Visible','off');
            
        end;


    case 'plotsetdiff' % for each state, plot (aft-bef) of a set of rats
        ratset=rat_task_table('','action',['get_' tasktype],'area_filter',area_filter);

        diffset=0;
        for s=1:length(statelist)
            eval(['diffset.' statelist{s} '=[];']);
        end;
        for r=1:length(ratset)
            [bef aft]=state_duration_beforeafter(ratset{r}, 'action', 'getdata','followhh',followhh,'statelist',statelist);
            for s=1:length(statelist)
                tmpb=eval(['bef.' statelist{s} ';']);
                tmpa=eval(['aft.' statelist{s} ';']);
                df = mean(tmpa)-mean(tmpb);

                eval(['diffset.' statelist{s} '= horzcat(diffset.' statelist{s} ', df);']);
            end;
        end;

        figure; xpos=0;
        for s=1:length(statelist)
            dat=eval(['diffset.' statelist{s} ';']);
            basicbar(dat, 'xpos', xpos, 'bcolor',[1 1 1] * 0.5);
            xpos=xpos+2;
        end;


        set(gca,'XTick', 0.5:2:(2*length(statelist)), 'XTickLabel', statelist);
        ylabel('seconds');
        title(sprintf('Difference in state duration\n%s:%s (%s)', tasktype, area_filter, followhh));

    case 'getdata'
        try
            load(infile);
        catch
            fprintf(1,'%s:%s -- can''t find datafile; resaving.\n', mfilename,ratname);
            state_duration_beforeafter(ratname, 'action', 'save', 'statelist', statelist,'followhh', followhh);
            load(infile);
        end;


    otherwise
        error('unknown action.');
end;




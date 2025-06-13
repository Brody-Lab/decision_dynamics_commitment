function [datesused indates] = collect_webers(varargin)
[l h] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
[l2 h2] = calc_pair('d', sqrt(200*500), 0.95,'suppress_out', 1);
[l3 h3] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);

pairs = { ...
    'infile', 'psych' ; ...
    'psychthresh', 1 ; ... % set to 1 to ignore dates where there are < 2 values in a given bin.
    'experimenter','Shraddha'; ...
    % which sessions to analyze? ----------------------------------------
    'master_dstart', 1 ; ...  %first session to analyze from
    'master_dend', 1000; ...  %last session to analyze to
    'lastfew', 7; ...
    % which rat set?
    'area_filter', 'mPFC' ; ...
    'blocks_use', 1 ; ...
    'isflipped', 1 ; ...
    % binning data -----------------------------------------------------
    'binmin_dur', l2 ; ...
    'binmax_dur', h2 ; ...
    'binmin_pitch', l ; ...
    'binmax_pitch', h ; ...
    'num_bins', 8 ; ...
    'justgetdata', 1 ; ... % if true, doesn't plot anything, just assigns data in caller's namespace
    % see comments above for fields assigned
    'pitch', 0 ; ...% set to 1 if using pitch rats
    'action','plot'; ... % can be 'save', 'plot','or 'plotsingle'
    'singlerat', 'Boogie' ; ...
    'clr_singleavg', [1 1 1]*0; ...
    'clr_singlesession', [1 0 0] ; ...
    };
parse_knownargs(varargin,pairs);

if pitch==1, ratgroup='pitch';else ratgroup='duration';end;

ratlist1 = rat_task_table('','action',['get_' ratgroup '_psych'],'area_filter', 'ACx2'); %{ 'Lascar', 'Pips'};
ratlist2=  rat_task_table('','action',['get_' ratgroup '_psych'],'area_filter', 'mPFC'); %{ 'Lascar', 'Pips'};
%ratlist2 = rat_task_table('','action',['get_' ratgroup
%'_psych'],'area_filter', 'mPFC'); %{ 'Lascar', 'Pips'};

preflipped = [ zeros(size(ratlist1)), ones(size(ratlist2))];
blocks_use = [ones(size(ratlist1)) zeros(size(ratlist2))];
ratlist=[ratlist1 ratlist2];


if ~strcmpi(area_filter,'ACx2')
    % blocks_use=0;
    % isflipped=0;
end;

infile = 'psych_before';
num_bins = 8;
experimenter = 'Shraddha';

weberdata ={};
datesused = {};
indates = {};

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;
 outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];     

switch action
    case 'save'
        for r = 1:length(ratlist)
            fprintf(1,'%s ...\n', ratlist{r});
            dstart = master_dstart;
            dend = master_dend;

            ratname = ratlist{r};

            if strcmpi(ratname,'Evenstar')
                binmin_pitch=8;
                binmax_pitch=16;
            end;

            ratrow = rat_task_table(ratname);
            task = ratrow{1,2};
            if strcmpi(task(1:3), 'dur'),
                binmin = binmin_dur;
                binmax = binmax_dur;
                pitch = 0;
                num_bins = 8;
            else
                %         if blocks_use(r) > 0
                binmin = binmin_pitch;
                binmax = binmax_pitch;
                %         else
                %             binmin = l3; binmax = h3;
                %         end;
                pitch = 1;
                numbins = 9;
            end;

            % get the data
            outdir = [Solo_datadir filesep 'Data' filesep experimenter filesep ...
                ratlist{r} filesep];
            fname = [outdir infile '.mat'];
            try
                load(fname);
            catch
                savepsychinfo(ratname);
                load(fname);
            end;

            % filter which days to use
            % -----------------------------------
            % Variables to filter a range of sessions
            % in your dataset >> BEGIN
            dend = min(dend, rows(dates));
            cumtrials = cumsum(numtrials(1:dend));
            lastidx = cumtrials(end);
            startidx = 1;

            if lastfew < 1000
                lastfew = min(rows(dates), lastfew);
                dstart = rows(dates)-(lastfew-1);
            end;

            if dstart > 1
                startidx= cumtrials(dstart-1) +1;
            end;
            fprintf(1,'*** %s: Date filter: Using Day %i to Day %i (Trials %i to %i)\n', mfilename, dstart, dend, startidx, lastidx);
            % << END filtering session dates

            dates = dates(dstart:dend);
            fprintf(1, '\tDates used in analysis:\n');
            dates

            numtrials = numtrials(dstart:dend);
            rxn= rxn(dstart:dend);

            fnames = {'logdiff','hit_history','logflag','psychflag', 'left_tone', 'right_tone', 'side_list', 'events','timeout_count_var'};
            for f =1:length(fnames)
                if exist(fnames{f},'var')
                    %  fprintf(1,'\t%s\n', fnames{f});
                    eval([fnames{f} ' = ' fnames{f} '(startidx:lastidx);']);
                end;
            end;

            str= [ 'indates.' ratlist{r} '= dates;'];
            eval(str);

            % compute psych_oversessions
            if blocks_use(r) > 0 && exist('blocks_switch','var') && (sum(isnan(blocks_switch)) == 0) % a file created since blocks_switch was created
                try
                    if length(blocks_switch) < cumtrials(end)
                        if exist('psychflag','var')
                            blocks_switch = psychflag(startidx:lastidx);
                        end;
                    else
                        blocks_switch = blocks_switch(startidx:lastidx);
                    end;
                catch
                    error('uh oh, blocks_Switch is throwing an error...');
                end;
                if length(blocks_switch) == length(hit_history) % blocks_switch was implemented for this rat.
                    psychflag = blocks_switch;
                else
                    error('Blocks Switch should have the same dimension as hit_history.');
                end;
            end;

            in={};
            myf = {'hit_history', 'numtrials','binmin','binmax','dates'};
            for f = 1:length(myf)
                eval(['in.' myf{f} ' = ' myf{f} ';']);
            end;

            if preflipped==0
                in.flipped = flipped;
            else
                in.flipped=zeros(size(hit_history));
            end;

            in.ltone=left_tone;
            in.rtone=right_tone;
            in.slist = side_list;
            in.psych_on = psychflag;
            %
            %     out.tallies , out.replongs , out.xcomm , out.xmid , out.xfin
            % out.weber , out.overall_betahat , out.overall_xc , out.overall_xf
            % out.overall_xmid out.overall_weber, out.overall_ci,
            % out.psychdates ,out.logtones,
            % out.bins ,out.failed_dates
            out = psych_oversessions(ratname,in, ...
                'justgetdata',1,'pitch', pitch,'num_bins', num_bins,'noplot',1);
            eval(['weberdata.' ratlist{r} '= out;']);
            tmp = out.psychdates;
            if ~isempty(tmp),
                str= [ 'datesused.' ratlist{r} '= dates(tmp);'];
                eval(str);
            else
                eval(['datesused.' ratlist{r} '= {};']);
            end;
        end;
        save([outdir 'weberout_' ratgroup], 'weberdata','datesused');
        
    case 'plotsingle'
               if pitch==0,
                binmin = binmin_dur;
                binmax = binmax_dur;
                pitch = 0;
                num_bins = 8;
            else
                %         if blocks_use(r) > 0
                binmin = binmin_pitch;
                binmax = binmax_pitch;
                %         else
                %             binmin = l3; binmax = h3;
                %         end;
                pitch = 1;
                numbins = 9;
            end;
              
        load([outdir 'weberout_' ratgroup]);
        
        curr = eval(['weberdata.' singlerat '.weber;']);
        
        try
            x=makebargroups({curr},clr_singleavg); hold on;
        catch
            addpath('Analysis/duration_disc/graphicutil/');
            x=makebargroups({curr},clr_singleavg); hold on;
        end;
        
        plot(ones(size(curr))*x, curr, '.r','Color',clr_singlesession,'MarkerSize',10);
        
        ratrow=rat_task_table(singlerat); task=ratrow{1,2};
        if strcmpi(task,'duration_discobj'), task='d'; else task='p'; end;
        fmt_d = '3.0';
        fmt_p = '1.1';        
        
        str=['Mean=%2.2f (%' eval(['fmt_' task]) 'f) ; SD = %2.2f (%' eval(['fmt_' task]) 'f)'];
        fprintf(1,str, ...
            mean(curr), jnd(mean(curr),task), ...
            std(curr), jnd(std(curr),task));
        
           ylabel('Weber ratio');
        title(['Weber ratio for week pre-lesion: ' strrep([ratgroup ': ' singlerat], '_', ' ')]);

        sub__formataxes(gca);

        set(gca,'YTick', 0:0.05:0.3);
        ytkraw = get(gca,'YTick') * sqrt(binmin*binmax);
        if pitch>0
            ytkraw=round(ytkraw*10)/10;
            unt='kHz';
        else
            ytkraw= round(ytkraw*10)/10;
            unt='ms';
        end;
        set(gca,'FontSize', 14,'FontWeight','bold','XTick',[], ...
            'XLim',[-1 2], 'YLim',[0 0.4], ...
            'Position',[0.15 0.1 0.65 0.8]);
        ax2=axes('Position',get(gca,'Position'), ...
            'YAxisLocation','right', ...
            'Color','none', 'XTick',[],'YTick', get(gca,'YTick'),...
            'XLim',get(gca,'XLim'), 'YLim', get(gca,'YLim'), ...
            'YTickLabel', ytkraw,'FontSize',14, 'FontWeight','bold');
        set(get(ax2,'YLabel'), 'String', sprintf('JND (%s)', unt));
        sub__formataxes(ax2);
        sign_fname(gcf,mfilename);
        
        2;

    case 'plot'
            if pitch==0,
                binmin = binmin_dur;
                binmax = binmax_dur;
                pitch = 0;
                num_bins = 8;
            else
                %         if blocks_use(r) > 0
                binmin = binmin_pitch;
                binmax = binmax_pitch;
                %         else
                %             binmin = l3; binmax = h3;
                %         end;
                pitch = 1;
                numbins = 9;
            end;
              
        load([outdir 'weberout_' ratgroup]);
        % Now plot data ------------------------------
        % Figure 1 - Each rat's weber distribution

        allrat_overalls =[]; % collection of each rat's pooled weber

        close all;
        ax=axes;
        maxie = 0;
        meanie=NaN(size(ratlist));% mean webers
        sadie=NaN(size(ratlist));
        weberset=cell(size(ratlist));
        for r = 1:length(ratlist)
            curr = eval(['weberdata.' ratlist{r} ';']);

            ov = curr.overall_weber; distro = curr.weber; distro=distro(find(distro ~= -1));
            maxie = max(maxie, max(distro)); maxie = max(maxie, ov);

                        if sum(sign(distro)) == -1 * length(distro) % all negative, flipped rat
                distro=distro*-1;
            end;

            weberset{r}=distro;
                
            sd = nanstd(distro); m = nanmean(distro);
            meanie(r)=m; sadie(r)=sd;
            %     patch([r-0.2 r-0.2 r+0.2 r+0.2], [m-sd m+sd m+sd m-sd], [0.8 0.8 1],'EdgeColor','none'); hold on;
            %     l=line([r-0.2 r+0.2], [ov ov],
            %     'Color','r','LineWidth',3); % pooled weber
            %     line([r-0.2 r+0.2], [m m], 'Color',[0 0 0.5], 'LineWidth',2); % mean of individual days
            %     plot(r * ones(size(distro)), distro, '.b', 'MarkerSize',20);
            allrat_overalls = horzcat( allrat_overalls, ov);
        end;

        if cols(weberset)>1, weberset=weberset';end;
        if pitch > 0, 
            clr = group_colour('frequency'); ttype='pitch';
        else
            clr = group_colour('duration'); ttype='duration';end;
        try
            makebargroups(weberset,clr_singleavg); hold on;
        catch
            addpath('Analysis/duration_disc/graphicutil/');
            makebargroups(weberset,clr_singleavg); hold on;
        end;

        xtks=(0:3:(length(ratlist)-1)*3)+0.5;
        for r=1:length(ratlist)
            plot(ones(size(weberset{r}))*xtks(r), weberset{r},'.r','Color', clr_singlesession,...
                'MarkerSize',10);
        end;

        set(gca,'XLim', [-0.5 (length(ratlist)*3)+0.5], 'YLim',[0 0.4]);
        set(gca,'XTick',xtks, 'XTickLabel', 1:length(ratlist), 'YTick', 0:0.1:0.5);
        xlabel('Individual animals');
        ylabel('Weber ratio');
        title(['Weber ratio for week pre-lesion: ' strrep([ratgroup ': ' area_filter], '_', ' ')]);

        sub__formataxes(gca);

        ytkraw = get(gca,'YTick') * sqrt(binmin*binmax);
        if pitch>0
            ytkraw=round(ytkraw*10)/10;
            unt='kHz';
        else
            ytkraw= round(ytkraw*10)/10;
            unt='ms';
        end;
        yl=get(gca,'YLim'); ytk=get(gca,'YTick');
        set(gca,'FontSize', 14,'FontWeight','bold','Position',[0.1 0.2 0.8 0.65]);
        ax2=axes('Position',get(gca,'Position'), ...
            'YAxisLocation','right', ...
            'Color','none', 'XTick',[],'YTick', get(gca,'YTick'),...
            'XLim',get(gca,'XLim'), 'YLim', get(gca,'YLim'), ...
            'YTickLabel', ytkraw,'FontSize',14, 'FontWeight','bold');
        set(get(ax2,'YLabel'), 'String', sprintf('JND (%s)', unt));
        sub__formataxes(ax2);
%         sign_fname(gcf,mfilename);

%         set(gcf,'Position',[440   482   150*length(ratlist)   252]);
        set(gcf,'Position',[360   596   708   262]);
        
         uicontrol('Tag', 'figname', 'Style','text', 'String', ['weber_prelesion_' ttype '_indiv'], 'Visible','off');

        % Figure 2 --- Distribution of overall webers (one point per rat)
        x = allrat_overalls;

        makebargroups({allrat_overalls}, clr);hold on;
        plot(ones(size(x))*0.5, x, 'or', 'MarkerSize',7,'LineWidth',1.3,'Color',clr_singleavg);

        axpos=[0.25 0.1 0.4 0.8];
        set(gca,'XTick',[], 'XLim',[-0.2 1.5],...
            'YTick', ytk,'YLim',yl,...
            'Position',axpos);
        xlabel(ttype); ylabel('Weber ratio');

        ytkraw = get(gca,'YTick') * sqrt(binmin*binmax);
        if pitch>0
            ytkraw=round(ytkraw*10)/10;
        else
            ytkraw= round(ytkraw*10)/10;
        end;
        axes__format(gca);

        ax2=axes('Position',axpos, ...
            'YAxisLocation','right', ...
            'Color','none', 'XTick',[],'YTick', get(gca,'YTick'),...
            'XLim',get(gca,'XLim'), 'YLim', get(gca,'YLim'), ...
            'YTickLabel', ytkraw,'FontSize',14, 'FontWeight','bold');
        set(get(ax2,'YLabel'), 'String', sprintf('JND (%s)', unt));

        title(['Distribution of pooled webers: ' strrep([ratgroup ': ' area_filter], '_', ' ')]);

        axes__format(ax2);
        set(get(gca,'Title'),'FontSize',14);
%         sign_fname(gcf,mfilename);
%         set(gcf,'Position',[ 42   240   412   279]);
set(gcf,'Position',[1020         602         300         327]);
 uicontrol('Tag', 'figname', 'Style','text', 'String', ['weber_prelesion_' ttype '_group'], 'Visible','off');

        % Now print textual output
        sep = repmat('*',1, 100);
        fprintf(1, '%s\n', sep);
        fprintf(1,'Group name:%s\nArea: %s\n',ratgroup, area_filter);
        fprintf(1,'# rats = %i\n', length(ratlist));
        fprintf(1,'Pooled weber = %2.2f +/- %2.2f\n', mean(x), std(x));
        fprintf(1, '%s\n', sep);

    otherwise
        error('unknown action');
end;


function [] = sub__formataxes(a) %axis handle
t = get(a,'XLabel');
set(t,'FontSize', 14, 'FontWEight','bold');
t = get(a,'YLabel');
set(t,'FontSize', 14, 'FontWEight','bold');
t = get(a,'Title');
set(t,'FontSize', 14, 'FontWEight','bold');



function [] = showprogress2final(ratname,varargin)

pairs = { ...
    'infile', 'taskprogress' ; ...
    'experimenter','Shraddha' ; ...
    'action','load' ; ...
    'date_lims', [1 1000] ; ...
    'datatype', 'finaltask'; ... [ finaltask | sharpening]
    }
parse_knownargs(varargin, pairs);

% load paths, make filename --------------------------------------
global Solo_rootdir;
global Solo_datadir;
if isempty(Solo_rootdir), mystartup; end;
stat_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'stat_sandbox'];
event_analysis_dir = [Solo_rootdir filesep 'Analysis' filesep 'duration_disc' filesep 'Event_Analysis'];

if ~is_in_path(stat_dir)
    fprintf(1,'Adding stat_sandbox to path ...\n');
    addpath(stat_dir);
    addpath(event_analysis_dir);
end;

outdir = [Solo_datadir filesep 'Data' filesep];
outdir = [outdir experimenter filesep ratname filesep];

if strcmpi(action,'save_finaltask') || strcmpi(action,'load_finaltask')
    if ~strcmpi(datatype, 'sharpening')
        infile = 'finaltask';
    end;
end;

%if strcmpi(action(1:4),'load'), action = 'load'; end;
fname = [outdir infile];
fprintf(1,'File: %s\n',fname);

switch action
    case 'save_finaltask' %save info from spl randomization to sharpening onset.
        % look up dates for logdiff from rat table


        ratrow = rat_task_table({ratname});
        task = ratrow{1,2};

        if strcmpi(datatype,'sharpening')
            sharpdates = ratrow{1,rat_task_table('','action','get_sharp_col')};
            from = sharpdates{1}; to= sharpdates{2};
        else
            to_final = ratrow{1,rat_task_table('','action','get_basictask_col')};
            to_sharp = ratrow{1,rat_task_table('','action','get_sharp_col')};
            from = to_final{2}; to = to_sharp{1};

        end;
        if strcmpi(to,'999999'),  to = yearmonthday;  end;

        fprintf(1,'\tDates are from %s to %s...',from,to);
        dates = get_files(ratname, 'fromdate', from, 'todate', to);

        fields = {'SPL_mix', 'blocks_switch','Tone_Loc','GO_Loc','tone_spl','go_spl',...
            'vpd','logdiff','left_prob'};

        if strcmpi(task(1:3),'dur')
            fields(end+1:end+2)={'dur_short','dur_long'};
        else
            fields(end+1:end+2)={'pitch_low','pitch_high'};
        end;

        get_fields(ratname, 'task',task, 'from', from, 'to',to,'datafields',fields);

        if strcmpi(task(1:3),'dur')
            save(fname, 'dates','hit_history','numtrials', 'SPL_mix', 'Tone_Loc','GO_Loc',...
                'vpd','dur_short','dur_long','logdiff',...
                'tone_spl','go_spl','blocks_switch','left_prob');
        else
            save(fname, 'dates','hit_history','numtrials', 'SPL_mix', 'Tone_Loc','GO_Loc',...
                'vpd','pitch_low','pitch_high','logdiff',...
                'tone_spl','go_spl','blocks_switch','left_prob');
        end;

    case 'save'
        % look up dates for logdiff from rat table
        ratrow = rat_task_table({ratname});
        task = ratrow{1,2};

        sdates = ratrow{1,rat_task_table('','action','get_basictask_col')};
        from = sdates{1}; to = sdates{2};
        if strcmpi(to,'999999'),  to = yearmonthday;  end;

        fprintf(1,'\tDates are from %s to %s...',from,to);
        dates = get_files(ratname, 'fromdate', from, 'todate', to);

        fields = {'SPL_mix', 'blocks_switch','Tone_Loc','GO_Loc','tone_spl','go_spl','vpd','logdiff','left_prob'};

        if strcmpi(task(1:3),'dur')
            fields(end+1:end+2)={'dur_short','dur_long'};
        else
            fields(end+1:end+2)={'pitch_low','pitch_high'};
        end;

        get_fields(ratname, 'task',task, 'from', from, 'to',to,'datafields',fields);

        if strcmpi(task(1:3),'dur')
            save(fname, 'dates','hit_history','numtrials', 'SPL_mix', 'Tone_Loc','GO_Loc',...
                'vpd','dur_short','dur_long','logdiff',...
                'tone_spl','go_spl','blocks_switch','left_prob');
        else
            save(fname, 'dates','hit_history','numtrials', 'SPL_mix', 'Tone_Loc','GO_Loc',...
                'vpd','pitch_low','pitch_high','logdiff',...
                'tone_spl','go_spl','blocks_switch','left_prob');
        end;

    case 'print_stats'
        load(fname);


        % Summary printout
        b='-'; llen =100;
        fprintf(1,'%s\n',repmat(b,1,llen));
        fprintf(1,'%s: %i sessions\n',ratname,length(dates));
        fprintf(1,'Date range: %s  to %s\n', dates{1},dates{end});
        fprintf(1,'%s\n',repmat(b,1,llen));


    case 'load'

        ratrow = rat_task_table({ratname});
        task = ratrow{1,2};
        load(fname);

        % -------------------
        % fields are:
        %'dates','hit_history','numtrials', 'SPL_mix',
        %'Tone_Loc','GO_Loc','vpd','dur_short','dur_long','blocks_switch');
        fromnum = min(date_lims(1), length(numtrials));
        tonum = min(date_lims(2), length(numtrials));

        if strcmpi(task(1:3),'dua'),
            dur_short = pitch_low;
            dur_long = pitch_high;
        end;

        % get date ranges
        fnames ={'SPL_mix', 'Tone_Loc','GO_Loc','vpd','dur_short','dur_long',...
            'tone_spl','go_spl','blocks_switch','hit_history','logdiff','left_prob'};
        dates = dates(fromnum:tonum);
        cumtrials = cumsum(numtrials);
        numtrials = numtrials(fromnum:tonum);

        if fromnum == 1, cumfrom=1; else cumfrom = cumtrials(fromnum-1)+1;end;
        cumto=cumtrials(tonum);
        for idx = 1:length(fnames)
            eval([fnames{idx} ' = ' fnames{idx} '(cumfrom:cumto);']);
        end;


        figure;
        set(gcf,'Toolbar','none','Position',[100 200 800 500]);

        % plot tone loc and go loc
        axes('Position',[0.1 0.1 0.8 0.1]);
        l=plot(1:length(Tone_Loc),Tone_Loc, '.b',1:length(GO_Loc),GO_Loc,'-g');
        for idx = 1:length(l),(set(l(idx),'LineWidth',2)); end;
        set(gca,'YLim',[-1 2],'YTick',[0 1],'YTickLabel',{'off','on'},'Color',[1 1 0.8]);
        draw_separators(numtrials,-1, 2);
        t=ylabel(sprintf('Loc\nswitch'));
        set(t,'FontWeight','bold','FontSize',10);
        xlabel('Trial #');

        % plot tone and GO SPL
        axes('Position',[0.1 0.2 0.8 0.1]);
        l=plot(1:length(tone_spl),tone_spl, '.b',1:length(go_spl),go_spl,'-g');
        set(l,'LineWidth',2);
        maxie=max(max(go_spl),max(tone_spl));
        draw_separators(numtrials,0,maxie);
        set(gca,'GridLineStyle','none','XTick',[]);
        set(gca,'YLim',[0 maxie+5],'YTick',25:25:75,'Color',[1 1 0.8]);
        draw_separators(numtrials,0,maxie+5);
        t=ylabel(sprintf('SPL\n'));
        set(t,'FontWeight','bold','FontSize',10);

        % plot SPLmix
        axes('Position',[0.1 0.3 0.8 0.1]);
        l=plot(1:length(SPL_mix),SPL_mix, '-b');
        set(l,'LineWidth',2);
        title('SPL_mix');
        draw_separators(numtrials,0,max(vpd));
        set(gca,'GridLineStyle','none','YTick',[],'XTick',[]);
        set(gca,'YLim',[-1 2],'YTick',[0 1],'YTickLabel',{'off','on'});
        draw_separators(numtrials,-1, 2);
        t=ylabel(sprintf('SPLmix\nswitch'));
        set(t,'FontWeight','bold','FontSize',10);

        % plot tone duration
        axes('Position',[0.1 0.4 0.8 0.15]);
        %         l=plot(1:length(dur_short),dur_short,'.r', 1:length(dur_long), dur_long,'-b');
        %         set(gca,'GridLineStyle','none','XTick',[]);
        %         set(gca,'YLim',[-0.1 0.6],'YTick',0:0.2:0.6);
        %         t=ylabel(sprintf('Cue\ndur (s)'));
        %         set(t,'FontWeight','bold','FontSize',10);

        %        l=plot(logdiff,'-g');hold on;
        l=plot(left_prob,'-g'); set(l,'Color',[1 0.5 0]); hold on;
        %         diffs = diff(logdiff);
        %         idx=find(diffs ~=0);
        %         for i=1:length(idx)
        %             line([idx(i)+1 idx(i)+1], [0 1],'Color','b','LineWidth',2);
        %         end;
        set(gca,'GridLineStyle','none','XTick',[]);
        set(gca,'YLim',[0 1],'YTick',0.25:0.25:1);
        t=ylabel('LeftProb');
        set(t,'FontWeight','bold','FontSize',10);


        draw_separators(numtrials,0, 1);

        % plot vpdlist
        %         axes('Position',[0.1 0.55 0.8 0.1]);
        %         l=plot(1:length(vpd),vpd, '.k');set(l,'Color',[0.3 0.3 0.3]);
        %         draw_separators(numtrials,0,max(vpd));
        %         set(gca,'GridLineStyle','none','XTick',[]);
        %         set(gca,'YTick',0:0.2:1.5,'YLim',[0 max(vpd)+0.2]);
        %         t=ylabel('VPD (seconds)');
        %         set(t,'FontWeight','bold','FontSize',10);
        %                     text(1,max(vpd)+0.05,sprintf('%s (%i)', dates{1},1));
        %                     offset=0;
        %                 for k = 6:5:length(dates)
        %                     newadd = sum(numtrials(k-5:k-1));
        %                     offset=offset+newadd;
        %             text(offset,max(vpd)+0.05,sprintf('%s (%i)',dates{k}, k));
        %                 end;

        % plot hit rate
        axes('Position',[0.1 0.55 0.8 0.4]);
        sub__plot_hitrate(dates,hit_history, numtrials,fromnum);
        draw_separators(numtrials,0,1);

        t=title(sprintf('%s: Progress over days to final task',ratname));
        set(t,'FontWeight','bold','FontSize',14);


        child = get(gcf,'Children');
        for cidx=1:length(child), if strcmpi(get(child(cidx),'Type'),'axes'),
                set(child(cidx),'XLim',[1 length(logdiff)]);
            end;
        end;

        % Summary printout
        b='-'; llen =100;
        fprintf(1,'%s\n',repmat(b,1,llen));
        fprintf(1,'%s: %i sessions\n',ratname,length(dates));
        fprintf(1,'Date range: %s  to %s\n', dates{1},dates{end});
        fprintf(1,'%s\n',repmat(b,1,llen));

        set(gcf,'Position', [-1296         355        2339         535]);

    case 'load_sharpening'
        ratrow = rat_task_table(ratname);
        task = ratrow{1,2};

        if strcmpi(task(1:3),'dur')
            binmin = 200; binmax=500;
            ttype = 'd';
        else
            binmin = 8; binmax = 16;
            ttype='p';
        end;

        load(fname);

        % -------------------
        % fields are:
        %'dates','hit_history','numtrials', 'SPL_mix', 'Tone_Loc','GO_Loc',...
        %'vpd','pitch_low','pitch_high','logdiff',...
        %'tone_spl','go_spl','blocks_switch','left_prob');
        fromnum = min(date_lims(1), length(numtrials));
        tonum = min(date_lims(2), length(numtrials));

        if strcmpi(task(1:3),'dur')
            mylow='dur_short';
            myhigh='dur_long';
            myunits = 'ms';
        else
            mylow='pitch_low'; myhigh='pitch_high';
            myunits = 'kHz';
        end;
        fnames ={'SPL_mix', 'Tone_Loc','GO_Loc','vpd',mylow,myhigh,...
            'tone_spl','go_spl','blocks_switch','hit_history','logdiff','left_prob'};
        dates = dates(fromnum:tonum);
        cumtrials = cumsum(numtrials);
        numtrials = numtrials(fromnum:tonum);

        if fromnum == 1, cumfrom=1; else cumfrom = cumtrials(fromnum-1)+1;end;
        cumto=cumtrials(tonum);
        for idx = 1:length(fnames)
            eval([fnames{idx} ' = ' fnames{idx} '(cumfrom:cumto);']);
        end;

        % Start plotting
        figure;
        set(gcf,'Toolbar','none','Position',[100 200 1000 500]);

        t= sum(numtrials);

        %         % plot psych flag / cue values
        axes('Position',[0.05 0.05 0.9 0.2]);
        [lpair rpair] = calc_pair(ttype, sqrt(binmin*binmax), logdiff,'suppress_out',1);
        %    plot(lpair,'-b'); hold on; plot(rpair,'-r');
        cuesep = rpair-lpair;
        plot(cuesep,'-b');

        ylabel(sprintf('Cue separation (%s)', myunits));
        set(gca,'XLim',[1 t],'FontSize',18,'FontWeight','bold', 'YLim',[min(cuesep)*0.9 max(cuesep)*1.1],...
            'YGrid','on');
        ylim = get(gca,'YLim');
        draw_separators(numtrials,ylim(1),ylim(2));

        %         plot(blocks_switch,'-g'); set(gca,'YLim',[-1 2], 'YTick',[0 1],'YTickLabel',{'off','on'});
        % plot logdiff
        logaxes=axes('Position',[0.05 0.25 0.9 0.3]);
        patch([0 0 t t], [0 0.7 0.7 0],[1 1 0.6],'EdgeColor','none');hold on;
        l=plot(logdiff, '.k');
        ylabel('Logdiff');
        line([1 sum(numtrials)],[0.7 0.7],'LineStyle',':','Color',[0.7 0.4 0],'LineWidth',2);
        draw_separators(numtrials,0,1);
        set(gca,'XLim',[1 t],'FontSize',18,'FontWeight','bold',...
            'YGrid', 'on','YLim', [0.4 0.9],'YTick', [0.5 0.7],...
            'XTick',[]);

        % plot hit rate
        axes('Position',[0.05 0.55 0.9 0.37]);
        hh_chunks=sub__plot_hitrate(dates,hit_history, numtrials,fromnum);
        draw_separators(numtrials,0,1);
        set(gca,'XLim',[1 t],'FontSize',18,'FontWeight','bold');
        set(gca,'YTick',0.5:0.25:1, 'YTickLabel',50:25:100,'XTick',[],'YLim',[0.75 1]);
        [allcontigsof7 contigpos goodcontig dto7 dtopsych] = sub__get_7_breakpoint(hh_chunks, logdiff, cumtrials);
        fprintf('%s:\n\tTotal days=%i\n\t# contigs of 0.7:%i\n\tDays to learn 0.7=%i\n\tFrom there to psych=%i\n\n',...
            ratname,  length(numtrials), length(allcontigsof7),dto7, dtopsych);

        t=title(sprintf('%s: Sharpening progress', ratname));
        set(t,'FontSize',16,'FontWeight','bold');
        
%        figure; hist(allcontigsof7);
        
        % paint contigs on logaxis
        set(gcf,'CurrentAxes', logaxes);
        hold on;
        for k = 1:rows(contigpos)
            idx = contigpos(k,1):contigpos(k,2);
            plot(idx, logdiff(idx),'.b');
        end;
                    idx = goodcontig(1):goodcontig(2);
        plot(idx, logdiff(idx),'.g');
        
    otherwise
        error('invalid action');
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subroutines
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Draws vertical lines separating session info
function [] = draw_separators(numtrials,low,hi);
offset=0;
for k = 1:length(numtrials),
    offset=offset+numtrials(k);
    line([offset offset], [low hi], 'LineStyle','-', 'Color',[0.8 0.8 0.8]);
end


% Calculates and plots hit rate
function [super_chunked] = sub__plot_hitrate(dates,hit_history,numtrials,fromnum)

trials_so_far=0;
super_chunked={};
mean_hh=[];
numchunks=[];
for s = 1:length(numtrials)
    sidx = trials_so_far + 1;
    eidx = (sidx + numtrials(s))-1;

    % use only vars from current session before filtering
    curr_hh = hit_history(sidx:eidx);
    out = hrate_over_time(curr_hh);
    if length(out.chunked_hh) == 0 % not a single chunk
        fprintf(1,'Ignoring %s; not enough chunks\n', dates{s});
        numchunks = horzcat(numchunks, length(out.chunked_hh));
        super_chunked{end+1} = [];
    else
        super_chunked{end+1} = out.chunked_hh;
        mean_hh = vertcat(mean_hh, out.overall_hh);
        trials_so_far = trials_so_far + numtrials(s);
        numchunks = horzcat(numchunks, length(out.chunked_hh));
        % fprintf('%s has %i trials and %i chunks\n',dates{s}, length(idx), numchunks(end));
    end;
end;
window = out.window; % window is the same for all so we can just pick the last one.

chunks_so_far = 0;
valid=0;
prevdate = 0;
superidx=0;
daynum=fromnum;
for k = 1:length(numchunks)
    fprintf(1,'%i: %i\n', k, chunks_so_far);
    if numchunks(k) == 0,
        %mp = mean([chunks_so_far  chunks_so_far+1]);
        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k');hold on;
        t=text(chunks_so_far+0.5, 0.55, 'X'); set(t,'FontSize',8,'Color','r', 'FontWeight','bold');
        chunks_so_far = chunks_so_far+0;
        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k');
    else
        superidx=superidx+1;
        valid=valid+1;
        hh_chunk = super_chunked{superidx};

        start_chunk = chunks_so_far+1;
        end_chunk = (start_chunk + length(hh_chunk))-1;

        currdate = dates{valid}(1:6);
        if k > 1
            datediff = str2double(currdate) - str2double(prevdate);
            if datediff ~= 1
                patch([start_chunk start_chunk end_chunk end_chunk], ...
                    [0.52 0.98 0.98 0.52], [0.8 1 0.8],'EdgeColor','none');
            end;
        end;

        plot(start_chunk:end_chunk, hh_chunk, '-r');
        hold on;
        mp = mean([chunks_so_far  chunks_so_far+length(hh_chunk)]);
        chunks_so_far = chunks_so_far + length(hh_chunk);

        line([chunks_so_far+0.5 chunks_so_far+0.5], [0 1],'LineStyle',':','Color','k','LineWidth',2);
        datetmp = dates{valid}; datetmp = datetmp(3:6);
        if end_chunk-start_chunk > 15
            t=text(start_chunk, 1.05, sprintf('%s - %i%%', dates{k},round(mean_hh(valid,1)*100)));
            set(t,'FontWeight','bold','FontSize',9);
        end;
        t2=text((start_chunk+end_chunk)/2, 1, sprintf('%i',daynum));
        set(t2,'FontSize',14, 'Color','r','FontWeight','bold');

        prevdate = dates{valid}(1:6);
        daynum=daynum+1;
    end;
end;

xlim =get(gca,'XLim');
line(get(gca,'XLim'), [0.8 0.8], 'LineStyle',':','Color','k');
line(get(gca,'XLim'), [0.9 0.9], 'LineStyle',':','Color','b');
set(gca,'YLim',[0.5 1.1]);

function [allcontigsof7 contigpos goodcontig dto7 dtopsych] = sub__get_7_breakpoint(hh_chunks, logdiff,cumtrials)

dto7 = length(cumtrials); %baseline assumption is that animal hasn't learned 0.7 octave separation
dtopsych = 0;
allcontigsof7=[]; % sizes of all contigs of 0.7, regardless of the performance therein.
contigpos=[];
for d = 1:length(cumtrials)
    sidx=1;
    if d>1, sidx = cumtrials(d-1)+1; end;
    eidx = cumtrials(d);

    currhh = hh_chunks{d};
    if ~isempty(currhh)
        if length(currhh) > 30
            currhh = currhh(31:end);
            currlog = logdiff(sidx:eidx);
            currlog = currlog(31:end);
            logidx= find(currlog == 0.7);
            hhidx = find(currhh > 0.85);
            idx = logidx;%intersect(hhidx,logidx);
            if ~isempty(idx) % there is point in the session where logdiff
                % is at 0.7 and hit rate is above 85%
               
                if (length(currhh) - min(idx)) > 30 % there are atleast 30 more trials left in the session
                    contigs = diff(idx);
                    breaks = find(contigs > 1);

                    contiglen = 0; maxfirst=0; maxlast=0;
                    if isempty(breaks) % one stretch of 0.7 only
                        contiglen = length(idx);
                        maxfirst=1; maxlast=contiglen;
                        
                        if contiglen > 20
                             allcontigsof7 = horzcat(allcontigsof7, contiglen); 
                             firstidx = (sidx+30+idx(1))-1;
                             lastidx = (sidx+30+contiglen)-1;
                             contigpos = vertcat(contigpos, [firstidx lastidx]);
                        end;
                        
                        goodidx = intersect(1:length(idx), hhidx);                        
                        if length(goodidx)>20   % if there are at least 20 trials 
                                                %that have a hit rate > 85%
                        dto7 = d; % days to learn 0.7 octave separation
                        dtopsych = length(cumtrials)-d; % days to psych starting from that point
                                                goodcontig = contigpos(end,:);
                        return;
                        % to the end of
                        % sharpening
                        % (not
                        % including
                        % that day)
                        end;

                    else % there is at >1 contig. Take all of them
                        firstpos =1; lastpos=0;
                        for b = 1:length(breaks)
                            if b > 1, firstpos = breaks(b)+1; end;
                            if b < length(breaks), lastpos = breaks(b+1); else lastpos = length(idx); end;
                            % at this point we have the biggest contig of 0.7
                   
                    % make sure it is atleast 20 trials long
                    if ((lastpos-firstpos)+1) > 20
                        allcontigsof7 = horzcat(allcontigsof7, (lastpos-firstpos)+1);                   
     firstidx = (sidx+30+firstpos)-1;
                             lastidx = (sidx+30+lastpos)-1;
                             contigpos = vertcat(contigpos, [firstidx lastidx]);                        
                        goodidx = intersect(firstpos:lastpos, hhidx);                                                                                              
                        if length(goodidx)>20 % if there are at least 20 trials 
                                                %that have a hit rate > 85%
                        dto7 = d; % days to learn 0.7 octave separation
                        dtopsych = length(cumtrials)-d; % days to psych starting from that point
                        goodcontig = contigpos(end,:);
                        return;
                        % to the end of
                        % sharpening
                        % (not
                        % including
                        % that day)
                        end;
                    end;
%                             % found the biggest contig
%                             if ((lastpos-firstpos)+1) > contiglen,
%                                 contiglen= (lastpos-firstpos)+1;
%                                 maxfirst = firstpos; maxlast = lastpos;
%                             end;
                        end;
                    end;
                end;
            end;
        end;
    end;

end;

2;
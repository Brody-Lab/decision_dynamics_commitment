
function [out] = average_psych_curves(varargin)

% examples:
% average_psych_curves('area_filter','ACx2','action','load','pre_lastfew',
% 10,'post_firstpsych',3);

[lf hf] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
[lfold hfold] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);
[ld hd]= calc_pair('d',sqrt(200*500),0.95,'suppress_out',1);
pairs = { ...
    'action','load'; ...
    'outfile', 'blah';...
    'tasktype', 'pitch_psych'; ...
    'metric', 'slope' ; ...
    'infile', 'psych' ; ...
    'psychthresh', 1 ; ... % set to 1 to ignore dates where there are < 2 values in a given bin.
    'experimenter','Shraddha'; ...
    % see comments above for fields assigned
    % which data to use? -----------------------------------------------
    'area_filter', 'ACx'; ...
    'post_firstpsych', 3; ... % how many PSYCH SESSIONS to use to construct 'after' curve (note: could be less than real sessions)
    'post_firstfew', 3; ... % how many days to use to construct 'after' psych curve
    'pre_lastfew', 7; ...
    'numSims', 1000;...
    % binning data -----------------------------------------------------
    'binmin_dur', ld ; ...
    'binmax_dur', hd ; ...
    'binmin_freq', lf ; ...
    'binmax_freq', hf ; ...
    'num_bins', 8 ; ...
    'justgetdata', 0 ; ... % if true, doesn't plot anything, just assigns data in caller's namespace
    % structs filled only when data is being permuted
    'data_before',{};...
    'data_after', {};...
    'ratcolour',{};...
    'pitch',0;...
    'binmin',0;...
    'binmax',0;...
    'bin_midpoint',0;...
    };
parse_knownargs(varargin,pairs);

if strcmpi(area_filter(1:3),'ACx'),
    [binmin_freq binmax_freq] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
    [binmin_freqold binmax_freqold] = calc_pair('p', sqrt(8*16), 1.4,'suppress_out', 1);
elseif strcmpi(area_filter,'mPFC')
    [binmin_freq binmax_freq] = calc_pair('p', sqrt(8*16), 1,'suppress_out', 1);
else
    error('Please define a value for pitch for this brain region''s data');
end;

out=0;

global Solo_datadir;
if isempty(Solo_datadir), mystartup; end;

switch action
    case 'save'
        % ttypes = {'duration_psych'};
        %        for t = 1:length(ttypes)
        ratset=rat_task_table('','action',['get_' tasktype],'area_filter',area_filter);
        rat_before = 0; % col1 before, col2 after; each entry is n-by-2.
        % Col1 of each entry is x values; col2 of each entry is y values
        ratcolour = {};

        for r = 1:length(ratset)
            ratname = ratset{r};
            ratrow = rat_task_table(ratname);
            task = ratrow{1,2};
            if strcmpi(task(1:3), 'dur'),
                binmin = binmin_dur;
                binmax = binmax_dur;
                pitch = 0;
                num_bins = 8;
            else
                if ~rat_task_table(ratname, 'action','notyetflipped')% ACX round 2 rat with Princeton naming scheme
                    binmin = binmin_freq;
                    binmax = binmax_freq;
                else
                    binmin=binmin_freqold;
                    binmax=binmax_freqold;
                end;
                pitch = 1;
                num_bins = 9;
            end;
            currcolour = rand(1,3);
            eval(['ratcolour.' ratname ' = currcolour;']);

            % get 'before' data
            out = sub__psychavg(ratname,'psych_before',...
                pitch,num_bins,binmin,binmax,'last_few', pre_lastfew);
            eval(['rat_before.' ratname ' = out;']);

            % get 'after' data
            out = sub__psychavg(ratname,'psych_after',...
                pitch,num_bins,binmin,binmax,'first_few',post_firstpsych, 'count_psychsessions_only', 1);

            % Turn this on to get first X sessions
            %       out = sub__psychavg(ratname,'psych_after',...
            %           pitch,num_bins,binmin,binmax,'first_few',post_firstfew, 'count_psychsessions_only', 0);

            eval(['rat_after.' ratname ' = out;']);
        end;

        outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
        fname = [outdir outfile];
        %   tasktype=ttypes{t};
        save(fname, 'rat_before','rat_after','ratcolour','num_bins','binmin','binmax', 'pitch','tasktype','area_filter');
        %end;

    case 'load'
        outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
        %    fname = [outdir tasktype '_' area_filter '_psychdata.mat'];
        
        if strcmpi(infile,'psych') % change default.
            infile = [tasktype '_' area_filter '_psychdata_LAST7FIRST3PSYCH'];
        end;
        fname=[outdir infile];
        try
            load(fname);
        catch
            ans=questdlg(sprintf('Couldn''t find pre-saved file. Save from raw data?\n New file will be %s', infile), ...
                'Save afresh?', 'Yes','No','Yes');
            if strcmpi(ans, 'Yes')
                average_psych_curves('area_filter',area_filter,'action','save','tasktype',tasktype, ...
                    'outfile', infile , 'metric', 'residuals');
            else
                msgbox('Not doing anything.', 'Done','none');
                return;
            end;
            load(fname);
        end;

        if pitch > 0,
            bin_midpoint = sqrt(binmin_freq*binmax_freq);
            binmin = log2(binmin_freq);
            binmax = log2(binmax_freq);
        else
            bin_midpoint = sqrt(binmax_dur*binmin_dur);
            binmin = log(binmin_dur);
            binmax = log(binmax_dur);
        end;

        %         rat_before=rmfield(rat_before, 'Bilbo');
        %         rat_after=rmfield(rat_after, 'Bilbo');
        r=fieldnames(rat_before);
        for k =1:length(r)
            fprintf('Including %s...\n', r{k});
        end;

        real_metric = average_psych_curves('action','analyze',...
            'area_filter',area_filter,...
            'tasktype', tasktype,'pitch',pitch, 'metric',metric, ...
            'data_before',rat_before,'data_after', rat_after, ...
            'bin_midpoint',bin_midpoint, 'binmin', binmin, 'binmax', binmax,'ratcolour',ratcolour);

        sim_metric = average_psych_curves('action','permute',...
            'area_filter',area_filter,...
            'tasktype', tasktype,'pitch',pitch, 'metric',metric, ...
            'data_before',rat_before,'data_after', rat_after, ...
            'bin_midpoint',bin_midpoint, 'binmin', binmin, 'binmax', binmax,'ratcolour',ratcolour,'numSims', numSims);

        %figure;
        %hist(sim_metric);
        % line([real_metric real_metric], [0 numSims], 'LineStyle','-','Color','r','LineWidth',2);
        % title(sprintf('Distribution of %s', metric));

        alphaval=0.05;
        typeoftest = 'onetailed_gt';
        [sig pvalue] = sub__dosigtest(real_metric, sim_metric, typeoftest, alphaval);

        sig
        pvalue

    case 'analyze'
        rat_before = data_before;
        rat_after = data_after;


        % extrapolate logistic fits beyond stimulus bins
        % to accommodate clipping later on
        [rat_before] = sub__extrapolatebig(rat_before,pitch, bin_midpoint);
        [rat_after] = sub__extrapolatebig(rat_after,pitch, bin_midpoint);

        [normed_before shiftparams] = sub__shiftgraphs(rat_before, ratcolour, 0);
        % sub__plotset(normed_before, ratcolour);
        normed_after = sub__applyshift(rat_after, shiftparams);

        if 0%justgetdata == 0
            figure; subplot(1,2,1);
            patch([binmin binmin binmax binmax], [0 1 1 0], [0.9 0.9 1],'EdgeColor','none'); hold on;
            sub__plotset(rat_before, ratcolour, 'xx','yy');
            title('BEFORE - raw');
            subplot(1,2,2);
            patch([binmin binmin binmax binmax], [0 1 1 0], [0.9 0.9 1],'EdgeColor','none'); hold on;
            sub__plotset(rat_after, ratcolour, 'xx','yy');
            title('AFTER - raw');

            figure; subplot(1,2,1);
            sub__plotset(normed_before, ratcolour, 'normed_x');
            title('Normalized BEFORE - not interpolated');
            subplot(1,2,2);
            sub__plotset(normed_after, ratcolour, 'normed_x');
            title('Normalized AFTER - not interpolated');
        end;

        [normed_before normed_after] =  sub__interpolate(normed_before, normed_after);

        %         % if at this point, differences are acceptable and can use x's of
        %         % one as x's of the other.
        [avgbefore_x avgbefore_y errbef] = sub__average(normed_before);
        [avgafter_x avgafter_y erraft] = sub__average(normed_after);

        if justgetdata == 0
            if 0
                figure; subplot(1,2,1);
                sub__plotset(normed_before, ratcolour, 'newxx','newyy');
                hold on; plot(avgbefore_x, avgbefore_y, '-k');
                title('Normalized Before');

                %set(gca,'XLim',[-2 +2]);

                subplot(1,2,2); sub__plotset(normed_after, ratcolour, 'newxx','newyy');
                hold on; plot(avgafter_x, avgafter_y, '-k');
                title('Normalized After');
                %   set(gca,'XLim',[-2 +2]);

            end;

            % plot avg'ed before and after curves on same graph
            figure;

            aftermid = sub__stim_at(avgafter_x, avgafter_y, 0.5);
            aftermid = avgafter_x(aftermid);

            l=line([0 0],[0 1],'LineWidth',2,'Color',[0 0 1],'LineStyle',':');
            hold on;
            l=line([aftermid aftermid],[0 1],'LineWidth',2,'Color',[1 0 0],'LineStyle',':');
            minx = min(min(avgbefore_x), min(avgafter_x)); maxx= max(max(avgbefore_x), max(avgafter_x));
            l=errorbar(avgbefore_x, avgbefore_y, errbef, errbef,'.b'); set(l,'Color',[0.8 0.8 1],'LineWidth',1,'MarkerSize',2);

            l=errorbar(avgafter_x, avgafter_y, erraft, erraft,'.r'); set(l,'Color',[1 0.9 0.9],'LineWidth',1,'MarkerSize',2);
            l=plot(avgbefore_x, avgbefore_y, '-b'); set(l,'LineWidth',2);
            l=plot(avgafter_x, avgafter_y, '-r'); set(l,'LineWidth',2);

            beflow = avgbefore_x(sub__stim_at(avgbefore_x, avgbefore_y,0.25));
            l=line([beflow beflow],[0 0.25],'LineWidth',2,'Color','b','LineStyle',':');
            l=line([minx beflow],[0.25 0.25],'LineWidth',2,'Color','b','LineStyle',':');

            befhigh = avgbefore_x(sub__stim_at(avgbefore_x, avgbefore_y,0.75));
            l=line([befhigh befhigh],[0 0.75],'LineWidth',2,'Color','b','LineStyle',':');
            l=line([minx befhigh],[0.75 0.75],'LineWidth',2,'Color','b','LineStyle',':');

            if strcmpi(tasktype(1:3),'dur'),
                xtxt='Normalized duration (milliseconds)';
                ytxt = '% Reported "LONG"';
                mp = sqrt(binmin_dur * binmax_dur);
                zerotxt = round(mp);
                addfactor = log(mp);
                txtformat='%i ms';
                lowtxt = round(exp(beflow+addfactor));
                hitxt = round(exp(befhigh+addfactor));
                mybase = 'exp(';

            else
                txtformat= '%1.1f KHz';
                xtxt='Normalized frequency (KHz)';
                ytxt='% Reported "HIGH"';
                mp=sqrt(binmin_freq*binmax_freq);
                zerotxt = round(mp * 10)/10;
                addfactor = log2(mp);
                lowtxt = round((2^(beflow+addfactor))*10)/10;
                hitxt = round((2^(befhigh+addfactor))*10)/10;
                mybase='2^(';

            end;
            lodist = beflow;
            beflow = beflow+addfactor;
            hidist=befhigh;

            minx= 3*lodist;
            maxx= 3*hidist;
            text(minx*0.9,0.28,sprintf(['x=' txtformat], lowtxt),'FontAngle','italic','FontSize',14,'FontWeight','bold');

            befhigh = befhigh+addfactor;
            text(minx*0.9,0.78,sprintf(['x=' txtformat], hitxt),'FontAngle','italic','FontSize',14,'FontWeight','bold');

            before_weber = eval([ mybase 'befhigh) - ' mybase 'beflow)']);
            before_weber= eval(['before_weber /' mybase 'addfactor)']);

            aftlow = avgafter_x(sub__stim_at(avgafter_x, avgafter_y,0.25));
            %            aftmid = avgafter_x(sub__stim_at(avgafter_x, avgafter_y,0.5));
            aftlow = aftlow+addfactor;
            afthigh = avgafter_x(sub__stim_at(avgafter_x, avgafter_y,0.75));
            afthigh = afthigh+addfactor;
            aftermid=aftermid+addfactor;

            after_weber = eval([ mybase 'afthigh) - ' mybase 'aftlow)']);
            after_weber= eval(['after_weber /' mybase 'aftermid)']);

            before_weber = round(before_weber*100)/100;
            after_weber= round(after_weber*100)/100;


            ylbl=ylabel(ytxt); set(ylbl,'FontSize',24,'FontWeight','bold');
            set(gca, 'XLim', [minx maxx], 'YLim',[0 1.05],'YTick',0:0.25:1, 'YTickLabel', 0:25:100,'FontSize',24,'FontWeight','bold');
            set(gca,'XTick',0, 'XTickLabel', zerotxt);
            xlbl=xlabel(xtxt); set(xlbl,'FontSize',24, 'FontWeight','bold');



            text(0.4*maxx, 0.15, sprintf('weber=%1.2f', before_weber), 'Color','b','FOntSize',20);
            text(0.4*maxx, 0.05, sprintf('weber=%1.2f', after_weber), 'Color','r','FOntSize',20);

            %   text(0.02, 0.1, 'Training midpoint', 'COlor',[.2 .2 .2],'FontAngle','italic', 'FontSize',18);
            %l=legend({'Before','After'}); set(l,'FontSize', 16, 'FontWeight','bold','LineWidth',2,'Location','NorthWest');
            text(0.9*minx, 0.97, 'Before','Color','b','FontSize',24,'FontWeight','bold');
            text(0.9*minx, 0.85, 'After','Color','r','FontSize',24,'FontWeight','bold');
            t=title(sprintf('Group: %s ; Area: %s ; # rats = %i\nAveraged and normalized psych curves',...
                strrep(tasktype,'_', ' '), area_filter, length(fieldnames(rat_before))));
            set(t,'FontSize',14, 'FontWeight','bold');
        end;

        out=sub__compute_metric(avgbefore_x, avgbefore_y, avgafter_x, avgafter_y,'metric', metric);

    case 'plot_before_after'
        outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
        fname = [outdir tasktype '_' area_filter '_psychdata.mat'];
        load(fname);

        figure;
        subplot(1,2,1);
        sub__plotset(rat_before, ratcolour);
        title('Before');

        subplot(1,2,2);
        sub__plotset(rat_after,ratcolour);

    case 'permute'
        data1 = data_before;
        data2 = data_after;

        curve_buffer = {};
        sim_residuals=[];

        % assign unique names to entries in before and after graph so they may be
        % permuted easily
        fnames1 = fieldnames(data1);
        for f = 1:length(fnames1)
            curve_buffer{f} = [fnames1{f} '1'];
        end;
        fnames2 = fieldnames(data2);
        for f = 1:length(fnames2)
            curve_buffer{f+length(fnames1)} = [fnames2{f} '2'];
        end;

        scramble_id = {};
        for sim = 1:numSims
            fprintf(1,'.');
            % make new jumbled set of curves
            jumbled_idx = randperm(length(curve_buffer));
            jumbled1 = 0; jumbled2 = 0;

            for i = 1:(length(curve_buffer)/2)
                mynameis = curve_buffer{jumbled_idx(i)};
                eval(['jumbled1.scramble' num2str(i) ' = data' mynameis(end) '.' mynameis(1:end-1) ';']);
                scramble_id{i} = mynameis;
            end;
            for i = 1:(length(curve_buffer)/2)
                mynameis = curve_buffer{jumbled_idx(i+length(fnames1))};
                eval(['jumbled2.scramble' num2str(i) ' = data' mynameis(end) '.' mynameis(1:end-1) ';']);
                scramble_id{i+length(fnames1)} = mynameis;
            end;

            %    sim_residuals = horzcat(sim_residuals, sub__getresidual(avg1_x, avg1_y, avg2_x, avg2_y) );
            currsim = average_psych_curves('action','analyze','data_before',jumbled1,'data_after', jumbled2, ...
                'area_filter',area_filter,...
                'pitch',pitch,'bin_midpoint',bin_midpoint, 'binmin', binmin, 'binmax', binmax,'ratcolour',...
                ratcolour,'justgetdata',1,'metric', metric);
            sim_residuals = horzcat(sim_residuals, currsim);
        end;

        out = sim_residuals;
    otherwise
        error('Invalid action');
end;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBROUTINES

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [data] = sub__extrapolatebig(data,ispitch, bin_midpoint)
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    try
        xx = out.xx;
    catch
        2;
    end;
    rangex = max(xx) - min(xx);
    [newxx newyy] = logistic_fitter('get_interpolated', out.bins, ispitch, ...
        out.overall_betahat, NaN, bin_midpoint,...
        min(xx) - (0.5*rangex) : 0.0002 : max(xx) + (0.5*rangex));
    out.xx = newxx;
    out.yy = newyy;
    eval(['data.' ratname ' = out;']);
end;



% loads psychometric curve for entire before/after session
% and computes a shifted/scaled average curve
function [out] = sub__psychavg(ratname,infile,pitch,num_bins,binmin, binmax,varargin)
pairs = { ...
    'first_few', 1000; ...
    'last_few', 1000; ...
    'precedence', 'first_few'; ...% if there aren't enough, which one do you want? first-few or last-few?
    'count_psychsessions_only', 0;...
    };
parse_knownargs(varargin,pairs);


if (count_psychsessions_only >0 )
    fprintf(1,'*** *** Warning! *** *** \n');
    pause(3);
    fprintf(1,'Counting psych sessions, NOT real sessions\n');
end;

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep ratname filesep];
fname = [outdir infile '.mat'];

load(fname);
cumtrials = cumsum(numtrials);

notyetflipped = rat_task_table(ratname, 'action','notyetflipped');

if count_psychsessions_only > 0
    ptrials = sub__getpsych(numtrials,psychflag);
    idx = find(ptrials > 16);
    
    if length(idx) < first_few
        fprintf(1,'FEW SESSION WARNING: - %s only %i of %i sessions', ratname, max(idx), first_few);
        first_few = length(idx);
    end;

    try
    fprintf(1,'For %s ---> used sessions %i, %i and %i', ratname, idx(1:first_few));
    catch
        2;
    end;
    in.dates = dates(idx(1:first_few));
    in.numtrials = numtrials(idx(1:first_few));
    in.binmin=binmin;
    in.binmax=binmax;

    in.ltone=[]; in.rtone=[]; in.slist=[]; in.psych_on=[]; in.hit_history=[];
    in.flipped=[];
    for k = 1:first_few
        curridx = idx(k);
        if curridx == 1, cumsidx = 1; else cumsidx = cumtrials(curridx-1)+1;end;
        cumeidx = cumtrials(curridx);

        tmp= in.ltone; tmp =horzcat(tmp,left_tone(cumsidx:cumeidx)); in.ltone = tmp;
        tmp=in.rtone; tmp=horzcat(tmp,right_tone(cumsidx:cumeidx)); in.rtone=tmp;
        tmp=in.slist; tmp=horzcat(tmp,side_list(cumsidx:cumeidx)); in.slist=tmp;
        tmp=in.psych_on; tmp= horzcat(tmp,psychflag(cumsidx:cumeidx)); in.psych_on=tmp;
        tmp=in.hit_history;tmp= horzcat(tmp,hit_history(cumsidx:cumeidx)); in.hit_history=tmp;
        tmp=in.flipped;
        if ~notyetflipped  % Princeton rat
            tmp=horzcat(tmp, flipped(cumsidx:cumeidx));
        else
            tmp=horzcat(tmp, zeros(1,(cumeidx-cumsidx)+1));
        end;
        in.flipped=tmp;

    end;
else
    if (first_few + last_few ~= 2000)
        if (first_few ~= 1000) && (last_few ~=1000) % both are specified
            error('Sorry, I currently only support one or the other.');
        else % only one is specified
            if first_few ~=1000
                sidx = 1;
                eidx = min(length(numtrials), first_few);
            else % last_few ~= 1000
                eidx = length(numtrials);
                sidx = max(1,eidx - (last_few - 1));
            end;
        end;
    end;

    in={};

    if sidx == 1, cumsidx = 1; else cumsidx = cumtrials(sidx-1)+1;end;
    cumeidx = cumtrials(eidx);

    in.dates = dates(sidx:eidx);
    in.numtrials = numtrials(sidx:eidx);
    in.binmin=binmin;
    in.binmax=binmax;

    in.ltone=left_tone(cumsidx:cumeidx);
    in.rtone=right_tone(cumsidx:cumeidx);
    in.slist = side_list(cumsidx:cumeidx);
    in.psych_on = psychflag(cumsidx:cumeidx);
    in.hit_history = hit_history(cumsidx:cumeidx);
    if ~notyetflipped  % Princeton rat
        in.flipped = flipped(cumsidx:cumeidx);
    else
        in.flipped = zeros((cumeidx-cumsidx)+1,1);
    end;
end;

out = psych_oversessions(ratname,in, ...
    'justgetdata',0,'pitch', pitch,...
    'psychthresh',1,'num_bins', num_bins);

fnames = fieldnames(in);
for f = 1:length(fnames)
    eval(['out.' fnames{f} ' = in.' fnames{f} ';']);
end;
%justgetdata=1;

function [ptrials] = sub__getpsych(numtrials, psychflag)
ptrials=[];
cumtrials=cumsum(numtrials);
for i = 1:length(numtrials)
    if i == 1, cumsidx = 1; else cumsidx = cumtrials(i-1)+1;end;
    cumeidx = cumtrials(i);

    currp = psychflag(cumsidx:cumeidx);
    ptrials = horzcat(ptrials, length(find(currp > 0)));
end;

% given raw before/after data, plots 'before' curves before and after
% scaling. Also returns scale/shift parameters for each rat
function [normeddata shiftparams] = sub__shiftgraphs(data,plotclr, doplot)

shiftparams=0;
normeddata = 0;

if doplot > 0
    f=figure; set(f,'Tag','scalefig');
    subplot(1,2,1);
    set(gca,'Tag','before_scale'); title('Before scaling');
    subplot(1,2,2);
    set(gca,'Tag','after_scale'); title('After scaling');
end;

fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);

    if doplot > 0
        eval(['currcolour = plotclr.' ratname ';']);
        set(0,'CurrentFigure',findobj('Tag','scalefig'));
        set(gcf,'CurrentAxes', findobj('Tag','before_scale'));
        l=plot(out.xx, out.yy,'-r');
        set(l,'Color',currcolour,'LineWidth',2); hold on;
        set(gca,'Tag','before_scale');
    end;

    % now plot scaled
    try
        mp = sub__stim_at(out.xx,out.yy,0.5);
        mp = out.xx(mp);
    catch
        sprintf('WARNING:No x-val for 50% for %s. Using range midpoint', ratname);
        mp = sqrt(out.binmin * out.binmax);
    end;

    x2 = out.xx - mp; % out.overall_xmid;     % shifted
    tau =sub__getslope(x2, out.yy);
    norm_x = x2 * tau;

    if doplot > 0
        fprintf(1,'%s:\t\tOld slope = %2.2f', ratname,tau);
    end;
    if doplot > 0
        set(gcf,'CurrentAxes', findobj('Tag','after_scale'));
        l=plot(norm_x, out.yy,'-r');
        set(l,'Color',currcolour,'LineWidth',2);   hold on;
        set(gca,'Tag','after_scale');
        fprintf(1,'\t\tNew slope = %2.4f\n', sub__getslope(norm_x, out.yy));
    end;

    tmp = [out.overall_xmid tau];
    eval(['shiftparams.' ratname ' = tmp;']);
    if doplot > 0
        fprintf(1,'\t\t Shift = %2.1f, Scale = %2.1f\n', out.overall_xmid, tau);
    end;

    out2 = out;
    out2.normed_x = norm_x;

    eval(['normeddata.' ratname ' = out2;']);

end;

if doplot > 0
    set(gcf,'CurrentAxes', findobj('Tag','before_scale'));
    title('Before scaling');
    set(gcf,'CurrentAxes', findobj('Tag','after_scale'));
    title('After scaling');
end;

% given shiftparams (translation, scale) from before curves, apply to
% 'after' curves and return transformed graphs
function [shiftedafter] = sub__applyshift(data, shiftparams)
shiftedafter=0;
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    eval(['shift = shiftparams.' ratname ';']);

    xx = out.xx; yy = out.yy;
    shifted_xx = (xx - shift(1)) * shift(2);

    out2 = out;
    out2.normed_x = shifted_xx;

    eval(['shiftedafter.' ratname ' = out2;']);
end;


% plot all curves from a given set
function [] = sub__plotset(data,plotclr,varargin)
fnames = fieldnames(data);
if nargin < 3
    xplot = 'xx';
else
    xplot = varargin{1};
end;

if nargin < 4
    yplot = 'yy';
else
    yplot = varargin{2};
end;

for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    eval(['currcolour = plotclr.' ratname ';']);

    l=plot(eval(['out.' xplot]), eval(['out.' yplot]), '-r');
    set(l,'Color',currcolour,'LineWidth',2);   hold on;
end;

function [x avgy err] = sub__average(data)
fnames = fieldnames(data);

firstrat = fnames{1};
eval(['out = data.' firstrat ';']);
avgy = out.newyy;

for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data.' ratname ';']);
    curryy = out.newyy; if rows(curryy)> 1, curryy = curryy'; end;
    avgy = vertcat(avgy, curryy);
    x = out.newxx;
end;
err = std(avgy) ./ rows(avgy);
avgy = mean(avgy);


function [s] = sub__getslopezerotoone(x,y)
s=sub__getslope(x,y,'minval',0.16,'maxval',0.84);


function [s] = sub__getslope(x,y,varargin)
pairs = { ...
    'minval',0.25;...
    'maxval',0.75 ;...
    };
parse_knownargs(varargin,pairs);
stdminus = sub__stim_at(x,y,minval);
stdplus = sub__stim_at(x,y, maxval);
%fprintf(1,'minus = %2.1f, plus %2.1f\n', stdminus, stdplus);

try
    s = (maxval-minval) / (x(stdplus) - x(stdminus));
catch
    if minval == 0.25 && maxval == 0.75
        try
            s=sub__getslope(x,y,'minval',0.4, 'maxval',0.7);
        catch
            sprintf('Original slope way too bad to compute');
            s=sub__slopewalk(x,y,floor(length(x)/10));
        end;
    else
        sprintf('A normalized slope is having trouble finding 16 and 84%');
    end;
end;

function [stim] = sub__stim_at(x,y, pt)
if min(y) > pt || max(y) < pt % you're asking for a point that isn't on the curve
    stim=-1;
    return;
end;

stim = find(abs(y - pt) == min(abs(y-pt)));

% given a 2d dataset (x,y), computes the slope for
function [maxslope] = sub__slopewalk(x,y, ssize)
startpos=ssize;
endpos=(length(x)-ssize)+1;

maxslope=-10;
xa=NaN; xb=NaN;
ya=NaN; yb=NaN;
for i=1:endpos
    ychange=y((i-1)+ssize)-y(i);
    xchange=x((i-1)+ssize)-x(i);
    currslope=ychange/xchange;
    if currslope > maxslope
        maxslope=currslope;
        xa=x(i); xb=x((i-1)+ssize);
        ya=y(i); yb=y((i-1)+ssize);
    end;
end;

% figure;
% plot(x,y,'-b', [xa xb], [ya yb],'-r');




% given a collection of xx and yy pairs with disparate x-axes values, find
% an x-axis to which all old xx-yy values can be commonly interpolated
% preparation for averaging
function [data1 data2] =  sub__interpolate(data1, data2)

bufferx = [];
lastx = [];

olddata1=data1;
olddata2=data2;

fnames = fieldnames(data1);

largestofmin = -1000;
smallestofmax = +1000;
minnie = +1000; maxie = -1000;
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    lastx = out.normed_x; % to get a sense of how many x-values are in any given xx-yy pair
    largestofmin = max(largestofmin, min(lastx));
    smallestofmax = min(smallestofmax, max(lastx));
    minnie = min(minnie, min(lastx));
    maxie = max(maxie, max(lastx));
end;

fnames = fieldnames(data2);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data2.' ratname ';']);
    lastx = out.normed_x; % to get a sense of how many x-values are in any given xx-yy pair
    largestofmin = max(largestofmin, min(lastx));
    smallestofmax = min(smallestofmax, max(lastx));
    minnie = min(minnie, min(lastx));
    maxie = max(maxie, max(lastx));
end;

newmin =largestofmin;
newmax = smallestofmax;
stepsize = (newmax-newmin) / length(lastx);
newxx = newmin:stepsize:newmax;
idx=find(abs(newxx - 0) == min(abs(newxx-0)));
if newxx(idx) < 0
    newxx2 = [ newxx(1:idx) 0 newxx(idx+1:end)];
else
    newxx2 = [ newxx(1:idx-1) 0 newxx(idx:end)];
end;
newxx = newxx2;


% now make new interpolated yy values for each xx-yy pair, using newxx
%first for 'before' curves
fnames = fieldnames(data1);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data1.' ratname ';']);
    out.newxx = newxx;
    try
        out.newyy = interp1(out.normed_x ,out.yy, out.newxx,'spline','extrap');
    catch
        2;
    end;
    eval(['data1.' ratname ' = out;']);
end;
% then for 'after' curves
fnames = fieldnames(data2);
for f = 1:length(fnames)
    ratname = fnames{f};
    eval(['out = data2.' ratname ';']);
    out.newxx = newxx;
    out.newyy = interp1(out.normed_x ,out.yy, out.newxx,'spline');
    eval(['data2.' ratname ' = out;']);
end;


function [scaled_fits] = sub__scalefits(data,bmp)
fnames = fieldnames(data);
scaled_fits = [];
for f = 1:length(fnames)
    ratname = fnames{f};
    out = eval(['data.' ratname ';']);
    out.shiftparam = out.xmid;
    out.scaleparam = 1 ./(out.betahat(4)); %set tau__BEFORE to 1
    newbeta = out.betahat; newbeta(4) = newbeta(4) * out.scaleparam;

    newxx = -1*bmp:0.01:2*bmp;
    yy = logistic_setbound(newbeta,newxx, 'binrange_mp',0);
    out.newxx = newxx;
    out.newyy = yy;

    eval(['scaled_fits.' ratname ' = out;']);
end;

function [] = sub__plotinterpol(data)
fnames = fieldnames(data);
for f = 1:length(fnames)
    ratname = fnames{f};
    out = eval(['data.' ratname ';']);

    figure;
    l=plot(out.normed_x, out.yy, '-r');
    set(l,'LineWidth',3);
    hold on; l=plot(out.newxx, out.newyy,'.b'); set(l,'MarkerSize',15);
    title(ratname);
end;

function [res] = sub__getresidual(avg1_x, avg1_y, avg2_x, avg2_y)
if sum(abs(avg1_x - avg2_x)) ~= 0, error ('x-axes for before and after curves should be the same!'); end;
res = sum((avg2_y - avg1_y).^2)*mean(diff(avg1_x));


function [sig pct_farther] = sub__dosigtest(dataval, simvals, typeoftest, alphaval);
switch typeoftest
    case 'two_tailed'
        idx_larger = find(simvals >= dataval);
        pct_farther = length(idx_larger) / length(simvals);
    case 'onetailed_gt'
        idx_gt = find(simvals >=dataval);
        pct_farther = length(idx_gt) / length(simvals);
    case 'onetailed_ls'
        idx_ls = find(simvals <= dataval);
        pct_farther = length(idx_ls) / length(simvals);
    otherwise
        error('Invalid value for typeoftest: should be one of [two_tailed | onetailed_gt0 | onetailed_ls0]');
end;

if pct_farther <= alphaval
    sig = 1; % if less than alpha % differences are this large, our diff is significant; reject null
else
    sig = 0; % it's not sig; do not reject null
end;

function [m] = sub__compute_metric(x1, y1, x2, y2,varargin)
pairs = { ...
    'metric', 'slope'; ...
    };
parse_knownargs(varargin,pairs);

switch metric
    case 'slope'
        m=sub__getslope(x1,y1) - sub__getslope(x2,y2) ;
    case 'residuals'
        m = sub__getresidual(x1,y1, x2,y2);
    otherwise
        error('invalid metric type');
end;

function [] = sub__doforall(mystruct)
f=fieldnames(mystruct);
for i=1:length(f),
    curr = eval(['mystruct.' f{i}]);
    st = sub__stim_at(curr.xx, curr.yy,0.5); curr.xx(st),
end;


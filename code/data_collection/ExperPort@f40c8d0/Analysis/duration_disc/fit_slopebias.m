function [] = fit_slopebias(area_filter, action, varargin)
% does linear or sigmoid fit to psych curves before and after lesion.
% computes slope and bias before and after lesion
%
% example calls
% fit_slopebias('ACx2', 'save', 'addfname', 'forcelinear_setimperfect','icalc', 5)
% fit_slopebias('ACxall', 'plot_slopes', 'addfname', 'forcelinear_setimperfect','icalc', 5)
% fit_slopebias('ACxall', 'plot_qvalues', 'addfname', 'forcelinear_setimperfect','icalc', 5)

pairs = { ...
    'icalc', 1 ; ... % method code for computing impairment. See 'impair' case for descriptions
    'addfname', 'default' ; ... % additional filename prefix to indicate variation on computation tried in this round
    'postpsych', 1 ; ...
    'psychthresh', 1 ; ...
    'ignore_trialtype', 0 ; ...
    'ignore_empty',1 ; ... % if a task group has no members, doesn't attempt to perform
                           % calculations for them
    };
parse_knownargs(varargin,pairs);

postpsych=1;
if strcmpi(area_filter,'ACx')
    ACxround1=1;
else
    ACxround1=0;
end;


% graph params
try
    dur_clr=group_colour('duration');
catch
    addpath('Analysis/duration_disc/graphicutil/');
    dur_clr=group_colour('duration');
end;
freq_clr=group_colour('frequency');
msize=20;


global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'impair_metric' filesep];

if postpsych==0
    fpfx='slopebias_beforeafter_psychall';
else
    fpfx='slopebias_beforeafter_postpsych';
end;

fname = [fpfx area_filter];
fname = [fname '_' addfname];

warning off MATLAB:singularMatrix;

switch action
    case 'save'
        freqset = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);
        [fbrep fbtal farep fatal fbefp faftp fslope fbias fqlin fqsig] = sub__getparams(freqset, ACxround1, postpsych, psychthresh, ignore_trialtype);

        durset = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
        [dbrep dbtal darep datal dbefp daftp dslope dbias dqlin dqsig] = sub__getparams(durset, ACxround1, postpsych, psychthresh, ignore_trialtype);
        save([outdir fname], ...
            'fbrep', 'fbtal', 'farep', 'fatal', ...
            'dbrep', 'dbtal', 'darep', 'datal', ...
            'faftp', 'fbefp', 'daftp', 'dbefp', ...
            'fslope', 'fbias', 'fqlin', 'fqsig', ...
            'dslope','dbias','dqlin','dqsig');

    case 'load'
        plist={'fslope','fbias','fqsig','fqlin', ...
            'dslope','dbias','dqsig','dqlin', ...
            'fbrep', 'fbtal', 'farep', 'fatal', ...
            'dbrep', 'dbtal', 'darep', 'datal'};
        plist2 = {'dbefp','daftp','fbefp','faftp'}; % arrays

        if strcmpi(area_filter, 'ACxall')
            load([outdir fpfx 'ACx_' addfname]);
            for k=1:length(plist)
                eval([plist{k} '1 = ' plist{k} ';']); 
            end;
            for k=1:length(plist2)
                eval([plist2{k} '1 = ' plist2{k} ';']); 
            end;

            load([outdir fpfx 'ACx2_' addfname]);
            for k=1:length(plist)                
                eval([plist{k} '2 = structconcat(' plist{k} ',' plist{k} '1);']);
            end;

            for k=1:length(plist2)
                eval([plist2{k} '2 = vertcat(' plist2{k} ',' plist2{k} '1);']);
            end;
            
            load([outdir fpfx 'ACx3_' addfname]);
            for k=1:length(plist)  
                if strcmpi(plist{k}(1),'d')
                    eval([plist{k} ' = structconcat(' plist{k} ',' plist{k} '2);']);
                else
                    eval([plist{k} ' = ' plist{k} '2;']);
                end;
            end;

            for k=1:length(plist2)
                if strcmpi(plist2{k}(1),'d')
                eval([plist2{k} ' = vertcat(' plist2{k} ',' plist2{k} '2);']);
                else
                    eval([plist{2} ' = ' plist{k} '2;']);
                end;
            end;            
            2;

        else
            load([outdir fname]);
        end;

        plist = [plist plist2];

        for k=1:length(plist)
            assignin('caller',plist{k},eval(plist{k}));
        end;

        %          fit_slopebias(area_filter, 'plot',fslope, fbias, dslope, dbias);

    case 'rankslopes'
        load([outdir fname]); % raw slopes
        [v1 n1 r1]=sub__rankslope(dslope, fslope);
        rankplot(n1,r1);
        %         load([outdir fname '_withtan']);
        %         [v2 n2 r2]=sub__rankslope(dslope, fslope);
    case 'rankbias'
        load([outdir fname]); % raw slopes

        [v1 nm1] = struct2array(dbias);
        [v2 nm2] = struct2array(fbias);

        v=vertcat(v1,v2);
        nm=vertcat(nm1, nm2);

        x = abs(v(:,1)-v(:,2)); % more +ve numbers mean larger slope changes
        [y i] = sort(x);
        r=i(end:-1:1);

        rankplot(nm,i);

    case 'rankhitrate'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load', 'addfname', addfname);
        end;

        dnames = fieldnames(dslope);
        fnames = fieldnames(fslope);

        [dnames db] = sub__hitrate(dbrep, dbtal,0);
        [dnames2 da] = sub__hitrate(darep, datal,0);
        [fnames fb] = sub__hitrate(fbrep, fbtal,0);
        [fnames2 fa] = sub__hitrate(farep, fatal,0);

        if ~cellstr_are_equal(dnames, dnames2)
            error('dnames order doesn''t match');
        end;

        if ~cellstr_are_equal(fnames, fnames2)
            error('dnames order doesn''t match');
        end;

        dimpair = db-da;
        fimpair = fb-fa;

        % plot all impair on same x-value
        figure; msize=8;
        plot(ones(size(dimpair)), dimpair,'ob','Color', dur_clr,'MarkerSize', msize); hold on;
        plot(ones(size(fimpair)), fimpair,'.b','Color', freq_clr,'MarkerSize', msize);
        for k = 1:length(dnames), text(0.9, dimpair(k), dnames{k}, 'FontSize',14, 'FontWeight','bold','Color', dur_clr,'HorizontalAlignment', 'right'); end;
        for k = 1:length(fnames), text(1.1, fimpair(k), fnames{k}, 'FontSize',14, 'FontWeight','bold','Color', freq_clr); end;
        title('hr aft - hr bef');
        set(gcf,'Position', [50+800   280   200   445]);
        set(gca,'XTick',[],'XLim',[0.5 1.5]);
        axes__format(gca);


        allimp=[dimpair; fimpair];
        allnm=[dnames; fnames];
        [y i] = sort(allimp);
        rankplot(allnm, i);


    case 'plot_qvalues'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load','addfname', addfname);
        end;

        sub__plotqvals(dqlin, dqsig);
        title('Timing rats');

        sub__plotqvals(fqlin, fqsig);
        title('Frequency rats');

    case 'plot_slopes'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load', 'addfname', addfname);
        end;

        [dslope dnames] = struct2array(dslope);
        [fslope fnames] = struct2array(fslope);

        % transform function
        dslope = sub__slopetr(dslope);
        fslope = sub__slopetr(fslope);

        dgrp=[];
        dgrp.xtklbl='Timing';
        dgrp.names=dnames;
        dgrp.clr=dur_clr;
        dgrp.dat=dslope;

        fgrp=[];
        fgrp.xtklbl='Frequency';
        fgrp.names=fnames;
        fgrp.clr=freq_clr;
        %   fgrp.dat=tan(fslope*(pi/2));
        fgrp.dat=fslope;

        % plotpairs(dgrp,fgrp);

        % now plot before after slopes on a per-rat basis
        2;
        allbef = [dslope(:,1); fslope(:,1)];
        allaft = [dslope(:,2); fslope(:,2)];
        allnames = [dnames; fnames];
        figure;
        msize=20;
        for k = 10:10:90
            if mod(k,30)==0, fw = 2; else fw=1; end;
            line([0 length(allnames)+1], [k k],'Color',[1 1 1]*0.3, 'LineStyle',':','LineWidth', fw); hold on;
        end;

        plot(1:length(allbef), allbef,'.b', 'MarkerSize',msize);
        plot(1:length(allaft), allaft,'.r', 'MarkerSize',msize);
        for k=1:length(allnames)
            tmp = allnames{k}(1:4);
            text(k-0.3, 10, tmp,'FontWeight','bold','FontSize',14);
            line([k+0.5 k+0.5],[0 90],'Color',[1 1 1]*0.3);
        end;
        set(gca,'YLim',[0 90], 'XLim',[0 length(allnames)+1]);
        ylabel('Degrees'); xlabel('Rat names');
        set(gcf,'Position',[100   340   843   260]);

    case 'plot_impairdim'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load','addfname', addfname);
        end;

        [dslope dbias dnames] =sub__getslopebias(dslope, dbias,1);
        [fslope fbias fnames] =sub__getslopebias(fslope, fbias,1);

        msize=8;
        %         figure;
        hold on;
        ds=sub__sdiff(dslope);
        db=sub__bdiff(dbias);
        plot(ds,db,'.r','Color', dur_clr,'MarkerSize',msize,'Marker','d','MarkerFaceColor',dur_clr);
        hold on;
        % give verbose output
        fprintf(1,'*** Timing ***\n');
        for k=1:length(dnames)
            fprintf(1,'%s=[%3.3f\t%3.3f]\n', dnames{k}, ds(k), db(k));
        end;

        fs=sub__sdiff(fslope);
        fb=sub__bdiff(fbias);
        plot(fs,fb,'.r','Color', freq_clr,'MarkerSize',msize,'Marker', 'd', 'MarkerFaceColor',freq_clr);
        2;
        % give verbose output
        fprintf(1,'*** Frequency ***\n');
        for k=1:length(fnames)
            fprintf(1,'%s=[%3.3f\t%3.3f]\n', fnames{k}, fs(k), fb(k));
        end;

        yl=[-1 1]; xl=[-1 1];
        xlabel('Slope change (>0 => flattening)'); ylabel('Bias change (>0 => increase)');
        set(gca,'YLim',yl);
        set(gca,'XLim',xl);
        line([0 0],yl,'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);
        line(xl,[0 0], 'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);

        % pool and compute impairment distance


    case 'impair'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load','addfname', addfname);
        end;

        if icalc == 7
            hr_ep=1;
        else
            hr_ep=0;
        end;

        % collect hit rate
        [dnames db] = sub__hitrate(dbrep, dbtal,hr_ep);
        [dnames2 da] = sub__hitrate(darep, datal,hr_ep);
        dhr = db-da;    
        
        if isempty(fbrep),        
            fhr=[];
        else
            [fnames fb] = sub__hitrate(fbrep, fbtal,hr_ep);
            [fnames2 fa] = sub__hitrate(farep, fatal,hr_ep);
              fhr = fb-fa;
              
        end;

        if ~cellstr_are_equal(dnames, dnames2)
            error('dnames order doesn''t match');
        end;

        if exist('fnames','var')
        if ~cellstr_are_equal(fnames, fnames2)
            error('dnames order doesn''t match');
        end;
        end;
          

        % 1= S+B
        % 2= norm(S) + norm(B)  where norm(x) = x/max(all x's)
        % 3= z-score. ( (s-mu(s))/sigma(s) ) + ( (b-mu(b)) / sigma(b) )
        % impair is (slope change)+(bias change)
        % 4= 2S+B
        % 5= 2S+B rectified by hit rate difference.
        % 6=PCA on slope, bias and hitrate

        [dimpair dnames ds db misc]=sub__computeimpair(dslope, dbias, dhr, icalc,...
            'slp2', fslope, 'bs2', fbias,'hr2', fhr, 'ignore_empty', ignore_empty);
        if icalc == 6
            g1s=length(dhr);

            dimpair = dimpair(:,1)+dimpair(:,2);
            
            if ~isempty(fhr)
                fimpair=dimpair(g1s+1:end);
            end;
            dimpair=dimpair(1:g1s);

            dnames = misc.names;
            if ~isempty(fhr)
                fnames = dnames(g1s+1:end); dnames=dnames(1:g1s);
                fs = ds(g1s+1:end);
                fb = db(g1s+1:end);
            end;
            ds= ds(1:g1s);
            db = db(1:g1s);


            %             % now do the bar graph version
            %             [g1x g2x]=makebargraph(dimpair, dimpair(g1s+1:end), 'ylbl', 'impair', ...
            %                 'g1_clr', dur_clr, 'g1_lbl', 'Timing', ...
            %                 'g2_clr', freq_clr, 'g2_lbl', 'Frequency');
            %             plot(ones(size(dhr))*g1x, dimpair, '.r', 'Color', [0.5 0 0],'MarkerSize', msize); hold on;
            %             plot(ones(size(fhr))*g2x, fimpair, '.r', 'Color', [0 0 0.5],'MarkerSize', msize);
            %             2;

            %             figure;
            %             impair = misc.impair;
            %             msize=20;
            %             plot(impair(1:g1s,1), impair(1:g1s,2), '.r', 'Color', dur_clr,'MarkerSize', msize); hold on;
            %             plot(impair(g1s+1:end,1), impair(g1s+1:end,2), '.r', 'Color', freq_clr,'MarkerSize', msize);
            %             n=misc.names;
            %             for k=1:length(n)
            %                 text(impair(k,1), impair(k,2),n{k});
            %             end;
            %
            %             xlabel('pca dim 1'); ylabel('pca dim 2');
            %             line([-3 3],[0 0],'LineStyle',':','Color', [1 1 1]*0.5,'LineWidth',2);
            %             line([0 0],[-3 3],'LineStyle',':','Color', [1 1 1]*0.5,'LineWidth',2);
            %
            %             vmini = misc.V;
            %             axes__format(gca);


        else
            [fimpair fnames fs fb]=sub__computeimpair(fslope, fbias, fhr, icalc,...
                'slp2', dslope, 'bs2', dbias, 'hr2', dhr,'ignore_empty',ignore_empty);
        end;


        dgrp=[];
        dgrp.xtklbl='Timing';
        dgrp.names=dnames;
        dgrp.clr=dur_clr;
        
        if ~isempty(fhr)

        fgrp=[];
        fgrp.xtklbl='Frequency';
        fgrp.names=fnames;
        fgrp.clr=freq_clr;
        end;

        toplot = {'s','b', 'impair'};
        tt = {'Slope term','Bias term','Impair'};
        poslist = [
            50   280   301   445
            50+400   280   301   445 ; ...
            50+800   280   301   445];
        for p=3:length(toplot)
            dgrp.dat=eval(['d' toplot{p}]);
            if isempty(fhr)
                fgrp.dat=[];
            else
                fgrp.dat=eval(['f' toplot{p}]);
            end;
            
            plot2groupdots(dgrp,fgrp);
            title(tt{p});
            set(gcf,'Position',poslist(p,:));
            axes__format(gca);
        end;

        % plot all impair on same x-value
        figure; msize=8;
        plot(ones(size(dimpair)), dimpair,'ob','Color', dur_clr,'MarkerSize', msize); hold on;
        for k = 1:length(dnames), text(0.9, dimpair(k), dnames{k}, 'FontSize',14, 'FontWeight','bold','Color', dur_clr,'HorizontalAlignment', 'right'); end;
        
        if ~isempty(fhr)
        plot(ones(size(fimpair)), fimpair,'.b','Color', freq_clr,'MarkerSize', msize);
        for k = 1:length(fnames), text(1.1, fimpair(k), fnames{k}, 'FontSize',14, 'FontWeight','bold','Color', freq_clr); end;
        end;
        
        title('impair');
        set(gcf,'Position', [50+800   280   200   445]);
        set(gca,'XTick',[],'XLim',[0.5 1.5]);
        xl = get(gca,'XLim');
        line(xl, [0 0],'Color',[1 1 1]*0.5,'LineWidth',2, 'LineStyle',':');

        axes__format(gca);


        % now plot a bar graph
        dimp=dimpair;
        if isempty(fhr)
           fimp=[];
        else
            fimp=fimpair;
        end;
        
        if sum(isnan(dimpair))>0
            warning('found NAN values in dimpair');
            dimp=dimpair(~isnan(dimpair));
        elseif sum(isnan(fimpair))>0
            warning('found NAN values in fimpair');
            fimp=fimpair(~isnan(fimpair));
        end;
        
        [dx fx]=makebargraph(dimp, fimp, 'g1_clr',dur_clr, 'g2_clr', freq_clr, 'g1_lbl','Timing', 'g2_lbl','Frequency');
        msize=6;
        plot(ones(size(dimp))*dx, dimp,'ob','Color', [0.3 0 0],'MarkerSize',msize,'LineWidth',1.5);
        if ~isempty(fhr)
            plot(ones(size(fimp))*fx, fimp,'ob','Color', [0 0 0.3],'MarkerSize',msize,'LineWidth',1.5);
        end;
        
        title('IMPAIR post-ACx lesion');
        ylabel('IMPAIR');
        axes__format(gca);
        set(gca,'YLim',[-0.3 1.5],'YTick',-0.2:0.2:1);
        set(gcf,'Position',[655   415   323   457]);
        
        [s p] = permutationtest_diff(dimp,fimp,'typeoftest','onetailed_ls0');
        joinwithsigline(gca,dx,fx,0.6,1,1.2);
        if p < 0.001, stars='***'; 
        elseif p < 0.01, stars='**'; 
        elseif p < 0.05, stars='*';
        else stars='ns'; end;
        text(1, 1.3, stars,'FontSize',20,'FontWeight','bold');
        
        allimp=[dimpair; fimpair];
        allnm=[dnames; fnames];
        [y i] = sort(allimp);
         rankplot(allnm, i);

        diff_list = cell(1,2); diff_list{1} = dimpair; diff_list{2} = fimpair;
        fname_list = cell(1,2); fname_list{1} = dnames; fname_list{2} = fnames;
        grpnames = {'duration','frequency'};

        outf = [ outdir area_filter '_impair_' addfname '_calc' num2str(icalc) ];
        save(outf, 'diff_list','fname_list','grpnames');

    case 'plot_sandb'
        if ~exist('fslope', 'var')
            fit_slopebias(area_filter,'load','addfname',addfname);
        end;


        sub__plotvaldiffs(dslope, dur_clr,'Timing',fslope, freq_clr, 'Frequency',@sub__sdiff,1);
        title('Slope'); ylabel('Post-Pre');
        axes__format(gca);

        sub__plotvaldiffs(dbias,dur_clr,'Timing',fbias,freq_clr,'Frequency', @sub__bdiff,0);
        axes__format(gca);
        title('Bias');ylabel('Post-Pre');

        % make raw and pool among groups
        allsl = structconcat(dslope, fslope);
        allbs = structconcat(dbias, fbias);
        [rsl sln] = struct2array(allsl); rsl=sub__sdiff(rsl);
        [rbs bsn] = struct2array(allbs); rbs=sub__bdiff(rbs);

        % are distributions approx. normal?
        percentile_plot(rsl, 'Slope');
        percentile_plot(rbs,'Bias');


    otherwise
        error('action not implemented');
end;

% ------------------------------------------------------------------------
% subroutines
% ------------------------------------------------------------------------
function [ breps btal areps atal bp ap pslope pbias pqlin pqsig] = sub__getparams(ratset, acxflag, postpsych, psychthresh, ignore_trialtype)

pslope=[];
pbias=[];
pqlin=[];
pqsig=[];
bp=[];
ap=[];

breps = [];
btal=[];
areps=[];
atal=[];

for r=1:length(ratset)
    fprintf(1,'*** %s\n', ratset{r});
    [bstruct astruct] = fit_singlepsych(ratset{r},...
        'acxflag', acxflag, 'postpsych', postpsych, ...
        'psychthresh', psychthresh, 'ignore_trialtype', ignore_trialtype);

    outp={'slope','bias','qlin','qsig'};
    for k =1:length(outp)
        eval(['p' outp{k} '.' ratset{r} '= [bstruct.' outp{k} ' astruct.' outp{k} '];']);
    end;

    bp=vertcat(bp, bstruct.p);
    ap=vertcat(ap, astruct.p);

    eval(['btal.' ratset{r} ' = bstruct.tallies;']);
    eval(['breps.' ratset{r} '= bstruct.reps;']);

    eval(['areps.' ratset{r} '=astruct.reps;']);
    eval(['atal.' ratset{r} '=astruct.tallies;']);
end;

% returns rats ranked from worst to best in slope difference
% v=raw before/after values; nm= names corresponding to v
% rk = rank number (1 is worst)
function [v nm i] =sub__rankslope(set1, set2)
[v1 nm1] = struct2array(set1);
[v2 nm2] = struct2array(set2);


v=vertcat(v1,v2);
v = sub__slopetr(v);
nm=vertcat(nm1, nm2);

x = sub__sdiff(v); % more +ve numbers mean larger slope changes
[y i] = sort(x);
i=i(end:-1:1);

fprintf(1,'*** Rank ***\n');
for k=1:length(i)
    fprintf(1,'#%i: %s = %1.2f\n', i(k), nm{i(k)}, x(i(k)));
end;
fprintf(1,'***      ***\n');


function [rawslp rawbs forder1] =sub__getslopebias(slp,bs,mkslpraw_flag)
[rawslp,forder1] = struct2array(slp);
rawslp = sub__slopetr(rawslp);

[rawbs, forder2] = struct2array(bs);

if ~cellstr_are_equal(forder1,forder2)
    error('fix the fnames order');
end;

% if mkslpraw_flag>0
%     rawslp=tan(rawslp*(pi/2));
% end;


% given slope and bias structs, computes 'impairment' measure in a variety
% of ways.
% returns:
% 1) impairment metric
% 2) forder - names of rats.
% 3) sterm and bterm - slope and bias terms after being transformed (operands to impairment calc)
function [impair,forder1, sterm bterm misc] = sub__computeimpair(slp,bs, hr, imethod, varargin)
pairs = { ...
    'slp2', [] ; ...
    'bs2', [] ; ...
    'hr2', []; ...
    };
parse_knownargs(varargin,pairs);
misc=[];
fprintf(1,'imethod = %i\n', imethod);

if isempty(slp)
    impair=[];
    forder1=[];
    sterm=[];
    bterm=[];
    misc=[];
    return;
end;
    

[rs,forder1] = struct2array(slp);
rs = sub__slopetr(rs);

if ~isempty(bs)
[rb, forder2] = struct2array(bs);
else
    bs=[];
end;


if ~cellstr_are_equal(forder1,forder2)
    error('fix the fnames order');
end;

if ismember(imethod,[2 3 6])
    [rs2, forder12] = struct2array(slp2);
    [rb2, forder22] = struct2array(bs2);
    if ~cellstr_are_equal(forder12,forder22)
        error('fix the fnames order');
    end;


    s2=sub__sdiff(rs2);
    b2 =sub__bdiff(rb2);
end;

switch imethod
    case 1 % s+b
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=sterm+bterm;
    case 4
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=(2*sterm)+bterm;
    case 2 % norm(s) + norm(b)-- norm_by_max
        s=sub__sdiff(rs);
        b=sub__bdiff(rb);

        sterm= (1/max([s; s2])) * s;
        bterm = (1/max([b; b2])) * b;

        impair=sterm+bterm;
    case 3 % norm(s) + norm(b) -- norm_by_mean
        s=sub__sdiff(rs);
        b=sub__bdiff(rb);

        sterm= (1/mean([s; s2])) * s;
        bterm = (1/mean([b; b2])) * b;
        impair=sterm+bterm;

    case 5
        % set to +ve if hit rate worsened after lesion
        % hr > 0 means impair
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=(2*sterm)+bterm;

        impair(hr>0) = abs(impair(hr > 0));

    case 6 % PCA on slope, bias and hit rate
        misc.names = [forder1; forder12];

        s = sub__sdiff(rs); s2 = sub__sdiff(rs2);
        b = sub__bdiff(rb); b2 = sub__bdiff(rb2);

        s = [sub__row(s); sub__row(s2)]; sterm=s;
        b = [sub__row(b); sub__row(b2)]; bterm=b;
        hr = [sub__row(hr);sub__row(hr2)];

        s = sub__normalize(s,misc.names); title('slope');
        b = sub__normalize(b,misc.names); title('bias');
        h = sub__normalize(hr,misc.names); title('hrate');
        X = [s b h];

        [V,D]=eig(X'*X);

        % pick only 2nd and 3rd column
        misc.V=V;
        misc.D=D;
        misc.X=X;
        misc.colchoices = [1 2];

        impair = X * V(:,misc.colchoices);
        misc.impair = impair;
        sterm = s;

    case 7 % (slope+bias correct)*change in hit rate
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair = ((1*sterm)) + hr;

    case 8
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=hr;
        
    case 9
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=bterm;
        
    case 10
        sterm=sub__sdiff(rs);
        bterm=sub__bdiff(rb);
        impair=sterm;

    otherwise
        error('invalid method code');
end;

function [] = sub__plotqvals(qlin, qsig)
% get raw values for q's
[qlin_raw forder1]=struct2array(qlin);
[qsig_raw forder2]=struct2array(qsig);
if ~(cellstr_are_equal(forder1,forder2))
    error('fnames don''t match');
end;

offset=2;
xpos=1;
msize=20;
figure;
xtks=[];
for k=1:length(forder1)
    plot([xpos xpos+1], qlin_raw(k,:),'-k');hold on;
    plot([xpos xpos+1], qlin_raw(k,:), '.k', 'Marker','o','MarkerSize',8);
    plot([xpos xpos+1], qsig_raw(k,:),'-b');
    plot([xpos xpos+1], qsig_raw(k,:), '.b','MarkerSize',msize);
    xtks=horzcat(xtks, xpos+0.5);

    line([xpos+1.5 xpos+1.5],[0 1], 'Color', [1 1 1]*0.5);
    xpos=xpos+offset;
end;

line([0 xpos], [0.1 0.1],'Color',[1 1 1]*0.5, 'LineWidth',2,'LineStyle',':');

text(xpos-1,0.9, 'Line fit', 'Color','k','FontWeight','bold', 'FontSize',14);
text(xpos-1, 0.85,'Sigmoid fit', 'Color','b','FontWeight','bold', 'FontSize',14);

ylabel({'Q', '(Line:BK; Sigmoid:BL)'});
set(gca,'XLim',[0 xpos],'XTick',xtks,'XTickLabel', forder1);
set(gcf,'Position',[ 360   613   873   245]);
axes__format(gca);


function [] = sub__plotvaldiffs(g1, g1clr, gnm1, g2, g2clr,gnm2,fnhandle, amslope)
figure;
sub__ps(g1,g1clr,1, fnhandle,amslope); hold on;
sub__ps(g2,g2clr,2, fnhandle,amslope);

set(gca,'XLim',[0.5 2.5]);
set(gca,'XTick',1:2, 'XTickLabel',{gnm1, gnm2});
set(gcf,'Position',[440   289   301   445]);


function [flist fraw] = sub__ps(g, gclr,xpos, f,amslope)
msize=20;

[fraw flist] = struct2array(g);
if amslope > 0
    fraw = sub__slopetr(fraw);
end;
diff=f(fraw);

plot(ones(length(flist))*xpos, diff, '.b', 'Color',gclr,'MarkerSize',msize);
for k=1:length(flist)
    text(xpos+0.2, diff(k), flist{k},'FontWeight','bold','FontSize',14);
end;


% given replong and tallies for multiple rats (one rat per row)
% returns overall "% correct" value for each rat
function [nm h] = sub__hitrate(rp, tl, endpoints_only)

lbound = 4;
rbound = 5;
tidx=1:8;

if endpoints_only>0
    lbound=2;
    rbound=7;
    tidx=[1:lbound rbound:8];
end;


nm = fieldnames(rp);
h=NaN(size(nm)); % each row has a hit rate

for k=1:length(nm)
    r = eval(['rp.' nm{k} ';']);
    t = eval(['tl.' nm{k} ';']);
   
    if strcmpi(nm{k},'Bilbo')
        2;
    end;

    low = sum(t(1:lbound) - r(1:lbound)); % # correct trials on low
    hi =  sum(r(rbound:8)); % # correct trials on high

    h(k) = (low+hi) / sum(t(tidx));
    if isnan(h(k))
        low=sum(t(1:4)) - sum(r(1:4));
        hi = sum(5:8);
        h(k) = (low+hi) / sum(t);
    end;

end;



% convert slope from degree to radian
function [s] = sub__slopetr(s)
multfac=0.73; shiftfac = 0;
srad=atan(s * multfac);
sdeg= (180/pi)*srad;
s=sdeg-shiftfac;

% force to be a row vector
function [s] = sub__row(s)
if rows(s) > 1 && cols(s) > 1, error('sorry, I only work with vectors, not matrices.'); end;
if cols(s)>1, s=s'; end;

function [d] = sub__sdiff(s)
d=(s(:,1)-s(:,2))/90;

function [d] =sub__bdiff(b)
d=abs(b(:,2)-b(:,1));


function [s] = sub__same(s)
function [t] = sub__rectify(s)
t=abs(s);

function [s2] = sub__normalize(s,n)
if ~(rows(s)>1 && cols(s) ==1), error('sorry, I only take row vectors'); end;

mu=mean(s); sigma=std(s);
s2=(s-mu) ./ sigma;

figure;
x=[zeros(size(s)); ones(size(s2))];
y = [s; s2];
for k=1:length(s)
    line([0 1],[s(k) s2(k)],'Color','r'); hold on;
    text(2, s2(k), n{k});
end;

plot(x,y,'.k','MarkerSize', 15);
set(gca,'XLim',[-1 3],'XTick',[0 1], 'XTickLabel', {'orig','norm'});
set(gcf,'Position',[98   327   419   563]);

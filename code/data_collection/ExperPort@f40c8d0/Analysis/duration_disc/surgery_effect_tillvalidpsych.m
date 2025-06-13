function [] = surgery_effect_tillvalidpsych(action)
% For each rat in the set, gets the first post-lesion session in which the
% rat met criteria to generate valid psych curve (see loadpsychinfo for
% description of criteria).
% plots this metric for duration rats and frequency rats

if nargin<1, action='load'; end;

ACxround1=1;
preflipped=1;
psychthresh=1;
postpsych=1;
ignore_trialtype=0;
isafter=1;

area_filter='ACx';

global Solo_datadir;
outdir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
outf = [outdir mfilename];

switch action
    case 'save'
        % duration rats first
        durlist = rat_task_table('','action','get_duration_psych','area_filter',area_filter);

        dfirst=NaN(size(durlist));
        for r=1:length(durlist)
            ratname=durlist{r};
            loadpsychinfo(ratname, 'infile', [ratname '_psych_after'], 'justgetdata',1,...
                'graphic',0, ...
                'ACxround1', ACxround1, ...
                'preflipped', preflipped, ...
                'psychthresh',psychthresh,...
                'postpsych', postpsych, ...
                'ignore_trialtype', ignore_trialtype, ...
                'isafter', isafter, ...
                'dstart', 1, 'dend', 3,'lastfew', 1000,...
                'eliminate_Mondays', 0,...
                'daily_bin_variability', 1, 'patch_bounds', 1);
            dfirst(r)=useidx(1);
        end;

        % frequency rats second
        freqlist = rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

        ffirst=NaN(size(freqlist));
        for r=1:length(freqlist)
            ratname=freqlist{r};
            loadpsychinfo(ratname, 'infile', [ratname '_psych_after'], 'justgetdata',1,...
                'graphic', 0 , ...
                'ACxround1', ACxround1, ...
                'preflipped', preflipped, ...
                'psychthresh',psychthresh,...
                'postpsych', postpsych, ...
                'ignore_trialtype', ignore_trialtype, ...
                'isafter', isafter, ...
                'dstart', 1, 'dend', 3,'lastfew', 1000,...
                'eliminate_Mondays', 0,...
                'daily_bin_variability', 1, 'patch_bounds', 1);
            ffirst(r)=useidx(1);
        end;

        save(outf, 'durlist', 'dfirst', 'freqlist', 'ffirst');

    case 'load'       
        try
            load(outf);
        catch
            fprintf(1,'Unable to load. Resaving...\n');
            surgery_effect_tillvalidpsych('save');
            load(outf);
        end;
        dfirst
        ffirst
        
        bins=1:10;
        h=hist(dfirst,bins); set(h,'FaceColor', group_colour('duration'));
        f=hist(ffirst,bins); set(f,'FaceColor', group_colour('frequency'));

%         [x1 x2]=makebargraph(dfirst, ffirst, ...
%             'g1_clr', group_colour('duration'), 'g2_clr', group_colour('frequency'), ...
%             'g1_lbl','Timing','g2_lbl','Frequency', 'ylbl',{'First post-lesion session','with valid psych trials'}, 'errtype','std');
%         
%         msize=24;
%         plot(ones(size(dfirst))*x1, dfirst,'.r','Color', [1 0 0], 'MarkerSize',msize);
%         plot(ones(size(ffirst))*x2, ffirst,'.r','Color', [0 0 0.3], 'MarkerSize',msize);
%         title(sprintf('%s: Sessions till valid psych',area_filter));    
%         set(gca,'YTick',0:2:8, 'YLim',[0 8]);
%         axes__format(gca);
        
    otherwise
        error('invalid action');
end;
2;
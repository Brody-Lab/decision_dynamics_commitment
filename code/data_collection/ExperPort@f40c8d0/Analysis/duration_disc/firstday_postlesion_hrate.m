function [] = firstday_postlesion_hrate(area_filter, numt)

lastfew=0;

d = rat_task_table('','action', 'get_duration_psych', 'area_filter',area_filter);
dhpre = sub__ratset(d,50,1);
dh=sub__ratset(d,numt,lastfew);
dh= [dhpre dh];

f = rat_task_table('','action', 'get_pitch_psych', 'area_filter',area_filter);
fhpre=sub__ratset(f,50,1);
fh=sub__ratset(f,numt, lastfew);
fh = [fhpre fh];

if length(numt) < 2
    makebargraph(dh, fh, ...
        'g1_clr', group_colour('duration'), 'g2_clr', group_colour('frequency'), ...
        'g1_lbl','Timing', 'g2_lbl','Frequency','errtype','iqr');

    title(sprintf('%s: First %i', area_filter, numt));
    uicontrol('Tag', 'figname', 'Style','text', 'String', [area_filter '_first' num2str(numt)], 'Visible','off');
    ylabel('% Correct');

    [s p]=permutationtest_diff(dh, fh);
    fprintf(1,'sig:%i, p=%1.2f\n', s, p);

    set(gca,'YLim',[0 1.2],'YTick',0.2:.2:1,'YTickLabel',20:20:100);
else
    %
    %     figure;
    %     colormap hot;
    %     cmap = colormap;
    %     df=mean(dh,1)-mean(fh,1);
    %     TOP_DIFF = 0.5;
    %     for t=1:length(numt)
    %         patch([t t t+1 t+1], [0 1 1 0], cmap(floor((df(t)/TOP_DIFF) * length(cmap)),:));
    %     end;
    %
    %     colorbar;
    %     set(gca,'YLim',[0 1]);
    %     set(gca,'XTick', 1.5:1:length(numt)+1,'XTickLabel',numt);
    %     set(gcf,'Position',[100 100 800 150]);
    
    numt=[-50 numt];

    dclr=group_colour('duration');
    fclr=group_colour('frequency');
    data=cell(length(numt),2);
    clr= [dclr; fclr];
    for k=1:length(numt)
        data{k,1} = dh(:,k);
        data{k,2} = fh(:,k);
    end;
    [xpos] = makebargroups(data,clr, 'errtype','iqr','what2show','median');

    line([0 xpos(end)+1],[0.5 0.5],'LineStyle',':','Color',[1 1 1]*0.5,'LineWidth',2);
    set(gca,'XTickLabel',[numt]);
    set(gca,'YLim',[0 1.2], 'YTick',0:0.2:1,'YTickLabel',0:20:100);
    ylabel('% Correct');
    title([area_filter ': First X post-lesion trials']);

    axes__format(gca);
    set(gcf,'Position',[123   495   978   310]);
end;



function [hrate] = sub__ratset(ratlist,numt,lastfew)

global Solo_datadir;
indir=[Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep 'psych_compiles' filesep];

hrate=NaN(length(ratlist), length(numt));

for r=1:length(ratlist)
    if lastfew > 0
        infile = [indir ratlist{r} '_psych_before'];
    else
        infile = [indir ratlist{r} '_psych_after'];
    end;

    load(infile);

    for s=1:length(numt)
        currt = min(numt(s), numtrials(1));
        clr=rand(1,3);
        if lastfew>0
            hrate(r,s)=mean(hit_history(end-currt:end));
        else
            hrate(r,s)=mean(hit_history(1:currt));
        end;
    end;
end;

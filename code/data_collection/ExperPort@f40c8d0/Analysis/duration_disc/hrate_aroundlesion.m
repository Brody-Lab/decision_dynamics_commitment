function [] = hrate_aroundlesion(area_filter,action)

switch action
    case 'save'
        dur_rats = rat_task_table('','action','get_duration_psych','area_filter',area_filter);
        freq_rats =rat_task_table('','action','get_pitch_psych','area_filter',area_filter);

        experimenter='Shraddha';
        lastfew=5;
        firstfew=3;

        durbef=NaN(length(dur_rats),lastfew*2);
        duraft=NaN(length(dur_rats),firstfew*2);
        freqbef=NaN(length(freq_rats),lastfew*2);
        freqaft=NaN(length(freq_rats),firstfew*2);

        for r=1:length(dur_rats)
            loadpsychinfo(dur_rats{r}, 'infile','psych_before','lastfew',lastfew,'justgetdata',1,'noplot',1);
            durbef(r,:) = sub__hrate(concat_hh, numtrials);

            loadpsychinfo(dur_rats{r}, 'infile','psych_after','isafter',1, ...
                'dstart',1, 'dend', firstfew, 'justgetdata',1,'noplot',1);
            try
                duraft(r,:) =sub__hrate(concat_hh, numtrials);
            catch
                2;
            end;
        end;

        for r=1:length(freq_rats)
            loadpsychinfo(freq_rats{r}, 'infile','psych_before','lastfew',lastfew,'justgetdata',1,'noplot',1);
            freqbef(r,:)=sub__hrate(concat_hh, numtrials);

            loadpsychinfo(freq_rats{r}, 'infile','psych_after','isafter',1, ...
                'dstart',1, 'dend', firstfew, 'justgetdata',1,'noplot',1);
            try
                freqaft(r,:)=sub__hrate(concat_hh, numtrials);
            catch
                2;
            end;

        end;
        
        desc='durbef has mean hitrate of lastfew pre-lesion sessions with sems of same sessions. similar format for duraft,freqbef, freqaft';
        desc = {desc ; 'first X columns are means; next X cols are sems'};
        
        save('mPFC_hrates','durbef','duraft','freqbef','freqaft','dur_rats','freq_rats','desc', 'lastfew','firstfew','area_filter')

    case 'load'        
       global Solo_datadir;
       indir = [Solo_datadir filesep 'Data' filesep 'Shraddha' filesep 'Set_Analysis' filesep];
       load([indir 'mPFC_hrates']);
       
       dclr=group_colour('duration');
       fclr=group_colour('frequency');
       
       figure;
       for d=1:length(durbef)
           try
           y=durbef(d,1:lastfew); err=durbef(d,lastfew+1:end);
           catch
               2;
           end;
           errorbar(-1*lastfew:1:-1, y,err,err,'.b','Color',dclr); hold on;
           plot(-1*lastfew:1:-1, y,'-b','Color',dclr);
       end;
2;
        
    otherwise
        error('invalid action');
end;



2;

function [o] = sub__hrate(hh, tr)

cumt = cumsum(tr);

h=NaN(size(tr));
v=NaN(size(tr));
for t=1:length(tr)
    if t==1, sidx=1; else sidx=cumt(t-1)+1; end;
    eidx=cumt(t);
    fprintf(1,'%i\t:%i\n', sidx,eidx);

    c=hh(sidx:eidx);
    c=c(~isnan(c));
    h(t)=mean(c);
    if isnan(h(t))
        2;
    end;
    v(t)=std(c)/sqrt(length(c));
end;

o=[h v];
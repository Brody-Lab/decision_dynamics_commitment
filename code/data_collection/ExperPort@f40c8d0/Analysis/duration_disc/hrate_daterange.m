function [] = hrate_daterange(ratname, varargin)
% plots the hit rate over a range of dates. data across sessions are not
% mixed.

pairs = { ...
    'from', '000000'; ...
    'to', '999999' ; ...
    'preset', 'none' ; ... % [none | prelesion | postlesion]
    'graphic', 0 ; ...
    'first_few', 1000;... % not valid for prelesion
    'last_few', 1000 ; ... % not valid for postlesion
    };
parse_knownargs(varargin, pairs);

if iscell(ratname)
    for k=1:length(ratname)
        sub__eachrat(ratname{k}, from, to, preset, graphic, first_few, last_few);
    end;
else
        sub__eachrat(ratname, from, to, preset, graphic, first_few, last_few);
end;

function [] = sub__eachrat(ratname, from, to, preset, graphic,first_few, last_few)

switch preset
    case 'none'        
    case 'prelesion'
        ratrow=rat_task_table(ratname);
        dt=ratrow{1,rat_task_table(ratname,'action','get_prepsych_col')};
        from=dt{1}; to=dt{2};
        
        
    case 'postlesion'
        ratrow=rat_task_table(ratname);
        dt=ratrow{1,rat_task_table(ratname,'action','get_postpsych_col')};
        from=dt{1}; to=dt{2};
    otherwise
        error('invalid preset value');
end;            

get_fields(ratname,'from', from, 'to', to);
cumtrials = cumsum(numtrials);

if ~strcmpi(preset,'prelesion')
    maxdays = min(last_few, length(numtrials));
    idx=length(dates)-(maxdays-1):length(dates);
elseif ~strcmpi(preset,'postlesion')
    maxdays=min(first_few, length(numtrials));
    idx=1:maxdays;
end;

dates= dates(idx);
fprintf(1,'%s:',ratname);
for d=1:length(dates), fprintf(1,'%s ', dates{d}); end;
fprintf(1,'\n');

hh=[];
for p=idx
    if p==1, sidx=1; else sidx = cumtrials(p-1)+1;end;
    eidx=cumtrials(p);
    
    h2=hrate_kernalize(hit_history(sidx:eidx)); if rows(h2>1), h2=h2';end;
    hh = horzcat(hh, h2);
end;

if graphic==0, return; end;

figure;
set(gcf,'Position',[100 200 200*maxdays 300]);
axes('Position',[0.05 0.1 0.9 0.85]);

clr='b';
plot(hh*100,'-r', 'Color',clr); hold on;
plot(hh*100,'.r','Color',clr);
for p=1:maxdays
    line([cumtrials(p) cumtrials(p)], [0 100],...
    'LineStyle','-','Color','k');
end;
xlabel('Trial #');
ylabel('hit rate');
set(gca,'XLim', [0 length(hh)],'YLim',[45 100]);

text(10, 95, ratname,'FontSize', 18, 'FontWeight','bold');

axes__format(gca);
set(gcf,'Toolbar','none');
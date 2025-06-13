function [clast claststate idx] = rxn_time_statewise(p,rts,varargin)

pairs = { ...
    'validcoutstates', {'cue','pre_go','chord','wait_for_apoke'} ;...
    'graphic', 0 ; ...
    
    };
parse_knownargs(varargin,pairs);


clens=cell(size(p));
cen_all=[]; % all valid center pokes
clast=NaN(size(p)); % last center poke of each trial
claststate=NaN(size(p));
clast2wa=NaN(size(p)); %time between this cout and start of wait_for_apoke
for k=1:rows(p)
    cens = p{k}.center1_states(:,2);
    wa=p{k}.wait_for_apoke(1,1);
    isvalid=1;
    c=1;

    sset=[];
    for s=1:length(validcoutstates), sset=horzcat(sset, eval(['rts{k}.' validcoutstates{s}])); end;
    validcouts = ismember(cens, sset);


    if rows(p{k}.wait_for_apoke)>1
        error('why does wapoke have >1 row?');
    end;

    cen= p{k}.center1(validcouts==1,:);
    tmp = cen(:,2)-cen(:,1);

    try
        clens{k}=tmp;

        clast2wa(k)=wa(1,1)-cen(end,2);

        if clast2wa(k)>0.05
            2;
        end;
    catch
        error('no final cout?');
    end;

    if rows(clens{k}) > 1, clens{k}=clens{k}';end;
    cen_all=horzcat(cen_all, clens{k});

    % last cpoke of trial
    clast(k)=tmp(end);

    isvalid=find(validcouts>0);
    mys=p{k}.center1_states(isvalid(end),2);
    for s=1:length(validcoutstates),
        if ismember(mys, eval(['rts{k}.' validcoutstates{s}]) )
            claststate(k)=s;
        end;
    end;

end;

% ignore those trials where cout occurred suspiciously far away from
% wait_for_apoke
idx = intersect(find(clast2wa < 0.1), find(clast2wa > -0.1));

claststate=claststate(idx);
clast=clast(idx);


if graphic >0
    % show distribution of states in which last-couts occurred
    figure;
    n = hist(claststate, 1:length(validcoutstates));
    plot(n,'.b');
    set(gca,'XLim',[0 length(validcoutstates)+1],'XTick', 1:length(validcoutstates), 'XTickLabels', validcoutstates);
    fprintf(1,'Cout states=%i of %i accounted for\n', sum(n), rows(p));
    xlabel('State of cout');
    ylabel('# couts');
    %title(sprintf('%s:%s to %s',ratname, fromd, tod));

    % show distribution of lengths of all couts, and those of last-couts
    figure;
    plot(ones(size(cen_all)), cen_all,'.b');hold on;
    plot(ones(size(clast))*2, clast, '.r');
    set(gca,'XLim',[0 3],'XTick',1:2,'XTickLabel',{'All Cpokes','Last Cpoke'});
    ylabel('Duration (s)');
    %title(sprintf('%s:%s to %s',ratname, fromd, tod));
end;


2;


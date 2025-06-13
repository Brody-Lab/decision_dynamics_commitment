function [] = reaction_time_notimeouts(ratname, indate)
% for each trial, returns the reaction time
% reaction time is defined as time between the first side-poke and the cout
% that preceded it.
% Also returns, for each such reaction_time, what the duration of cpoke
% before it was.

get_fields(ratname, 'from', indate, 'to', indate, 'datafields',{'pstruct'});

hits=find(hit_history==1);
pstruct=pstruct(hits);
for k=1:rows(pstruct)
    2;
end;
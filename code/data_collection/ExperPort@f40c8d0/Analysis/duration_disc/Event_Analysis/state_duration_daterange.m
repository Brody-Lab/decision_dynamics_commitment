function [statedurs] = state_duration_daterange(ratname, from, to, varargin)

pairs = { ...
    'statelist', {'wait_for_cpoke','wait_for_apoke'};...
    'followhh', 'all' ; ... [ all | hit | miss ] % see state_duration_sessionavg for description
    'graphic', 0 ; ...
    'use_dateset','range'; ... % range or given
    'given_dateset', {} ; .... % fill with dates for analysis if use_dateset=given
    };
parse_knownargs(varargin,pairs);    


get_fields(ratname, 'from', from, 'to', to, 'use_dateset', use_dateset , ...
    'given_dateset', given_dateset, 'datafields',{'pstruct'});


statedurs=0;

for s=1:length(statelist)
    eval(['statedurs.' statelist{s} '=[];']);
end;

cumtrials=cumsum(numtrials);
for p = 1:length(numtrials)
    if p==1, sidx=1; else sidx=cumtrials(p-1)+1; end; 
    eidx=cumtrials(p);
    
    currp=pstruct(sidx:eidx);
    sd=state_duration_sessionavg(currp, statelist, 'followhh', followhh,'hh', hit_history(sidx:eidx));
    for s=1:length(statelist)
        eval(['tmp=statedurs.' statelist{s} ';']);
        tmp=horzcat(tmp, eval(['sd.' statelist{s} ';']));
        eval(['statedurs.' statelist{s} '=tmp;']);
    end;
end;

2;
function [] = hrate_daterange_ratset(varargin)

pairs = {...
    'wildcard', 0 ; ... % set this to 1 if you want to directly supply ratset
'ratset', {} ; ...
'area_filter', 'ACx2'; ... % choose from value names of area_(tasktype) struct (rat_task_table)
'tasktype', 'pitch' ; ...
'first_few', 1000 ; ...
'preset', 'postlesion'; ...
};
parse_knownargs(varargin,pairs);

if wildcard==0
ratset=rat_task_table('','action',['get_' tasktype '_psych'],'area_filter',area_filter);
end;

hrate_daterange(ratset, 'from','090204','graphic',1,'first_few', first_few, 'preset', preset);

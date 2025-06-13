function [] = triallen_influence_oneday(ratname, oneday, varargin)
pairs = {
    'psych_only', 1 ; ... % set false to look at psych and non-psych trials
    };
parse_knownargs(varargin,pairs);

 triallen_influence(ratname,'use_dateset','given','given_dateset',{oneday},'psych_only', psych_only)
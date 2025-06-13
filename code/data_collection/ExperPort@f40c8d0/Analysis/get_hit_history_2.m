function [hh] = get_hit_history_2(ratname, task, date, varargin)
% Given a ratname, task name (classname for the task), date (YYMMDD
% format), returns the hit_history for the particular experiment.
%
% Optional parameters:
% f_ver: the version of the file returned ('a','b','c', etc.,). Default is
% 'a'.
%

pairs = { ...
    'f_ver', 'a'; ...
    };

parse_knownargs(varargin, pairs);

load_datafile(ratname, task, date, f_ver);
hh = eval(['saved.' task '_hit_history;']);

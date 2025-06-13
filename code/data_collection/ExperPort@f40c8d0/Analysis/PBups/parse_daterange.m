function [date_str startdate enddate] = parse_daterange(daterange)
% function [date_str startdate enddate] = parse_daterange(daterange)
%
% daterange may be:
%	1) numeric (single number or range of integers), specifying
%	   number of days in the past from today
%      for exmple 
%	2) a string of the form 'yyyy-mm-dd' for a specific date
%	3) a cell array of two string specifying a range of dates
%	4) a cell array of a column vector of strings with specific dates
%
% returns date_str, which may be used with bdata to pull out the correct
% dates

if ischar(daterange),
	date_str = ['sessiondate="' daterange '"'];
	startdate = daterange;
	enddate   = daterange;
elseif iscell(daterange),
	if size(daterange,1) == 1,
		date_str = ['sessiondate>="' daterange{1} '" and sessiondate<= "' daterange{2} '"'];
		startdate = daterange{1};
		enddate   = daterange{2};
	else
		date_str = ['sessiondate="' daterange{1} '" '];
		startdate = daterange{1};
		enddate = daterange{end};
		for nd = 2:size(daterange,1),
			date_str = [date_str 'or sessiondate="' daterange{nd} '" '];
		end;
	end;
else % if daterange is numeric
    if length(daterange) == 1, %#ok<ALIGN>
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(0) ' day)']);
    else
        startdate= bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(1)) ' day)']);
        enddate  = bdata(['select date_sub("' datestr(now,29) '" , interval ' num2str(-1*daterange(2)) ' day)']);
	end;
    date_str = ['sessiondate>="' startdate{1} '" and sessiondate<= "' enddate{1} '"'];
	startdate = startdate{1};
	enddate   = enddate{1};
end
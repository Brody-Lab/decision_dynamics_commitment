%   [ymd] = yearmonthday([datenum=now])   Returns year, month, day in
%                                         string format, YYMMDD .
%
% Default day to do this for is "now", i.e. when the function is
% called. But other days are acceptable. E.g., for 5 days ago you can
% call:
%
%   >> yearmonthday(now-5)
%
% If you give no date at all, it assumes you mean today, e.g.:
%
%   >> today_string = yearmonthday;
%

function [ymd] = yearmonthday(day)

   if nargin<1, day = now; end;
   
   ymd = datestr(day,25);
   ymd = ymd([1 2 4 5 7 8]);
   
   
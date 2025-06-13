%yearmonthday.m   [ymd] = yearmonthday()   Returns the current year, month,
%                                          and day in string format, YYMMDD

function [ymd] = yearmonthday()

   ymd = datestr(date,25);
   ymd = ymd([1 2 4 5 7 8]);
   
   
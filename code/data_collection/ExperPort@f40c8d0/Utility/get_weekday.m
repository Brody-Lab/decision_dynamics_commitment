function [wd] = get_weekday(d, varargin)
% Given a date string formatted as yymmdd, returns the corresponding
% weekday
% Sample usage:
%    m = get_weekday('060420');
%    m  ('Thu');
% Options:
% 'single_letter' - set to 1 to get single-letter equivalents of the
% weekdays:
  
%
% Single-letter equivalents of weekdays (Mon-Sun): M, T, W, R, F, S, N
  
  pairs = { ...
      'single_letter', 0
      };
  parse_knownargs(varargin, pairs);
 
  sl_array = 'NMTWRFS'; % array of single-letter weekdays
  
   [n, s] = weekday([d(3:4) '/' d(5:6) '/' d(1:2)]);
   
   if single_letter > 0
     wd = sl_array(n);
   else
     wd = s;
   end;
  
  
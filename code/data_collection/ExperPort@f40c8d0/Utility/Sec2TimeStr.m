function timestr = Sec2TimeStr(sec)
% TIMESTR = SEC2TIMESTR(SEC)
% convert time in seconds to a pretty format in hours, minutes

   hours = floor(sec/3600);
   minutes = floor(sec/60)-hours*60;
   seconds = floor(sec - hours*3600 - minutes*60);
   
   
   timestr = sprintf('%02d:%02d:%02d',hours,minutes,seconds);
   
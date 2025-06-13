% [c] = cellstr(wt)
%
% Given a WaterCalibrationTable object, returns a cell column
% vector. Each row will be a string. When displayed in order, this
% makes for a nice human-readable representation of the table.
%

function [c] = cellstr(wt)

   c = cell(length(struct(wt))+1, 1);

   c{1} = 'Initials      Date         Valve      secs  ul Dispense';
   for i=2:rows(c),
      initials = wt(i-1).initials;
      initials = [initials ' '*ones(1, 7-length(initials))];

      date     = datestr(wt(i-1).date, 'dd/mmm/yy HH:MM');

      valve    = wt(i-1).valve;
      valve    = [valve ' '*ones(1, 12-length(valve))];
      
      time     = sprintf('%g', wt(i-1).time);
      time     = [time ' '*ones(1, 7-length(time))];

      dispense = sprintf('%g', wt(i-1).dispense);
      dispense = [dispense ' '*ones(1, 7-length(dispense))];
      c{i} = sprintf('%s %s  %s %s %s', initials, date, valve, time, ...
                     dispense);
   end;
   
          

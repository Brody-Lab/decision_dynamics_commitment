% [wt, offside] = add_entry(wt, initials, valve, time, dispense)
%
% Adds an entry into a WaterCalibrationTable object wt. Returns the
% updated wt, and another WaterCalibrationTable object, offside. This
% last is a subset of wt, and contains all the entries that are
% inconsistent with the added entry (see
% inconsistent_with_last_entry.m). 
%
% If offside is empty (i.e., isempty(offside)==1), then there were no
% inconsistencies. 
%
% PARAMETERS:
% -----------
%
% wt       The WaterCalibrationTable object to add an entry to
%
% initials A string with the initials of the human doing the
%          calibration.
%
% valve    A string identifying the name of the valve for which an
%          entry is being added. E.g., 'left1water'. Or any other name.
%
% time     Number, assumed to be in seconds, indicating how long the
%          valve was open for.
%
% dispense Number, assumed to be in uL, indicating how much water came
%          out. 
%



function [wt, offside] = add_entry(wt, initials, valve, time, dispense)

   if ~isnumeric(time) | ~isnumeric(dispense),
      error(['time must be a number, in seconds, and dispense must be a ' ...
             'number, in ul.']);
   end;

   % Check to see whether the same time entry existed for this valve:
   valves = cell(size(wt)); [valves{:}] = deal(wt.valve); 
   times  = cell(size(wt)); [times{:}]  = deal(wt.time);
   times  = cell2mat(times);
   
   if ~isempty(valves) & ~isempty(times),
      u = find(strcmp(valve, valves) & time == times);
   else
      u = [];
   end;
   
   wt(end+1).initials = initials;
   wt(end).date       = now;
   wt(end).valve      = valve;
   wt(end).time       = time;
   wt(end).dispense   = dispense;
   
   wt = WaterCalibrationTable(wt);
   
   % If there was a previous entry with same valve, same time, delete it
   if ~isempty(u),
      wt = remove_entry(wt, u);
   end;

   offside = inconsistent_with_last_entry(wt);
   
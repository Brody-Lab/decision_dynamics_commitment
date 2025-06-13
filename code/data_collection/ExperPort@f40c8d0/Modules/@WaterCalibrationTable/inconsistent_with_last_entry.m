% [offside] = inconsistent_with_last_entry(wt)
% 
% Checks a wt object for inconsistencies in the sense of a monotonic
% time-->water relationship. That is, looks at the very last entry,
% and asks whether any previous entries are inconsistent in the sense
% that either (1) a smaller dispense time gives greater water; or (2) a
% greater dispense time gives less water.
%
% If any of these are found, returns a WaterCalibrationTable object
% containing only these, the inconsistent, entries. If the return is
% empty, no inconsistencies were found. 
%


function [offside] = inconsistent_with_last_entry(wt)
   
% check for offside entries  (entries with lower times but higher dispenses)

   if isempty(wt), offside = wt; return; end;

   valves = cell(size(wt)); [valves{:}] = deal(wt.valve); 
   times  = cell(size(wt)); [times{:}]  = deal(wt.time);
   times  = cell2mat(times);
   dispenses = cell(size(wt)); [dispenses{:}]  = deal(wt.dispense);
   dispenses  = cell2mat(dispenses);

   u = find(strcmp(valves{end}, valves) & ...
            ((times < times(end) & dispenses >= dispenses(end)) | ...
             (times > times(end) & dispenses <= dispenses(end)))  );
   offside = wt(u);
   
% [valves, times, dispenses, dates] = deal_table(wt)
%
% parses out a table from its structure/object form into separate cell
% vectors of strings or numeric matrices. All returned objects have the
% same number of elements.
%
% PARAMETERS:
% -----------
%
% wt     A WaterCalibrationTable object
%
% RETURNS:
% --------
%
% valves      A cell vector of strings representing valve names
%
% times       A numeric vector of times representing valve opening times.
%
% dispenses   A numeric vector of dispenses giving dispense volumes
%             corresponding to the opening times
%
% dates       A numeric vector of dates in which the above measurements
%             were taken. See the Matlab built-in now.m for the format.
%

function [valves, times, dispenses, dates] = deal_table(wt)
   
   valves         = cell(size(wt)); 
   times          = cell(size(wt)); 
   dispenses      = cell(size(wt));   
   dates          = cell(size(wt)); 

   if isempty(wt), return; end;
   
   [valves{:}]    = deal(wt.valve); 
   
   [times{:}]     = deal(wt.time); 
   times          = cell2mat(times);
   
   [dispenses{:}] = deal(wt.dispense);
   dispenses      = cell2mat(dispenses);

   [dates{:}]     = deal(wt.date); 
   dates          = cell2mat(dates);

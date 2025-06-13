% [VALVE, TIME, DISPENSE, DATE, TECH] = deal_last_table_entry(wt)
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
% VALVE      The last valve name
%
% TIME       Valve opening time.
%
% DISPENSE   Dispense volume corresponding to the opening time
%
% DATE       The date in which the above measurement was taken. 
%
% TECH       The initials of the tech who performed the most recent calibration
%

function [VALVE, TIME, DISPENSE, DATE, TECH] = deal_last_table_entry(wt)
   
   VALVE = []; TIME = []; DISPENSE = []; DATE = []; TECH = '';

   valves         = cell(size(wt)); 
   times          = cell(size(wt)); 
   dispenses      = cell(size(wt));   
   dates          = cell(size(wt)); 
   techs          = cell(size(wt));

   if isempty(wt), return; end;
   
   [valves{:}]    = deal(wt.valve); 
   
   [times{:}]     = deal(wt.time); 
   times          = cell2mat(times);
   
   [dispenses{:}] = deal(wt.dispense);
   dispenses      = cell2mat(dispenses);

   [dates{:}]     = deal(wt.date); 
   dates          = cell2mat(dates);
   
   [techs{:}]      = deal(wt.initials);
   
   VALVE    = valves(end);
   TIME     = times(end);
   DISPENSE = dispenses(end);
   DATE     = dates(end);
   TECH     = techs{end};
   
   
   

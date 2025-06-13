% [cols] = GetDIOScheduledWaveInputColumns(sm)
%
% Given a FSM sm, returns the input columns (if any) of any scheduled
% waves that might be defined. These could, in principle, include
% scheduled waves whose alarms masquerade as nose cone events.
%
% All elements of cols will be unique.
%

function [cols] = GetDIOScheduledWaveInputColumns(sm)
   
   scheds = GetDIOScheduledWaves(sm);

   scheds       = GetDIOScheduledWaves(sm);
   schedids     = scheds(:,1);
   schedincols  = scheds(:,2);
   schedoutcols = scheds(:,3);
   
   cols = unique([schedincols ; schedoutcols]);
   cols = cols(cols>0);
   
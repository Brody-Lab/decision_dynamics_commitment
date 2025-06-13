% sched_matrix = GetDIOScheduledWaves(sm)  % Get Digital I/O line schedwaves
%
% This function returns the current scheduled waves matrix for Digital
% I/O lines registered with a state machine. Note that only if
% SetStateMatrix.m has been called will the registered scheduled waves
% be actually sent to the machine, so be careful and don't
% assume that the ScheduledWaves returned here are already running
% unless you know that SetStateMatrix has been called.
%
% PARAMETERS:
% -----------
%
%  sm      A SoftSMMarkII object
%
%
% RETURNS:
% --------
%
% sched_matrix    an M by 7 numeric matrix, where M is the number of
%                 registered DIO scheduled waves. For the format of
%                 this matrix, see SetScheduledWaves.m
%

function [sched_matrix] = GetDIOScheduledWaves(sm)

   sched_cell = sm.SchedWaves;
   
   sched_matrix = zeros(size(sched_cell,1), 7);
   for i=1:size(sched_cell,1)
      sched_matrix(i,1) = sched_cell{i}.id;
      sched_matrix(i,2) = sched_cell{i}.inEvtCol;
      sched_matrix(i,3) = sched_cell{i}.outEvtCol;
      sched_matrix(i,4) = sched_cell{i}.dioLine;
      sched_matrix(i,5) = sched_cell{i}.preamble;
      sched_matrix(i,6) = sched_cell{i}.sustain;
      sched_matrix(i,7) = sched_cell{i}.refraction;
   end;
   
   return;

% [t] = isUsingHappenings(sma)   Returns 1 if sma.use_happenings is 1, 0 otherwise.
%
% PARAMETERS:
% -----------
%
% sma     A @StateMachineAssembler object
%
%
% RETURNS:
% --------
%
% t       1 if sma.use_happenings is 1
%         0 otherwise.

% Written by J.S. 2017
% Help edited by C.K. 2019



function [t] = isUsingHappenings(sma)

   t = sma.use_happenings == 1;
   
   
% [t] = is_no_dead_time_technology(sma)   Returns 1 if sma has been defined
%                  with the 'no_dead_time_technology' flag on, 0 otherwise.
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
% t       1 if sma was created with the 'no_dead_time_technology' flag on,
%         0 otherwise.

% Written by C. Brody May 2007



function [t] = is_no_dead_time_technology(sma)

   t = (sma.pre35_curr_state ~= -1);
   
   
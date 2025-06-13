% [csma] = compressed(sma)    Compress a StateMachineAssembler
%
% Given a StateMachineAssembler object, this function returns a compressed
% version that is good for using with the disassembler, but that cannot be
% used with assemble.m or send.m. This is useful for saving space when
% storing many StateMachienAssembler objects (e.g., oe per trial).
%
%
% [For developers only: internally, this function keeps only the output
% columns and state names, discaring all the input_to_statchange info.
%

% Written by Carlos Brody April 2007


function [sma] = compressed(sma)

   outcols             = sort(cell2mat(sma.output_map(:,2)));
   sma.states          = sma.states(:,outcols);
   sma.iti_states      = sma.iti_states(:,outcols);
   sma.default_actions = [];
   
   
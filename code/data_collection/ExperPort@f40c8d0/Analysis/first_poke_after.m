% [pokeid, time] = first_poke_after(tlim, pstruct, {'pokelist', {}})
%
% Given a parsed_events structure (as produced by the @StateMachineAssembler 
% disassembler and made available in Dispatcher inb every trial), finds the
% first nose poke after or at time tlim. Returns pokeid (typically one of 'C',
% 'L', or 'R'), and the time at which the poke occurred.
%
% If no poke fits the conditions, pokeid and time return as empty matrices.
%
% pstruct can be either a structure that has a field called 'pokes'; or, if
% no field with that name exists, it is assumed that you have passed the
% contents of the 'pokes' field.
%


function [pokeid, time] = first_poke_after(tlim, pstruct, varargin)

   pairs = { ...
     'pokelist'  {}  ; ...
   }; parseargs(varargin, pairs);

   if isfield(pstruct, 'pokes'), pstruct = pstruct.pokes; end;

   if isempty(pokelist),
     all_pokeids = setdiff(fieldnames(pstruct), {'starting_state', 'ending_state'});
   else
     all_pokeids = pokelist;
   end;

   
   pokeid = []; time = [];
   for i=1:length(all_pokeids),
     u = find(pstruct.(all_pokeids{i})(:,1) >= tlim);
     if ~isempty(u),
       newtime = min(pstruct.(all_pokeids{i})(u,1));

       if isempty(pokeid),    pokeid = all_pokeids{i}; time = newtime;
       elseif newtime < time, pokeid = all_pokeids{i}; time = newtime;
       end;
     end;
   end;
% [pokeid, time] = last_poke_before(tlim, pstruct, {'pokelist', {}})
%
% Given a parsed_events structure (as produced by the @StateMachineAssembler 
% disassembler and made available in Dispatcher inb every trial), finds the
% last nose poke before or at time tlim. Returns pokeid (typically one of 'C',
% 'L', or 'R'), and the time at which the poke occurred.
%
% If no poke fits the conditions, pokeid and time return as empty matrices.
%


function [pokeid, time] = last_poke_before(tlim, pstruct, varargin)

   pairs = { ...
     'pokelist'  {}  ; ...
   }; parseargs(varargin, pairs);


   if isempty(pokelist),
     all_pokeids = setdiff(fieldnames(pstruct.pokes), {'starting_state', 'ending_state'});
   else
     all_pokeids = pokelist;
   end;

   
   pokeid = []; time = [];
   for i=1:length(all_pokeids),
     u = find(pstruct.pokes.(all_pokeids{i})(:,1) <= tlim);
     if ~isempty(u),
       newtime = max(pstruct.pokes.(all_pokeids{i})(u,1));

       if isempty(pokeid),    pokeid = all_pokeids{i}; time = newtime;
       elseif newtime > time, pokeid = all_pokeids{i}; time = newtime;
       end;
     end;
   end;
function [cpokestats] = compile_cpoke_stats(evs, RTS, cpokestats)


   % ---- If called with cells we are doing multiple trials; loop and recurse
   if iscell(evs),
      if ~iscell(RTS) | ~all(size(RTS)==size(evs)),
         error(['if one of evs and RTS is a cell, they must both be, and '...
                'of the same size.']);
      end;
      if isempty(evs), return; end;
      cpokestats = compile_cpoke_stats(evs{1}, RTS{1});      
      for i=2:length(evs),
         cpokestats = compile_cpoke_stats(evs{i}, RTS{i}, cpokestats);
      end;
      return;
   end;
   
   % ---- ok, doing single trial, go into main body

   % --- If not given to us already, compile list of known states
   fnames = fieldnames(RTS);
   if nargin<3,
      cpokestats = struct;
      for i=1:length(fnames), cpokestats.(fnames{i}) = 0; end;
   end;
   if isempty(evs), return; end;
   
   EventIds = struct( ...
     'cin',   1,  'cout',   2,  ...
     'lin',   3,  'lout',   4,  ...
     'rin',   5,  'rout',   6,  ...
     'tup',   7);

   % Find and focus on center in events:
   z = find(evs(:,2) == EventIds.cin);
   if ~isempty(z),
      for i=1:length(fnames),
         nu = length(find(ismembc(evs(z,1), RTS.(fnames{i}))));
         cpokestats.(fnames{i}) = cpokestats.(fnames{i}) + nu;
      end;
   end;
   
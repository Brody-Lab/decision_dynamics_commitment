% [wt] = youngest_entry(wt)
%
% Prune all but the youngest entry from the water table.
%

function [wt] = youngest_entry(wt)

   if isempty(wt), return; end;
   
   dates          = cell(size(wt)); 
   [dates{:}]     = deal(wt.date); 
   dates          = cell2mat(dates);

   [sorted, I] = sort(dates);
   
   wt = wt(I(end));
   
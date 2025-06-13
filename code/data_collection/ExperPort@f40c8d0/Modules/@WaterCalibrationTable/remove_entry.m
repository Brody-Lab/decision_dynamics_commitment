% [wt] = remove_entry(wt, n)
%
% Given a wt object, removes the n'th entry and returns the resulting
% wt object. Which one is the n'th entry? Do a display(wt); first entry
% is the top one, second is the next, and so on all the way down.
%

function [wt] = remove_entry(wt, n)
   
   if length(wt)==0 | n<1 | n>length(wt),
      error('Can''t remove nonexistent entry');
   end;
   
   wt = wt([1:n-1 n+1:end]);
   
   
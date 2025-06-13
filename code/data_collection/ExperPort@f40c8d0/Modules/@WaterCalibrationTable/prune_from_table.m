% [wt] = prune_from_table(wt, {'days', Inf})
%
% Prunes entries from a water table, returning the water table
% resulting after the pruning.
%
% PARAMETERS:
% -----------
%
% wt       The water calibration table object to be pruned
%
%
% OPTIONAL PARAMETERS:
% --------------------
%
% 'days'   Entries must be this many days or younger in order not to be
%          pruned from the table. Default is Inf (no one gets pruned).
%
%
% RETURNS:
% --------
%
% wt       Pruned table
%
%
% EXAMPLE CALLS:
% -------------_
%
%      >> pruned = prune_from_table(wt, 'days', 5);
%


function [wt] = prune_from_table(wt, varargin)

   pairs = { ...
     'days'      Inf   ; ...
   }; parseargs(varargin, pairs);
   
   dates          = cell(size(wt)); 
   [dates{:}]     = deal(wt.date); 
   dates          = cell2mat(dates);
   
   wt = wt(find(now - dates <= days));

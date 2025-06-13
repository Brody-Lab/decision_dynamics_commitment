% [labels] = get_labels(sma)
% 
% Returns an n-by-2 cell. The first column of the cell will be strings,
% representing state names. The second column will be a number, indicating
% the state number that each of these strings corresponds to.

% Written by Carlos Brody October 2006

function [labels] = get_labels(sma)
   
   labels = sma.state_name_list;
   
   % Find which labels correspond to iti states
   u = find(cell2mat(labels(:,3)));
   
  % If there are any iti states, these all come at the end of the
  % normal states; their effective state number thus needs to be
  % adjusted:
   if ~isempty(u),
     labels(u,2) = num2cell(cell2mat(labels(u,2))+rows(sma.states));
   end;
   
   labels = labels(:,1:2);
   
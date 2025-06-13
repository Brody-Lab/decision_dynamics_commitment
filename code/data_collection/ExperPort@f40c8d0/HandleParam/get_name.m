% [names] = get_name(c)   Assuming c is a cell vector of SPHs, return
%                         an equal-sized cell with result of get_name on each

function [names] = get_name(c)
   
   names = cell(size(c));
   for i=1:length(c(:)),
      names{i} = get_name(c{i});
   end;
   
function [v] = getvals(R, name)

   u = find(strcmp(R(1,:), name));
   if isempty(u), error(['Couldn''t find the ' name ' column.']); end;
   
   v = zeros(size(R,1)-1, 1);
   for i=2:size(R,1), v(i-1) = R{i,u}; end;
   
   
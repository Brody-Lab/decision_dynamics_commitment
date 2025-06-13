function [val] = getvalue(R, trial, name)

   u = find(strcmp(R(1,:), name));
   if isempty(u), error(['Couldn''t find the ' name ' column.']); end;
   
   if trial > size(R,1)-1  |  trial<1, error('trial must be > 0 and less than rows(R)'); end;
   
   val = R{trial+1,u};
   
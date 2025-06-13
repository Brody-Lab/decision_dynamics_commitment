function [name] = get_state_name(num, rts)
% get_state_name
%   When given a struct mapping RealTimeState names to numbers and a
%   number, resolves an array of state "num"bers into a name.
%   Returns a Mx1 cell array, where position i is the state name 
%   for num(i).


name = cell(size(num,1),1);
f = fieldnames(rts);

for ctr = 1:size(f,1)
    q = eval(['rts.' f{ctr}]);
    inds = ismember(num, q); inds = find(inds > 0);    
    if length(inds) > 0
        name(inds) = cellstr(repmat(f{ctr},length(inds),1));
    end;
end;
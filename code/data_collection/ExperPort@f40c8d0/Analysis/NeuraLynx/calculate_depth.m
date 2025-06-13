function calculate_depth(rats)
% function that calculates cumulative depth from turn_down_log and adds it
% to the appropriate field in the same log. If no argument is given, it
% makes the calculation for all rats on the turn_down_log. Calculates based
% on the "turn" entry in the turn_down_log rather than the "turned_to"
% entry.

% Input %
% rats: a cell array of strings specifying rat names or a string for a
%       single rat

all_rats = bdata('select distinct ratname from ratinfo.turn_down_log');

if isempty(rats)
    rats=all_rats;
end

% make a string into a cell array so that code below does not need
% modification
if ischar(rats)
    rats = {rats};
end



for rx=1:numel(rats)
    
    rat=rats{rx};
    
    % check that this rat is on the turn_down_log
    if ~ismember(rats{rx}, all_rats)
        fprintf(2,'Rat %s is not on the turn_down_log\n', rat);
        continue;
    end
    
    [id, turn_date, turn_time, turn]=bdata('select id, turn_date, turn_time, turn from ratinfo.turn_down_log where ratname="{S}" order by turn_date, turn_time',rat);
    depth=cumsum(turn);
    
    for tx=1:numel(id)
        mym(bdata,'update ratinfo.turn_down_log set depth="{S}" where id="{S}"',depth(tx)*0.3175, id(tx))
    end
end
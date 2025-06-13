function [clr] = group_colour(gname)

switch gname
    case 'duration'
        clr = [1 0.5 0];
    case 'frequency'
        clr = [0 0.3 1];
    case 'durlite'
        clr=[1 0.8 0];
    case 'freqlite'
        clr= [0.5 0.7 1];
    otherwise
        error('option can either be duration or frequency');
end;
function [recorded, accounted] = unaccounted_chord(p, se)

recorded = cell(rows(p),1);
accounted = cell(rows(p),1);
diff = zeros(rows(p),1);

for k = 1:rows(p)
    if rows(p{k}.chord) ~= rows(se{k}.cue)
        error('p and se have unequal rows for trial %i', k);
    end;
    recorded{k} = p{k}.chord(:,2) - p{k}.chord(:,1);
    accounted{k} = (se{k}.cue(:,2)-se{k}.cue(:,1)) + ...
            (se{k}.pre_go(:,2) - se{k}.pre_go(:,1)) + ...
            (se{k}.go(:,2) - se{k}.go(:,1));
        
    dummy = cell2mat(recorded{k}) - cell2matk
        
end;
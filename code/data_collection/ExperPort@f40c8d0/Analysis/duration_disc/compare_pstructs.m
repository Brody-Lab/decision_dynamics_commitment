function [] = compare_pstructs(ratname, date);

pold = get_pstruct(ratname,date);
pnew = get_pstruct(ratname,date, 'pstruct_format','new');

% compare number of rows in each state

if length(pold) ~= length(pnew),
    error('Mismatched number of trials');
end;

pokestates = {'center1','center1_states','left1','left1_states','right1','right1_states'};
for k = 1:rows(pold)
    fold = fieldnames(pold{k});
    for f = 1:length(fold)
        if sum(ismember(fold{f}, pokestates)) == 0
            oldval = pold{k}.(fold{f});
            newval = pnew{k}.states.(fold{f});
            try
                if newval ~= oldval
                    error(sprintf('Trial %i, field %s: Mismatch', k, fold{f}));
                end;
            catch
                error('Mismatched dimensions');
            end;
        end;
    end;
end;
function [] = time_per_state(ratname,date)

p = get_pstruct(ratname,date);

times = {}; % key: statename, value: array of start and end times

for k = 1:rows(p)
    f = fieldnames(p);
    for m = 1:length(f)
        idx = find(strcmpi(times(:,1), f(m)));
        tmp = times{idx,2};
        vertcat(tmp, p{f(m)});
        times{idx,2} = tmp;
    end;
end;
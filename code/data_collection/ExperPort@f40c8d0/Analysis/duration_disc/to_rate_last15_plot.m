function [] = to_rate_last15_plot(ratname, indate)

get_fields(ratname, 'use_dateset', 'given', 'given_dateset', {indate}, ...
    'datafields', {'pstruct'});

% buffer timeout_count
timeout_count = NaN(size(pstruct));
for k = 1:rows(pstruct)
    timeout_count(k) = rows(pstruct{k}.timeout);
end;

to_rate_Last10 = NaN(size(pstruct));
to_rate_Last15 = NaN(size(pstruct));
to_rate_Last25 = NaN(size(pstruct));

for n = 1:rows(pstruct)
    % calculate timeout rate
    for del = [25 10 15],
        mn = max([1 n-del]);
        mystr=['to_rate_Last' num2str(del) '(n) = mean(timeout_count(mn:n));']; 
        eval(mystr);
    end;
end;

figure;
plot(to_rate_Last15,'.k');
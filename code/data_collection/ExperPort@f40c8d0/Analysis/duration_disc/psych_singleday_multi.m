function [] = psych_singleday_multi(ratname, from, to)

f = get_files(ratname, 'fromdate', from,'todate', to);

for idx = 1:length(f)
    psychometric_curve(ratname, f{idx},'nodist',1);
end;


function [count_list, salvage] = count_punishment_wholesale()

ratname = 'chanakya';
task = 'dual_discobj';

dates = available_dates(ratname,task);
if strcmpi(ratname, 'cuauhtemoc') || strcmpi(ratname, 'moctezuma')
    i = find(strcmp(dates, '051018a')); % Date when BadBoySPL and WN_SPL had been implemented + 1
    dates = dates(i:end);
    
end;

count_list = cell(0,4);
count_list{1,1} = 'Date';
count_list{1,2} = 'Changes';
count_list{1,3} = 'EVS rows';
count_list{1,4} = 'RTS rows';

for today = 1:size(dates,1)
    d = dates{today};
    date = d(:,1:end-1); f_ver = d(:,end);
    [count, evs, rts] = ...
          count_punishment_changes(ratname, task, date, f_ver);
    count_list{today, 1} = d;
    count_list{today, 2} = count;    
    count_list{today, 3} = evs;
    count_list{today, 4} = rts;
end;

temp = count_list;

% Difference in history rows using data file
d = cell2mat(temp(:,3:4)); 
d(:,3) = d(:,2)-d(:,1); 
for j = 1:rows(d), temp{j,5} = d(j,3);end;

% Difference between bb/wn-counting and datafile
for j=1:rows(d), temp{j,6} = temp{j,5} - temp{j,2}; end;

f = temp(:,[1 6]);
g = cell2mat(temp(:,6)); h = abs(g);

salvage = find(h < 2);  % Off-by-one errors are fine since RTS usually has one row more than EVS
salvage = temp(salvage,1);
sprintf('Salvageable: %s of %s', num2str(length(find(h<2))), num2str(length(g)))
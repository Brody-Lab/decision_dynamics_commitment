

ratname = 'Chanakya';
task = 'dual_discobj';
dates = { '051214', 'a' ; ...
%    '051207' , 'b' ;  ...
%    '051207' , 'c' ; ...
    };


figure;
numplots = size(dates,1);

for i = 1:size(dates,1)
    load_datafile(ratname, task, dates{i,1}, dates{i,2});
    subplot(numplots,1,i);
    separate_pd_dd_trials(saved, saved_history, task, [ratname ':' dates{i,1} '(' dates{i,2} ')']); 
end;
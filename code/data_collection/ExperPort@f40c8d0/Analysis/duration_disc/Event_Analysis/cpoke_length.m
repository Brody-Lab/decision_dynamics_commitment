function [] = cpoke_length(ratname,doffset,varargin)

pairs = { ...
    'timeout_trials', 0 ; ... % when set to 1, examines only those occurrences that precede a timeout
    };


date = getdate(doffset);
p = get_pstruct(ratname,date);

times = state_times(ratname, doffset, doffset);

r = rat_task_table(ratname);
task = r{1,2};

plot_states =  {'center1'} ;%;,'left1','right1'};

% average duration of each state
durations = [];
total_time = [];
for k = 1:length(plot_states)
    if isfield(times,plot_states{k})
        
        eval(['tmp = times.' plot_states{k} ';']);
        figure;dur =tmp(:,2)-tmp(:,1);
        
        subplot(1,2,1);        
        plot(1:length(dur),dur*1000,'.b');        
        ylabel('milliseconds');
        xlabel('occurrence #');
        title(plot_states{k});
        
        subplot(1,2,2);
        hist(dur*1000);
        xlabel('milliseconds'); title('Histogram view');
        tmp1 = mean(tmp(:,2)-tmp(:,1));
        eval(['durations.' plot_states{k} ' = tmp1;']);

        tmp2 = sum(tmp(:,2)-tmp(:,1));
        eval(['total_time.' plot_states{k} ' = tmp2;']);
    end;
end;

durations = orderfields(durations);
total_time = orderfields(total_time);
titles = fieldnames(durations);
n = cell2mat(struct2cell(durations));
n_total = cell2mat(struct2cell(total_time)) / (60 * 60); % total times shown in hours


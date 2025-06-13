function [] = pid_plot_save(obj)

GetSoloFunctionArgs;

% to find the most recently saved data file...
% owner = determine_owner;  ??? owner = data_parse_and_call_sph_callback???
%Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
rat_dir = [pwd filesep '..' filesep 'SoloData' filesep 'Data' filesep ratname];
u = dir([rat_dir filesep 'data_@odor_testobj_' ratname '_' yearmonthday '*.mat']);
[filename{1:length(u)}] = deal(u.name);
filename = sort(filename');
% now load the most recently saved data file
load([rat_dir filesep filename{end}]);
pid_traces = [];
scan_freq = 6000; % scan frequency of FSM daq.
for i = 2: saved.odor_testobj_Trial_Counts
    events = saved_history.odor_testobj_LastTrialEvents{i,1};
    % find the time of the state that turns the odor valve on
    T1 = events(find(events(:,1)==41 & events(:,2)==0), 3);
    T2 = events(find(events(:,1)== 42 & events(:,2)==7),3);
    % now events(T1, 3) is the time we want, we will align the PID data
    % with this time point.
    % Note: scanned_data contain data scanned from all the channels of FSN AI.
    scanned_data = saved.FSM_DAQ_ai_scans{i,1};
    % set T1 as time 0.
    scanned_data = floor(scanned_data*1e4)/1e4;
    T1 = floor(T1*1e4)/1e4;
    T2 = floor(T2*1e4)/1e4;
    scanned_data(:,1)= scanned_data(:,1) - T1;
    % truncate the scanned_data from -50 ms to end
    offset = find(scanned_data(:,1)==0);
    scanned_data = scanned_data(offset-0.05*scan_freq: offset+(T2-T1+1)*scan_freq,:);
    % now we have the same time offset of scanned data for all the trials,
    % we can sum them and get the average
    pid_traces = [pid_traces scanned_data(:, value(pid_daq_channel))];
end

% put the first column of pid_traes as time index
pid_time_index = scanned_data(:,1);
pid_avg = mean(pid_traces,2);
pid_std = std(pid_traces,0, 2);
figure; hold on;
y_lim = max(pid_avg+pid_std)+ 10;
x1 = 0; x2 = T2-T1;
fill([x1 x1 x2 x2], [0 y_lim y_lim 0], [0.7 0.7 0.8],'LineStyle','none');
save([rat_dir filesep yearmonthday '_pid.mat'], 'pid_avg', 'pid_std','pid_time_index');
errorshade(pid_time_index', pid_avg', pid_std');
    
    
    
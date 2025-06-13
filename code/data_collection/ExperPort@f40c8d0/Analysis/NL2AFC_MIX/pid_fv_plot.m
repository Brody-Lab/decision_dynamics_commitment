function [] = pid_fv_plot(action, sessionname, varargin)
% action: 'single', for plotting pid trace of individual trials.
%                   after each plot, program will wait for a key. 
%                   Anykey except p and s will leads to plot of next trial.
%                   press p will lead to plot the previous trial. 
%                   press s will stop the program, and return.

% action: 'average', for plotting the averaged pid data from the 20 trials
%                   with same final valve delay. The color shades indicate
%                   the time of final valve delay and odor delivery time.
%                   Figures and variables will be saved.

% sessionname: date + session_ID.

% varargin: to plot the average pid data with final valve delays within a
%           particular time range. You should always input 2 time values 
%           indicating the time range. For example, if you input 0.1, 0.4,
%           the averaged data with delays between 0.1s and 0.4s will be
%           plotted, and saved.
    
ratname = 'PIDdaq';
taskname = 'odor_testobj';
%session = 'a';
rat_dir = [pwd filesep '..' filesep 'SoloData' filesep 'Data' filesep ratname];
filename = [rat_dir filesep 'data_@' taskname '_' ratname '_' sessionname '.mat'];
load(filename);
Trials = saved.odor_testobj_Trial_Counts;
bad_trace = [1];
repeats = 5;
counts = 0;
scan_freq = 6000;
rt_define = [10 80];
switch action
    case 'single'
        i = 2;
        while i <= Trials
            if ismember(i, bad_trace)
                i = i+1;
                continue
            end
            events = saved_history.odor_testobj_LastTrialEvents{i,1};
            % find the time of the state that turns the odor valve on
            t1 = events(find(events(:,1)==41 & events(:,2)==0), 3);
            t2 = events(find(events(:,1)== 42 & events(:,2)==0),3);
            t3 = events(find(events(:,1)== 42 & events(:,2)==7),3);
            temp = saved.FSM_DAQ_ai_scans{i};
            temp = floor(temp*1e4)/1e4;
            t1 = floor(t1*1e4)/1e4;
            t2 = floor(t2*1e4)/1e4;
            t3 = floor(t3*1e4)/1e4;
            temp(:,1)= temp(:,1) - t2;
            offset = find(temp(:,1)==0);
            if isempty(offset)
                offset = find(abs(temp(:,1))< 1e-4);
            end
            temp = temp(offset(1)-(t2-t1+0.03)*scan_freq: offset(1)+(t3-t2+1)*scan_freq,:);
            x1 = t1-t2; x2 = 0; x3 = t3-t2;
            y1 = min(temp(:,2)); y2 = max(temp(:,2));
            close all;
            figure; hold on;
            title(['final valve delay: ' num2str(saved_history.OdorSection_final_valve_delay{i})],...
                'FontSize', 15);
            fill([x1 x1 x2 x2], [y1 y2 y2 y1], [0.9 0.2 0.2],'LineStyle','none');
            fill([x2 x2 x3 x3], [y1 y2 y2 y1], [.5 .9 .6],'LineStyle','none');
            plot(temp(:,1), temp(:,2));
            xlim([temp(1,1)-0.01 temp(end,1)]); ylim([y1-0.01 y2+0.01]);
            xlabel('Time (s)','FontSize', 13); ylabel('PID Voltage (volts)', 'FontSize', 13);
            gonext = input('Anykey: next trace, p: previous trace, s: stop ','s');
            if strcmpi(gonext, 'p')
                i = i - 1;
            elseif strcmpi(gonext, 's')
                return;
            else
                i = i+1;
            end
            disp('Trial #:'); disp(i);
        end
    case 'average'
    zero_point = [];%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5555    
        final_valve_delay = cell2mat(saved_history.OdorSection_final_valve_delay);
        final_valve_delay = floor(final_valve_delay*100)/100;
        if size(varargin,2) == 2
            lo = varargin{1};
            hi = varargin{2};
            a = find(abs(final_valve_delay-lo)< 0.015);
            b = find(abs(final_valve_delay-hi)< 0.015);
            rng1 = a(1); rng2 = b(1)+19;
        else
            rng1 = 2; rng2 = Trials;
        end
        traces = [];
        fv_delay = [];
        trace_avg = {}; trace_std = {};
        rise_time = [];
        for i = rng1:rng2
            counts = counts+1;
            if i > size(saved_history.odor_testobj_LastTrialEvents,1),
                break;
            elseif ismember(i,bad_trace) % exclude the bad traces
                continue;
            end;
            events = saved_history.odor_testobj_LastTrialEvents{i,1};
            % find the time of the state that turns the odor valve on
            t1 = events((events(:,1)==41 & events(:,2)==0), 3); % time olfmeter valve on
            t2 = events((events(:,1)== 42 & events(:,2)==0),3); % time of final valve on
            t3 = events((events(:,1)== 42 & events(:,2)==7),3); % time final valve off
            temp = saved.FSM_DAQ_ai_scans{i}; % temporarily store the scaned data of the current trial in 'temp'
            temp = floor(temp*1e4)/1e4;
            t1 = floor(t1*1e4)/1e4;
            t2 = floor(t2*1e4)/1e4;
            t3 = floor(t3*1e4)/1e4;
            temp(:,1)= temp(:,1) - t2; % offsetting the time stamp in the scaned data
            offset = find(temp(:,1)==0);
            if isempty(offset)
                offset = find(abs(temp(:,1))< 1e-4);
            end; 
            % truncate extra data of the beginning and the end of each trial
            temp = temp(offset(1)-round((t2-t1+0.01)*scan_freq): round(offset(1)+(t3-t2+1)*scan_freq),:);
           
            if size(traces,1)> size(temp,1)
                d = size(traces,1) - size(temp,1);
                temp = [temp; temp(end-d+1:end,:)];
                
            elseif ~isempty(traces) && size(traces,1)< size(temp,1)
                d =  size(temp,1) - size(traces,1);
                traces = [traces; traces(end-d+1:end,:)];
            end
            time_idx = temp(:,1);
            traces = [traces temp(:,2)];
            if counts==repeats
                % the delay was changed every repeats trials
                % now get the average trace over the last repeats trials.
                temp_mean = mean(traces,2);
                zero_pt = find(time_idx==0);
                if temp_mean(zero_pt)> temp_mean(zero_pt-600)+ 1e-3 % calibrate offset point by the voltage amplitude
                % disp(temp(offset,2)); disp(temp(offset-600,2));
                    x = find(temp_mean(1:zero_pt) <= temp_mean(zero_pt-600)+1e-3);
                    zero_pt = x(end); time_idx = time_idx - time_idx(zero_pt);
                end
                temp_std = std(traces,0, 2);
                fv_delay = [fv_delay  final_valve_delay(i)]; % store every delay time into a variable.
                trace_avg = [trace_avg [time_idx temp_mean]]; % store the averaged traces with time index  into a cell array. 
                trace_std = [trace_std temp_std]; % store the stdv into a cell array.
                x1 = t1-t2; x2 = 0; x3 = t3-t2;
                y1 = min(temp_mean); y2 = max(temp_mean)+0.05;
                figure; hold on; 
                title(['final valve delay: ' num2str(final_valve_delay(i))],...
                    'FontSize', 15);
                % shade the time of the fv delay
                fill([x1 x1 x2 x2], [y1 y2 y2 y1], [0.9 0.2 0.2],'LineStyle','none'); 
                % shade the time after fv open to the close of both fv and odor valve
                fill([x2 x2 x3 x3], [y1 y2 y2 y1], [.5 .9 .6],'LineStyle','none');
                % plot the mean trace with errorshade of the stdv.
                errorshade(time_idx', temp_mean', temp_std');
                xlim([temp(1,1)-0.01 temp(end,1)]); ylim([y1-0.01 y2+0.01]);
                xlabel('Time (s)','FontSize', 13); ylabel('PID Voltage (volts)', 'FontSize', 13);
                hold off;
                saveas(gcf, [filename(1:end-4) '_' num2str(final_valve_delay(i)) '.fig']);
                saveas(gcf, [filename(1:end-4) '_' num2str(final_valve_delay(i)) '.jpg']);
                traces = []; counts = 0; 
                
                % next find the rising time of each average trace
                bsl = mean(temp_mean(1:offset-10));
                temp_mean = temp_mean - bsl;
                rise_a = find(temp_mean >= max(temp_mean)* rt_define(1)/100);
                rise_b = find(temp_mean >= max(temp_mean)* rt_define(2)/100);
                rt = time_idx(rise_b(1)) - time_idx(rise_a(1));
                rise_time = [rise_time rt];
            end
        end
        figure; hold on;
        plot(fv_delay, rise_time, '-o','MarkerSize', 13);
        xlabel('FV delays (s)', 'FontSize', 13); 
        ylabel(['Rise time ' num2str(rt_define(1)) '-' num2str(rt_define(2)) '% (s)'],'FontSize',13);
        save([filename(1:end-4) '_avg'], 'time_idx', 'trace_avg', 'trace_std','rise_time','fv_delay');
end

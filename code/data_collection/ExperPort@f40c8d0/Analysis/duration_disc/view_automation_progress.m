function [last_change] = view_automation_progress(ratname, date)

% % Calculate date
% n = now;
% n = n + doffset;
% 
% v = datevec(n);
% yy=int2str(v(1)); yy = yy(3:4);
% mm = int2str(v(2)); if v(2) < 10, mm = ['0' mm];end; 
% dd = int2str(v(3)); if v(3) < 10, dd = ['0' dd]; end;
% date = [yy mm dd 'a'];
% fprintf(1, 'File date is: %s\n', date);


ratrow = rat_task_table({ratname});
load_datafile(ratname, date);

last_change = saved.SessionDefinition_last_change_tracker;
last_change = last_change(1:150);

task = ratrow{1,2};
if strcmpi(task(1:3),'dur')
    psych = cell2mat(saved_history.ChordSection_psych_on);
else
psych = cell2mat(saved_history.ChordSection_pitch_psych);
end;
psych2 = ones(size(psych)); psych2(find(psych < 1)) = 10; psych2(find(psych>0)) = 20;
 
figure;
plot(1:length(last_change), last_change, '.b',1:length(psych),psych2,'-r'); 
xlabel('Trial #'); ylabel('Value of lastchange');
title(sprintf('%s (%s): Value of lastchange', ratname, date));

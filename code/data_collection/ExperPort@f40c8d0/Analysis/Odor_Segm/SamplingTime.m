function [SampTime] = SamplingTime(real_time_event) 
% Calculate the sampling time of a particular trial.
% real_time_event, one of saved_history.'taskname'_LastTrialEvents

center_out = 0;
center_out_states = find(real_time_event(:,1)>40 & real_time_event(:,2)==2); % States contain center out action
% Next find the state of effective center_out
for i = center_out_states,
    if real_time_event(i,1)< real_time_event(i+1,1)
        center_out = i;
    end;
end;
if center_out == 0
    SampTime = 0;
else
    SampTime = real_time_event(center_out, 3)- real_time_event(center_out - 3, 3); %Stimulus started at the start of last state
end;

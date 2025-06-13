function  d = frame_diff(T)

global trial_times
global output
global peh
global frame_num
global t

    
current_trial = find(T - trial_times(:,1) >= 0 & T - trial_times(:,2) < 0);
if isempty(current_trial) && T > max(trial_times(:))
    d = nan;
    return
end

if ~isnan(t(current_trial))
    flash = output.eventpairs(t(current_trial),2) * output.framerate;
    offset = (T - mean(peh(current_trial).states.sync_flash)) * output.framerate;

    F = flash + offset;
else
    F = nan;
end

d = abs(F - frame_num);
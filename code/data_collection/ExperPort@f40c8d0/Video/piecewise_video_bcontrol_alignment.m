function F = piecewise_video_bcontrol_alignment(T,output,sessid)

%T is the Bcontrol time you want to find a video frame for. if T is empty
%function assumes you want a Bcontrol time for every frame
%
%output is the variable generated from sync_video_to_trials4.m
%
%sessid is the session id from the sessions MySQL table

if ~isempty(T)
    peh = bdata(['select peh from parsed_events where sessid=',num2str(sessid)]);
    peh = peh{1};

    for i = 1:numel(peh) 
        sync_flash(i,:) = peh(i).states.sync_flash;
    end

    m_sync_flash = mean(sync_flash,2) + output.timeshift;
    for i = 1:numel(m_sync_flash)

        d = abs(m_sync_flash(i) - output.eventpairs(:,2));
        d(d > 2) = Inf;
        temp = find(d == min(d));
        if numel(temp) == 1; t(i) = temp;
        else                 t(i) = nan;
        end
    end

    for i = 1:numel(peh)
        trial_times(i,:) = [peh(i).states.state_0(1,2),peh(i).states.state_0(2,1)];
    end

    for i = 1:numel(T)

        current_trial = find(T(i) - trial_times(:,1) > 0 & T(i) - trial_times(:,2) < 0);

        if ~isnan(t(current_trial))
            flash = output.eventpairs(t(current_trial),2) * output.framerate;
            offset = (T(i) - mean(peh(current_trial).states.sync_flash)) * output.framerate;

            F(i) = round(flash + offset);
        else
            F(i) = nan;
        end
    end
    
else
        
    if ~isfield(output,'eventpairs')
        disp('Variable "output" does not contain the field "eventpairs". Frame times cannot be determined.');
        F = nan;
        return
    end
    
    FrameTimes = zeros(1,numel(output.RED_flash));
    
    flash_frames =  output.eventpairs(:,2) * output.framerate;
    flash_times  = (output.eventpairs(:,1) - output.timeshift) / output.timescale;
    
    frame_dur = 1 / output.framerate;
    for i = 1:numel(flash_frames)
        prevf = (1 - (flash_frames(i) - floor(flash_frames(i)))) * frame_dur;
        nextf = (1 - (ceil(flash_frames(i)) - flash_frames(i)))  * frame_dur;
    
        FrameTimes(floor(flash_frames(i))) = flash_times(i) - prevf;
        FrameTimes(ceil( flash_frames(i))) = flash_times(i) + nextf;
        
        if i == 1
            firstflash = floor(flash_frames(i));
            gap_dur = firstflash - 1;
            insert = (FrameTimes(firstflash) - (frame_dur * gap_dur)):frame_dur:FrameTimes(firstflash) - frame_dur;
            FrameTimes(1:gap_dur) = insert;
            
        else 
            gap_start = find(FrameTimes == 0,1,'first');
            gap_stop  = floor(flash_frames(i));
            gap_dur   = gap_stop - gap_start;
            time_dur  = FrameTimes(gap_stop) - FrameTimes(gap_start-1);
            insert = FrameTimes(gap_start-1):time_dur/(gap_dur + 1):FrameTimes(gap_stop);
            FrameTimes(gap_start-1:gap_stop) = insert;
            
            if i == numel(flash_frames)
                gap_start = find(FrameTimes == 0,1,'first');
                gap_stop  = numel(output.RED_flash);
                gap_dur   = (gap_stop - gap_start) + 1;
                insert = FrameTimes(gap_start-1):frame_dur:FrameTimes(gap_start-1) + (frame_dur * gap_dur);
                FrameTimes(gap_start-1:end) = insert;
            end
        end
            
    end
    F = FrameTimes;
    
end




% options = optimoptions('fmincon','Display','off');
% 
% global trial_times
% global output
% global peh
% global frame_num
% global t
% 
% frame_num = floor(output.eventpairs(t(1),2) * output.framerate);
% T = trial_times(1,1);
% 
% [best_t,score] = fmincon(@frame_diff,T,[],[],[],[],0,1e6,[],options);
% FrameTimes(frame_num) = best_t;
% 
% frame_time = 1 / output.framerate;
% 
% for i = 1:max([numel(output.RED_flash),numel(output.RED_flash_insframes)])
% 
%     if ~isnan(best_t)
%         T = best_t + frame_time;
%     else
%         T = max(FrameTimes);
%     end
%     frame_num = frame_num + 1;
% 
%     if rem(frame_num,100) == 0
%         disp(['Computing time for frame ',num2str(frame_num),'...']);
%     end
%     score = frame_diff(T);
%     if isnan(score) 
%         T = T + 1; 
%         score = 10; 
%     end
% 
%     if score < 1e-3
%         best_t = T;
%         FrameTimes(frame_num) = best_t;
%     else
%         disp(['Searching for frame ',num2str(frame_num),'...']);
%         try
%             [best_t,score] = fmincon(@frame_diff,T,[],[],[],[],0,1e6,[],options);
%         catch
%             best_t = nan;
%         end
%         FrameTimes(frame_num) = best_t;
%     end
% end
% F = FrameTimes;


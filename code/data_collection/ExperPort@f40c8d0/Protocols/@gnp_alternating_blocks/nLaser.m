function [laservec] = nLaser(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation goes here
GetSoloFunctionArgs;
switch action,
    case 'init',
        SoundManagerSection(obj, 'init');
        SoundManagerSection(obj, 'declare_new_sound', 'laser');
%         SoundManagerSection(obj, 'declare_new_sound', 'sound');
        nLaser(obj, 'build');
    case 'onTime',
        local_fractionOn = onTime*freq;
        if local_fractionOn>=1,
            warndlg('CONTIUOUS PULSE');
        end
        fractionOn.value = local_fractionOn;
    case 'fractionOn',
        local_onTime = fractionOn/freq;
        onTime.value = local_onTime;
    case 'freq',
        nLaser(obj, 'onTime'); %or nLaser(obj, 'fractionOn');
        
    case 'build',
        %build the vector!
        if value(fractionOn) >= 1,
            warndlg('CONTIUOUS PULSE');
        end
                
        snd = zeros(2,round(samp_rate*len));%the 2 is to direct the LASER Pulse
%         only on the right speaker, left speaker is actual sound!

        on_length=round(samp_rate/freq*fractionOn);
        for i=1:int32(round(len*freq))
            start_idx=(samp_rate/freq*(i-1))+1;
            end_idx=start_idx+on_length-1;
            if end_idx>round(samp_rate*len),
                end_idx=round(samp_rate*len);
            end;
            snd(2,start_idx:end_idx)=amp;
        end;
        laservec.value = snd;
%         figure;plot(snd)
%         axis([0 len*samp_rate -0.5 1.5])
    
    %Send it to the Sound Manager Section!!
    
    SoloParamHandle(obj, 'laserID', 'value', 0);
    laserID.value = SoundManagerSection(obj, 'get_sound_id', 'laser');
    SoundManagerSection(obj, 'set_sound', 'laser', value(laservec), 1);% 'loop_fg=1'
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
%     SoundManagerSection(obj, 'play_sound', 'laser', 1)
    DeclareGlobals(obj, 'rw_args', {'laserID'});
    warndlg(sprintf('LASER PULSE READY!!'));
    
    
%     case '22KHz',
%         
%         amp=1;
%         
%         time = value(soundTime);
%         sfreq = value(soundFreq);
%         
%         if sfreq>150,
%             amp=1;
%         elseif sfreq<=150,
%             amp=4;
%         elseif sfreq < 50,
%             amp=8;
%         elseif sfreq < 20,
%             amp=20;
%         end
%         
%         
%         t=[0:1/200000:time];
%         t=t(1:end-1);
%         snd = zeros(2,round(200000*time));
%         
%         snd(1,:) = (amp*(sin(2*pi*sfreq*t)));
%         
%     SoloParamHandle(obj, 'soundID', 'value', 0);
%     soundID.value = SoundManagerSection(obj, 'get_sound_id', 'sound');
%     SoundManagerSection(obj, 'set_sound', 'sound', snd);
%     SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
%     SoundManagerSection(obj, 'play_sound', 'sound', 1)
% %     figure; plot(snd);
    
    case 'free_laser',
        if value(freeLaser)==1,
            SoundManagerSection(obj, 'play_sound', 'laser', 1)
        end
        if value(freeLaser)==0,
            SoundManagerSection(obj, 'stop_sound', 'laser', 1)
        end

    case 'update', 
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
end;
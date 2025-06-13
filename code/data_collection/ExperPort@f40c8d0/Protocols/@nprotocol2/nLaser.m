function [laservec] = nLaser(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation goes here
GetSoloFunctionArgs;
switch action,
    case 'init',
        SoundManagerSection(obj, 'declare_new_sound', 'laser');
        SoloParamHandle(obj, 'laserID', 'value', 0);
        laserID.value = SoundManagerSection(obj, 'get_sound_id', 'laser');
        DeclareGlobals(obj, 'rw_args', {'laserID'});
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
       
    SoundManagerSection(obj, 'set_sound', 'laser', value(laservec), 1);% 'loop_fg=1'
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
%     SoundManagerSection(obj, 'play_sound', 'laser', 1)
    
    warndlg(sprintf('All vectors built now press \n\n              submit'));
        
    case 'free_laser',
        if value(freeLaser)==1,
            SoundManagerSection(obj, 'play_sound', 'laser', 1)
        end
        if value(freeLaser)==0,
            SoundManagerSection(obj, 'stop_sound', 'laser', 1)
        end

    case 'free_shock',
        dispatcher('toggle_bypass', 7);
        
    case 'update',
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
end;
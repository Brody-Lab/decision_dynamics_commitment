function [ snd ] = nSound(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation of function goes here
GetSoloFunctionArgs;
switch action,
    case 'init'
        SoundManagerSection(obj, 'init');
        SoundManagerSection(obj, 'declare_new_sound', 'sound');
        SoundManagerSection(obj, 'declare_new_sound', 'go_sound');
        
        SoloParamHandle(obj, 'soundID', 'value', 0);
        soundID.value = SoundManagerSection(obj, 'get_sound_id', 'sound');
        
        SoloParamHandle(obj, 'go_soundID', 'value', 0);
        go_soundID.value = SoundManagerSection(obj, 'get_sound_id', 'go_sound');
        
        DeclareGlobals(obj, 'rw_args', {'soundID', 'go_soundID'});
        
    case 'play'
        SoundManagerSection(obj, 'play_sound', 'go_sound', 1)
        
    case 'wplay'
        SoundManagerSection(obj, 'play_sound', 'sound', 1)
        
    case 'build',
        
        amp=1;
        time = value(soundTime);
        sfreq = value(soundFreq);
        
        if sfreq>150,
            amp=0.1;
        elseif sfreq<=150,
            amp=4;
        elseif sfreq < 50,
            amp=8;
        elseif sfreq < 20,
            amp=20;
        end
        
        t=(0:1/200000:time);
        t=t(1:end-1);
        snd = zeros(2,round(200000*time));
        
        snd(1,:) = (amp*(sin(2*pi*sfreq*t)));
      
%         Build white noise sound

        wamp=value(wNoiseAmp);
        wtime = value(wNoiseTime);
               
        wt=(0:1/200000:wtime);
        wt=wt(1:end-1);
        wsnd = zeros(2,round(200000*wtime));
        
        wsnd(1,:) = wamp*(rand(1,length(wt)));
        
        
        SoundManagerSection(obj, 'set_sound', 'sound', wsnd);
        SoundManagerSection(obj, 'set_sound', 'go_sound', snd);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
%         SoundManagerSection(obj, 'play_sound', 'sound', 1)
        % figure; plot(snd);
        
    case 'old_stuff_that_I_don''t_rememer_if_I_need'
%         % newstartup;
%         sm = RTLSoundMachine('192.168.5.10', 3334, 0);
%         fsm = RTLSM2('192.168.5.10', 3333, 0);
%         % t=[0:1/200000:5];
%         % t=t(1:end-1);
% 
%         length = 5;
%         amp = 0.8333;
%         freq =400;
%         fraction_on = 0.5;
%         samp_rate = 200000;
% 
%         snd = zeros(1,round(samp_rate*length));
% 
%         on_length=round(samp_rate/freq*fraction_on);
%         for i=1:int32(round(length*freq))
%             start_idx=(samp_rate/freq*(i-1))+1;
%             end_idx=start_idx+on_length-1;
%             if end_idx>round(samp_rate*length),
%                 end_idx=round(samp_rate*length);
%             end;
%             snd(start_idx:end_idx)=amp;
%         end;
% 
%         % figure;plot(snd)
% 
%         % snd = sin(2*pi*880*t);
%         sm=LoadSound(sm, 1, snd, 'both');
%         mat=[0 0 0 0 0 0 1 5 0 1; 1 1 1 1 1 1 0 5 0 1];
%         fsm=SetStateMatrix(fsm, mat);
%         fsm=Run(fsm);
%         % fsm=Halt(fsm);

end; %switch
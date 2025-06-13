function [ snd ] = SoundSection(obj, action)
%SOUND Summary of this function goes here
%   Detailed explanation goes here
GetSoloFunctionArgs;
switch action,
    case 'init'
        SoundManagerSection(obj, 'init');
        SoundManagerSection(obj, 'declare_new_sound', 'sound');
        SoloParamHandle(obj, 'soundID', 'value', 0);
        soundID.value = SoundManagerSection(obj, 'get_sound_id', 'sound');
        DeclareGlobals(obj, 'rw_args', {'soundID'});
        SoundSection(obj, 'build');
        
    case 'build',
        amp=0.1;
        time = 0.08;
        sfreq = 6000;
        t=[0:1/200000:time];
        t=t(1:end-1);
        snd = zeros(2,round(200000*time));
        snd(1,:) = (amp*(sin(2*pi*sfreq*t)));
        SoundManagerSection(obj, 'set_sound', 'sound', snd);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        % figure; plot(snd);

    case 'play'
        SoundManagerSection(obj, 'play_sound', 'sound', 1)
    
end;
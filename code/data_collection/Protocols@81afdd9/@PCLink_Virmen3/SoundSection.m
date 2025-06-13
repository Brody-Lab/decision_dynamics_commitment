% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'declare_new_sounds'   Make the definition of the sounds for
%            the task

function SoundSection(obj, action)

GetSoloFunctionArgs(obj);
dur_sound = 250;
attenuation = 1;
freqs_ac = value(freqs_sound);

switch action
    
    %% declare_new_sounds
    % -----------------------------------------------------------------------
    %
    %         declare_new_sounds
    %
    % -----------------------------------------------------------------------
    
    case 'declare_new_sounds'
        
        SoundManagerSection(obj, 'init');
        
        % Generate the sounds we need.
        sr = SoundManagerSection(obj,'get_sample_rate');
        
        snd_low = MakeBeep( sr,  attenuation, freqs_ac(1), dur_sound);
        snd_high = MakeBeep( sr,  attenuation, freqs_ac(2), dur_sound);
        
        SoundManagerSection(obj,'declare_new_sound','snd_low',   [snd_low; snd_low]);
        SoundManagerSection(obj,'declare_new_sound','snd_high', [snd_high; snd_high]);
        
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
    case 'sounds_more_difficult'
        
        % Generate the sounds we need.
        sr = SoundManagerSection(obj,'get_sample_rate');
        
        if freqs_ac(1)*1.1 + 100 < freqs_ac(2)*0.9
            freqs_ac(1) = freqs_ac(1)*1.1;
            freqs_ac(2) = freqs_ac(2)*0.9; 
            freqs_sound.value = freqs_ac;
            disp({'frequencies', freqs_ac(1) freqs_ac(2)})
            snd_low = MakeBeep( sr,  attenuation, freqs_ac(1), dur_sound);
            snd_high = MakeBeep( sr,  attenuation, freqs_ac(2), dur_sound);

            SoundManagerSection(obj,'set_sound','snd_low',   [snd_low; snd_low]);
            SoundManagerSection(obj,'set_sound','snd_high', [snd_high; snd_high]);

            SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        end
        
        case 'sounds_more_easy'
        
        % Generate the sounds we need.
        sr = SoundManagerSection(obj,'get_sample_rate');
        
        
        freqs_ac(1) = freqs_ac(1)*0.9;
        freqs_ac(2) = freqs_ac(2)*1.1; 
        freqs_sound.value = freqs_ac;
        disp({'frequencies', freqs_ac(1) freqs_ac(2)})
        snd_low = MakeBeep( sr,  attenuation, freqs_ac(1), dur_sound);
        snd_high = MakeBeep( sr,  attenuation, freqs_ac(2), dur_sound);
        
        SoundManagerSection(obj,'set_sound','snd_low',   [snd_low; snd_low]);
        SoundManagerSection(obj,'set_sound','snd_high', [snd_high; snd_high]);
        
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
        
end
end
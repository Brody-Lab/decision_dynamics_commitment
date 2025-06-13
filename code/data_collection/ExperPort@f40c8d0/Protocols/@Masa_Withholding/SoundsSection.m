
function  [x, y, IdToneSmall, IdToneLarge, IdToneSmallLarge, ...
            IdNoise, IdNoiseBurst]  =  SoundsSection(obj,action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'
        
        SoundManagerSection(obj, 'init');

        EditParam(obj, 'NoiseLoudness',  0.01,  x, y);   next_row(y);
        set_callback(NoiseLoudness, {'SoundsSection', 'set_noise'});
        
        EditParam(obj, 'SoundSPL',     70,  x, y);   next_row(y);
        EditParam(obj, 'SoundDur',    0.08,  x, y);   next_row(y);        
        MenuParam(obj, 'SmallTone', {'Low','High'}, 1, x, y);next_row(y);
        
        % large be automatically the opposite tone
        % low tone is 6 kHz, high tone is 14 kHz
        set_callback({SoundSPL, SoundDur, SmallTone}, {'SoundsSection', 'set_tone'});
        
        sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        SoloParamHandle(obj, 'SoundSampRate', 'value', sound_samp_rate);
        
        SoloParamHandle(obj, 'IdToneSmall', 'value', 0);
        SoloParamHandle(obj, 'IdToneLarge', 'value', 0);
        SoloParamHandle(obj, 'IdToneSmallLarge', 'value', 0);
        SoloParamHandle(obj, 'IdNoise', 'value', 0);
        SoloParamHandle(obj, 'IdNoiseBurst', 'value', 0);
        
        SoundManagerSection(obj, 'declare_new_sound', 'ToneForSmall');
        SoundManagerSection(obj, 'declare_new_sound', 'ToneForLarge');
        SoundManagerSection(obj, 'declare_new_sound', 'ToneForSmallLarge');
        SoundManagerSection(obj, 'declare_new_sound', 'Noise');
        SoundManagerSection(obj, 'declare_new_sound', 'NoiseBurst');
        
        IdToneSmall.value = SoundManagerSection(obj, 'get_sound_id', 'ToneForSmall');
        IdToneLarge.value = SoundManagerSection(obj, 'get_sound_id', 'ToneForLarge');
        IdToneSmallLarge.value = SoundManagerSection(obj, 'get_sound_id', 'ToneForSmallLarge');
        IdNoise.value = SoundManagerSection(obj, 'get_sound_id', 'Noise');
        IdNoiseBurst.value = SoundManagerSection(obj, 'get_sound_id', 'NoiseBurst');
        
        PushbuttonParam(obj, 'Play_NoiseBurst', x,y, 'label', 'Play_NoiseBurst', 'position');next_row(y);
        set_callback(Play_NoiseBurst,{'SoundManagerSection', 'play_sound', 'NoiseBurst'});
        PushbuttonParam(obj, 'Play_Noise', x,y, 'label', 'Play_Noise','position',[x y 100 20]);
        set_callback(Play_Noise,{'SoundManagerSection', 'play_sound', 'Noise'});    
        PushbuttonParam(obj, 'Stop_Noise', x,y, 'label', 'Stop_Noise','position',[x+100 y 100 20]);next_row(y);
        set_callback(Stop_Noise,{'SoundManagerSection', 'stop_sound', 'Noise'});
        PushbuttonParam(obj, 'Play_ToneForLarge', x,y, 'label', 'Play_ToneLarge');next_row(y);
        set_callback(Play_ToneForLarge,{'SoundManagerSection', 'play_sound', 'ToneForLarge'});
        PushbuttonParam(obj, 'Play_ToneForSmall', x,y, 'label', 'Play_ToneSmall');next_row(y);
        set_callback(Play_ToneForSmall,{'SoundManagerSection', 'play_sound', 'ToneForSmall'});
        
        SubHeaderParam(obj, 'SubHeaderSoundSection','Sound Section',x,y); next_row(y);
        
        SoundsSection(obj, 'set_tone');
        SoundsSection(obj, 'set_noise');
        SoundsSection(obj, 'prepare_next_trial');
        
    case 'set_tone'
        %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        RISE_FALL=5; %5ms
        t=0:(1/value(SoundSampRate)):value(SoundDur);
        t=t(1:(end-1));

        fake_rp_box = bSettings('get', 'RIGS', 'fake_rp_box');
        if (fake_rp_box==2 || fake_rp_box==20),
            
            %At first, make sound for 70dB, later adjust the amplitude according
            %to SoundSPL
            sound_machine_server = bSettings('get', 'RIGS', 'sound_machine_server');
            card_slot = bSettings('get', 'RIGS', 'card_slot');

            if (strcmp(sound_machine_server,'192.168.5.43') && card_slot == 0),
                snd_low=10^((-74.5)/20)*(sin(2*pi*6000*t));
                snd_high=10^((-61)/20)*(sin(2*pi*14000*t));
            elseif (strcmp(sound_machine_server,'192.168.5.43') && card_slot == 1),
                snd_low=10^((-67.5)/20)*(sin(2*pi*6000*t));
                snd_high=10^((-65.5)/20)*(sin(2*pi*14000*t));
            elseif (strcmp(sound_machine_server,'192.168.5.33') && card_slot == 0),
                snd_low=10^((-79)/20)*(sin(2*pi*6000*t));
                snd_high=10^((-68.5)/20)*(sin(2*pi*14000*t));
            elseif (strcmp(sound_machine_server,'192.168.5.23') && card_slot == 0),
                snd_low=10^((-74)/20)*(sin(2*pi*6000*t));
                snd_high=10^((-71)/20)*(sin(2*pi*14000*t));
            elseif (strcmp(sound_machine_server,'192.168.1.20') && card_slot == 0),
                snd_low=10^((-74)/20)*(sin(2*pi*6000*t)); %NEED TO BE CALIBRATED
                snd_high=10^((-71)/20)*(sin(2*pi*14000*t)); %NEED TO BE CALIBRATED
            elseif (strcmp(sound_machine_server,'192.168.1.20') && card_slot == 1),
                snd_low=10^((-74)/20)*(sin(2*pi*6000*t)); %NEED TO BE CALIBRATED
                snd_high=10^((-71)/20)*(sin(2*pi*14000*t)); %NEED TO BE CALIBRATED
            else
                error('Please calibrate the sound pressure level for this rig!!')
            end;
            
        elseif fake_rp_box == 3,
            snd_low=10^((-20)/20)*(sin(2*pi*6000*t));
            snd_high=10^((-20)/20)*(sin(2*pi*14000*t));
        else
            error('don''t know this fake_rp_box number %d', fake_rp_box);
        end;

        Edge=MakeEdge(value(SoundSampRate), RISE_FALL );
        LEdge=length(Edge);
        % Put a cos^2 gate on the leading and trailing edges.
        snd_low(1:LEdge)=snd_low(1:LEdge) .* fliplr(Edge);
        snd_low((end-LEdge+1):end)=snd_low((end-LEdge+1):end) .* Edge;
        snd_high(1:LEdge)=snd_high(1:LEdge) .* fliplr(Edge);
        snd_high((end-LEdge+1):end)=snd_high((end-LEdge+1):end) .* Edge;

        %set the amplitude
        SOUND_SPL_70 = value(SoundSPL) - 70;
        switch value(SmallTone),
            case 'Low',
                sound_small=(10^(SOUND_SPL_70/20))*snd_low;
                sound_large=(10^(SOUND_SPL_70/20))*snd_high;
            case 'High',
                sound_small=(10^(SOUND_SPL_70/20))*snd_high;
                sound_large=(10^(SOUND_SPL_70/20))*snd_low;
        end;

        %tone for fake_cin (small_large)
        sound_small_large=[sound_small sound_large];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %"set"_sound using SoundManagerSection
        SoundManagerSection(obj, 'set_sound', 'ToneForSmall', sound_small);
        SoundManagerSection(obj, 'set_sound', 'ToneForLarge', sound_large);
        SoundManagerSection(obj, 'set_sound', 'ToneForSmallLarge', sound_small_large);        
        
    case 'set_noise'
        NOISE_LEN = 1; %doesn't matter, because of loop
        NOISE_B_LEN = 0.06;
        
        fake_rp_box = bSettings('get', 'RIGS', 'fake_rp_box');
        if (fake_rp_box==2 || fake_rp_box==20),
            %noise for ITI
            noise = value(NoiseLoudness)*0.1*rand(2,NOISE_LEN*value(SoundSampRate));

            %noise burst for center port re-enter
            noise_burst ...
                = value(NoiseLoudness)*rand(2,NOISE_B_LEN*value(SoundSampRate));
        elseif fake_rp_box==3, %emulater
            noise = 0.03*rand(2,NOISE_LEN*value(SoundSampRate));
            noise_burst = 0.3*rand(2,NOISE_B_LEN*value(SoundSampRate));
        end;
        
        %"set"_sound using SoundManagerSection
        SoundManagerSection(obj, 'set_sound', 'Noise', noise, 1); %last arg: loop_flag
        SoundManagerSection(obj, 'set_sound', 'NoiseBurst', noise_burst);

    case 'prepare_next_trial'
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;


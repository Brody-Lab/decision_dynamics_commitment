
sound_samp_rate=200000;
duration=5;

%simple way to make pure tone
t=0:1/sound_samp_rate:duration;
t=t(1:end-1);
%%%%%%%%%%%%%%%%%%%%%%%%
freq=14000;
%%%%%%%%%%%%%%%%%%%%%%%%
attenuation=40;

sound_pure=(10^(-attenuation/20))*sin(2*pi*freq*t);

% % make FM tone
%       fm_params.carrier_frequency      = 6000;
%       fm_params.carrier_phase          = 0;
%       fm_params.modulation_frequency   = 50;
%       fm_params.modulation_phase       = 0;
%       fm_params.modulation_index       = 500;
%       fm_params.amplitude              = 70;
%       fm_params.duration               = duration*1000;
%       fm_params.ramp                   = 5;
%       
%       samplerate                    = sound_samp_rate;
%       
%       sound_fm = (10^(-attenuation/20))*MakeFMTone(fm_params, samplerate);
%       
%       %make AM tone
% 
%       am_params.carrier_frequency      = 14000;
%       am_params.carrier_phase          = 0;
%       am_params.modulation_frequency   = 100;
%       am_params.modulation_phase       = 0;
%       am_params.modulation_depth       = 0.5;
%       am_params.amplitude              = 70;
%       am_params.duration               = duration*1000;
%       am_params.ramp                   = 5;
%       
%       samplerate                    = sound_samp_rate;
%       
%       
%       sound_am = (10^(-attenuation/20))*MakeAMTone(am_params, samplerate);
%       
%       %make Noise
%       sound_noise = (10^(-attenuation/20))*rand(1,floor(duration*sound_samp_rate));
      
      %make Chord
      %sound = MakeChord(sound_samp_rate,  0, ...
      %        6000, 8, duration*1000, 5);

      %make Pure tone 
      %     sound = MakeChord(sound_samp_rate,  0, ...
      %     6000, 1, duration*1000, 5);

rpbox('InitRP3StereoSound');
sm = rpbox('getsoundmachine');
sm = SetSampleRate(sm, sound_samp_rate);
sm = LoadSound(sm, 1, sound_pure, 'right', 0, 0);
% sm = LoadSound(sm, 2, sound_fm, 'both', 0, 0);
% sm = LoadSound(sm, 3, sound_am, 'both', 0, 0);
% sm = LoadSound(sm, 4, sound_noise, 'both', 0, 0);
sm = rpbox('setsoundmachine', sm);

fsm=rpbox('getstatemachine');
fsm=SetInputEvents(fsm,[],'ai');
mat=[1 duration 2 1;1 0 0 0];
fsm=SetStateMatrix(fsm,mat);
ForceState(fsm,0);

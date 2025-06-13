function [w1,w2]=tonestim(T1,T2,AUD1_loudness,AUD2_loudness,AUD1_pitch,AUD2_pitch,Fs)  

%borrowed from SoundInterface Tones
sr=Fs;
vol1 = value(AUD1_loudness);
vol2 = value(AUD2_loudness);
loop = 0;
bal = 0;
dur1 = value(T1)*1000;
dur2 = value(T2)*1000;
freq1 = value(AUD1_pitch);
freq2 = value(AUD2_pitch);

            R1Vol=vol1*min(1,(1+bal));
            L1Vol=vol1*min(1,(1-bal));
            R2Vol=vol2*min(1,(1+bal));
            L2Vol=vol2*min(1,(1-bal));
            
                    t1=0:(1/sr):(dur1/1000); 
                    t1 = t1(1:end-1);
                    tw1=sin(t1*2*pi*freq1);
                    RW1=R1Vol*tw1;
                    LW1=L1Vol*tw1;
                    w1=[LW1;RW1];
                    clear tw1
                    
                    t2=0:(1/sr):(dur2/1000); 
                    t2 = t2(1:end-1);
                    tw2=sin(t2*2*pi*freq2);
                    RW2=R2Vol*tw2;
                    LW2=L2Vol*tw2;
                    w2=[LW2;RW2];
                    clear tw2
                    
            % 
% params1=[];
% params2=[];
% params1.ramp = 5; %5ms rising/falling edge
% params1.duration=T1*1000; %duration is in ms, T1 is in sec
% params1.amplitude=value(AUD1_loudness);
% params1.modulation_depth=0; %no modulation, just carrier freq
% params1.modulation_phase=0;
% params1.modulation_frequency=0;
% params1.carrier_phase=0;
% params1.carrier_frequency=value(AUD1_pitch);
% 
% params2.ramp = 5; %5ms rising/falling edge
% params2.duration=T2*1000; %duration is in ms, T2 is in sec
% params2.amplitude=value(AUD2_loudness);
% params2.modulation_depth=0; %no modulation, just carrier freq
% params2.modulation_phase=0;
% params2.modulation_frequency=0;
% params2.carrier_phase=0;
% params2.carrier_frequency=value(AUD2_pitch);
% 
% varargin1{1}=params1;
% varargin1{2}=Fs;
% varargin2{1}=params2;
% varargin2{2}=Fs;
% 
% normbase1=EmilyMakeAMTone(params1,Fs);
% normbase2=EmilyMakeAMTone(params2,Fs);
end


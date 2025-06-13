function [normbase]=singletone(sigma,T,Fs)

% ------INPUTS:
% sigma         is ????
% T             duration of each signal in milisecond                                     
% Fs            sampling frequency
%
% ------OUTPUT:
% normbase      used to produce the audio sounds
%
%

sigma=1;
filter_type='BUTTER';
outband=60;
replace=1;
L=floor(T*Fs);                      % Length of signal (samplerate/s * sec)
%%%%%%%%%%% produce position values %%%%%%%
pos1 = sigma*randn(Fs,1);
% makes a vector of pseudorandom values, length of sample rate

% pos1(pos1>outband)=[];
% pos1(pos1<-outband)=[];
    
base = randsample(pos1,L,replace);
% base is a random sample of positions, the length of the signal

%%%% Filter the original position values %%%%%%
%filtbase=filt(base,fcut,Fs,filter_type);
hf = design(fdesign.bandpass('N,F3dB1,F3dB2',10,fcut(1),fcut(2),Fs));
% hf is the filter designer (not the design itself, just specifications)
filtbase=filter(hf,base);
% applies filter to random sample of positions
normbase=filtbase./(max(abs(filtbase)));
% normbase is the normalized so all values are btw -1,1
end


%% from MakeFMTone.m
% function tone = MakeFMTone(varargin)
% 
% pref.maxSPL = 70;   % max. amplitude in dB SPL
% 
% % [This function generates frequency-modulated tones]
% %
% % function tone = MakeFMTone(varargin)
% %   REQUIRED input paramters:
% %   varargin{1} - parameters structure (see below)
% %   varargin{2} - sampling rate of the resulting sound (in Hz)
% %
% % The parameter structure MUST have the following fields:
% %
% % carrier_frequency         -   carrier frequency of the sound (in Hz)
% % carrier_phase             -   initial phase of the carrier frequency
% % modulation_frequency      -   modulation frequency of the sound (in Hz)
% % modulation_phase          -   modulation phase
% % modulation_index          -   depth of modulation
% % amplitude                 -   amplitude/intensity of the sound (dB)
% % duration                  -   duration (in ms)
% % ramp                      -   rising/falling edge (in ms)
% %
% % Example:
% % params.carrier_frequency      = 6000;
% % params.carrier_phase          = 0;
% % params.modulation_frequency	= 50;
% % params.modulation_phase       = 0;
% % params.modulation_index       = 500;
% % params.amplitude              = 70;
% % params.duration               = 500;
% % params.ramp                   = 5;
% %
% % samplerate                    = 44100;
% %
% % tone = MakeFMTone(params, samplerate);
% %   this creates 500 ms long fm-tone with carrier frequency (i.e. centered on) 6000 Hz.
% %
% % The amplitude of the final sound depends on pref.maxSPL defined above, i.e. you MUST know the
% % MAXIMUM dB SPL sound pressure level your system/speaker can deliver. Your requested amplitude will
% % be adjusted to pref.SPL, i.e. if you say (pref.SPL) that your system is calibrated to 70 dB, and
% % request amplitude of 80 dB, your sound wave's amplitude wil be larger than your system can handle
% % and the actual sound coming out of the speaker will be distorted....
% 
% 
% % orig: sFM.m Wang Lab, Johns Hopkins University (Edited on January 13, 2004 by Tom Lu)
% 
% tone=[];
% 
% if nargin<2
%     return;
% end
% 
% params          =varargin{1};
% samplerate      =varargin{2};
% Fc              =params.carrier_frequency;
% carrier_phase   =params.carrier_phase;
% Fm              =params.modulation_frequency;
% modulation_phase=params.modulation_phase;
% modulation_index=params.modulation_index;
% amplitude       =params.amplitude;
% duration        =params.duration;
% ramp            =params.ramp;
% 
%     amplitude=(10.^((amplitude-pref.maxSPL)/20));
% 
%     npts=samplerate*(duration/1000);
%     x=(1:npts)/samplerate;
%     tone=sin(2*pi*Fc*x - modulation_index/Fm*(cos(2*pi*Fm*x + modulation_phase - pi/2)) + carrier_phase);
%     tone=amplitude*tone;
% 
%     edge=MakeEdge(ramp,samplerate);     % prepare the edges
%     ledge=length(edge);
%     tone(1:ledge)=tone(1:ledge).*fliplr(edge);
%     tone((end-ledge+1):end)=tone((end-ledge+1):end).*edge;
% 
% 
% % Uncomment the following if you want to how the sounds look like    
% % figure
% % subplot(211)
% % plot((1:length(tone))/samplerate*1000, tone)
% % xlabel('Time (ms)')
% % ylabel('amplitude')
% % 
% % subplot(212)
% % % plot((1:length(fft(tone)))/length(fft(tone))*(samplerate/1000), abs(fft(tone)))
% % specgram(tone,[],samplerate/1000)
% % ylabel('Frequency (kHz)');
% 

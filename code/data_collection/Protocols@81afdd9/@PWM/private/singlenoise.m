function [normbase]=singlenoise(sigma_1,T,fcut,Fs,filter_type)
%GetSoloFunctionArgs(obj);

%%%%%%%%%%%%%%%%% Determines of the type of filter used %%%%%%%%%%%%%%%%%%%
%'LPFIR': lowpass FIR%%%%%'FIRLS': Least square linear-phase FIR filter design
%'BUTTER': IIR Butterworth lowpass filter%%%%%%'GAUS': Gaussian filter (window)
%'MOVAVRG': Moving average FIR filter%%%%%%%%'KAISER': Kaiser-window FIR filtering
% 'EQUIRIP':Eqiripple FIR filter%%%%% 'HAMMING': Hamming-window based FIR 
%
%
% T is duration of each signal in milisecond, fcut is the cut-off frequency                                     
% Fs is the sampling frequency
% outband=40;
sigma_1=1;
%T=10000;
%fcut=[3000 4000];
%Fs=200000;
filter_type='BUTTER';
outband=60;
replace=1;
L=floor(T*Fs);                      % Length of signal (samplerate/s * sec)
%%%%%%%%%%% produce position values %%%%%%%
pos1 = sigma_1*randn(Fs,1);
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


function [base,target,normbase,normtarget]=noisestim(sigma_1,sigma_2,T,fcut,Fs,filter_type)

%%%%%%%%%%%%%%%%% Determines of the type of filter used %%%%%%%%%%%%%%%%%%%
%'LPFIR': lowpass FIR%%%%%'FIRLS': Least square linear-phase FIR filter design
%'BUTTER': IIR Butterworth lowpass filter%%%%%%'GAUS': Gaussian filter (window)
%'MOVAVRG': Moving average FIR filter%%%%%%%%'KAISER': Kaiser-window FIR filtering
% 'EQUIRIP':Eqiripple FIR filter%%%%% 'HAMMING': Hamming-window based FIR 
% T is duration of each signal in milisecond, fcut is the cut-off frequency                                     
% Fs is the sampling frequency
% outband=40;
replace=1;
L=floor(T*Fs);                      % Length of signal
t=L*linspace(0,1,L)/Fs;          % time in miliseconds
%%%%%%%%%%% produce position values %%%%%%%
pos1 = sigma_1*randn(Fs,1);
% pos1(pos1>outband)=[];
% pos1(pos1<-outband)=[];
    
pos2 =sigma_2*randn(Fs,1);
% pos2(pos2>outband)=[];
% pos2(pos2<-outband)=[];
base = randsample(pos1,L,replace);
target = randsample(pos2,L,replace);
%%%% Filter the original position values %%%%%%
filtbase=filt(base,fcut,Fs,filter_type);
filttarget=filt(target,fcut,Fs,filter_type);
normbase=filtbase./(max(abs(filtbase)));
normtarget=filttarget./(max(abs(filttarget)));
end

%%%%%% plot the row and filtered position values %%%%%%%%%
% subplot(2,2,1)
% plot(t,base,'r');
% ylabel('base')
% xlabel('Time (ms)')
% subplot(2,2,2)
% plot(t,target,'g');
% ylabel('target')
% xlabel('Time (ms)')
% subplot(2,2,3)
% plot(t,filtbase)
% ylabel('filtbase')
% xlabel('Time (ms)')
% subplot(2,2,4)
% plot(t,filttarget)
% ylabel('filttarget')
% xlabel('Time (ms)')

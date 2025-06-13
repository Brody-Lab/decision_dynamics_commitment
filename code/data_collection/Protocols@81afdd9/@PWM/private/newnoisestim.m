function [normbase1,normbase2]=newnoisestim(sigma_1,sigma_2,T1,T2,fcut,Fs,filter_type)

%%%%%%%%%%%%%%%%% Determines of the type of filter used %%%%%%%%%%%%%%%%%%%
%'LPFIR': lowpass FIR%%%%%'FIRLS': Least square linear-phase FIR filter design
%'BUTTER': IIR Butterworth lowpass filter%%%%%%'GAUS': Gaussian filter (window)
%'MOVAVRG': Moving average FIR filter%%%%%%%%'KAISER': Kaiser-window FIR filtering
% 'EQUIRIP':Eqiripple FIR filter%%%%% 'HAMMING': Hamming-window based FIR 
% T is duration of each signal in milisecond, fcut is the cut-off frequency                                     
% Fs is the sampling frequency
% outband=40;
replace=1;
L1=floor(T1*Fs);                   % Length of signal
L2=floor(T2*Fs);
% t1/2 are not currently used, AthenaDelayComp had them as a nonfunctioning
% plot option
% t1=L1*linspace(0,1,L1)/Fs;
% t2=L2*linspace(0,1,L2)/Fs;
%%%%%%%%%%% produce position values %%%%%%%
pos1 = sigma_1*randn(Fs,1);
% pos1(pos1>outband)=[];
% pos1(pos1<-outband)=[];
    
pos2 =sigma_2*randn(Fs,1);
% pos2(pos2>outband)=[];
% pos2(pos2<-outband)=[];
base1 = randsample(pos1,L1,replace);
base2 = randsample(pos2,L2,replace);
%%%% Filter the original position values %%%%%%
filtbase1=filt(base1,fcut,Fs,filter_type);
filtbase2=filt(base2,fcut,Fs,filter_type);
normbase1=filtbase1./(max(abs(filtbase1)));
normbase2=filtbase2./(max(abs(filtbase2)));

end

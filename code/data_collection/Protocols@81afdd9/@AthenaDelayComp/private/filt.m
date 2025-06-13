function filtsignal=filt(signal,fcut,Fs,filter_type)
a=2;            % wp/ws used in butterworth method and LS linear FIR method
N=200;          % filter order used in lowpass FIR method
rp=3;           % passband ripple in dB used in butterworth method
rs=60;          % stopband attenuation in dB used in butterworth method
beta=0.1102*(rs-8.8);   %used in Kaiser window to obtain sidelobe attenuation of rs dB
if strcmp(filter_type, 'GAUS') || strcmp(filter_type, 'MOVAVRG')
window = fix(Fs/fcut);      % window size used in Gaussian and moving average methods
end
wp=2*fcut/Fs;               % normalized passband corner frequency wp, the cutoff frequency
ws=a*wp;                    % normalized stopband corner frequency


switch filter_type
    case 'BUTTER'   %Butterworth IIR filter
        if length(wp)>1
        ws(1)=2*(fcut(1)/2)/Fs;
        ws(2)=2*(fcut(2)+fcut(1)/2)/Fs;
        [n,wn]=buttord(wp,ws,rp,rs);
        [b,a]=butter(n,wn,'bandpass');
        else
        [n,wn]=buttord(wp,ws,rp,rs);
        [b,a]=butter(n,wn,'low');
        end
        filtsignal=filter(b,a,signal);%conventional filtering
    case 'LPFIR'    %Lowpass FIR filter
        d=fdesign.lowpass('N,Fc',N,fcut,Fs); % Fc is the 6-dB down point, N is the filter order(N+1 filter coefficients)
        Hd = design(d);
        filtsignal=filter(Hd.Numerator,1,signal); %conventional filtering
    case 'FIRLS'    %Least square linear-phase FIR filter design
        b=firls(255,[0 2*fcut/Fs a*2*fcut/Fs 1],[1 1 0 0]);
        filtsignal=filter(b,1,signal); %conventional filtering
    case 'EQUIRIP'  %Eqiripple FIR filter
        d=fdesign.lowpass('Fp,Fst,Ap,Ast',wp,ws,rp,rs);
        Hd=design(d,'equiripple');
        filtsignal=filter(Hd.Numerator,1,signal); %conventional filtering
    case 'MOVAVRG'  % Moving average FIR filtering, Rectangular window
        h = ones(window,1)/window;
        b = fir1(window-1,wp,h);
        filtsignal = filter(b, 1, signal);
    case 'HAMMING'  % Hamming-window based FIR filtering
        b = fir1(150,wp);
        filtsignal = filter(b, 1, signal);        
        filtsignal = filter(h, 1, signal);
    case 'GAUS'     % Gaussian-window FIR filtering
        h = normpdf(1:window, 0, fix(window/2));
        b = fir1(window-1,wp,h);
        filtsignal = filter(b, 1, signal);
    case 'GAUS1'    % Gaussian-window FIR filtering
        b = fir1(window-1,wp,gausswin(window,2)/window);
        filtsignal = filter(b, 1, signal);
    case 'KAISER'   %Kaiser-window FIR filtering
        h=kaiser(window,beta);
        b = fir1(window-1,wp,h);
        filtsignal = filter(b, 1, signal);     
        
    otherwise
    sprintf('filter_type is wrong!! havaset kojast!!')
end


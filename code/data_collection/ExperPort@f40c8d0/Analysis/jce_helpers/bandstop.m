function y=bandstop(ecg, fs, bnd)

if size(ecg, 2)==512
   NCS_flag=1; 
    %assume that this is a neuralynx type file
   ecg=reshape(ecg',1,numel(ecg));
    
end

%function y=bandstop(sig, sf, bnd)
% Takes a signal and filters out the band at bnd
% sig is the signal
% sf is the sampling frequency in Hz
% bnd is the band to get rid of.

% based on source from :
% http://www.scienceprog.com/removing-60hz-from-ecg-using-digital-band-stop
% -filter/
dim=size(ecg);

w0=2*pi*((bnd)/(fs));
G=1/(2-2*cos(w0));

y=filter( [1/G, -2*cos(w0)/G, 1/G],1, ecg);

if NCS_flag
    y=reshape(ecg, 512, numel(ecg)/512)';
end
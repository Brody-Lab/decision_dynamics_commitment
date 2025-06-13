
function [snd] = MakeWNRamp(dur, srate, vol, vol2)
% makes a white noise ramping sound
% Input parameters
% dur - length in milliseconds (for 2s sound, use dur=2000)
% srate - sampling rate (per second)
% vol - starting volume factor
% vol2 - ending volume factor 
%
% Author - Shraddha Pai (Sep 08)
% Adapted from Jeff Erlich's Plugins/SoundInterface.m

% dur1= 2000;
% sr= get_generic('sampling_rate');
% vol  = 0.002;
% vol2 = 0.03;

LW = []; RW = [];


t=0:(1/sr):(dur1/1000); t = t(1:end-1);
if vol>0,
    vramp = vol*exp((t/t(end)).*log(vol2/vol));
else
    vramp = vol + (t/t(end))*(vol2 - vol);
    warning('SOUNDUI:LogOfZero', 'WhiteNoiseRamp: vol==0, using linear instead of log volume scale');
end;
RW=vramp.*randn(size(t));
LW=vramp.*randn(size(t));
clear t; clear vramp;

snd =[LW' RW'];

%sound([LW' RW'], get_generic('sampling_rate'));


% Generates a @PWM/@AthenaDelayComp style pink noise stimulus. Ported over
% from those protocols.
%
% Jorge Yanar, March 2023

function [AUD1, AUD2] = classical_loudness_stim(lfreq, hfreq, stim_length_s, AUD1_loudness,...
                                          AUD2_loudness, fcut, Fs, filter_type)
    % First, generate normAUD1 and normAUD2. These are white noise stimuli
    % that have been gaussian smoothed.
    [normAUD1, normAUD2] = newnoisestim(1, 1, stim_length_s, fcut, Fs, filter_type);

    % Generate two modulator waves composed of butterworth
    % bandpass-filtered white noise.
    modulator1 = singlenoise(1, stim_length_s, [lfreq, hfreq], Fs, 'BUTTER');
    modulator2 = singlenoise(1, stim_length_s, [lfreq, hfreq], Fs, 'BUTTER');

    % Multiply these with the two waves to generate final AUD stimuli
    AUD1 = normAUD1(1 : stim_length_s*Fs) .* modulator1(1 : stim_length_s*Fs) .* AUD1_loudness;
    AUD2 = normAUD2(1 : stim_length_s*Fs) .* modulator2(1 : stim_length_s*Fs) .* AUD2_loudness;
end


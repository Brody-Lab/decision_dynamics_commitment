function normbase = singlenoise(sigma1, stim_length_s, fcut, Fs, filter_type)
    signal_length = floor(stim_length_s * Fs);
    %sigma1 = 1;
    %filter_type = 'BUTTER';
    
    replace = true;
    pos1 = sigma1 * randn(Fs, 1);
    % Base is a random sample of positions, of length equal to the signal
    base = randsample(pos1, signal_length, replace);
    
    % Bandpass filter with Butterworth
    hf = design(fdesign.bandpass('N,F3dB1,F3dB2', 10, fcut(1), fcut(2), Fs));
    filtbase = filter(hf, base);             % applies filter to random sample of positions
    normbase = filtbase./max(abs(filtbase)); % normalized s.t. all values btw -1,1
end
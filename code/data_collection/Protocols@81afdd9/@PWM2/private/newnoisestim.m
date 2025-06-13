function [normbase1, normbase2] = newnoisestim(sigma1, sigma2, stim_length_s, fcut, Fs, filter_type)
    % Compute length of signals in number of samples
    signal_length = floor(stim_length_s*Fs);

    % Produce position values
    pos1 = sigma1 * randn(Fs, 1);
    pos2 = sigma2 * randn(Fs, 1);
    replace = true;
    base1 = randsample(pos1, signal_length, replace);
    base2 = randsample(pos2, signal_length, replace);

    % Filter the original position values
    filtbase1 = custom_filt(base1, fcut, Fs, filter_type);
    filtbase2 = custom_filt(base2, fcut, Fs, filter_type);
    normbase1 = filtbase1 ./ max(abs(filtbase1));
    normbase2 = filtbase2 ./ max(abs(filtbase2));
end
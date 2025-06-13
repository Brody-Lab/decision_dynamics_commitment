function [slope peaks] = extract_wave_slope(waves, plotit)

% waves is a Nx4x32 matrix, where N is the number of events in this
% cluster
%
% note that I have not yet made attempts to put reasonable units on any of
% waveforms
%
% the function returns slope, a Nx4 matrix, where each row is an event and
% each column is the slope of the waveform on a tetrode channel
%
% peak is a Nx4 matrix, where each row is an event and each column of the
% value of eighth sample in the waves vector

if nargin < 2,
    plotit = 0;
end;

N = rows(waves);
slope = zeros(N, 4);
peaks = zeros(N,4);
for n = 1:N,
    for tet = 1:4,
        wf = reshape(waves(n, tet, :), [1 32]);
        p = 8;
        peak   = wf(p);       % peak of waveform
        [valley v] = min(wf(1:p));  % valley that occurs before the peak
        slope(n, tet) = (peak - valley)/(p-v); % rather arbitrary units at this point
        peaks(n, tet)  = peak;
    end;
end;

if plotit,
    markersize = 2;
    figure; 
    subplot(5,1,1);
    meanwave = reshape(mean(waves,1), [4 32]);
    meanwave = [meanwave(1,:) 0 meanwave(2,:) 0 meanwave(3,:) 0 meanwave(4,:)];
    samples = [1:32 NaN 33+[1:32] NaN 66+[1:32] NaN 99+[1:32]];
    plot(samples, meanwave, 'b-');
    
    subplot(5,1,2:3); hold on;
    plot(slope(:,1), slope(:,2), 'r.', 'MarkerSize', markersize);
    plot(-slope(:,3), slope(:,2), 'r.', 'MarkerSize', markersize);
    plot(-slope(:,3), -slope(:,4), 'r.', 'MarkerSize', markersize);
    plot(slope(:,1), -slope(:,4), 'r.', 'MarkerSize', markersize);
    title('Slope');
    
    subplot(5,1,4:5); hold on;
    plot(peaks(:,1), peaks(:,2), 'k.', 'MarkerSize', markersize);
    plot(-peaks(:,3), peaks(:,2), 'k.', 'MarkerSize', markersize);
    plot(-peaks(:,3), -peaks(:,4), 'k.', 'MarkerSize', markersize);
    plot(peaks(:,1), -peaks(:,4), 'k.', 'MarkerSize', markersize);
    title('Peak');
end;
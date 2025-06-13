function [width height fr refrac err] = spike_features(cellid, plotit)
% function [width height fr refrac err] = spike_features(cellid, plotit)
%
% given a cellid, returns the width and height of the recorded waveform,
% computed as peak-to-trough on the tetrode channel where the amplitude
% of the wave was largest.
%
% also estimates the firing rate (fr) very roughly and returns the fraction
% of events occuring within a 1 ms refractory period.
%
% err = 1 means refrac > 5e-4, multiunit activity
% err = 2 means waveform is upside-down


if nargin < 2, plotit = 0; end;
err = 0;

[ts wave] = bdata('select ts,wave from spktimes where cellid={Si}', cellid);
ts = ts{1};
wave = wave{1};

% approximate the firing rate
fr = 1/mean(diff(ts));

% wave is a struct containing the mn and std of the waveform
% wave.mn and wave.std are each 4x32 vectors; 
% each row is the 1 msec waveform of one electrode

t = linspace(0,1,32);  % waves sampled for 1 msec at 32kHz
tt = linspace(0,1,1000); % microsecond intervals

interp_wave = zeros(4, length(tt));
h = zeros(1,4);
for i = 1:4,
	interp_wave(i,:) = spline(t, wave.mn(i,:), tt);
	h(i) = max(interp_wave(i,:)) - min(interp_wave(i,:)); % height of waveform
end;

% use only the tetrode for which the height was maximal
[y n] = max(h);
[peak_y peak_t]     = max(interp_wave(n,:));
[trough_y trough_t] = min(interp_wave(n,:));
width  = abs(peak_t - trough_t) * 1e-3; % in milliseconds
height = abs(peak_y - trough_y); % in microvolts

% parse error codes:
refrac = sum(diff(ts)<1e-3)/numel(ts); % fraction of spikes occuring within 1 msec
if refrac > 5e-4,
	err = 1; % multiunit activity
end;
if abs(trough_y) > abs(peak_y),
	err = 2; % upside-down waveform
end;


% plotting
if plotit,
	figure;
	for k = 1:4,
		subplot(2,2,k); hold on;
		plot(t, wave.mn(k,:), 'k', 'LineWidth', 2);
		plot(t, [wave.mn(k,:)-wave.std(k,:); wave.mn(k,:)+wave.std(k,:)], 'k--');
		if k == n,
			plot([peak_t trough_t]/1000, [peak_y trough_y], 'r.', 'MarkerSize', 20);
		end;
	end;
end
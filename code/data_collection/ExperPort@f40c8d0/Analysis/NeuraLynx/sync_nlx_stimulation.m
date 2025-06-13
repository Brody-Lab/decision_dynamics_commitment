% sync_nlx_stimulation.m
% script to process acute recording of ChR2 infected brain

%% pick a data folder to process
olddir=pwd;
if ~exist('fldr','var')
    fldr=uigetdir('Please select a folder to process.');
end

nofldr=1;
while nofldr
    try
        if fldr==0 % then they cancelled
            return
        end

        cd(fldr)
        nofldr=0;
    catch
        fldr=uigetfolder('Please select a folder to process.');
    end
end

%% process events
evf=dir('Events.nev');
if isempty(evf) || numel(evf)>1
    [f, p, filterindex] = uigetfile('*.?ev', 'Pick an NLX events file');
    evf=[];
    evf.name=[p f];
end

[ts, ttls, event_id, extra, event_str]=nev2mat(evf.name);
ts = ts/1e6;  % convert usec to sec

% convert event_str into a cell array of string
for ev = 1:rows(event_str),
    e_str{ev} = event_str(ev, :);
end;

idx = strfind(e_str, 'Starting Recording');

recording_start = [];
for ev = 1:length(idx),
    if ~isempty(idx{ev}), recording_start = [recording_start; ev]; end; %#ok<AGROW>
end;

%% extract data from recorded MUA channel
block = [2 3];
ratname = 'M004';
depth = 300; 
channel = 'MUA07_3';
csc = ncsc2mat([channel '.ncs'], '.');

% read the ADbitvolts from the header
n=regexp(csc.hd,'ADBitVolts','end');
bitvolts=str2double(csc.hd(n+1:n+14)); % THIS IS A TOTAL HACK 

% reassemble the data into a one-dimensional vector
V = reshape(shiftdim(csc.data,1), [sum(csc.nValSamp), 1]);
V = bitvolts * V;  % V is now in units of Volts

srate = csc.sampFreq/1e6;  % timestamps are in microseconds, srate started out in samples/sec

% reconstruct the time stamps of the data file
t = zeros(cols(csc.data), rows(csc.data));
dt = median(diff(csc.ts))/median(csc.nValSamp);
for i = 1:length(csc.ts)
    t(:, i) = csc.ts(i):dt:csc.ts(i)+csc.nValSamp(i)*dt-dt;
end;
t = reshape(t, [sum(csc.nValSamp), 1]);
t = t/1e6; % convert usec to sec


clear csc;
% trim data to just this block to save space
b(1) = max([1, qfind(t, ts(recording_start(block(1))))]);
if numel(recording_start) >= block(2),
	b(2) = qfind(t, ts(recording_start(block(2))));
else
	b(2) = length(t);
end;
% [temp b] = qbetween2(t, ts(recording_start(block(1))), ts(recording_start(block(2))));
V = V(b(1):b(2));
t = t(b(1):b(2));


%% parse the pulses found in this block for different stimulation protocols
pulse_In  = find(ttls == 16);  % find all start of pulses as reported by the ttls
if numel(recording_start) >= block(2),
	pulse_In = pulse_In(pulse_In > recording_start(block(1)) & pulse_In < recording_start(block(2)));
else
	pulse_In = pulse_In(pulse_In > recording_start(block(1)));
end;
pulse_Out = pulse_In + 1;  % and when these pulses were turned off

% P = NaN * zeros(size(t));
% for p = 1:length(pulse_In),
%     [y ind] = qbetween2(t, ts(pulse_In(p)), ts(pulse_Out(p)));
%     if ~isempty(ind), P(ind(1):ind(2)) = 0; end;
% end;

% convert pulse_In and pulse_Out to timestamps (in sec)
pulse_In  = ts(pulse_In);
pulse_Out = ts(pulse_Out);

pulse_delay = pulse_In(2:end) - pulse_In(1:end-1);
pulse_width = pulse_Out - pulse_In;

train_start = find(pulse_delay > 1); % start of each pulse train
train_start = [0; train_start; length(pulse_width)];
trains = cell(length(train_start)-1,1);
for i = 1:length(train_start)-1,
    tr.width = mean(pulse_width(train_start(i)+1:train_start(i+1)));
    tr.rate  = 1/median(pulse_delay(train_start(i)+1:train_start(i+1)-1));
    tr.dur   = pulse_Out(train_start(i+1)) - pulse_In(train_start(i)+1) + pulse_width(train_start(i)+1);
    tr.pulse_In = pulse_In(train_start(i)+1:train_start(i+1));
    trains{i} = tr;
end;


%% plot traces for each train
intensity = [3.7 3.5 3.3 3.1 2.9 2.7]; %2.7 2.5];
for i = 1:length(trains),
	b = [qfind(t, trains{i}.pulse_In(1)) qfind(t, trains{i}.pulse_In(end)+trains{i}.width+15e-3)];
	if b(1) > 0,
		figure; hold on;
		set(gcf, 'Position', [400 200 800 200]);	
		set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [1 1 8 2], 'PaperPositionMode', 'manual');	
		plot(t(b(1)-1000:b(2))-t(b(1)), V(b(1)-1000:b(2)), 'k');
		h = line([trains{i}.pulse_In trains{i}.pulse_In+trains{i}.width]'-t(b(1)), 0*ones(length(trains{i}.pulse_In), 2)'); 
		set(h, 'Color', 'b', 'LineWidth', 5);
		axis tight;
		ylim([-1 1]*1e-4);
		xlim([-0.05 0.95]);
% 		print('-depsc2', '-loose', sprintf('~/Desktop/chr2_acute/%s_%gum_%s_%gmsec_%gHz_trace.eps', ratname, depth, channel, round(1e3*trains{i}.width), round(trains{i}.rate)));
		print('-depsc2', '-loose', sprintf('~/Desktop/chr2_acute/%s_%gum_%s_%1.2gV_%gmsec_%gHz_trace.eps', ratname, depth, channel, intensity(i), round(1e3*trains{i}.width), round(trains{i}.rate)));
	end;
end;

%%
buffer = 5e-3; % 10 msec buffer

E = zeros(length(trains), 2);
for i = 1:length(trains),
	pulse_width = round(trains{i}.width*1e3)*1e-3;
    [y, x] = cdraster(trains{i}.pulse_In(1:5), t, V, buffer, max(pulse_width+buffer, 25e-3), 0.001/32);
    
	figure; hold on;
	set(gcf, 'Position', [100 200 200 200]);
	set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [1 1 2 2], 'PaperPositionMode', 'manual');
    plot(x, y, 'Color', 0.7*[1 1 1]);
    plot(x, mean(y), 'k');
	h = line([0 trains{i}.width], -1.5e-4*[1 1]); set(h, 'Color', 'b', 'LineWidth', 3);
	axis tight;
	ylim([-1 1]*1.6e-4);
% 	title(sprintf('%s, %g msec pulses at %g Hz for %0.1g sec', channel(1:5), round(1e3*trains{i}.width), round(trains{i}.rate), trains{i}.dur));
	print('-depsc2', '-loose', sprintf('~/Desktop/chr2_acute/%s_%gum_%s_%1.2gV_%gmsec_%gHz.eps', ratname, depth, channel, intensity(i), round(1e3*trains{i}.width), round(trains{i}.rate)));
	
	E(i,1) = mean(sum(abs(y), 2));
	E(i,2) = std(sum(abs(y), 2));
end;
    
%% Traverse up
cd(olddir)

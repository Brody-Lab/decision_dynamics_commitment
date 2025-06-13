
% Usage:
% Beep=Make2Sines( SRate, Attenuation, F1, F2, ToneDuration, Delay, [RiseFall] )

% Create sine tone with frequency f1, delay, and sine tone with freq f2

% 'SRate' is the sample rate in Hz.
% 'Attenuation' is a scalar (0 dB is an amplitude 1 sinusoid.)
% 'F1' and 'F2' in Hz
% 'ToneDuration' and 'Delay' in milliseconds
% A fifth optional parameter 'RiseFall' specifies the 10%-90%
% rise and fall times in milliseconds using a cos^2 edge.



function mega_snd= make_sound(fvector, varargin )

pairs = { ...
    'Attenuation', 10 ; ...
    'ToneDuration', 2 * 1000; ...
    'SRate', 50e6/1024 ; ...
    'RiseFall', 0.005*1000 ; ...
    'offset', 0 * 1000; ... % offset after (k-1)th tone that current tone starts
    };
parse_knownargs(varargin,pairs);


% Create a time vector.
megat = 0:(1/SRate):(ToneDuration/1000);
megat = megat(1:end-1);
mega_snd = zeros(size(megat));

for f = 1:length(fvector)

if ((f-1) * offset) < ToneDuration
    start_time = (f-1)*offset;
    end_time = (ToneDuration - ((f-1)*offset));
    start_idx = max(1,round((f-1) * offset *SRate));
    end_idx = round((length(megat) - start_idx) + 1);
else
    start_time =0;
    end_time = ToneDuration;
    start_idx = 1;
    end_idx = length(mega_snd);
end;

t = start_time:(1/SRate):(end_time/1000);
t = t(1:end-1);    
snd = 10^(-Attenuation/20) * sin( 2*pi*fvector(f)*t );

% SP: Left as is from Make2Sines.m
% If the user specifies, add edge smoothing.
% Edge=MakeEdge( SRate, RiseFall );
% LEdge=length(Edge);
% Put a cos^2 gate on the leading and trailing edges.
% snd(1:LEdge)=snd(1:LEdge) .* fliplr(Edge);
% snd((end-LEdge+1):end)=snd((end-LEdge+1):end) .* Edge;
mega_snd(start_idx:end_idx) = snd + mega_snd(start_idx:end_idx);

end;

%sound(mega_snd, SRate);
% [snd data] = make_pbup_mixed3(R, gamma_dir, gamma_freq, srate, T, varargin)
%
% Makes Poisson bups
% bup events from the left and right speakers are independent Poisson
% events
%
% =======
% inputs:
%
%	R		total rate (in clicks/sec) of bups from both left and right
%	      speakers (r_L + r_R).
%
%	gamma_dir		the natural log ratio of right and left rates: log(r_R/r_L)
%
%   gamma_freq	    the natural log ratio of high and low probabilities: log(p_H/p_L)
%
%	srate	sample rate
%
%	T		total time (in sec) of Poisson bup trains to be generated
%
% =========
% varargin:
%
% bup_width
%			width of a bup in msec  (Default 3)
%
% bup_ramp
%           the duration in msec of the upwards and downwards volume ramps
%           for individual bups. The bup volume ramps up following a cos^2
%           function over this duration and it ramps down in an inverse
%           fashion.
%
% crosstalk_dir
%			between 0 and 1, determines volume of left clicks that are
%			heard in the right channel, and vice versa.
%
% crosstalk_freq
%			between 0 and 1, determines volume of hi clicks that are
%			added to low clicks, and vice versa.
%
% vol_hi
%           volume multiplier for clicks at high frequency
%
% vol_low
%           volume multiplier for clicks at low frequency
%
% ========
% outputs:
%
% snd		a vector representing the sound generated

% data		a struct containing the actual bup times (in sec, centered in
%			middle of every bup) in snd.
%			data.left and data.right
%

function [snd data] = make_pbup_mixed3(R, gamma_dir, gamma_freq, srate, T, varargin)

pairs = {...
    'bup_width',        5; ...
    'bup_ramp',         2; ...
    'crosstalk_dir'         0; ...
    'crosstalk_freq'         0; ...
    'freq_vec', [6500 14200]; ...
    'vol_low', 1; ...
    'vol_hi', 1; ...
    }; parseargs(varargin, pairs);


% rates of Poisson events on left and right
rrate = R/(exp(-gamma_dir)+1);
lrate = R - rrate;



% rates of Poisson events on left and right
hirate = R/(exp(-gamma_freq)+1);
lorate = R - hirate;



frac_hi=hirate./(hirate+lorate);
frac_lo=1-frac_hi;


rhirate=rrate*frac_hi;
rlorate=rrate*frac_lo;


lhirate=lrate*frac_hi;
llorate=lrate*frac_lo;




%t = linspace(0, T, srate*T);
lT = srate*T; %the length of what previously was the t vector

% times of the bups are Poisson events
tp_rhi = find(rand(1,lT) < rhirate/srate);
tp_rlo = find(rand(1,lT) < rlorate/srate);

tp_lhi = find(rand(1,lT) < lhirate/srate);
tp_llo = find(rand(1,lT) < llorate/srate);


data.right_hi = tp_rhi/srate;
data.right_lo = tp_rlo/srate;
data.left_hi  = tp_lhi/srate;
data.left_lo  = tp_llo/srate;





buph = singlebup_old(srate, 0, 'ntones', 1, 'width', bup_width, 'basefreq', max(freq_vec), 'ramp', bup_ramp);
bupl = singlebup_old(srate, 0, 'ntones', 1, 'width', bup_width, 'basefreq', min(freq_vec), 'ramp', bup_ramp);


if(length(buph)/2==round(length(buph)/2))
    buph=[buph 0];
end
if(length(bupl)/2==round(length(bupl)/2))
    bupl=[bupl 0];
end

buph=buph*vol_hi;
bupl=bupl*vol_low;






if  crosstalk_freq > 0, % implement crosstalk_freq
    
    temp_buph = buph + crosstalk_freq*bupl;
    temp_bupl = bupl + crosstalk_freq*buph;
    
    buph=temp_buph/(1+crosstalk_freq);
    bupl=temp_bupl/(1+crosstalk_freq);

end;








w = floor(length(buph)/2);

snd = zeros(2, lT);


for i = 1:length(tp_rhi), % place hi-freq right bups
    bup=buph;
    if tp_rhi(i) > w && tp_rhi(i) < lT-w,
        snd(2,tp_rhi(i)-w:tp_rhi(i)+w) = snd(2,tp_rhi(i)-w:tp_rhi(i)+w)+bup;
    end;
end;

for i = 1:length(tp_rlo), % place lo-freq right bups
    bup=bupl;
    if tp_rlo(i) > w && tp_rlo(i) < lT-w,
        snd(2,tp_rlo(i)-w:tp_rlo(i)+w) = snd(2,tp_rlo(i)-w:tp_rlo(i)+w)+bup;
    end;
end;

for i = 1:length(tp_lhi), % place hi-freq left bups
    bup=buph;
    if tp_lhi(i) > w && tp_lhi(i) < lT-w,
        snd(1,tp_lhi(i)-w:tp_lhi(i)+w) = snd(1,tp_lhi(i)-w:tp_lhi(i)+w)+bup;
    end;
end;

for i = 1:length(tp_llo), % place lo-freq left bups
    bup=bupl;
    if tp_llo(i) > w && tp_llo(i) < lT-w,
        snd(1,tp_llo(i)-w:tp_llo(i)+w) = snd(1,tp_llo(i)-w:tp_llo(i)+w)+bup;
    end;
end;




if  crosstalk_dir > 0, % implement crosstalk_dir
    temp_snd(1,:) = snd(1,:) + crosstalk_dir*snd(2,:);
    temp_snd(2,:) = snd(2,:) + crosstalk_dir*snd(1,:);

    % normalize the sound so that the volume (summed across both
    % speakers) is the same as the original snd before crosstalk
    ftemp_snd = fft(temp_snd,2);
    fsnd      = fft(snd,2);
    Ptemp_snd = ftemp_snd .* conj(ftemp_snd);
    Psnd      = fsnd .* conj(fsnd);
    vol_scaling = sqrt(sum(Psnd(:))/sum(Ptemp_snd(:)));

    snd = real(ifft(ftemp_snd * vol_scaling));
end;

snd(snd>1) = 1;
snd(snd<-1) = -1;



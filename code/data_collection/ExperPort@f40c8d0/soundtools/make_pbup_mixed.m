% [snd data] = make_pbup_mixed(R, gamma_dir, gamma_freq, srate, T, varargin)
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
% crosstalk
%			between 0 and 1, determines volume of left clicks that are
%			heard in the right channel, and vice versa.
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

function [snd data] = make_pbup_mixed(R, gamma_dir, gamma_freq, srate, T, varargin)

pairs = {...
    'bup_width',        5; ...
    'bup_ramp',         2; ...
    'crosstalk'         0; ...
    'freq_vec', [6500 14200]; ...
    'vol_low', 1; ...
    'vol_hi', 1; ...
    }; parseargs(varargin, pairs);


% rates of Poisson events on left and right
rrate = R/(exp(-gamma_dir)+1);
lrate = R - rrate;



% fraction of clicks with high and low frequency
frac_hi =exp(gamma_freq/2);
frac_lo =exp(-gamma_freq/2);
frac_hi=frac_hi./(frac_hi+frac_lo);




%t = linspace(0, T, srate*T);
lT = srate*T; %the length of what previously was the t vector


% times of the bups are Poisson events
if ~isnan(lrate); tp1 = find(rand(1,lT) < lrate/srate); else tp1 = []; end
if ~isnan(rrate); tp2 = find(rand(1,lT) < rrate/srate); else tp2 = []; end

data.left  = tp1/srate;
data.right = tp2/srate;


%%% if there are more clicks for the low gamma, inverts labels
val1=length(tp1);
val2=length(tp2);
if((gamma_dir>0 && val2<val1) || (gamma_dir<0 && val2>val1))
    temp=tp1;
    tp1=tp2;
    tp2=temp;
end



%%% divide the pooled left and right bups into hi and lo frequency
ind1=1:length(tp1);
ind2=-(1:length(tp2));
vec=[ind1 ind2];
vec=vec(randperm(length(vec)));
num=round(frac_hi*length(vec));

ind_hi=vec(1:num);
ind_lo=vec(num+1:end);

ind1h=sort(ind_hi(ind_hi>0));
tp1h=tp1(ind1h);
ind1l=sort(ind_lo(ind_lo>0));
tp1l=tp1(ind1l);

ind2h=-sort(ind_hi(ind_hi<0));
tp2h=tp2(ind2h);
ind2l=-sort(ind_lo(ind_lo<0));
tp2l=tp2(ind2l);



%%% if there are more clicks for the frequency with low gamma, inverts labels
val1=length(tp1h)+length(tp2h);
val2=length(tp1l)+length(tp2l);
if((gamma_freq>0 && val2>val1) || (gamma_freq<0 && val2<val1))
    temp=tp1h;
    tp1h=tp1l;
    tp1l=temp;
    temp=tp2h;
    tp2h=tp2l;
    tp2l=temp;
end


data.left_hi  = tp1h/srate;
data.left_lo  = tp1l/srate;
data.right_hi = tp2h/srate;
data.right_lo = tp2l/srate;



buph = singlebup(srate, 0, 'ntones', 1, 'width', bup_width, 'basefreq', max(freq_vec), 'ramp', bup_ramp);
bupl = singlebup(srate, 0, 'ntones', 1, 'width', bup_width, 'basefreq', min(freq_vec), 'ramp', bup_ramp);


if(length(buph)/2==round(length(buph)/2))
    buph=[buph 0];
end
if(length(bupl)/2==round(length(bupl)/2))
    bupl=[bupl 0];
end

buph=buph*vol_hi;
bupl=bupl*vol_low;


w = floor(length(buph)/2);

snd = zeros(2, lT);


for i = 1:length(tp1h), % place hi-freq left bups
    bup=buph;
    if tp1h(i) > w && tp1h(i) < lT-w,

        snd(1,tp1h(i)-w:tp1h(i)+w) = snd(1,tp1h(i)-w:tp1h(i)+w)+bup;
    end;
end;

for i = 1:length(tp1l), % place lo-freq left bups
    bup=bupl;
    if tp1l(i) > w && tp1l(i) < lT-w,
        snd(1,tp1l(i)-w:tp1l(i)+w) = snd(1,tp1l(i)-w:tp1l(i)+w)+bup;
    end;
end;


for i = 1:length(tp2h), % place hi-freq right bups
    bup=buph;
    if tp2h(i) > w && tp2h(i) < lT-w,
        snd(2,tp2h(i)-w:tp2h(i)+w) = snd(2,tp2h(i)-w:tp2h(i)+w)+bup;
    end;
end;

for i = 1:length(tp2l), % place lo-freq right bups
    bup=bupl;
    if tp2l(i) > w && tp2l(i) < lT-w,
        snd(2,tp2l(i)-w:tp2l(i)+w) = snd(2,tp2l(i)-w:tp2l(i)+w)+bup;
    end;
end;


if  crosstalk > 0, % implement crosstalk
    temp_snd(1,:) = snd(1,:) + crosstalk*snd(2,:);
    temp_snd(2,:) = snd(2,:) + crosstalk*snd(1,:);

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



function [snd,data] = make_time_train(tot_rate,alpha,srate,T,varargin)
% =======
% inputs:
%
%	tot_rate		
%           total rate (in clicks/sec) of bups 
%	alpha		
%           the shape param of the gamma distribution. alpha = 1 is the
%           special case of an exponential distribution, equivalent to the
%           PBups distribution of ICIs.
%	srate	
%           sample rate of sounds
%	T		
%           total time (in sec) of bup trains to be generated
%
% =========
% varargin:
%
% bup_width
%			width of a bup in sec  (Default .003)
% base_freq       
%           base frequency of an individual bup, in Hz. The individual bup
%           consists of this in combination with ntones-1 octaves above the
%           base frequency. (Default 2000)
% 
% ntones
%           number of tones comprising each individual bup. The bup is the
%           basefreq combined with ntones-1 higher octaves. (Default 5)
% 
% bup_ramp        
%           the duration in msec of the upwards and downwards volume ramps
%           for individual bups. The bup volume ramps up following a cos^2
%           function over this duration and it ramps down in an inverse
%           fashion.
% min_ISI
%           imposes an additional minimum ISI (in s) between bup times. 
%           This is implemented by adding this time to the bup_width as 
%           
% avoid_collisions
%           imposes a minimum ISI just big enough so that bups can't interfere.
%           implemented by filtering out ICIs smaller than a bup_width.
%
% force_fixed
%           if flag is on, make the ICIs explicitly the same
%
    %% parse and validate args
    pairs = {...
        'bup_width',        0.003; ...
        'base_freq',        2000; ...
        'n_tones',           5; ...
        'bup_ramp',         2; ...
        'avoid_collisions'  1; ...
        'min_ISI',          0; ...
        'force_fixed'       0; ...
        }; parseargs(varargin, pairs);
    if tot_rate > 1
        tot_rate = 1/tot_rate;
    end
    if bup_width > 1
        bup_width = bup_width/1000;
    end
    beta = tot_rate/alpha;

    bup = singlebup(srate, 0,'ntones', n_tones, 'width', bup_width*1000, 'basefreq', base_freq(1), 'ramp', bup_ramp);
    
    % Makes extra samples--there's no reason there can't be more than the mean rate
    % ICIs are in seconds now
    if force_fixed == 1
        ICIs = ones(1, round(T/tot_rate)*2)*tot_rate;
    else
        ICIs = gamrnd(alpha,beta,[1 round(T/tot_rate) * 2]); 
        if avoid_collisions == 1
            ICIs = ICIs(ICIs > bup_width+min_ISI);
        end
    end
    % now, transform the sampled ICIs, and add a click ind to the front. 
    ici_inds = [0 cumsum(ICIs(cumsum(ICIs)<T-bup_width)) * srate]+1;
    
    snd = zeros(1,round(T *srate));
    for i =1:length(ici_inds)
        cur_ind = round(ici_inds(i));
        snd(cur_ind:cur_ind+length(bup)-1) = bup;
    end
    snd = [snd;snd]; % make the sound stereo

    data.alpha = alpha;
    data.tot_rate = tot_rate;
    data.beta = beta;
    data.ICIs = abs(diff(ici_inds/srate));
    data.n_bups = length(ici_inds);
    
end

function [snd,lrate,rrate,data] = make_pbup_dev_adrian(total_rate, gamma, srate, T, varargin)
%
% Makes Poisson bups
% bup events from the left and right speakers are independent Poisson
% events
%
% (N.B. from AGB 2017: Although technically since we're dealing with discrete time the buptimes are
% realizations of a Bernoulli process, i.e. a series of Bernoulli trials whose success probability 
% is analogous to the Poisson rate paramter.)
%
%
% =======
% inputs:
%
%	total_rate		total rate (in clicks/sec) of bups from both left and right
%	      speakers (r_L + r_R). Note that if distractor_rate > 0, then total_rate
%	      includes these stereo distractor bups as well.
%
%	gamma		the natural log ratio of right and left rates: log(r_R/r_L)
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
% 
% first_bup_stereo
%			if 1, then the first bup to occur is forced to be stereo
%
% distractor_rate
%			if >0, then this is the rate of stereo distractors (bups that
%			are played on both speakers).  These stereo bups are generated
%			as Poisson events and then combined with those generated for
%			left and right sides.
%			note that this value affects the total_rate used to compute independent
%			Poisson rates for left and right sides, such that
%			total_rate = total_rate - 2*distractor_rate
%
% generate_sound
%			if 1, then generate the snd vector
%			if 0, the snd vector will be empty; data will still contain the
%			bups times
%
% fixed_sound
%			if [], then generate new pbups sound
%			if not empty, then should contain a struct D with fields:
%				D.left  = [left bup times]
%				D.right = [right bup times]
%				D.lrate
%				D.rrate
%			these two vectors should be at least as long as T, so there's
%			no gap in the sound that's generated
%
% crosstalk
%			[left_crosstalk right_crosstalk]
%			between 0 and 1, determines volume of left clicks that are
%			heard in the right channel, and vice versa.
%			if only number is provided, the crosstalk is assumed to be
%			symmetric (i.e., left_crosstalk = right_crosstalk)
%
%
% min_ISI
%           imposes a minimum ISI (in ms) between bup times. This is implemented by
%           increasing the interval between the Bernoulli trials.
%           AGB 2017.
%
% avoid_collisions
%           imposes a minimum ISI just big enough so that bups can't interfere.
%           Chuck 2010-10-05. Significantly rewritten by AGB 2017.
%
% force_count
%           produces a pseudo-poisson click train where the precise number 
%           of clicks is predetermined. The rate variables are interpreted 
%           as counts.  
%           added: Chuck 2010-10-05
%
% seed
%           user defined noise seed (output will be deterministic if you
%           supply this)
%
% task_type
%           default is 1 (classic) where clicks are played from either side
%           speaker. Specifing 0 will cause all the clicks to be 
%           played in stereo with the "left" clicks using the first entry
%           in the base_freq vector and the "right" clicks suing the
%           second. This is the frequency version of the task.
%           added: Chuck 2018-05-16
%
% ========
% outputs:
%
% snd		a vector representing the sound generated
%
% lrate		rate of Poisson events generated only on the left
%
% rrate		rate of Poisson events generated only on the right
%
% data		a struct containing the following fields:

% 'left' and 'right' : the actual bup times (in sec, centered in middle of every bup) 
% 'snd' : the sound itself, with bups placed at the times in 'left' and
%           'right'. The length of sound is the number of discrete time samples that most
%           closely approximates the stimulus duration specified in T.
% 'firstLastPossibleTime' : a 2-element vector giving the time, in seconds,
%           when the first and last bup could have occurred, giving the limitations
%           imposed by the bup width (bups can't be so close to the edge they can't
%           play in their entirety) and the sampling frequency. This allows you to
%           avoid the (slightly) incorrect assumption that the bup times
%           could have occurred uniformly on [0,T].
% 'min_ISI' : the min_ISI in ms set by the user (0 by default)
% 'real_min_ISI' : the actual min ISI used (an integer multiple of the
%           sampling period), in sec
% 'n_bup_can_fit' : the length of the Bernoulli process, i.e. the number of
%           discrete bins in which bups can occur.
% 'real_T' : the difference between the times in 'firstLastPossibleTime'
% 'bup_width' : the bup_width set by the user in ms
% 'base_freq' : the base frequency of the bups set by the user in Hz
% 'bup_ramp'  : the length of the one-sided envelope applied to each side
%           of the bup
% 'first_bup_stereo' : whether or not user set the first bup to be a stereo
%           bup, false by default. Note the bug in the implementation of
%           this, that has been maintained for consistency with old code.
% 'fixed_sound' : whether or not a series of buptimes was supplied by the
%           user directly
% 'force_count' : whether the lrate and rrate should be interpreted as
%           counts instead of the success probability of the Bernoulli process.
% 'crosstalk' : the value of crosstalk specified by the user  ([0 0] by
%           default)

% N.B.:
% significantly modified by Adrian Bondy (2017) to fix bugs, add features,
% and improve documentation. Significant changes are:
%   1) correct reporting of removal of bups that are too near the beginning
%   or end of the stimulus to play
%   2) correctly defining this exclusion period (was too conservative by
%   one sample before)
%   3) properly implementing the avoid_collisions option
%   4) output includes more information, including the real stimulus
%   duration (an integer multiple of the sampling period) in field
%   'firstLastPossibleTime'
%   5) documentation of bug when first_bup_stereo is true. This bug is
%   preserved for consistency with old code behavior.
%   6) added flag 'min_ISI' which lets the user set the minimum inter-bup
%   interval allowed (on each side separately). This is an extension of
%   "avoid_collisions" which requires a minimum ISI of one bup width
%   exactly. To understand how both of these are implemented, it is worth
%   noting that the buptimes are not, as we usually say, Poisson processes,
%   but rather Bernoulli processes (the discrete analog). A Bernoulli
%   process consists of a series of coin flips with probability p. Without
%   a minimum ISI, the buptimes are a realization of such a process with a
%   coin flip performed at each time sample (the rigs sample at 200kHz).
%   With a minimum ISI imposed, a coin flip is performed at time steps
%   separated by the minimum ISI (or to be more precise, the nearest
%   multiple of the sampling period).

    %% parse and validate args
    pairs = {...
        'bup_width',        3; ...
        'base_freq',        2000; ...
        'ntones',           5; ...
        'bup_ramp',         2; ...
        'first_bup_stereo'  0; ...
        'distractor_rate'   0; ...
        'generate_sound'    1; ...
        'fixed_sound'      []; ...
        'crosstalk'     [0 0]; ...
        'avoid_collisions'  0; ...
        'force_count'       0; ...
        'min_ISI',          0; ...
        'seed',            []; ... % generates a random noise seed up to 10^6 using the current time as a default
        'task_type',        1; ...
        }; parseargs(varargin, pairs);

    if isempty(crosstalk), crosstalk = [0 0]; end %#ok<NODEF>
    if numel(crosstalk) < 2, crosstalk = crosstalk*[1 1]; end
    if isnan(gamma)
        error('Gamma cannot be NaN.');
    end
    if isnan(total_rate)
        error('total rate cannot be NaN.');
    end

    %% make a single bup so I know exactly how many samples it takes up
    if task_type == 0 && numel(base_freq) > 1
        %bups that favor responding  left will use the first value in the
        %base_freq vector and those that favor responding right will use
        %the second value
        bupl = singlebup(srate, 0,'ntones', ntones, 'width', bup_width, 'basefreq', base_freq(1), 'ramp', bup_ramp);
        bupr = singlebup(srate, 0,'ntones', ntones, 'width', bup_width, 'basefreq', base_freq(2), 'ramp', bup_ramp);
        bup  = bupl;
        doing_frequency_version = 1;
    else
        bup = singlebup(srate, 0,'ntones', ntones, 'width', bup_width, 'basefreq', base_freq(1), 'ramp', bup_ramp);
        doing_frequency_version = 0;
    end
    if task_type == 0 && numel(base_freq) == 1
        disp('Warning: To use Frequency version of click task the base_freq must contain 2 values');
    end

    %% figure out some statistics
    n_bup_samples = length(bup);
    real_bup_width = n_bup_samples/srate;    
    w=floor(n_bup_samples/2);  
    real_min_ISI=round(min_ISI*srate/1000)./srate;
    if avoid_collisions == 1
        real_min_ISI = max(real_bup_width,real_min_ISI);
    elseif real_min_ISI<1./srate
        real_min_ISI = 1./srate;
    end        
    
    real_T = round(T*srate)./srate; % time in seconds of the entire sound
    
    if real_min_ISI<real_bup_width
        n_bup_can_fit = floor((real_T-(real_bup_width-real_min_ISI))./real_min_ISI); % bups extend beyond their bins, we need to allocate extra room at the ends
    else
        n_bup_can_fit = floor(real_T./real_min_ISI); % the case where we don't have to worry about bups extending beyond their bins    
    end
    
    % make left and right rates    
    lrate = total_rate ./ ( exp(gamma) + 1 ); % doing the calculation for the left rate first avoids numerical underflow for high values of gamma (i.e. so that lrate doesn't end up being exactly 0) - AGB 2017
    rrate = total_rate - lrate;    
        
    %% make bup times
    if isempty(fixed_sound)
        % set seed
        if ~isempty(seed)
            try
                RandStream.setDefaultStream(RandStream('mt19937ar','Seed',seed))            
            catch
                rng(seed,'twister');
            end
        end
        %
        if distractor_rate > 0
            total_rate = total_rate - distractor_rate*2;
        end
        
        if lrate*real_min_ISI>1
            error('Left rate of %g Hz cannot be realized with a minimum ISI of %1g ms.',lrate,real_min_ISI*1000);
        end
        if rrate*real_min_ISI>1
            error('Right rate of %g Hz cannot be realized with a minimum ISI of %1g ms.',rrate,real_min_ISI*1000);
        end        
        
        
        % 
        if force_count == 1
            %rates are interpreted as counts and therefore must be integers
            rrate = round(rrate);
            lrate = round(lrate);
            temp = randperm(n_bup_can_fit); tp1 = temp(1:lrate); tp1 = sortrows(tp1')'; 
            temp = randperm(n_bup_can_fit); tp2 = temp(1:rrate); tp2 = sortrows(tp2')';  
        else
            % note that this way of "avoiding collisions" involves only allowing a discrete set of times, one bupwidth apart, when a click can occur.
            % You could take other approaches, like sampling from a modified
            % Poisson process with a refractory period
            tp1 = find(rand(1,n_bup_can_fit) < lrate*real_min_ISI);
            tp2 = find(rand(1,n_bup_can_fit) < rrate*real_min_ISI);                 
        end
        
            
        %% first bup stereo %%
        % 
        % in order not to alter the difference in bup numbers between left and
        % right, the extra stereo bup is placed randomly somewhere between 0 and
        % the earliest bup on either side. 
        % AGB 2017: ***the above, original logic is not true, see note below **    
        if first_bup_stereo
            first_bup = min([tp1 tp2]);
            %% AGB
            % this next line is a bug, bup_width is interpreted as being in seconds, 
            % but it is actually in ms!
            % As a result of the above bug, the first way of making a
            % stereo bup is essentially always chosen, independent of the
            % timing of the bups. "Fixing" this now would result in a significant
            % change from legacy behavior so I have left it as is. Always
            % using the first way of making a bup is....fine, I think. (?)
            bupwidth = bup_width*srate/2;  % should  : bupwidth = bup_width*srate./1000./2
            %%
            if first_bup <= bupwidth % first way of making a stereo bup
                extra_bup = first_bup;
            else % second way of making a stereo bup
                extra_bup = ceil(rand(1)*(first_bup-bupwidth) + bupwidth); 
            end
            tp1 = union(extra_bup, tp1);
            tp2 = union(extra_bup, tp2);
        end

        if distractor_rate*real_min_ISI>1
            error('Distractor rate of %g Hz cannot be realized with a minimum ISI of %1g ms.',distractor_rate,real_min_ISI*1000);
        elseif distractor_rate > 0
            if force_count == 1
                temp = randperm(n_bup_can_fit); td = temp(1:round(distractor_rate)); td = sortrows(td')'; 
            else
                td  = find(rand(1,n_bup_can_fit) < distractor_rate*real_min_ISI);
            end
            tp1 = union(td, tp1);
            tp2 = union(td, tp2);
        end
        %%
        % before this line, tp1 and tp2 are the inds of the possible
        % intervals. after this its inds in terms of sound samples
        tp1 = tp1 * round(srate*real_min_ISI); % round is only here to prevent weird floating point errors. srate*real_min_ISI should always be an integer to within machine precision.
        tp2 = tp2 * round(srate*real_min_ISI); 
        
 
        % now shift times to the center of the sound
        times_range = (n_bup_can_fit-1)*real_min_ISI;
        offset = floor(srate*((real_T-times_range)/2)-10^-10); % the -10^10 is there because I want the following behavior: floor(X) if X is not an integer, and X-1 otherwise
        tp1 = tp1 + offset - (real_min_ISI )*srate+1;
        tp2 = tp2 + offset - (real_min_ISI )*srate+1;  
        firstLastPossibleTime = [1 n_bup_can_fit]*real_min_ISI + offset/srate - real_min_ISI +1./srate;
        
        if firstLastPossibleTime(1)*srate<w
              error('Something has gone wrong. If we''ve correctly determined n_bup_can_fit and offset the times correctly, we shouldn''t hit this line ever.');
        end
        
    else  % if we've provided bupstimes for which a sound will be made     
        if isfield(fixed_sound,'lrate')
            lrate = fixed_sound.lrate;
        else
            lrate=NaN;
        end
        if isfield(fixed_sound,'rrate')
            rrate = fixed_sound.rrate;
        else
            rrate=NaN;
        end
        tp1 = round(sort(fixed_sound.left)*srate);
        tp2 = round(sort(fixed_sound.right)*srate);
        if any(tp1>n_bup_can_fit-w+1) || any(tp2>n_bup_can_fit-w+1) || any(tp1<w) || any(tp2<w)
            warning('user provided a fixed sound which includes bups that cannot be played in the given stimulus duration.');
        end
        if any(diff(tp1)<real_bup_width) || any(diff(tp2)<real_bup_width)
            warning('Some of your user defined bups will collide.');
        end
        firstLastPossibleTime=NaN; % could define this more rigorously but it probably would never be used
    end

    %% generate sound waveform
    if generate_sound
        snd = zeros(2, round(real_T*srate) );
        if doing_frequency_version == 0
            for i = 1:length(tp1) % place left bups
                if tp1(i)>w && tp1(i)+w<=size(snd,2)
                    snd(1,tp1(i)-w:tp1(i)+w) = snd(1,tp1(i)-w:tp1(i)+w)+bup;
                end
            end
            for i = 1:length(tp2) % place right bups
                if tp2(i)>w && tp2(i)+w<=size(snd,2)            
                    snd(2,tp2(i)-w:tp2(i)+w) = snd(2,tp2(i)-w:tp2(i)+w)+bup;
                end
            end

            if sum(crosstalk) > 0 % implement crosstalk
                temp_snd(1,:) = snd(1,:) + crosstalk(2)*snd(2,:);
                temp_snd(2,:) = snd(2,:) + crosstalk(1)*snd(1,:);

                % normalize the sound so that the volume (summed across both
                % speakers) is the same as the original snd before crosstalk
                ftemp_snd = fft(temp_snd,2);
                fsnd      = fft(snd,2);
                Ptemp_snd = ftemp_snd .* conj(ftemp_snd);
                Psnd      = fsnd .* conj(fsnd);
                vol_scaling = sqrt(sum(Psnd(:))/sum(Ptemp_snd(:)));

                snd = real(ifft(ftemp_snd * vol_scaling));
            end
        else
            for i = 1:length(tp1) % place left bups
                if tp1(i)>w && tp1(i)+w<=size(snd,2)
                    snd(1,tp1(i)-w:tp1(i)+w) = snd(1,tp1(i)-w:tp1(i)+w)+bupl;
                end
            end
            for i = 1:length(tp2) % place right bups
                if tp2(i)>w && tp2(i)+w<=size(snd,2)            
                    snd(1,tp2(i)-w:tp2(i)+w) = snd(1,tp2(i)-w:tp2(i)+w)+bupr;
                end
            end
            snd(2,:) = snd(1,:);
        end
        snd(snd>1) = 1;
        snd(snd<-1) = -1;
    else
        snd = [];
    end

    if ~isempty(seed)
        % shuffle seed up to max allowed, using the current time. This is
        % required to make things non-deterministic after fixing the seed.
        seed0 = mod(floor(now*8640000),2^32-1); 
        for i = 1:100
            clockSeed = mod(floor(now*8640000),2^32-1);
            if clockSeed ~= seed0, break; end
            pause(.01); % smallest recommended interval
        end
        try
            RandStream.setDefaultStream(RandStream('mt19937ar','Seed',clockSeed)); % old matlab            
        catch
            rng('shuffle','twister'); % new matlab
        end    
    end
    
    if ~isempty(fixed_sound)
        data = struct('left',tp1/srate,'right',tp2/srate,'firstLastPossibleTime',firstLastPossibleTime,'n_bup_samples',NaN,...
            'real_bup_width',real_bup_width,'min_ISI',NaN,'real_min_ISI',NaN,'n_bup_can_fit',n_bup_can_fit,'real_T',real_T,...
            'bup_width',bup_width,'base_freq',base_freq,'bup_ramp',bup_ramp,'first_bup_stereo',first_bup_stereo,'fixed_sound',fixed_sound,...
            'distractor_rate',NaN,'generate_sound',generate_sound,'crosstalk',crosstalk,'avoid_collisions',NaN,...
            'force_count',NaN,'seed',NaN);        
    else
        data = struct('left',tp1/srate,'right',tp2/srate,'firstLastPossibleTime',firstLastPossibleTime,'n_bup_samples',n_bup_samples,...
            'real_bup_width',real_bup_width,'min_ISI',min_ISI,'real_min_ISI',real_min_ISI,'n_bup_can_fit',n_bup_can_fit,'real_T',real_T,...
            'bup_width',bup_width,'base_freq',base_freq,'bup_ramp',bup_ramp,'first_bup_stereo',first_bup_stereo,'fixed_sound',fixed_sound,...
            'distractor_rate',distractor_rate,'generate_sound',generate_sound,'crosstalk',crosstalk,'avoid_collisions',avoid_collisions,...
            'force_count',force_count,'seed',seed);
    end
    
end


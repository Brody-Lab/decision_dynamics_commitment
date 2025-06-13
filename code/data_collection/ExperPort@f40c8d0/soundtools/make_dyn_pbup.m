% [snd lrate rrate data genState corResp] = make_dyn_pbup(R, g, srate, T,Tb, h,ES, varargin)
% Alex Piet, Ahmed El Hady, August 2015.
% This function takes a vector of generative states and makes a pbups based on their dynamic gammas. It also returns the choice of the optimal accumulator. 
%
% Makes Poisson bups
% bup events from the left and right speakers are independent Poisson
% events
%
% =======
% inputs:
%
%	R		total rate (in clicks/sec) of bups from both left and right
%           speakers (r_L + r_R). Note that if distractor_rate > 0, then R
%           includes these stereo distractor bups as well.
%
%	g		the natural log ratio of right and left rates: log(r_R/r_L).
%           Must be positive. As click rates switch, there is no concept of left
%           and right rates
%
%	srate	sample rate
%
%	T		total time (in sec) of Poisson bup trains to be generated
% 
%   Tb      Hazard Barrier. time (in sec) from end of the trial in which
%           generative state flips are not allowed. 
%   
%   h       Hazard rate (in Hz)
% 
%   ES      Generative End State (0 = 'left' or 1 = 'right)
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
%           fashion. (Default ??)
% 
% first_bup_stereo
%			if 1, then the first bup to occur is forced to be stereo
%			(Default ??)
%
% distractor_rate
%			if >0, then this is the rate of stereo distractors (bups that
%			are played on both speakers).  These stereo bups are generated
%			as Poisson events and then combined with those generated for
%			left and right sides.
%			note that this value affects the R used to compute independent
%			Poisson rates for left and right sides, such that
%			R = R - 2*distractor_rate (Default ??)
%
% generate_sound
%			if 1, then generate the snd vector
%			if 0, the snd vector will be empty; data will still contain the
%			bups times (Default ??)
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
% avoid_collisions
%           produces a pseudo-poisson clicks train where no clicks are
%           allowed to overlap.  If the click rate is so high that
%           collisions are unavoidable a warning will be displayed
%           added: Chuck 2010-10-05
%
% force_count
%           produces a pseudo-poisson click train where the precise number 
%           of clicks is predetermined. The rate variables are interpreted 
%           as counts.  
%           added: Chuck 2010-10-05
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
% data		a struct containing the actual bup times (in sec, centered in
%			middle of every bup) in snd.
%			data.left and data.right
%
% genState  a vector representing the generative state history. (1 = right,
%           0 = left)
% 
% corResp   a vector representing the correct response based on optimal
%           integration. (1 = right, 0  = left)
% 

function [snd lrate rrate data genSwitchTimes genState corResp R] = make_dyn_pbup(R, g, srate, T,Tb,h, ES, varargin)

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
    }; parseargs(varargin, pairs);

if isempty(crosstalk), crosstalk = [0 0]; end; %#ok<NODEF>
if numel(crosstalk) < 2, crosstalk = crosstalk*[1 1]; end;

% CHECK FOR NEGATIVE GAMMA. Dynamic clicks does not accept negative gammas
if g < 0; 
    disp('WARNING, GAMMA WAS NEGATIVE. IN THE FUTURE THIS WILL THROW AN ERROR');
    g = -g; 
end;

% CHECK FOR NEGATIVE HAZARD RATE. Negative hazard rates do not make sense
if isnan(h); error('BAD hazard rate'); end;
if h <= 0; 
    h = eps; 
end;

if T < 0 
    error('Time cannot be negative');
end
if Tb < 0
    disp('WARNING, Hazard Barrier cannot be negative. Forcing to zero');
    disp(Tb)
    Tb = 0;
end
if Tb > T
    Tb = T;
    disp('WARNING, Hazard Barrier was greater than trial duration, shortening to trial duration');
end

% CHECK FOR WEIRD END STATE
if ~( ES == 0 || ES == 1)
    error('No end generative state specified');
end

if isempty(fixed_sound),
	if distractor_rate > 0,
		R = R - distractor_rate*2;
	end;

	% rates of Poisson events on left and right
	rrate = R/(exp(-g)+1);
	lrate = R - rrate;
    if force_count == 1
        %rates are interpreted as counts and therefore must be integers
        rrate = round(rrate);
        lrate = round(lrate);
    end

	%t = linspace(0, T, srate*T);
    lT = round(srate*T); %the length of what previously was the t vector
    lTb = round(srate*Tb); % the length of the no transitions period
    hazbar_dex = round(lT - lTb);
    if hazbar_dex < 1; hazbar_dex = 1; end;
    if hazbar_dex > lT; hazbar_dex = lT; end;
    
    if avoid_collisions == 1
        disp('WARNING: avoid collisions functionality not implemented with Dynamic Clicks');
        lT2 = ceil(T * 1e3 / bup_width);
        if force_count == 1
            if ~isnan(lrate); temp = randperm(lT2); tp1 = temp(1:lrate); tp1 = sortrows(tp1')'; else tp1 = []; end
            if ~isnan(rrate); temp = randperm(lT2); tp2 = temp(1:rrate); tp2 = sortrows(tp2')'; else tp2 = []; end
        else
            if ~isnan(lrate); tp1 = find(rand(1,lT2) < lrate/(1e3/bup_width)); else tp1 = []; end
            if ~isnan(rrate); tp2 = find(rand(1,lT2) < rrate/(1e3/bup_width)); else tp2 = []; end
        end
        
        if first_bup_stereo,
            first_bup = min([tp1 tp2]);
            bupwidth = 1;
            if first_bup <= bupwidth, extra_bup = first_bup;
            else                      extra_bup = ceil(rand(1)*(first_bup-bupwidth));
            end;
            tp1 = union(extra_bup, tp1);
            tp2 = union(extra_bup, tp2);
        end
        
        if distractor_rate > 0,
            if force_count == 1
                temp = randperm(lT2); td = temp(1:round(distractor_rate)); td = sortrows(td')'; 
            else
                td  = find(rand(1,lT2) < distractor_rate/(1e3/bup_width));
            end
            tp1 = union(td, tp1);
            tp2 = union(td, tp2);
        end
        if (lrate + distractor_rate) * bup_width > 200 || (rrate + distractor_rate) * bup_width > 200
            disp('Warning: Click rate is set to high to ensure Poisson train with avoid_collisions on');
        end
        
        tp1 = tp1 * (srate / (1e3 / bup_width));
        tp2 = tp2 * (srate / (1e3 / bup_width));
        
    else
        % times of the bups are Poisson events
        if force_count == 1
            disp('WARNING: force_count functionality not implemented with Dynamic Clicks');
            if ~isnan(lrate); temp = randperm(lT); tp1 = temp(1:lrate); tp1 = sortrows(tp1')'; else tp1 = []; end
            if ~isnan(rrate); temp = randperm(lT); tp2 = temp(1:rrate); tp2 = sortrows(tp2')'; else tp2 = []; end
        else
            % Hazard rate is positive, ES has been checked to be left or
            % right, gamma is positive.
  
            % Make generative state. GenState = 0 == Left. GenState = 1 == Right
            switches =  rand(1,lT)  < h/srate;  % Generate state transitions
            switches(hazbar_dex:end) = 0;% MUTE ALL TRANSITIONS AFTER HAZARD BARRIER
            genSwitchTimes = find(switches)./srate; % find switch times
            culm = cumsum(switches);    %find number of switches
            genState = mod(culm, 2);    % compute whether we have flipped back
            %tvec = 1/srate:1/srate:T; %% for debugging, could elimnate
            if ES == 0
               if genState(end)
                    genState = ~genState;
               end
            else %end right
                if ~genState(end)
                   genState = ~genState; 
                end
            end

            % Make state dependent click rates
            if isnan(lrate); lrate = eps; end;
            if isnan(rrate); rrate = eps; end;
            STATElrate(logical(genState)) = lrate;
            STATErrate(logical(genState)) = rrate;
            STATElrate(~logical(genState)) = rrate;
            STATErrate(~logical(genState)) = lrate;
            
            % make clicks
            if ~isnan(lrate);
                L_clicks = rand(1,lT) < STATElrate/srate;
                tp1 = find(L_clicks); 
            else
                % Should never execute
                L_clicks = zeros(1,lT);
                tp1 = []; 
            end
            if ~isnan(rrate); 
                R_clicks = rand(1,lT) < STATErrate/srate;
                tp2 = find(R_clicks); 
            else
                % Should never execute
                R_clicks = zeros(1,lT);
                tp2 = [];
            end

        end
        % in order not to alter the difference in bup numbers between left and
        % right, the extra stereo bup is placed randomly somewhere between 0 and
        % the earliest bup on either side. This should be compatable with
        % dynamic pbups.
        if first_bup_stereo,
            first_bup = min([tp1 tp2]);
            bupwidth = bup_width*srate/2;
            if first_bup <= bupwidth,
                extra_bup = first_bup;
            else
                extra_bup = ceil(rand(1)*(first_bup-bupwidth) + bupwidth);
            end;
            tp1 = union(extra_bup, tp1);
            tp2 = union(extra_bup, tp2);
            
            % Updating for dynamic accumulator
            % 11/2017 update. This code used to crash when tp1 and tp2 were empty ( a trial with no clicks). I've updated this to perform a check for this case
            if numel(tp1) > 0
                L_clicks(tp1(1)) = 1;
            end
            if numel(tp2) > 0
                R_clicks(tp2(1)) = 1;
            end
        end;

        if distractor_rate > 0,
            disp('WARNING: Distractor rate functionality not implemented with Dynamic Clicks');
            if force_count == 1
                temp = randperm(lT); td = temp(1:round(distractor_rate)); td = sortrows(td')'; 
            else
                td  = find(rand(1,lT) < distractor_rate/srate);
            end
            tp1 = union(td, tp1);
            tp2 = union(td, tp2);
        end;
    end

	data.left  = tp1/srate;
	data.right = tp2/srate;
else  % if we've provided bupstimes for which a sound will be made
    disp('WARNING: provided bupstimes functionality not implemented with Dynamic Clicks');
	lrate = fixed_sound.lrate;
	rrate = fixed_sound.rrate;
	
	data.left = fixed_sound.left;
	data.right = fixed_sound.right;
	
	tp1 = round(fixed_sound.left*srate);
	tp2 = round(fixed_sound.right*srate);
	%t = linspace(0, T, srate*T);
    lT = srate*T;
end;

% Compute optimal answer
r1 = rrate/srate;
r2 = lrate/srate;
L_clk_prob = ((1-r1)*r2)/((1-r2)*r1);
R_clk_prob = (r1*(1-r2))/(r2*(1-r1));
% ev_prob = 1;
% Think this is the worst way to compute ev_prob? Well, its actually faster
% than a for-loop because matlab is silly. 
ev_prob = L_clicks - R_clicks;
ev_prob(ev_prob == 1) = L_clk_prob;
ev_prob(ev_prob==-1) = R_clk_prob;
ev_prob(ev_prob==0) = 1;
%R = ones(length(genState),1);
R = 1;
h1 = h/srate;
h1m = 1-h1;
for i = 2:length(genState)
    % Compute Evidence for this time step
    %if L_clicks(i) && R_clicks(i)
    %    ev_prob = 1;
    %elseif L_clicks(i)
    %    ev_prob = L_clk_prob;
    %elseif R_clicks(i)
    %    ev_prob = R_clk_prob;
    %else
    %   ev_prob = 1; 
    %end
%     if L_clicks(i) == R_clicks(i)
%         ev_prob = 1;
%     elseif L_clicks(i)
%         ev_prob = L_clk_prob;
%     else
%         ev_prob = R_clk_prob;
%     end
    % Compute overall evidence ratio that discounts old evidence
    %R(i) = ev_prob*(((1-h/srate)*R(i-1)+h/srate)/((h/srate)*R(i-1)+1-h/srate));
    R = ev_prob(i)*((h1m*R+h1)/(h1*R+h1m));
end
% Threshold evidence ratio to make correct choice.
corResp = R > 1; % NON LOG VERSION

if h==0 && ES ~=corResp(end)
    disp('Hazard was zero, yet generative state and correct response differ') 
end

if generate_sound,
    bup = singlebup(srate, 0, 'ntones', ntones, 'width', bup_width, 'basefreq', base_freq, 'ntones', ntones, 'ramp', bup_ramp);
	w = floor(length(bup)/2);

	snd = zeros(2, lT);
    % Update 11/2017 - Alex Piet
    % this function used to have a bug that just didn't place any clicks that happened within "w" of the start or end. I just shifted those clicks to be placed at the very edge. This means that occasionally clicks are played at a time < 1 ms different from what the click is recorded as!
	for i = 1:length(tp1), % place left bups
		if tp1(i) > w && tp1(i) < lT-w,
			snd(1,tp1(i)-w:tp1(i)+w) = snd(1,tp1(i)-w:tp1(i)+w)+bup;
        elseif tp1(i) <= w
 			snd(1,1:2*w+1) = snd(1,1:2*w+1)+bup;     
        elseif tp1(i) >= lT-w
            snd(1,end-2*w:end) = snd(1,end-2*w:end)+bup;
		end;
	end;
	for i = 1:length(tp2), % place right bups
		if tp2(i) > w && tp2(i) < lT-w,
			snd(2,tp2(i)-w:tp2(i)+w) = snd(2,tp2(i)-w:tp2(i)+w)+bup;
        elseif tp2(i) <= w
            snd(2,1:2*w+1) = snd(2,1:2*w+1)+bup;     
        elseif tp2(i) >= lT-w
            snd(2,end-2*w:end) = snd(2,end-2*w:end)+bup;    
		end;
	end;

	if sum(crosstalk) > 0, % implement crosstalk
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
	end;
		
	snd(snd>1) = 1;
	snd(snd<-1) = -1;
else
	snd = [];
end;

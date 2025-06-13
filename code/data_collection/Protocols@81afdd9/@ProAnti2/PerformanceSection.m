

% [varargout] = PerformanceSection(obj, action, x, y)
%
% This section will parse the events from dispatcher and contain all the
% performance variables, display them and also provide them as ro args to
% other
% functions that need performance variables to evaluate if statements for the
% next state matrix.
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      	To initialise the section and set up the GUI
%                        	for it.  
%					     	Returns [x, y] position variables for the GUI
%
%            'reinit'    	Delete all of this section's GUIs and data,
%                        	and reinit, at the same position on the same
%                        	figure as the original section GUI was placed. 
%						 	Returns [x,y]
%
%			 'parse_ev'  	Parses the events from dispatcher
%						 	Returns nothing.
%
%			 'end_of_trial' Handles end of trial info, figures out how the trial 
%							ended.  
%							Returns nothing.
%
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function varargout = PerformanceSection(obj, action, varargin)
   
GetSoloFunctionArgs;

switch action
%% init
    case 'init',
  
  	if nargin<4
  		warning('PROTOCOL:PROANTI:InitNumArgs','Incorrect # of variables passed for ''init''');
  		return;
  	end
  	
  	x=varargin{1};
  	y=varargin{2};
  

  oldy=y;
  boty=5;
  colw=0.6;
  rowh=0.85;
  labfrac=0.6;
  dispw=120;
  % Some non-gui params
   SoloParamHandle(obj, 'hit_history',      'value', []);
   SoloParamHandle(obj, 'gotit_history',  'value', []);
   SoloParamHandle(obj, 'RT',  'value', []);
   SoloParamHandle(obj, 'first_response', 'value', []);
   SoloParamHandle(obj, 'previous_plot','value',[]);
   SoloParamHandle(obj, 'previous_sides','value',[]);
   SoloParamHandle(obj, 'previous_cntxt','value',[]);
   SoloParamHandle(obj, 'block_history','value',[]);
   SoloParamHandle(obj, 'trial_types','value',[]);
   
   SoloParamHandle(obj, 'carlos_block_type',    'value', 0);
   SoloParamHandle(obj, 'carlos_block_counter', 'value', 0);

   %Solo(obj, 'ro_args', 'hit_history');


   [x, y] = AntibiasSection(obj, 'init', x, y, poke3resp_dist(1));
   y=boty;
   next_column(x);

   %  There are 2 main gui elements of the PerformanceSection
   % The performance graph at the top of the window.

   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)], 'Saveable',0);

   
   % Performance variables
   DispParam(obj, 'PRewarded','0',x,y, 'label','% Rewarded','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'PCorrect','0',x,y, 'label','% Corr','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'PProCorrect','0',x,y, 'label','% Pro Corr','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'PAntCorrect','0',x,y, 'label','% Anti Corr','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'PLeftCorr','0',x,y, 'label','% L Corr','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'PRightCorr','0',x,y, 'label','% R Corr','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'NLeftPokes','0',x,y, 'label','# L Pokes','position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'NRightPokes','0',x,y,'label','# R Pokes', 'position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'NCenterPokes','0',x,y,'label','# C Pokes', 'position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'streak','0',x,y,'label','Streak', 'position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   DispParam(obj, 'numtrials','0',x,y,'label','trial #', 'position',[x y dispw 15], 'labelfraction',labfrac);
   next_row(y,rowh);
   SubheaderParam(obj, 'PerformanceVars','Performance Vars', x,y,'position',[x y dispw 15]);
   next_column(x,colw); y=boty; 
	
	% % TRIAL VARS
	
  labfrac=0.6;
  DispParam(obj, 'reward_baited','1',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj,'goodPoke3','1',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac); % {'Left', 'Center' 'Right'};
  next_row(y,rowh);
  DispParam(obj,'poke2_snd_loc','-1',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac); % {'Left', 'Center' 'Right'};
  next_row(y,rowh);
  DispParam(obj, 'pro_trial', '-1', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh); 
%  DispParam(obj, 'Trials_Done', n_trials_done)x,y,;
     SubheaderParam(obj, 'TrialVars','Trial Vars', x,y,'position',[x y dispw 15]);
  next_row(y,rowh); 
 
  DispParam(obj, 'poke3TO', '20', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'poke3led', '-1 0 1', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'poke2poke3gap', '1', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'lightCue' ,'',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'poke2snd_delay' ,'0.1 ',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj,'goodPoke2','0',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac); % {'Left', 'Center' 'Right'};
  next_row(y,rowh);
  DispParam(obj, 'poke2TO', '20', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'poke1poke2gap', '1', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'poke1snd_delay' ,'0.1',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj,'goodPoke1','0',x,y, 'position',[x y dispw 15], 'labelfraction',labfrac); % {'Left', 'Center' 'Right'};
  next_row(y,rowh);
  DispParam(obj, 'poke1TO', '20', x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_column(x,colw);y=boty;
  
  labfrac=0.6;
  DispParam(obj, 'reward_time',0.2,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'delay2reward',0.2,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'missITIdur',0.01,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'hitITIdur',1,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'violationITIdur',0.01,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'block_counter',0,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'current_block',0,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  DispParam(obj, 'n_good_trials',0,x,y, 'position',[x y dispw 15], 'labelfraction',labfrac);
  next_row(y,rowh);
  
  
  
  
    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-130 pos(3)-130 100]);
	set(value(myaxes), 'Units', 'normalized');
    
    set(value(myaxes), 'YGrid','On','YTick', [-1.2 -0.8  0.8 1.2 ], 'YLim', [-1.5 1.5], 'YTickLabel', ...
                        {'AntiLeft', 'ProLeft', 'ProRight','AntiRight'});
    NumeditParam(obj, 'ntrials', 20, x, y, ...
                   'position', [5 pos(4)-100 40 30], 'labelpos', 'top', ...
                   'TooltipString', sprintf(['How many trials to show in plot\n'...
				   'Pro Trials are just inside the ticks, AntiTrials are just outside the ticks\n'...
				   'To see a range of trials just type "10 50" to see 10 to 50']));
			   
    set_callback(ntrials, {mfilename, 'update_plot'});      
    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    
    SoloFunctionAddAllVars('StateMatrixSection','ro_args');
    
        
    % and the text information
    
    
    varargout{1}=x;
    varargout{2}=y;
    
%% update_plot    
  case 'update_plot',
    
    cla(value(myaxes));
	if n_done_trials<1
		return;
	end

    ps = value(previous_sides);
    if ps(end)==-1, 
        hb = line(length(previous_sides), 2, 'Parent', value(myaxes));
    else                         
        hb = line(length(previous_sides), 1, 'Parent', value(myaxes));
    end;
    set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');

    xgreen = find(value(gotit_history)==1);
    ygreen = previous_sides(xgreen).*(1-0.2*previous_cntxt(xgreen));
    hg = line(xgreen, ygreen, 'Parent', value(myaxes));
    set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none'); 

    xred  = find(value(gotit_history)==0);
    yred = previous_sides(xred).*(1-0.2*previous_cntxt(xred));  
	hr = line(xred, yred, 'Parent', value(myaxes));
    set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none'); 
	
	
	xblack  = find(isnan(value(hit_history)));
	yblack = previous_sides(xblack).*(1-0.2*previous_cntxt(xblack));
	hk = line(xblack, yblack, 'Parent', value(myaxes));
	set(hk, 'Color', 'k', 'Marker', '.', 'LineStyle', 'none');

	previous_plot.value = [hb ; hr; hg; hk];
	if ~isscalar(ntrials+0)
		minx=min(ntrials+0);
		maxx=max(ntrials+0);
	else

		minx = n_done_trials - ntrials; if minx < 0, minx = 0; end;
		maxx = n_done_trials + 2; if maxx <= ntrials, maxx = ntrials+2; end;
	end
	set(value(myaxes), 'Xlim', [minx, maxx]);
    drawnow;

%% response_made
	case 'response_made',

    % Carlos and Sebastien: moved these two lines up here so every trial
    % (whether it ended on poke3 or in a violation) has a record of what
    % the intended correct side and intended context was. This is important
    % so that on 'update_plot' in this mfile n_done_trials>=1 necessarily 
    % implies non-empty(previous_sides). Moreover, it is better if
    % length(previous_sides) is always equal to n_done_trials.
    
	% This really is trial_ended code.   So let us consider all the ways
	% the trial may have ended.
	% Violation 
	% Hit
	% Miss
	outs={'vio','hit','mis'};
	trial_outcome=parsed_events.states.ending_state;
	to_abr=lower(trial_outcome(1:3));
	  if ~ismember(to_abr,outs)
		  
		  warning('PROANTI:PerformanceSection:BadOutcome','Trial ended in a funny way');
		      varargout{1}=0;
            return;
	  end
	  
	  previous_sides.value=[previous_sides(:); value(goodPoke3)];
      previous_cntxt.value=[previous_cntxt(:); value(pro_trial)];
	  block_history.value=[block_history(:); value(current_block)];
  
	  
	  if isequal('vio',to_abr)
		  %Then everything is essentially NAN.
		  RT.value=[value(RT); nan];
		  gotit_history.value=[value(gotit_history); nan];
		  hit_history.value=[value(hit_history); nan];
		  streak.value=0;
	  else
		  % hit or miss
		  block_counter.value = block_counter+1;
		  n_good_trials.value=n_good_trials+1;
		  if numel(parsed_events.states.wait_for_poke3)==0
			  varargout{1}=0;
			  warning('PROANTI:PerformanceSection:BadOutcome','If not violation then wait_for_poke3 should not be empty');
			  return;
		  end

		  %shit this is fucked up


		  [first_response, first_resp_time]=find_first_poke(parsed_events.states.wait_for_poke3, parsed_events.pokes);

		  if first_response==value(goodPoke3)
			  gotit_history.value=[value(gotit_history); 1];
			  if streak<0, streak.value=0;
			  else
				  streak.value=streak+1;
			  end
		  else
			  gotit_history.value=[value(gotit_history); 0];
			  if streak>0, streak.value=0;
			  else
				  streak.value=streak-1;
			  end
		  end

		  RT.value=[value(RT); first_resp_time];
		  hit_history.value=[value(hit_history); strcmp(trial_outcome,'hit_state')];
	  end
	  
		if n_done_trials>1
			if hit_history(numtrials+0)==1 || strcmp(repeat_on_error,'Never')
				repeat_flag=0;
			elseif strcmp(repeat_on_error,'Always') && hit_history(numtrials+0)~=1
				repeat_flag=1;
			elseif lower(repeat_on_error(1))==trial_outcome(1)
				repeat_flag=1;
			else
				% If trial ended in a violation and you have miss only or
				% vice versa you get here.
				repeat_flag=0;
			end
		else
			repeat_flag=0;
		end
        
		
        if repeat_flag==0  % we are NOT repeating the trial


            this_block_hits=gotit_history(block_history==current_block);
            this_block_sides=previous_sides(block_history==current_block);
            nnanIdx=find(~isnan(this_block_hits));
            sides4antiB=zeros(size(nnanIdx));
            sides4antiB(this_block_sides(nnanIdx)==1)='r';
            sides4antiB(this_block_sides(nnanIdx)==-1)='l';
            AntibiasSection(obj, 'update', poke3resp_dist(1), this_block_hits(nnanIdx), sides4antiB);
        end
        %% Also update display of perfomance variables and the plot....
        PCorrect.value=nanmean(gotit_history(:));
        PRewarded.value=nanmean(hit_history(:));
        
        if previous_sides(end)==-1
            PLeftCorr.value=nanmean(gotit_history(previous_sides==-1));
        else
            PRightCorr.value=nanmean(gotit_history(previous_sides==1));
        end

        if previous_cntxt(end)==-1
            PAntCorrect.value=nanmean(gotit_history(previous_cntxt==-1));
        else
            PProCorrect.value=nanmean(gotit_history(previous_cntxt==1));
        end
		numtrials.value=numtrials+1;
		ntrials.value=numtrials+0;
		varargout{1}=repeat_flag;

        
        
%% update        

    case 'update'
        NLeftPokes.value=NLeftPokes+size(latest_parsed_events.pokes.L, 1);
		NRightPokes.value=NRightPokes+size(latest_parsed_events.pokes.R, 1);
		NCenterPokes.value=NCenterPokes+size(latest_parsed_events.pokes.C, 1);

    

%% manual_push_history
  case 'manual_push_history'
    push_history(carlos_block_type);
    push_history(carlos_block_counter);

    
%% next trial
    case 'next_trial'
		

		% pro or anti
		tr = rand;
		if tr<pro_prob, pro_trial.value = 1;
		else            pro_trial.value = -1;
		end;

		if nPokes>=3
			enable(goodPoke1)

			% poke1     [L, R, C] = [-1 0 1]
			if sum(poke1led_prob)==0
				goodPoke1.value=[];
			else
				tr=rand;
				p1t=poke1led_prob;
				if tr<=p1t(1)
					goodPoke1.value=-1;
				elseif tr<=(p1t(2)+p1t(1))
					goodPoke1.value=0;
				else
					goodPoke1.value=1;
				end
			end

		else
			disable(goodPoke1);
		end


		if nPokes>=2
			enable(goodPoke2);
			% poke2     [L, R, C] = [-1 0 1]
			if sum(poke2led_prob)==0
				goodPoke2.value=[];
			else
				tr=rand;
				p2t=poke2led_prob;

				if tr<=p2t(1)
					goodPoke2.value=-1;
				elseif tr<=(p2t(2)+p2t(1))
					goodPoke2.value=0;
				else
					goodPoke2.value=1;
				end
			end

		else
			disable(goodPoke2);
		end


		% poke3     [L, R, C] = [-1 0 1]


		if prior_override == 1,
			my_prior = fullprior;

			pro_trial_history = cell2mat(get_history(pro_trial));
			goodPoke3_history = cell2mat(get_history(goodPoke3)); %#ok<NODEF>
			thist = pro_trial_history(1:n_done_trials)*100 + goodPoke3_history(1:n_done_trials);
			% Thus -101 = Anti Left; -99 = Anti Right ; 99 = Pro Left ; 101 = Pro Right
			hhist = gotit_history(1:n_done_trials); %#ok<NODEF>
			goodtrials=~isnan(hhist);

			done_types = unique(thist(goodtrials));
			done_hfrac = exponential_hitfrac(thist(goodtrials), hhist(goodtrials), AntibiasSection(obj, 'get', 'antibias_tau'));

			hfrac = ones(4,1);
			for i=1:length(done_types),
				switch done_types(i),
					case -101, hfrac(1) = done_hfrac(i);
					case  -99, hfrac(2) = done_hfrac(i);
					case   99, hfrac(3) = done_hfrac(i);
					case  101, hfrac(4) = done_hfrac(i);
				end;
			end;

			hitfrac.value   = round(hfrac'*100)/100;
			posterior.value = probabilistic_trial_selector(hfrac', value(fullprior), ...
				AntibiasSection(obj, 'get', 'Beta'));

			if ~strcmp(MaxSame, 'Inf') && MaxSame < n_done_trials,
				if all(previous_sides(n_done_trials-MaxSame+1:n_done_trials)==previous_sides(n_done_trials)), %#ok<NODEF>
					if previous_sides(n_done_trials)==-1, % Did MaxSame of Left
						my_prior = [0 fullprior(2) 0 fullprior(4)];
					else
						my_prior = [fullprior(1) 0 fullprior(3) 0];
					end;
					my_prior = my_prior/sum(my_prior);
				end;
			end;

			if isempty(hfrac),
				choiceprobs = my_prior;
			else
				choiceprobs = probabilistic_trial_selector(hfrac', my_prior, ...
					AntibiasSection(obj, 'get', 'Beta'));
			end;
			cpsum = [0 cumsum(choiceprobs)];
			choice_id = find(cpsum < rand(1), 1, 'last');
			switch choice_id,
				case 1,
					pro_trial.value = -1;
					goodPoke3.value = -1;
				case 2,
					pro_trial.value = -1;
					goodPoke3.value =  1;
				case 3,
					pro_trial.value =  1;
					goodPoke3.value = -1;
				case 4,
					pro_trial.value =  1;
					goodPoke3.value =  1;
				otherwise
					error('Eek:eek', 'huh?');
			end;

		else
			choiceprobs = AntibiasSection(obj, 'get_posterior_probs');

			%choiceprobs=p3t;

			% if MaxSame doesn't apply yet, choose randomly
			if strcmp(MaxSame, 'Inf') || MaxSame > n_started_trials,
				if rand <= choiceprobs(1),  goodPoke3.value = -1;
				else                           goodPoke3.value = 1;
				end;
			else
				% if MaxSame applies, check for its rules:
				% if there's been a string of MaxSame guys all the same, force
				% change
				if all(previous_sides(n_started_trials-MaxSame+1:n_started_trials) == ...
						previous_sides(n_started_trials)),
					if previous_sides(n_started_trials) == -1,
						goodPoke3.value = 1;
					else
						goodPoke3.value = -1;
					end;
					% else, choose randomly
				else
					if rand(1) <= choiceprobs(1),  goodPoke3.value = -1;
					else                           goodPoke3.value = 1;
					end;
				end;
			end;
		end;

		poke2_snd_loc.value=pro_trial*goodPoke3;  % pro_trial is 1 for pro, -1 for anti, and 0 for balanced.
		% goodPoke3 is 1 for right,
		% -1 for left and 0 for
		% center.

		if (locsnd_pro_hz ~= -1) && (pro_trial==1)

			SoundInterface(obj,'set','LeftSound', 'Freq1',	locsnd_pro_hz);
			SoundInterface(obj,'set','RightSound', 'Freq1',	locsnd_pro_hz);
		elseif (locsnd_anti_hz ~= -1) && (pro_trial==-1)
			SoundInterface(obj,'set','LeftSound', 'Freq1',	locsnd_anti_hz);
			SoundInterface(obj,'set','RightSound', 'Freq1',	locsnd_anti_hz);
		end




		if poke2led_rule(1)=='C'
			lightCue.value=goodPoke3*1;
		elseif poke2led_rule(1)=='W'
			lightCue.value=goodPoke3*(-1);
		elseif poke2led_rule(1)=='P'
	        lightCue.value=goodPoke3*pro_trial;	
		else
			
			lightCue.value='';
		end





		% which LEDs to light up for poke3?

		switch value(poke3led_rule)
			case 'All'
				poke3led.value=[-1 0 1];
			case 'Sides'
				poke3led.value=[-1 1];
			case 'Correct Only'
				poke3led.value=value(goodPoke3);
			case 'None'
				poke3led.value='';
			case 'Wrong Only'
				poke3led.value=value(goodPoke3)*-1;
			case 'ProAnti'
				poke3led.value=value(poke2_snd_loc);
				

		end


		% rewards

		[LT, RT]=WaterValvesSection(obj, 'get_water_times', value(streak));
		if goodPoke3==1         % a right  trial
			reward_time.value=RT*scale_reward;
		elseif goodPoke3==-1   % a left   trial
			reward_time.value=LT*scale_reward;
		else
			warning('PROANTI2:BADPK3VAL','should never have a value of poke3 other than 1 or -1')
		end

		t_vars={'poke1snd_delay', 'poke1TO', ...
			'poke1poke2gap', 'poke2TO', 'poke2snd_delay', 'poke3TO', 'delay2reward',...
			'poke2poke3gap'};
		for xi=1:numel(t_vars)
			eval([t_vars{xi} '.value=rand*(' t_vars{xi} '_max-' t_vars{xi}  '_min)+' t_vars{xi}  '_min;']);
		end

		dui_vars={'hitITIdur', 'missITIdur', 'violationITIdur'} ;
		for xi=1:numel(dui_vars)
			eval([dui_vars{xi} '.value=DistribInterface(obj, ''get_new_sample'', ''' dui_vars{xi} 'UI'');']);
		end

		if rand<=reward_prob
			reward_baited.value=1;
	%		hitITIdur.value=hitITIdur(:); % what does this do?
		else
			reward_baited.value=0;
		end
        
            
%% make_and_send_summary
	case 'make_and_send_summary'
		pd.context=value(previous_cntxt);
		pd.blocks=value(block_history);
		pd.sides=value(previous_sides);
		pd.gotit=value(gotit_history);
		pd.hit=value(hit_history);
		pd.nPokes=[NLeftPokes+0 NCenterPokes+0 NRightPokes+0];
		clo=get_sphandle('name','cntx_loc_o');
		clo=clo{1};
		pd.cntx_loc_overlap=cell2mat(get_history(clo));
		clo=get_sphandle('name','LeftSoundFreq1');
		clo=clo{1};
        pd.loc_snd_hz=cell2mat(get_history(clo));        
        pd.pk2delay=cell2mat(get_history(poke2snd_delay));
        pd.comment=CommentsSection(obj,'get_latest');
        af=handle_hist(ProAnti2,'SoundInterface', 'AntiSoundFreq1');
		af=cell2mat(af);
		pf=handle_hist(ProAnti2,'SoundInterface', 'ProSoundFreq1');
		pf=cell2mat(pf);
		pd.poke1sound_freq(pd.context==-1)=af(pd.context==-1);
        pd.poke1sound_freq(pd.context==1) = pf(pd.context==1);
        try
        hh=handle_hist(ProAnti2,'SoundInterface', 'RightSoundBal');
		pd.balance=cell2mat(hh);
        catch
        end
        
        pf=handle_hist(ProAnti2,'SettingsSection', 'poke2led_rule');
		pd.poke2led_rule=cell2mat(pf);
		pf=handle_hist(ProAnti2,'SoundInterface', 'ProSoundFreq1');
		pf=cell2mat(pf);

        
		pd.RT=value(RT);
		pd.helper={{'context','sides','gotit'}; {'RT'}};
		lets={'l' 'c' 'r'};
        
		sides=cell2mat(lets(previous_sides+2));
		% This is the general summary for x-protocol comparison
		sendsummary(obj, 'hits',value(gotit_history),'sides',sides,'protocol_data',pd)
		sessid=bdata('select last_insert_id()');
		% NOW make the PA summary
		c_t=pd.gotit==1;
        m_t=pd.gotit==0;
        p_t=pd.context==1;
        a_t=pd.context==-1;
        
        pro_hit=nanmean(pd.gotit(p_t));
        anti_hit=nanmean(pd.gotit(a_t));
        hits=sum(c_t);
        viols=sum(isnan(pd.hit));
        misses=sum(m_t);
        pro_hit_rt=nanmean(RT((c_t.*p_t)==1));
        pro_miss_rt=nanmean(RT((m_t.*p_t)==1));
        anti_hit_rt=nanmean(RT((c_t.*a_t)==1));
        anti_miss_rt=nanmean(RT((m_t.*a_t)==1));
		
        sqlstr1='insert into pa_sess ( sessid ,  num_trials ,  hits ,  misses  , violations ,  pro_hit_frac ,  anti_hit_frac  , pro_hit_rt  , pro_miss_rt  , anti_hit_rt  , anti_miss_rt ) ';
		sqlstr2			    =' values ( "{Si}","{Si}","{Si}","{Si}","{Si}","{S}","{S}","{S}","{S}","{S}","{S}")';
        bdata([sqlstr1 sqlstr2],sessid , numel(pd.gotit) ,  hits ,  misses  , viols ,  pro_hit ,  anti_hit  , pro_hit_rt  , pro_miss_rt  , anti_hit_rt  , anti_miss_rt );
    
%% get
  case 'get'
    switch varargin{1},
      case 'pro_trial',
        varargout{1} = value(pro_trial);
      case 'goodPoke3',
        varargout{1} = value(goodPoke3);
        
      otherwise,
        error('PerformanceSection:Invalid', 'Don''t know how to get "%s"', varargin{1});
    end;
    
        
        % do some stuff.
%% reinit

% Is reinit ever called by anyone?
    case 'reinit',
  
   
  	if nargin<4
  		warning('PROANTI:PerformanceSection','Incorrect # of variables passed for ''reinit''');
  		return;
  	end
  	
  	
    currfig = double(gcf);

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);
    
    varargout{1}=x;
    varargout{2}=y;

    % Restore the current figure:
    figure(currfig);
end;


function [poke, poke_time]=find_first_poke(wndw, pokes)

% For now let's just assume there are C, L, and R pokes.
% and let's assume further that we don't really care about center pokes
% here.


pokes_c={'L' 'R'};
f_poke=zeros(2,1);
for px=1:numel(pokes_c)
	
	tpin=pokes.(pokes_c{px})(:,1);
    f_poke(px)=min([tpin(tpin>wndw(1)); Inf]);
end

[poke_time, poke]=min(f_poke);
poke=2*poke-3;
poke_time=poke_time-wndw(1);




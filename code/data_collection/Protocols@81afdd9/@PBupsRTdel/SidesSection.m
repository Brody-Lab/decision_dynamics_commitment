% [x, y] = SidesSection(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
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


function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
%% init
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);

    % Left/Right antibias, over-rides the antibias in soundtable
    LogsliderParam(obj, 'LR_BiasTau', 30, 10, 400, x, y,  ...
        'label', 'LR bias tau', ...
        'TooltipString', 'Number of trials back over which to compute Left/Right antibias');
    next_row(y);
    NumeditParam(obj, 'LR_Beta', 0, x, y, ...
        'TooltipString', 'Antibias weight for Left versus Right trials; trumps the antibias beta in soundtable');
    next_row(y);
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '14', 'Inf'}, 3, ...
        x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');
    next_row(y);
    DispParam(obj, 'ThisSound', 1, x, y, ...
        'TooltipString', 'The id of the stimulus being presented for this trial');
    next_row(y);
    DispParam(obj, 'ProbRt', 1, x, y,...
        'TooltipString', 'Prob of receiving reward on right for any given trial, currently not meaningful during RT task');
    next_row(y);
    DispParam(obj, 'ThisTrial', 'RIGHT', x, y, 'position', [x y 200 20]); 
	next_row(y);
    SoloParamHandle(obj, 'previous_sides', 'value', 'r');
    SoloParamHandle(obj, 'previous_sounds', 'value', 1);	% sound id #
	SoloParamHandle(obj, 'previous_samples', 'value', 0); % sample duration
	SoloParamHandle(obj, 'previous_memory_gaps', 'value', 0); % memory duration
	SoloParamHandle(obj, 'previous_rt_task', 'value', 0); % identifier of task type
    SoloParamHandle(obj, 'previous_stims', 'value', 0); % stimulator channel activated
    SoloParamHandle(obj, 'CPokeTup','value', []); % for RT task the times between different clicks
    SoloParamHandle(obj, 'RewSideRT','value', {}); % the rewarded side based on the tup values above (for RT task)
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 6.5);
    
    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [60 pos(4)-140 pos(3)-280 100]);
    set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5]);       
    ToggleParam(obj, 'LeftRightOnly', 0, x, y, 'position', [pos(3)-320 pos(4)-180 100 20], ...
      'OnString', 'L/R only', 'OffString', 'stim type', ...
      'TooltipString', sprintf('\nShow all stim types separately or show sort only by L/R'));
    set_callback(LeftRightOnly, {mfilename, 'update_plot'});
    set_callback_on_load(LeftRightOnly, 1);

    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    % plot reward prob at any given time for a trial during RT task
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes2', 'saveable', 0, 'value', axes);
    set(value(myaxes2), 'Units', 'pixels');
    set(value(myaxes2), 'Position', [pos(3)-200 pos(4)-140 160 100]);
    set(value(myaxes2), 'YTick', [0.5 1], 'YLim', [0 1]);       
    xlabel('time, y:ProbRT'); 
    
    
    
%% next_trial
  case 'next_trial',

	% if LR_Beta is not zero, keep track of the left/right hitfracs and
	% choice probabilities
	if LR_Beta > 0,
		lr_pprob = PBupsSection(obj, 'get', 'pprobs');
		lr_pprob = sum(lr_pprob,1); lr_pprob = lr_pprob/sum(lr_pprob);
		prevs = value(previous_sides); prevs = prevs(1:length(hit_history)); %#ok<NODEF>

		kernel = exp(-(0:length(hit_history)-1)/LR_BiasTau)';
		kernel = kernel(end:-1:1);

		ul = find(prevs=='l');
		if isempty(ul), bias_left_hitfrac = 1;
		else            bias_left_hitfrac = nansum(hit_history(ul) .* kernel(ul))/sum(kernel(ul));
		end;

		rl = find(prevs=='r');
		if isempty(rl), bias_right_hitfrac = 1;
		else            bias_right_hitfrac = nansum(hit_history(rl) .* kernel(rl))/sum(kernel(rl));
		end;

		if isempty(ul) && ~isempty(rl), bias_left_hitfrac = bias_right_hitfrac; end;
		if isempty(rl) && ~isempty(ul), bias_right_hitfrac = bias_left_hitfrac; end;

		choices = probabilistic_trial_selector([bias_left_hitfrac, bias_right_hitfrac], lr_pprob, value(LR_Beta));
	else
		choices = [];
	end;

	this_side = '';
	% Check for MaxSame rules if it applies
	if ~strcmpi(value(MaxSame), 'Inf') && MaxSame <= n_started_trials,
		% if there's been a string of MaxSame guys all the same, force change
		if all(previous_sides(n_started_trials-MaxSame+1:n_started_trials) == previous_sides(n_started_trials)), 
			if previous_sides(n_started_trials) == 'l',
				this_side = 'r';
			else
				this_side = 'l';
			end;
		elseif ~isempty(choices), % if there is a trump LR_Beta, pick next side here
			if rand(1) > choices(1);
				this_side = 'r';
			else
				this_side = 'l';
			end;
		end;
	elseif ~isempty(choices),                    
	% if MaxSame rules do not apply, but LR_Beta > 0, just pick the next side
		if rand(1) > choices(1);
			this_side = 'r';
		else
			this_side = 'l';
		end;                
	end;

	[this_sound this_T] = StimulusSection(obj, 'next_trial', this_side);
	ThisSound.value = this_sound;
    
    
    if value(rt_task) == 1

        clicks = PBupsSection(obj, 'get_bup_times');
        clicks.left = clicks.left(clicks.left<5);
        clicks.right = clicks.right(clicks.right<5);
        ICI = sort([clicks.left clicks.right]);                 % clicks times left and right (to divide up the center poke state time)
        ICI = [min_rt ICI(ICI>min_rt)];
        cpoketup = [min_rt diff(ICI)];

        if value(rew_kappa) == 1

            for i = 1:length(ICI)
                delc = sum(clicks.right<ICI(i)) - sum(clicks.left < ICI(i));

                if delc <20 & delc > -20
                    if delc > 0
                        rewsideind{i} = sprintf(['wait_for_spoker_', num2str(delc)]);
                    elseif delc <0
                        rewsideind{i} = sprintf(['wait_for_spokel_', num2str(abs(delc))]);
                    elseif delc == 0
                        dumb4 = rand()
                        if dumb4 > 0.5
                            rewsideind{i} = sprintf(['wait_for_spoker_', num2str(delc)]);
                        else
                            rewsideind{i} = sprintf(['wait_for_spokel_', num2str(delc)]);
                        end
                    end
                elseif delc >= 20 
                    rewsideind{i} = sprintf(['wait_for_spoker_', num2str(20)]);
                elseif delc <= -20
                    rewsideind{i} = sprintf(['wait_for_spokel_', num2str(20)]);
                end
            end    

            if delc > 0
                ThisTrial.value = 'RIGHT';
            else   ThisTrial.value = 'LEFT';
            end    
            CPokeTup.value = cpoketup;
            RewSideRT.value = rewsideind;  


        else
        
            for i = 1:length(ICI)
                winR(i) = exp(value(rew_kappa)*(sum(clicks.right<ICI(i)) - sum(clicks.left<ICI(i))));
                winR(i) = winR(i)/(1+winR(i));
                rewside = winR(i) > rand();                  % 1 for left being correct and 0 for right being correct
                if rewside == 1
                    rewsideind{i} = 'wait_for_spokeR_temp';
                    rewsidetime(i) = 1;
                else
                    rewsideind{i} = 'wait_for_spokeL_temp';
                    rewsidetime(i) = 0;
                end
            end
        
            ProbRt.value = mean(winR);
            if mean(winR) > 0.5
                ThisTrial.value = 'RIGHT';
            else ThisTrial.value = 'LEFT';
            end
        
            CPokeTup.value = cpoketup;
            RewSideRT.value = rewsideind;
            % create a whole section displaying what would happen when the
            % animal leaves at a certain time
        
            % plotting the reward probabilities wrt time for the current trial
            a = cumsum(cpoketup);
            a = a(a<2);
            cla(value(myaxes2));
            hold(value(myaxes2),'on');
            plot(value(myaxes2), a, winR(1:length(a))); 
            scatter(value(myaxes2), a, rewsidetime(1:length(a)));
            set(value(myaxes2), 'YTick', [0.5 1], 'YLim', [0 1]);
            xlabel('time, y:ProbRT');
            set(value(myaxes2),'Box','off');
            hold(value(myaxes2),'off');
            drawnow;
        end
        
        
    else 

        if strcmp(value(reward_type), 'delta clicks'),
            % reward based on actual click difference and kappa strategy
            bupTimes = PBupsSection(obj, 'get_bup_times');
            sample_duration = PBupsSection(obj,'get','sample_duration');
            nBupsRight = sum(bupTimes.right < sample_duration);
            nBupsLeft = sum(bupTimes.left < sample_duration);
            
            tempvar1 = exp(value(rew_kappa)*(nBupsRight - nBupsLeft));
            prightrew = tempvar1/(1+tempvar1);
            
            ProbRt.value = prightrew;
            % drawing the rewarded side based on this probability
            if prightrew < rand()
                rewsidetrial = 'l';
            else rewsidetrial = 'r';
            end
            
            if rewsidetrial == 'l'
                ThisTrial.value = 'LEFT';
            elseif rewsidetrial =='r'
                ThisTrial.value = 'RIGHT';
            end
        else
            % reward based on generative gamma
            if this_sound < 0;
                ThisTrial.value = 'LEFT';
            else
                ThisTrial.value = 'RIGHT';
            end;
        end
    end
    
   SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'CPokeTup';'RewSideRT'}); 
	feval(mfilename, obj, 'update_trial_info');
    
    
    
%% update_trial_info
  case 'update_trial_info'
    
    % update previous_sides, previous_sounds, and previous_rt_task
    if strcmp(value(ThisTrial), 'LEFT'), %#ok<NODEF>
        s = 'l';
    else
        s = 'r';
    end
	
    if n_done_trials == 0,
        previous_sides.value   = s;
        previous_sounds.value  = value(ThisSound);
        previous_rt_task.value = value(rt_task);
        previous_stims.value   = PBupsSection(obj, 'get_ThisStim');
    elseif n_done_trials > 0,
        previous_sides.value   = [previous_sides(:); s];
        previous_sounds.value  = [previous_sounds(:); value(ThisSound)];
        previous_rt_task.value = [previous_rt_task(:); value(rt_task)];
        previous_stims.value   = [previous_stims(:); PBupsSection(obj, 'get_ThisStim')];
	end

%% update_last_trial_info
  case 'update_last_trial_info'
	if n_done_trials == 0,
		previous_samples.value = [];
		previous_memory_gaps.value = [];
	else
		if violation_history(n_done_trials) == 1,
			% on violation trials, there's no sensible way to determine the
			% actual sample duration
			sample_duration = NaN;
            memory_duration = NaN;
		else
			specs = StimulusSection(obj, 'get_stimulus_specs');
			if strcmp(specs.stim_timing, 'During Cpoke Only'),
                memory_duration = 0;
				if isfield(parsed_events.states, 'cpoke1') && rows(parsed_events.states.cpoke1) > 0,
					sample_duration = diff(parsed_events.states.cpoke1(1,:)) - specs.sound_delay;
				else
					sample_duration = NaN;
				end;
			else
				sample_duration = specs.sound_dur;
				if isfield(parsed_events.states, 'cpoke1') && rows(parsed_events.states.cpoke1) > 0,
                    memory_duration = diff(parsed_events.states.cpoke1(1,:)) - specs.sound_delay - sample_duration;
                else
					memory_duration = NaN;
				end;
			end;
		end;
		previous_samples.value = [previous_samples(:); sample_duration]; %#ok<NODEF>
		previous_memory_gaps.value = [previous_memory_gaps(:); memory_duration]; %#ok<NODEF>
	end;

%% get_previous_sides
  case 'get_previous_sides_and_sounds', 
    x = value(previous_sides); %#ok<NODEF>
	y = value(previous_sounds); %#ok<NODEF>
    
%% get_current_side
  case 'get_current_side',
          if strcmp(ThisTrial, 'LEFT'), x = 'l'; %#ok<NODEF>
          else                          x = 'r';
          end;
 
    
%% get_current_sound
  case 'get_current_sound',
    x = value(ThisSound); %#ok<NODEF>

%% make_and_send_summary
  case 'make_and_send_summary',
    pd.hits       = value(hit_history);
	pd.violations = value(violation_history);
    pd.sounds     = value(previous_sounds);		pd.sounds  = pd.sounds(1:length(hit_history));
	pd.samples    = value(previous_samples);	pd.samples = pd.samples(1:length(hit_history));
	pd.memory_gaps= value(previous_memory_gaps);pd.memory_gaps = pd.memory_gaps(1:length(hit_history));
    pd.sides      = value(previous_sides);		pd.sides   = pd.sides(1:length(hit_history));
    pd.rt_task    = value(previous_rt_task);	pd.rt_task   = pd.rt_task(1:length(hit_history));
    pd.stims      = value(previous_stims);      pd.stims = pd.stims(1:length(hit_history));
    pd.bupsdata   = PBupsSection(obj, 'get_all_bup_times');
    pd.stimdata   = PBupsSection(obj, 'get_all_stimulator_specs');

    nl=nan(size(pd.hits));
    nr=nan(size(pd.hits));
    
    for tx=1:numel(pd.hits)
         nl(tx)=sum(pd.bupsdata{tx}.left<pd.samples(tx));
         nr(tx)=sum(pd.bupsdata{tx}.right<pd.samples(tx));     
    end
    
    
    pd.n_left = nl;
    pd.n_right = nr;
    
    sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
    
    
%% update_plot
  case 'update_plot',
    if ~isempty(value(previous_plot)), delete(previous_plot(:)); previous_plot.value = []; end;
    if isempty(previous_sides), return; end; 

    ps = value(previous_sounds); %#ok<NODEF>

	sides = PBupsSection(obj, 'get', 'all_sides');
	sides = cellstr(sides');  % turns it into a cell array of characters where each row is a trial type
	nleft = PBupsSection(obj, 'get', 'nleft');
	nright = PBupsSection(obj, 'get', 'nright');
	sidemap = [-nleft:-1 1:nright];
	stim_list = sidemap;
	if LeftRightOnly == 1,
		sidemap(sidemap<0) = -1;
		sidemap(sidemap>0) = 1;
	end;
	soundname = 'PBups';
    
    if ps(end) ~= 0,
        hb = line(length(ps), sidemap(stim_list==ps(end)), 'Parent', value(myaxes));
        set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
    else
        hb = [];
    end
    
    xgreen  = find(hit_history==1 & violation_history==0);
	xggreen = find(hit_history==1 & violation_history==1);
    xred    = find(hit_history==0 & violation_history==0);
	xrred   = find(hit_history==0 & violation_history==1);
    xblk    = find(isnan(hit_history));
    ygreen  = zeros(size(xgreen));
	yggreen = zeros(size(xggreen));
    yred    = zeros(size(xred));
	yrred   = zeros(size(xrred));
    yblk    = zeros(size(xblk));
    for x = 1:length(stim_list),
        i = stim_list(x);
        ygreen(ps(xgreen) == i)   = sidemap(x);
		yggreen(ps(xggreen) == i) = sidemap(x);
        yred(ps(xred) == i)       = sidemap(x);
		yrred(ps(xrred) == i)     = sidemap(x);
        yblk(ps(xblk) == i)       = sidemap(x);
    end;
    
    hg = line(xgreen, ygreen, 'Parent', value(myaxes));
    set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none');
    hr = line(xred, yred, 'Parent', value(myaxes));
    set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none');
    hgg = line(xggreen, yggreen, 'Parent', value(myaxes));
    set(hgg, 'Color', 'g', 'Marker', 'o', 'LineStyle', 'none');
    hrr = line(xrred, yrred, 'Parent', value(myaxes));
    set(hrr, 'Color', 'r', 'Marker', 'o', 'LineStyle', 'none');
    hk = line(xblk, yblk, 'Parent', value(myaxes));
    set(hk, 'Color', 'k', 'Marker', '.', 'LineStyle', 'none');

    
    previous_plot.value = [hb; hg; hr; hgg; hrr; hk];
          
    minx = 0;
    maxx = n_done_trials + 2;
    set(value(myaxes), 'XLim', [minx, maxx]);
    set(value(myaxes), 'YLim', [min(sidemap)-0.5 max(sidemap)+0.5], 'YGrid', 'on');
    nrows = length(unique(sidemap));
    ticks = cell(nrows, 1);
    for x = 1:length(stim_list),
        if LeftRightOnly==0,
          ticks{find(stim_list==sidemap(x),1)} = [sides{x} ', ' sprintf([soundname ' %g'], stim_list(x))];
        else
          if sides{x}=='l', ticks{find(stim_list==sidemap(x),1)} = 'LEFT'; 
          else ticks{find(stim_list==sidemap(x),1)} = 'RIGHT'; 
          end;
        end;
    end
    set(value(myaxes), 'YTick', unique(sidemap), ...
        'YTickLabel', ticks, ...
        'YLim', [min(sidemap)-0.5 max(sidemap)+0.5]);
    set(get(value(myaxes), 'YLabel'), 'String', 'sounds');
    drawnow;
      
%% reinit
  case 'reinit',
    currfig = double(gcf);
    
    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;
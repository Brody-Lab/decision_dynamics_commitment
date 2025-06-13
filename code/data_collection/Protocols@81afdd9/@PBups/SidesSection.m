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
%


function [x, y] = SidesSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action
%% init
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    ToggleParam(obj,'ExcludeOptoTrials',0, x,y,'position',[x,y,200,20],...
        'OnString','Exclude Opto Trials in AntiBias','OffString','Include Opto Trials in AntiBias',...
        'TooltipString','Include or Exclude opto trials from antibias computation');
    next_row(y);
    
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
    
    DispParam(obj, 'ThisTrial', 'RIGHT', x, y, 'position', [x y 200 20]); 
	next_row(y);
    SoloParamHandle(obj, 'previous_sides', 'value', 'r');
    DeclareGlobals(obj,'ro_args','previous_sides');
    SoloParamHandle(obj, 'previous_sounds', 'value', 1);	% sound id #
	SoloParamHandle(obj, 'previous_samples', 'value', 0); % sample duration
	SoloParamHandle(obj, 'previous_memory_gaps', 'value', 0); % memory duration
	SoloParamHandle(obj, 'previous_rt_task', 'value', 0); % identifier of task type
    SoloParamHandle(obj, 'previous_stims', 'value', 0); % stimulator channel activated
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 6.5);
    
    % plot of side choices history at top of window
    pos = get(double(gcf), 'Position');
    newaxes = double(axes);
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', newaxes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-130 100]);
    set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5]);       
    ToggleParam(obj, 'LeftRightOnly', 0, x, y, 'position', [pos(3)-320 pos(4)-180 100 20], ...
      'OnString', 'L/R only', 'OffString', 'stim type', ...
      'TooltipString', sprintf('\nShow all stim types separately or show sort only by L/R'));
    set_callback(LeftRightOnly, {mfilename, 'update_plot'});
    set_callback_on_load(LeftRightOnly, 1);

    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    SoloFunctionAddVars('PBups', 'rw_args', {'previous_sides',...
                                             'previous_sounds',...
                                             'previous_samples',...
                                             'previous_memory_gaps',...
                                             'previous_rt_task',...
                                             'previous_stims'});
    
    
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
        
        hh_temp = hit_history;
        
        if value(ExcludeOptoTrials) == 1
            stim_specs_history = PBupsSection(obj,'get_all_stimulator_specs');
            for i = 1:min([numel(stim_specs_history),numel(hh_temp)])
                if stim_specs_history{i}.ison == 1
                    hh_temp(i) = nan;
                    kernel(i)  = nan;
                end
            end
        end

		ul = find(prevs=='l');
		if isempty(ul), bias_left_hitfrac = 1;
		else            bias_left_hitfrac = nansum(hh_temp(ul) .* kernel(ul))/nansum(kernel(ul));
		end;

		rl = find(prevs=='r');
		if isempty(rl), bias_right_hitfrac = 1;
		else            bias_right_hitfrac = nansum(hh_temp(rl) .* kernel(rl))/nansum(kernel(rl));
		end;

		if isempty(ul) && ~isempty(rl), bias_left_hitfrac = bias_right_hitfrac; end;
		if isempty(rl) && ~isempty(ul), bias_right_hitfrac = bias_left_hitfrac; end;

		choices = probabilistic_trial_selector([bias_left_hitfrac, bias_right_hitfrac], lr_pprob, value(LR_Beta));   
    else

		choices = []; % this means choice is set by PBupsSection and the bias parameters there take effect
	end;

    % checking if AR probabilities are in play
    isARbias = PBupsSection(obj, 'get', 'ARbias');

    if isARbias ~= 0
        repProb = PBupsSection(obj, 'get', 'repProb');
        if strcmp(value(previous_sides(end)), 'l')
            lr_pprob = [repProb 1-repProb];
        elseif strcmp(value(previous_sides(end)), 'r')
            lr_pprob = [1-repProb repProb];
        end  

    % we want ARbias to influence the side whether or not antibias is on, so picking sides here
    choices = probabilistic_trial_selector([bias_left_hitfrac, bias_right_hitfrac], lr_pprob, value(LR_Beta));   
    end


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
        end                
    end

	[this_sound this_T] = StimulusSection(obj, 'next_trial', this_side);
	ThisSound.value = this_sound;
    if strcmp(value(reward_type), 'delta clicks'),
        % reward based on actual click difference
        bupTimes = PBupsSection(obj, 'get_bup_times');
        sample_duration = PBupsSection(obj,'get','sample_duration');
        nBupsRight = sum(bupTimes.right < sample_duration);  
        nBupsLeft = sum(bupTimes.left < sample_duration);
        if nBupsRight < nBupsLeft
            ThisTrial.value = 'LEFT';
        elseif nBupsRight > nBupsLeft
            ThisTrial.value = 'RIGHT';
        elseif rand(1) > 0.5
            ThisTrial.value = 'LEFT';
        else
            ThisTrial.value = 'RIGHT';
        end
    elseif strcmp(value(reward_type), 'gamma'),
        % reward based on generative gamma
        if this_sound < 0;
            ThisTrial.value = 'LEFT';
        else
            ThisTrial.value = 'RIGHT';
        end
    elseif strcmp(value(reward_type), 'random_reward')
        if rand < 0.5
            ThisTrial.value = 'LEFT';
        else
            ThisTrial.value = 'RIGHT';
        end
    else
        ThisTrial.value = 'FREE';
    end
    
	feval(mfilename, obj, 'update_trial_info');
    

    
%% update_trial_info
  case 'update_trial_info'
    
    % update previous_sides, previous_sounds, and previous_rt_task
    if strcmp(value(ThisTrial), 'LEFT'), %#ok<NODEF>
        s = 'l';
    elseif strcmp(value(ThisTrial), 'RIGHT')
        s = 'r';
    else
        s = 'f';
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
    elseif strcmp(ThisTrial, 'RIGHT'),  x = 'r';
    else, x='f';
    end;
    
%% get_current_sound
  case 'get_current_sound',
    x = value(ThisSound); %#ok<NODEF>

%% make_and_send_summary
  case 'make_and_send_summary',
    pd.hits           = value(hit_history);
	pd.violations     = value(violation_history);
    pd.cpoke1_tups    = value(cpoke1_tup_history);
    pd.reward_type    = value(reward_type_history);
    
    ch = value(crashed_history);
    if numel(ch) < numel(hit_history); ch(end+1:numel(hit_history)) = 0; end
    pd.crash          = colvec(ch);
    
    chc = value(crashed_history_comments);
    if numel(chc) < numel(hit_history); for i=numel(chc)+1:numel(hit_history); chc{i} = []; end; end
    pd.crash_comments = colvec(chc);
    
    pd.sounds         = value(previous_sounds);		 pd.sounds  = pd.sounds(1:length(hit_history));
	pd.samples        = value(previous_samples);	 pd.samples = pd.samples(1:length(hit_history));
	pd.memory_gaps    = value(previous_memory_gaps); pd.memory_gaps = pd.memory_gaps(1:length(hit_history));
    pd.sides          = value(previous_sides);		 pd.sides   = pd.sides(1:length(hit_history));
    pd.rt_task        = value(previous_rt_task);	 pd.rt_task   = pd.rt_task(1:length(hit_history));
    pd.stims          = value(previous_stims);       pd.stims = pd.stims(1:length(hit_history));
    rd=get_sphandle('name','reward_delay'); rd=get_history(rd{1});
    pd.reward_delay = cell2mat(rd);      pd.reward_delay = pd.reward_delay(1:min([length(hit_history),numel(rd)])); %lengths can be different if it's a live save or from a reconstituted ASV file -Chuck
    
    pd.bupsdata   = PBupsSection(obj, 'get_all_bup_times');
    pd.stimdata   = PBupsSection(obj, 'get_all_stimulator_specs');

    nl=nan(size(pd.hits));
    nr=nan(size(pd.hits));
    
    for tx=1:min([numel(pd.hits),numel(pd.bupsdata)]) %lengths can be different if it's a live save or from a reconstituted ASV file -Chuck 
         nl(tx)=sum(pd.bupsdata{tx}.left<pd.samples(tx));
         nr(tx)=sum(pd.bupsdata{tx}.right<pd.samples(tx));     
    end

    pd.n_left = nl;
    pd.n_right = nr;
    
    %added fields for the water valve open time -Chuck 10-8-2018
    leftwatertime  = zeros(numel(parsed_events_history),1); leftwatertime(:)  = nan;
    rightwatertime = zeros(numel(parsed_events_history),1); rightwatertime(:) = nan;
    for i = 1:numel(parsed_events_history)
        left  = parsed_events_history{i}.waves.direct_left_reward;
        right = parsed_events_history{i}.waves.direct_right_reward;
        
        if ~isempty(right); rightwatertime(i) = mean(right); end
        if ~isempty(left);  leftwatertime(i)  = mean(left);  end
    end
    pd.leftwatertime  = leftwatertime;
    pd.rightwatertime = rightwatertime;
    
    %Let's ensure all fields are the same length. This may mean chopping
    %off the last entry in some fields if this is from a reconstituted file
    f = fields(pd);
    for i=1:numel(f)
        x = eval(['pd.',f{i}]);
        n(i) = numel(x);
    end
    croplength = min(n);
    for i=1:numel(f)
        x = eval(['pd.',f{i}]);
        x = x(1:croplength);
        eval(['pd.',f{i},' = x;']);
    end
    
    sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
    
%% psych_summary
  case 'psych_summary'
    x.hits       = value(hit_history);
	x.violations = value(violation_history);
    x.cpoke1_tups = value(cpoke1_tup_history);    
    x.sounds     = value(previous_sounds);		x.sounds  = x.sounds(1:length(hit_history));
	x.samples    = value(previous_samples);	x.samples = x.samples(1:length(hit_history));
    x.sides      = value(previous_sides);		x.sides   = x.sides(1:length(hit_history));	
    
    x.bupsdata   = PBupsSection(obj, 'get_all_bup_times');
    x.stimdata   = PBupsSection(obj, 'get_all_stimulator_specs');
    
    % peh for FC
    x.choices=x.hits;                        
    nanInds = isnan(x.hits);
    x.choices(~nanInds) = double((x.hits(~nanInds) & x.sides(~nanInds)=='r') | (~x.hits(~nanInds) & x.sides(~nanInds)=='l'));              
    if length(parsed_events_history)<length(x.hits)
        peh = cat(1,parsed_events_history{:},parsed_events);
    elseif length(parsed_events_history)>length(x.hits)
        error('');
    else
        peh = cat(1,parsed_events_history{:});        
    end
    states=cat(1,peh.states);
    left_rewards = logical(cellfun(@length,{states.left_reward}))';
    right_rewards = logical(cellfun(@length,{states.right_reward}))';            
    if any(left_rewards & right_rewards)
        error('Error in parsed event history: some trials have both left and right rewards.');
    end
    if any ( ( (x.hits(~nanInds) & x.sides(~nanInds)=='r') & ~right_rewards(~nanInds)) | ( (x.hits(~nanInds) & x.sides(~nanInds)=='l') & ~left_rewards(~nanInds)) )
        error('Disagreement between pd and peh: some trials have no rewards but hits and sides say there should be.');
    end
    x.choices(x.sides=='f') = right_rewards(x.sides=='f');               
%
    [x.n_left,x.n_right] = deal(nan(size(x.hits)));
    
    for tx=1:numel(x.hits)
         x.n_left(tx)=sum(x.bupsdata{tx}.left<x.samples(tx));
         x.n_right(tx)=sum(x.bupsdata{tx}.right<x.samples(tx));     
    end
    
    x.gamma = cellfun(@(x)x.gamma,x.bupsdata);
    
    
%% update_plot
  case 'update_plot',
    if ~isempty(value(previous_plot)), delete(previous_plot(:)); previous_plot.value = []; end;
    if isempty(previous_sides), return; end; 

    ps = value(previous_sounds); %#ok<NODEF>
    pside = value(previous_sides);

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
    xst     = find(previous_stims ~= 0);
    xblk    = find(isnan(hit_history));
    ygreen  = zeros(size(xgreen));
	yggreen = zeros(size(xggreen));
    yred    = zeros(size(xred));
	yrred   = zeros(size(xrred));
    yblk    = zeros(size(xblk));
    yst     = zeros(size(xst));
    

    for x = 1:length(stim_list),
        i = stim_list(x);
        ygreen(ps(xgreen) == i)   = sidemap(x);
		yggreen(ps(xggreen) == i) = sidemap(x);
        yred(ps(xred) == i)       = sidemap(x);
		yrred(ps(xrred) == i)     = sidemap(x);
        yblk(ps(xblk) == i)       = sidemap(x);
        yst(ps(xst) == i)         = sidemap(x);
      
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
    hst = line(xst, yst, 'Parent', value(myaxes));
    set(hst, 'Color', 'y', 'Marker', '*', 'LineStyle', 'none', 'MarkerSize', 3);

    
    previous_plot.value = [hb; hg; hr; hgg; hrr; hk; hst];
          
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
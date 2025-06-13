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
	
	% a dummy soloparamhandle to control if a pbups probe sound will be
	% played; this is a handle for session_control to determine if this sound
	% is used
	SoloParamHandle(obj, 'use_pbups_probe', 'value', 0);

    % Left/Right antibias, over-rides the antibias in soundtable
    LogsliderParam(obj, 'LR_BiasTau', 30, 10, 400, x, y,  ...
        'label', 'LR bias tau', ...
        'TooltipString', 'Number of trials back over which to compute Left/Right antibias');
    next_row(y);
    NumeditParam(obj, 'LR_Beta', 0, x, y, 'position', [x y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', 'Antibias weight for Left versus Right trials; trumps the antibias beta in soundtable');
    
    % Max times same side can appear
    NumeditParam(obj, 'MaxWithout', Inf, x, y, 'position', [x+100 y 100 20], ...
        'labelfraction', 0.7, ...
        'TooltipString', ...
      sprintf(['\nIf this many trials elapse without a particular stim type being chosen,' ...
      '\nit becomes the obligatory next stim.' ...
      '\nNote that MaxSame rule trumps MaxWithout rule.' ...
      '\nThis currently does not work when using Poisson bups.'])); next_row(y);
    MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', 'Inf'}, 3, ...
        x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');
    next_row(y);
    DispParam(obj, 'ThisSound', 1, x, y, ...
        'TooltipString', 'The id of the stimulus being presented for this trial');
    next_row(y);
    
    DispParam(obj, 'ThisTrial', 'LEFT', x, y); next_row(y);
    SoloParamHandle(obj, 'previous_sides', 'value', 'l');
    SoloParamHandle(obj, 'previous_sounds', 'value', 1);
    SoloParamHandle(obj, 'previous_violations', 'value', 0);
    SoloParamHandle(obj, 'previous_side_lights', 'value', 0);
    
    SubheaderParam(obj, 'title', 'Sides Section', x, y);
    next_row(y, 1.5);
    
    % plot of side choices history at top of window
    pos = get(gcf, 'Position');
    SoloParamHandle(obj, 'myaxes', 'saveable', 0, 'value', axes);
    set(value(myaxes), 'Units', 'pixels');
    set(value(myaxes), 'Position', [90 pos(4)-140 pos(3)-130 100]);
    set(value(myaxes), 'YTick', [1 2], 'YLim', [0.5 2.5]);   
    ToggleParam(obj, 'SortBySides', 0, x, y, 'position', [pos(3)-220 pos(4)-180 100 20], ...
      'OnString', 'Order by sides', 'OffString', 'Orig order', ...
      'TooltipString', sprintf(['\nOrder y axis by original stimulus number or sort ' ...
      '\nstimulus stypes first by left/right']));
    set_callback(SortBySides, {mfilename, 'update_plot'});    
    ToggleParam(obj, 'LeftRightOnly', 0, x, y, 'position', [pos(3)-320 pos(4)-180 100 20], ...
      'OnString', 'L/R only', 'OffString', 'stim type', ...
      'TooltipString', sprintf('\nShow all stim types separately or show sort only by L/R'));
    set_callback(LeftRightOnly, {mfilename, 'update_plot'});
    set_callback_on_load(LeftRightOnly, 1);

    xlabel('trial number');
    SoloParamHandle(obj, 'previous_plot', 'saveable', 0);
    
    
%% next_trial
  case 'next_trial',

    violation_flg = x;
    
    if violation_flg == 0, % if this was not a violation trial, pick the next trial
        switch value(SoundSource),
            case 0, % using sound table
                StimulusSection(obj, 'next_trial', value(hit_history), value(previous_sides), value(previous_sounds));
                choiceprobs = SoundTableSection(obj, 'get_posterior_probs', value(tablename));  
                nstimuli = length(choiceprobs);  

                if nstimuli == 0 || SoundsOn == 0, % if for some reason there's no sounds defined or sounds are off
                    ThisSound.value = 0;
                    if rand(1) < 0.5, 
                        s = 'l';
                        ThisTrial.value = 'LEFT';
                    else
                        s = 'r'; 
                        ThisTrial.value = 'RIGHT';
                    end;
                else  % else there are sounds defined,

                    % if LR_Beta is not zero, keep track of the left/right hitfracs and
                    % choice probabilities
                    if LR_Beta > 0,
                        sides  = cell2mat(SoundTableSection(obj, 'get', value(tablename), 'all_sides'));
                        pprobs = cell2mat(SoundTableSection(obj, 'get', value(tablename), 'all_pprobs'));

                        lr_pprob  = [sum(pprobs(sides=='l')) sum(pprobs(sides=='r'))]; lr_pprob = lr_pprob/sum(lr_pprob);
                        prevs = value(previous_sides); prevs = prevs(1:length(hit_history));

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


                    % Check for MaxSame rules if it applies
                    if ~strcmpi(value(MaxSame), 'Inf') && MaxSame <= n_started_trials,
                        % if there's been a string of MaxSame guys all the same, force change
                        if all(previous_sides(n_started_trials-MaxSame+1:n_started_trials) == previous_sides(n_started_trials)), 
                            if previous_sides(n_started_trials) == 'l',
                                SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'r');
                            else
                                SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'l');
                            end;
                        elseif ~isempty(choices), % if there is a trump LR_Beta, pick next side here
                            if rand(1) > choices(1);
                                SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'r');
                            else
                                SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'l');
                            end;
                        end;
                        choiceprobs = SoundTableSection(obj, 'get_posterior_probs', value(tablename));
                    elseif ~isempty(choices),                    
                    % if MaxSame rules do not apply, but LR_Beta > 0, just pick the next side
                        if rand(1) > choices(1);
                            SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'r');
                        else
                            SoundTableSection(obj, 'update_biashitfrac', value(tablename), 'l');
                        end;
                        choiceprobs = SoundTableSection(obj, 'get_posterior_probs', value(tablename));                
                    end;

                    % Check for MaxWithout rules if it applies
                    if MaxWithout ~= Inf
                        max_without_set = []; % the set of stims types to which the rule applies
                        for i = 1:nstimuli,
                            % find last time used
                            u = find(previous_sounds == i, 1, 'last');

                            % if it's never been used, then set the last use trial to zero
                            if isempty(u), u = 0; end; 

                            % if thie trial type is in use and we've gone MaxWithout trials
                            % without it, then add it to the to-be-chosen set
                            if choiceprobs(i) > 0 && n_started_trials - u >= MaxWithout,
                                max_without_set = [max_without_set i];
                            end;
                        end;

                        if ~isempty(max_without_set)
                            set_to_zero = setdiff(1:nstimuli, max_without_set);
                            choiceprobs(set_to_zero) = 0;
                            choiceprobs = choiceprobs/sum(choiceprobs);
                        end;
                    end;
        % 
        %             % if sounds are on, use local_sound picked from choiceprobs
        %             % if sounds are off, set ThisSound to zero, but still use
        %             % local_sound to determine the correct next side
        %             local_sound = find(cumsum(choiceprobs) > rand(1), 1, 'first');
        %             if SoundsOn == 1,  
        %                 ThisSound.value = local_sound;
        %             else               
        %                 ThisSound.value = 0;
        %             end;

                    choiceprobs = choiceprobs/sum(choiceprobs);
                    ThisSound.value = find(cumsum(choiceprobs) > rand(1), 1, 'first');
                    s = SoundTableSection(obj, 'get', value(tablename), value(ThisSound), 'side');
                    if strcmp(s, 'l');
                        ThisTrial.value = 'LEFT';
                    else
                        ThisTrial.value = 'RIGHT';
                    end;
                end;
                % end using sound table
            case 1, % if we're using Poisson bups
                % if LR_Beta is not zero, keep track of the left/right hitfracs and
                % choice probabilities
                if LR_Beta > 0,
                    lr_pprob  = PBupsSection(obj, 'get', 'pprobs');
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
                
                [this_sound this_side] = PBupsSection(obj, 'next_trial', this_side, value(use_pbups_probe));
                ThisSound.value = this_sound;
                if strcmp(this_side, 'l');
                    ThisTrial.value = 'LEFT';
                else
                    ThisTrial.value = 'RIGHT';
                end;
                % end using Poisson bups
        end; % end switch
        feval(mfilename, obj, 'update_trial_info');
    end;  % end if not violation trial
    
%% update_trial_info
  case 'update_trial_info'
    
    % update previous_sides and previous_sounds
    if strcmp(value(ThisTrial), 'LEFT'), %#ok<NODEF>
        s = 'l';
    else
        s = 'r';
    end
    if n_done_trials == 0,
        previous_sides.value  = s;
        previous_sounds.value = value(ThisSound);
        previous_side_lights.value = DistribInterface(obj,'get_current_sample','side_lights_dur');

    elseif n_done_trials > 0,
        previous_sides.value  = [previous_sides(:); s];
        previous_sounds.value = [previous_sounds(:); value(ThisSound)];
        previous_side_lights.value = [previous_side_lights(:); DistribInterface(obj,'get_current_sample','side_lights_dur')];
        
    end

%% get_current_hitfrac
    case 'get_current_hitfrac',
        
        sides=value(previous_sides(1:numel(hit_history)));
        hits=value(hit_history);
        % Get the stimulation history so you can exclude those trials from
        % calculation of the current_hitfrac
        stim_hist=StimulatorSection(SameDifferent,'get','stimulator_history');
        stim_hist=stim_hist(1:numel(hit_history));
        stim_hist=stim_hist(:);
        hits(stim_hist==1)=nan;
        
        x=exponential_hitfrac(sides, hits, value(LR_BiasTau), 'rl');
        
        

%% get_previous_sides
  case 'get_previous_sides', 
    x = value(previous_sides); %#ok<NODEF>
 
    case 'get_previous_sounds',
        x=value(previous_sounds);
    
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
    pd.hits   = value(hit_history);
    pd.hits = pd.hits(1:n_completed_trials);
    pd.sounds = value(previous_sounds);
    pd.sounds = pd.sounds(1:n_completed_trials);
    pd.sides  = value(previous_sides);
    pd.sides  = pd.sides(1:n_completed_trials);
    pd.sldur  = value(previous_side_lights);
    pd.sldur  = pd.sldur(1:n_completed_trials);
    
	S = StimulusSection(obj, 'get_send_summary_info',n_completed_trials);
	if isstruct(S)
	fn=fieldnames(S);
	for sx=1:numel(fn)
		pd.(fn{sx})=S.(fn{sx});
	end
    end
    
    S = RewardsSection(obj, 'get_send_summary_info',n_completed_trials);
	if isstruct(S)
	fn=fieldnames(S);
	for sx=1:numel(fn)
		pd.(fn{sx})=S.(fn{sx});
	end
    end
    
    S = StimulatorSection(obj, 'get_send_summary_info',n_completed_trials);
	if isstruct(S)
	fn=fieldnames(S);
	for sx=1:numel(fn)
		pd.(fn{sx})=S.(fn{sx});
	end
	end
	
    pd=ReinforcementSection(obj,'add_to_pd',pd);
	
    if SoundSource == 0,  % if we're using the sound table
        pd.soundtable = SoundTableSection(obj, 'get', value(tablename), 'stims');
        pd.bupsdata = {};
    else  % if we're using Poisson bups
        pd.soundtable = {};
        pd.bupsdata = PBupsSection(obj, 'get_all_bup_times');
    end;
    
    peh=get_sphandle('fullname','n_parsed_events');
    peh=get_history(peh{1});
    peh=cell2mat(peh);
    
    [csv,cout]=calc_cout(peh);
    
    
     pd.cout=cout;  % we are guaranteed that peh is n_completed_trials long.
     pd.csv=csv;
    
     [pd,peh]=fix_sizes_in_pd(pd,peh);
     gos=extract_event(peh,'cpoke1(end,2)');
     spk=extract_event(peh,'wait_for_spoke(1,2)');
     ton=extract_event(peh,'wait_for_spoke(1,1)');
     pd.mit=pd.cout-gos;
     pd.mt=spk-ton;
     
    sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
    
    
%% update_plot
  case 'update_plot',
    if ~isempty(value(previous_plot)), delete(previous_plot(:)); previous_plot.value = []; end;
    if isempty(previous_sides), return; end; 

    ps = value(previous_sounds); %#ok<NODEF>
    try
        if SoundSource == 0,
            nstims = SoundTableSection(obj, 'get', value(tablename), 'nstims');
        else
            nstims = PBupsSection(obj, 'get', 'nstimuli');
        end;
    catch
        nstims = 0;
    end;
    if nstims == 0 || SoundsOn == 0, return; end;

    if SoundSource == 0,
        sides = SoundTableSection(obj, 'get', value(tablename), 'all_sides');
        sidemap = 1:nstims;  % j=sidemap(i) => stimulus number i goes to row j in plot
        stim_list = sidemap;
        if SortBySides==1,
          [trash, trash2] = sort(sides); 
          [trash, sidemap] = sort(trash2); % j=sidemap(i) => stimulus number i goes to row j in plot
        end;
        if LeftRightOnly==1,
          for i=1:nstims,
            if sides{i}=='l', sidemap(i) = 2; else sidemap(i) = 1; end;
          end;
        end;
        soundname = 'Sound';
    else
        sides = PBupsSection(obj, 'get', 'all_sides');
        sides = cellstr(sides');  % turns it into a cell array of characters where each row is a trial type
        nleft = PBupsSection(obj, 'get', 'nleft');
        nright = PBupsSection(obj, 'get', 'nright');
        sidemap = [-nright:-1 1:nleft];
        stim_list = sidemap;
        if LeftRightOnly == 1,
            sidemap(sidemap<0) = -1;
            sidemap(sidemap>0) = 1;
        end;
        soundname = 'PBups';
    end;
    
    if ps(end) ~= 0,
        hb = line(length(ps), sidemap(find(stim_list==ps(end))), 'Parent', value(myaxes));
        set(hb, 'Color', 'b', 'Marker', '.', 'LineStyle', 'none');
    else
        hb = [];
    end
    
    xgreen = find(hit_history==1);
    xred   = find(hit_history==0);
    xblack = find(isnan(value(hit_history)));
    ygreen = zeros(size(xgreen));
    yred   = zeros(size(xred));
    yblack = zeros(size(xblack));
    for x = 1:length(stim_list),
        i = stim_list(x);
        i_green = find(ps(xgreen) == i);
        ygreen(i_green) = sidemap(x); %#ok<FNDSB>
        i_red = find(ps(xred) == i);
        yred(i_red) = sidemap(x); %#ok<FNDSB>
        i_black = find(ps(xblack) == i);
        yblack(i_black) = sidemap(x); %#ok<FNDSB>
    end;
    
    hg = line(xgreen, ygreen, 'Parent', value(myaxes));
    set(hg, 'Color', 'g', 'Marker', '.', 'LineStyle', 'none');
    hr = line(xred, yred, 'Parent', value(myaxes));
    set(hr, 'Color', 'r', 'Marker', '.', 'LineStyle', 'none');
    hk = line(xblack, yblack, 'Parent', value(myaxes));
    set(hk, 'Color', 'k', 'Marker', '.', 'LineStyle', 'none');
    
    previous_plot.value = [hb; hr; hg; hk];
          
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
   pause(0.1);
      
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
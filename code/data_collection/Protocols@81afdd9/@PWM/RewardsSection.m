% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.
%
%
% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
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
%            'get_stimulus'   Returns either (1) a structure with fields 'type'
%                        and 'duration', with the contents of 'type' being
%                        'lights' and the contents of 'duration' the
%                        maximum duration, in secs, of the stimulus; or (2) a
%                        structure with the fields 'type', 'duration', and
%                        'id', with contents 'sounds', duration of sound in
%                        secs, and integer sound_id, respectively.
%
%            'get_poked_trials'   Returns a double, number of trials in
%                        which subject poked in the appropriate poke at
%                        some point.
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
%
% x        When action == 'get_current_side', returns either the string 'l'
%          or the string 'r', for Left and Right, respectively.
%


function [x, y] = RewardsSection(obj, action, x, y)
   
GetSoloFunctionArgs(obj);

switch action


    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
    
        %% start from OverallPerformanceSection
        DispParam(obj, 'ntrials', 0, x, y); next_row(y);
        DispParam(obj, 'violation_rate', 0, x, y, 'TooltipString', ...
                  'Fraction of trials with a center poke violation'); next_row(y);
        DispParam(obj, 'timeout_rate', 0, x, y, 'TooltipString', ...
                  'Fraction of trials with timeout'); next_row(y);
        DispParam(obj, 'Left_hit_frac', 0, x, y, 'TooltipString', ...
                  'Fraction of correct Left trials'); next_row(y);
        DispParam(obj, 'Right_hit_frac', 0, x, y, 'TooltipString', ...
                  'Fraction of correct Right trials'); next_row(y);
        DispParam(obj, 'hit_frac', 0, x, y, 'TooltipString', ...
                  'Fraction of correct trials'); next_row(y);
        DispParam(obj, 'goodleft', 0, x,y);
        next_row(y);
        DispParam(obj,'goodright',0,x,y);
        next_row(y);
        DispParam(obj,'nRewarded',0,x,y);
        next_row(y);
        DeclareGlobals(obj, 'ro_args', 'goodleft');
        DeclareGlobals(obj, 'ro_args', 'goodright');

        
        MenuParam(obj, 'ControlTask', {'none', 'light chasing', 'no 1st sound', 'fixed 1st sound'}, ...
                  'none', x, y, 'TooltipString', sprintf(['\n choose type of control task \n' ...
                  'LIGHT CHASING means side light goes on at beginning of trial \n'...
                  'and indicates rewarded port \n'...
                  'NO 1ST SOUND is a categorization task with S2 only \n'...
                  'FIXED 1ST SOUND is a categorization task comparing a fixed S1 to variable S2s \n'])); 
        next_row(y);
        DeclareGlobals(obj, 'ro_args', 'ControlTask');
        
        NumeditParam(obj, 'ControlTaskFreq',0,x,y,'label','ControlTaskFreq','TooltipString','Frequency of trials that follow rules of control task');
        next_row(y);
        DeclareGlobals(obj, 'ro_args', 'ControlTaskFreq');
        
        MenuParam(obj, 'RewardFromPoke', {'cpoke', 'spoke'}, ...
                  'cpoke', x, y, 'TooltipString', sprintf(['\n mostly for training stages, \n' ...
                  'spoke means for stages 1-3, reward is based on side poking'])); next_row(y);
        DeclareGlobals(obj, 'ro_args', 'RewardFromPoke');
        ToggleParam(obj, 'RewardSound', 1, x, y, ...
                    'OnString', 'Reward Sounds ON', ...
                    'OffString', 'Reward Sounds OFF', ...
                    'TooltipString', 'turns on/off reward sounds'); next_row(y);
        DeclareGlobals(obj, 'ro_args', 'RewardSound');
        
        SubheaderParam(obj, 'title', 'Rewards Section', x, y);
        next_row(y, 1.5);
        SoloParamHandle(obj, 'previous_parameters', 'value', []);

    %---------------------------------------------------------------%
    %          evaluate                                             %
    %---------------------------------------------------------------%
    case 'evaluate'
  
        reward = SideSection(obj,'get_reward');
        

        if n_done_trials > 1,
            if hit_history(end) == 1;
            nRewarded.value = value(nRewarded)+1;
            else
                if violation_history(end)== 0;
                    if ~strcmp(reward,'NoReward')
                        nRewarded.value=value(nRewarded)+1;
                    end
                end
            end
            ntrials.value        = n_done_trials;
            violation_rate.value = numel(find(violation_history))/n_done_trials;
            timeout_rate.value = numel(find(timeout_history))/n_done_trials;
            good  = ~isnan(hit_history)';
            goods  = good(1:n_done_trials);
            lefts  = previous_sides(1:n_done_trials)=='l';
            rights = previous_sides(1:n_done_trials)=='r';
            goodleft.value = sum(hit_history(goods & lefts));
            goodright.value = sum(hit_history(goods & rights));
            Left_hit_frac.value  = mean(hit_history(goods & lefts));
            Right_hit_frac.value = mean(hit_history(goods & rights));
            hit_frac.value       = mean(hit_history(goods));
        end;
    
        if nargout > 0,
            x = [n_done_trials, value(violation_rate), value(timeout_rate), value(Left_hit_frac), ...
                value(Right_hit_frac), value(hit_frac), value(goodleft), value(goodright), value(nRewarded)];
        end;


    %---------------------------------------------------------------%
    %          get_poked_trials                                     %
    %---------------------------------------------------------------%
    case 'get_poked_trials',
        x = value(poked_trials); %#ok<NODEF>
        return;


    %---------------------------------------------------------------%
    %          add_to_pd                                            %
    %---------------------------------------------------------------%
    case 'add_to_pd'
        x.reward_time=cell2mat(get_history(RewardTime));
    

    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
    case 'prepare_next_trial',
        if isempty(parsed_events), return; end;    
        if ~isempty(previous_sides), %#ok<NODEF>          
            previous_sides = previous_sides(:);
            wdh = get_history(WaterDelivery); 
        if isempty(wdh), wdh{1}='direct'; end; % fix for wierd bug
        switch value(wdh{end}),
            case 'direct',                  csstate = 'direct_cs';
            case 'on correct poke',         csstate = 'cs';
            case 'on correctly timed poke', csstate = 'rewardable_cs';
            otherwise
              error('huh?');
        end;
        cs_onset = parsed_events.states.(csstate)(1,1);
        if isequal(PWMSection(obj, 'get_last_stimulus_loc'), 'anti-loc'),
            if previous_sides(end)=='l', poke = 'R'; else poke = 'L'; end;
            else
                if previous_sides(end)=='l', poke = 'L'; else poke = 'R'; end;
            end;
            mypokes = parsed_events.pokes.(poke)(:,1);
      
            if ~isempty(find(mypokes > cs_onset,1))
                poked_trials.value = poked_trials+1; %#ok<NODEF>
                consec_p_trials.value  = consec_p_trials+1; %#ok<NODEF>
                consec_up_trials.value = 0;
            else
                consec_p_trials.value  = 0;
                consec_up_trials.value = consec_up_trials+1; %#ok<NODEF>
            end
        end;
    
        if rows(parsed_events.states.lefthit)>0 || rows(parsed_events.states.righthit)>0,
            r_trials.value = [r_trials(1:n_done_trials-1) 1]; %#ok<NODEF>
            rewarded_trials.value = rewarded_trials+1; %#ok<NODEF>
            consec_r_trials.value = consec_r_trials+1; %#ok<NODEF>
        else
            r_trials.value = [r_trials(1:n_done_trials-1) 0]; %#ok<NODEF>
            consec_r_trials.value = 0;
        end;
    
        hit_history.value = value(r_trials);
    
        n_trials.value = n_trials+1; %#ok<NODEF>

    
        % Compute reaction times only for non-direct delivery modes:
        if strcmp(csstate, 'direct_cs'),
            consec_q_trials.value = 0;
        else
            if rows(parsed_events.states.lefthit>0)
                rt.value = parsed_events.states.lefthit(1,1)  - parsed_events.states.(csstate)(1,1);
            elseif rows(parsed_events.states.righthit>0)
                rt.value = parsed_events.states.righthit(1,1) - parsed_events.states.(csstate)(1,1);
            else
                warning('CLASSICAL:No_hit_state', 'No lefthit or righthit -- not computing rt!');
            end;

            if rt < rtThreshold, consec_q_trials.value = consec_q_trials + 1; %#ok<NODEF>
            else                 consec_q_trials.value = 0;
            end;
        end;
    
        % Now compute the good poke ratio stuff
        if ~isempty(previous_sides),
            preCSonset_pokes = ...
                length(find(parsed_events.states.(csstate)(1,1)-PokeMeasureTime < mypokes & ...
                mypokes < parsed_events.states.(csstate)(1,1)));
            postCSonset_pokes = ...
                length(find(parsed_events.states.(csstate)(1,1) < mypokes & ...
                mypokes < parsed_events.states.(csstate)(1,1)+PokeMeasureTime));
            if preCSonset_pokes > 0,      PokeRatio.value = postCSonset_pokes / preCSonset_pokes;
            elseif postCSonset_pokes > 0, PokeRatio.value = Inf;
            else                          PokeRatio.value = 0;
            end;
            if PokeRatio > PokeRatioThreshold,
                good_trials.value = good_trials+1; %#ok<NODEF>
                consec_g_trials.value = consec_g_trials+1; %#ok<NODEF>
            else
                consec_g_trials.value = 0;
            end;      
        end;


    %---------------------------------------------------------------%
    %          control                                              %
    %---------------------------------------------------------------%
    case 'control',
        % get control info for comments section
        if nargout>0
            if strcmp(ControlTask,'light chasing')
                x = ['lights' num2str(ControlTaskFreq)];
            elseif strcmp(ControlTask,'no 1st sound')
                x = ['nofirst' num2str(ControlTaskFreq)];        
            elseif strcmp(ControlTask,'fixed 1st sound')
                x = ['fixedfirst' num2str(ControlTaskFreq)];
            elseif strcmp(ControlTask,'none')
                x= ['none'];
            else
                if ControlTaskFreq == 0
                    x= ['none'];
                else
                    x = ['?control?'];
                end
            end
        end;


    %---------------------------------------------------------------%
    %          close                                                %
    %---------------------------------------------------------------%
    case 'close',
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
          'fullname', ['^' mfilename]);


    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
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
        
end




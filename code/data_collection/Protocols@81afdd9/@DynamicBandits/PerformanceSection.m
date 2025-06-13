% [x, y] = ParamsSection(obj, action, x, y)
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



function [x, y] = PerformanceSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',

        SoloParamHandle(obj,'reward_history','value',[]);
        SoloParamHandle(obj,'better_choices_history','value',[]);
        SoloParamHandle(obj,'sides_history','value',[]);
        SoloParamHandle(obj,'trial_type_history','value',[]);
        SoloParamHandle(obj,'cpoke_viol_history','value',[]);
        SoloParamHandle(obj,'viol_history','value',[]);
        
        DispParam(obj,'right_choices',0,x,y);
        next_row(y);
        DispParam(obj,'left_choices',0,x,y);
        next_row(y);
        
        DispParam(obj,'cpoke_violation_frac',0,x,y);
        next_row(y);
        DispParam(obj,'cpoke_violations',0,x,y);
        next_row(y);
        DispParam(obj,'violation_frac',0,x,y);
        next_row(y);
        DispParam(obj,'violation_trials',0,x,y);
        next_row(y);
        DispParam(obj,'better_choices_last50',0,x,y);
        next_row(y);
        DispParam(obj,'better_choices_frac',0,x,y);
        next_row(y);
        DispParam(obj,'better_choices',0,x,y);
        next_row(y);
        DispParam(obj,'reward_frac_last50',0,x,y);
        next_row(y);
        DispParam(obj,'reward_frac',0,x,y);
        next_row(y);
        DispParam(obj,'rewarded_trials',0,x,y);
        next_row(y);
        DispParam(obj,'nTrials',0,x,y);
        next_row(y);


        SubheaderParam(obj, 'title', 'Performance Section', x, y);
        next_row(y, 1.5);
        
        % Big plot at the top to display data
        pos = get(gcf, 'Position');
        SoloParamHandle(obj, 'axes1', 'saveable', 0, 'value', axes);
        set(value(axes1), 'Units', 'pixels');
        set(value(axes1), 'Position', [90 pos(4)-130 pos(3)-130 100]);
        set(value(axes1), 'YLim', [0 1]);
        ylabel('Context 1');
        
        SoloParamHandle(obj, 'axes2', 'saveable', 0, 'value', axes);
        set(value(axes2), 'Units', 'pixels');
        set(value(axes2), 'Position', [90 pos(4)-275 pos(3)-130 100]);
        set(value(axes2), 'YLim', [0 1]);
        ylabel('Context 2');
        xlabel('Trials');
        
        NumeditParam(obj,'smoothing',10,0,0,'position',[300 pos(4)-325 90 20],'labelfraction',0.75);
        set_callback(smoothing, {mfilename, 'update_plot'});
        set_callback_on_load(smoothing, 1);
        
        legend({'Right Reward Prob','Left Reward Prob','Probability of Right Choice'},'Location',[10 pos(4)-325 100 50]);
        SoloParamHandle(obj, 'previous_axes', 'saveable', 0);
        
        drawnow;

    case 'next_trial'
        
        
        nTrials.value = value(nTrials) + 1;
        
        if value(nTrials) > 0 % If the trial that we're preparing is NOT the first trial, record all the history stuff
        
        right_reward_visited = isfield(parsed_events.states, 'right_reward_state') && rows(parsed_events.states.right_reward_state) > 0;
        left_reward_visited = isfield(parsed_events.states, 'left_reward_state') && rows(parsed_events.states.left_reward_state) > 0;
        right_unreward_visited = isfield(parsed_events.states, 'right_unreward_state') && rows(parsed_events.states.right_unreward_state) > 0;
        left_unreward_visited = isfield(parsed_events.states, 'left_unreward_state') && rows(parsed_events.states.left_unreward_state) > 0;
        
        forgiveness_went_right = isfield(parsed_events.states, 'forgiveness_wait_for_left') && rows(parsed_events.states.forgiveness_wait_for_left) > 0;
        forgiveness_went_left = isfield(parsed_events.states, 'forgiveness_wait_for_right') && rows(parsed_events.states.forgiveness_wait_for_right) > 0;
        
        forgiveness_used = (isfield(parsed_events.states, 'forgiveness_right') && rows(parsed_events.states.forgiveness_right) > 0) || ...
            (isfield(parsed_events.states, 'forgiveness_left') && rows(parsed_events.states.forgiveness_left) > 0);
        
        if  right_reward_visited || left_reward_visited
            rewarded_trials.value = rewarded_trials + 1;
            reward = 1;
        else
            reward = 0;
        end
        
        
        if (right_reward_visited && ~forgiveness_used) || right_unreward_visited || (left_reward_visited && forgiveness_used) || forgiveness_went_right
            right_choices.value = right_choices + 1;
            sides_history.value = [sides_history(:);'r'];
            sideChosen = 'r';
        elseif (left_reward_visited && ~forgiveness_used) || left_unreward_visited || (right_reward_visited && forgiveness_used) || forgiveness_went_left
            left_choices.value = left_choices + 1;
            sides_history.value = [sides_history(:);'l'];
            sideChosen = 'l';
        else
            sides_history.value = [sides_history(:);'v'];
            sideChosen = 'v';
        end
            
        betterSide = BanditsSection(obj,'get_better_side');
        banditsSectionHistories = BanditsSection(obj,'get_histories');
        
        
        
        if betterSide == sideChosen
            better_choices.value = better_choices + 1;
            better_choices_history.value = [better_choices_history(:);1];
        else
            better_choices_history.value = [better_choices_history(:);0];
        end
        
        better_choices_frac.value = sum(better_choices_history(banditsSectionHistories.trial_type_history == 'f')) / sum(banditsSectionHistories.trial_type_history == 'f');
        
        if isfield(parsed_events.states, 'cpoke_violation') && rows(parsed_events.states.cpoke_violation) > 0
            cpoke_violations.value = cpoke_violations + 1;
            cpoke_viol = 1;
        else
            cpoke_viol = 0;
        end
        
        if isfield(parsed_events.states, 'violation_penalty') && rows(parsed_events.states.violation_penalty) > 0
            violation_trials.value = violation_trials + 1;
            viol = 1;
        else
            viol = 0;
        end
        
        reward_history.value = [reward_history(:);reward];
        cpoke_viol_history.value = [cpoke_viol_history(:);cpoke_viol];
        viol_history.value = [viol_history(:);viol];
        
        reward_frac.value = mean(reward_history(:));
        if length(reward_history(:)) >= 50
            reward_frac_last50.value = mean(reward_history(end-49:end));
        end
        better_choices_history_freeonly = better_choices_history(banditsSectionHistories.trial_type_history == 'f');
        if length(better_choices_history_freeonly(:)) >= 50
            better_choices_last50.value = mean(better_choices_history_freeonly(end-49:end));
        end
        
        
        violation_frac.value = sum(viol_history(:)) / sum(banditsSectionHistories.trial_type_history ~= 'f');
        
        cpoke_violation_frac.value = mean(cpoke_viol_history(:)); 
        
        end
        
        PerformanceSection(obj,'update_plot');
        
    case 'update_plot' 
        
        
        % First, clear the plot
        if ~isempty(value(previous_axes)) 
            delete(previous_axes(:)); 
            previous_axes.value = []; 
        end;
        drawnow;
        
        try
        set(value(axes1), 'XLim', [0.9 value(nTrials)]);
        set(value(axes2), 'XLim', [0.9 value(nTrials)]);
        
        bsHistories = BanditsSection(obj,'get_histories');
        
        nTrials = length(sides_history(:));
        choices = double(sides_history(:)=='r');
        choices(bsHistories.trial_type_history(1:nTrials) ~= 'f') = NaN;
        
        choices_c1 = choices;
        choices_c2 = choices;
        choices_c1(bsHistories.context_history==1) = NaN;
        choices_c2(bsHistories.context_history==0) = NaN;
        
        choices_c1_r = choices_c1; choices_c1_u = choices_c1;
        choices_c2_r = choices_c2; choices_c2_u = choices_c2;
        
        choices_c1_r(reward_history==0) = NaN;
        choices_c1_u(reward_history==1) = NaN;
        choices_c2_r(reward_history==0) = NaN;
        choices_c2_u(reward_history==1) = NaN;
        
        choices_c1_smoothed = smooth(choices_c1,value(smoothing));
        choices_c2_smoothed = smooth(choices_c2,value(smoothing));
        
        nHistories = length(bsHistories.right_prob1_history);
        nChoices1 = length(choices_c1_smoothed);
        nChoices2 = length(choices_c2_smoothed);
        
        rp1 = line(1:nHistories,bsHistories.right_prob1_history,'Color','blue','Parent',value(axes1));
        lp1 = line(1:nHistories,bsHistories.left_prob1_history,'Color','red','Parent',value(axes1));
        rp2 = line(1:nHistories,bsHistories.right_prob2_history,'Color','blue','Parent',value(axes2));
        lp2 = line(1:nHistories,bsHistories.left_prob2_history,'Color','red','Parent',value(axes2));
        chs1 = line(1:nChoices1,choices_c1_smoothed,'Parent', value(axes1),'Color','black');
        chs2 = line(1:nChoices2,choices_c2_smoothed,'Parent',value(axes2),'Color','black');
        
        chr1 = line(1:nChoices1,choices_c1_r,'Parent',value(axes1));
        chu1 = line(1:nChoices1,choices_c1_u,'Parent',value(axes1));
        chr2 = line(1:nChoices2,choices_c2_r,'Parent',value(axes2));
        chu2 = line(1:nChoices2,choices_c2_u,'Parent',value(axes2));
        set(chr1, 'Color', 'g', 'Marker', 'o', 'LineStyle', 'none');
        set(chu1, 'Color', 'r', 'Marker', 'o', 'LineStyle', 'none');
        set(chr2, 'Color', 'g', 'Marker', 'o', 'LineStyle', 'none');
        set(chu2, 'Color', 'r', 'Marker', 'o', 'LineStyle', 'none');
        
        previous_axes.value = [chs1,chs2,rp1,lp1,rp2,lp2,chr1,chr2,chu1,chu2];
        %pos = get(gcf, 'Position');
        legend1 = legend({'Right Reward Prob','Left Reward Prob','Probability of Right Choice'});
        
        set(legend1,'Units','pixels','Position',[6.2 343 211 60]);
        drawnow;
        
        catch
            warning('Unable to update the plot - perhaps you''re looking at data from before 8/1?');
        end
        
    case 'get_all'
        
        x.reward_history = value(reward_history);
        x.sides_history = value(sides_history);
        x.cpoke_viol_history = value(cpoke_viol_history);
        x.viol_history = value(viol_history);
        x.better_choices_history = value(better_choices_history);

end
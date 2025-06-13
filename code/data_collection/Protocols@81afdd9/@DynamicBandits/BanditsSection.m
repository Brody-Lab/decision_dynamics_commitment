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


function [x, y] = BanditsSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %% init
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
              
        % Histories
        SoloParamHandle(obj,'trial_type_history','value',[]);
        SoloParamHandle(obj,'left_baited_history','value',[]);
        SoloParamHandle(obj,'right_baited_history','value',[]);
        SoloParamHandle(obj,'context_history','value',[]);
        SoloParamHandle(obj,'left_prob1_history','value',[]);
        SoloParamHandle(obj,'right_prob1_history','value',[]);
        SoloParamHandle(obj,'left_prob2_history','value',[]);
        SoloParamHandle(obj,'right_prob2_history','value',[]);
        
        % Context One
        NumeditParam(obj,'LeftBaitProb1',0.5,x,y,'TooltipString','What is the probability of reward on the left side?')
        next_row(y);
        NumeditParam(obj,'RightBaitProb1',0.5,x,y,'TooltipString','What is the probability of reward on the right side?')
        next_row(y);
        [x,y] = SoundInterface(obj,   'add', 'Context1',    x, y);
        next_row(y,0.5);
        next_column(x); y=5;
        
        % Context Two
        NumeditParam(obj,'LeftBaitProb2',0.5,x,y,'TooltipString','What is the probability of reward on the left side?')
        next_row(y);
        NumeditParam(obj,'RightBaitProb2',0.5,x,y,'TooltipString','What is the probability of reward on the right side?')
        next_row(y);
        [x,y] = SoundInterface(obj,   'add', 'Context2',    x, y);
        next_row(y,0.5);
        y2 = y;
        next_column(x,-1);
        
        % This Trial stuff
        % Things relating to reward
        NumeditParam(obj,'min_water',5,x,y,'TooltipString','The smallest amount of water that the system will give out - less than this gets rounded to zero');
        next_row(y);
        NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
            'position', [x y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'all left reward times are multiplied by this number');
          NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
            'position', [x+100 y 100 20], ...
            'labelfraction', 0.7, ...
            'TooltipString', 'all right reward times are multiplied by this number');
        next_row(y);
        DispParam(obj,'LeftBaited',1,x,y,'TooltipString','Is a reward available on the left side this trial?')
        next_row(y);
        DispParam(obj,'RightBaited',1,x,y,'TooltipString','Is a reward available on the right side this trial?')
        next_row(y);
        ToggleParam(obj,'Trial_Context',0,x,y,'OffString','Context One','OnString','Context Two');
        next_row(y);
        MenuParam(obj,'Trial_Type', {'Free Trial','Forced: Right','Forced: Left','Instructed'}, 1, x, y,...
            'TooltipString', sprintf(['\n' ...
            'On a free trial, the rat can choose which poke to select - in a forced trial, the rat is required to go to the specified side. Trial type will be indicated to the rat using the lights.']));
        set_callback(Trial_Type, {mfilename,'update_baiting'});
        next_row(y);
        SubheaderParam(obj, 'title1', 'This Trial', x, y);
        next_row(y);
        
        
        
        y = y2;
        next_column(x);
        
        % Global Stuff
         ToggleParam(obj,'varyProbability',1,x,y,'OnString','Vary reward probability','OffString','Vary reward quantity','TooltipString','If black: parameters "rightBaitProb1" etc control reward probability.  If brown, they control the reward quantity available.  Variable names are unchanged to avoid sinking the ship of Theseus');
         next_row(y);
        ToggleParam(obj,'enableContexts',1,x,y,'OnString','Context Two Enabled','OffString','Context Two Disabled');
        next_row(y);
        set_callback(enableContexts, {mfilename,'enable_contexts'});
        
        NumeditParam(obj,'pContextOne',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'pInstructed',0,x,y);
        next_row(y);
        NumeditParam(obj,'pForceRight',0.1,x,y);
        next_row(y);
        NumeditParam(obj,'pForceLeft',0.1,x,y);
        next_row(y);
        NumeditParam(obj,'pChoice',0.8,x,y);
        next_row(y);
        
        % Antibias stuff
        LogsliderParam(obj, 'antibias_tau', 30, 10, 400, x, y,  ...
            'label', 'antibias tau', ...
            'TooltipString', 'Number of trials back over which to compute Left/Right antibias');
        next_row(y);
        NumeditParam(obj, 'antibias_beta', 0, x, y, ...
            'TooltipString', 'Antibias weight for Context 1 vs Context 2: if nonzero, overrides the parameter pContextOne');
        next_row(y);
        SubheaderParam(obj, 'title2', 'All Trials', x, y);
        next_row(y,1.5);
        
        next_column(x,-1);
        HeaderParam(obj, 'title3', 'Bandits Section', x, y,'width',400,'HorizontalAlignment','center');
        next_row(y, 2.5);
        next_column(x);
        
        set_callback(LeftBaitProb1, {mfilename, 'update_baiting'});
        set_callback(RightBaitProb1, {mfilename, 'update_baiting'});
        set_callback(LeftBaitProb2, {mfilename, 'update_baiting'});
        set_callback(RightBaitProb2, {mfilename, 'update_baiting'});
        set_callback(Trial_Context, {mfilename, 'update_baiting'});
        
        
        
        BanditsSection(obj,'update_baiting');
        
        
        %% Prepare next trial
    case 'prepare_next_trial'
        % Get ready for the next trial - first, decide which context we
        % should be using (remember it's 0 for context one, 1 for context
        % two)
        
        % First drift the values
        x = DriftSection(obj,'drift',[value(LeftBaitProb1),value(RightBaitProb1),value(LeftBaitProb2),value(RightBaitProb2)]);
        
        LeftBaitProb1.value = x(1);
        RightBaitProb1.value = x(2);
        LeftBaitProb2.value = x(3);
        RightBaitProb2.value = x(4);
        
        if ~value(enableContexts) % Context two is disabled - all trials will be context one
            context = 0;
        elseif antibias_beta > 0 % antibiasing is enabled - we need to compute the ppropriate context
            
            ps_history = PerformanceSection(obj,'get_all');
            hit_history = ps_history.better_choices_history;
            hit_history(value(trial_type_history)~='f') = NaN;
            
            ch = value(context_history);
            ch = ch(1:end-1);
            c1_hit_history = hit_history(ch(1:end-1)==0);
            c2_hit_history = hit_history(ch(1:end-1)==1);
            
            kernel = exp(-(0:length(hit_history)-1)/antibias_tau)';
            kernel = kernel(end:-1:1);
            
            if ~isempty(c1_hit_history)
                c1_hits = nansum(hit_history(ch==0) .* kernel(ch==0)/sum(kernel(ch==0)));
            else
                c1_hits = 0;
            end
            
            %bias_left_hitfrac = nansum(hit_history(ul) .* kernel(ul))/sum(kernel(ul));
            
            if ~isempty(c2_hit_history)
                c2_hits = nansum(hit_history(ch==1) .* kernel(ch==1)/sum(kernel(ch==1)));
            else
                c2_hits = 0;
            end
            
            p = probabilistic_trial_selector([c1_hits,c2_hits],[value(pContextOne),1-value(pContextOne)],value(antibias_beta));
            
            context = rand > p(1);
            
        else % We need to choose the context randomly
            context = rand > pContextOne;
        end
        Trial_Context.value = context;
        
        % Next, decide what kind of trial this wil be - force left, force
        % right, or choice
        BanditsSection(obj,'normalize'); % Make sure the probabilities sum to one
        
        r = rand;
        if r < value(pChoice)
            Trial_Type.value = 'Free Trial';
        elseif r < value(pChoice) + value(pForceLeft)
            Trial_Type.value = 'Forced: Left';
        elseif r < value(pChoice) + value(pForceLeft) + value(pForceRight)
            Trial_Type.value = 'Forced: Right';
        elseif r < value(pChoice) + value(pForceLeft) + value(pForceRight) + value(pInstructed)
            Trial_Type.value = 'Instructed';
        else
            error('Problem determining trial type');
        end
        
        BanditsSection(obj,'update_baiting');
        
        
        
        %% update_baiting
        
    case 'update_baiting'
        
        
        if value(Trial_Context) == 0
            LeftBaitProb = LeftBaitProb1;
            RightBaitProb = RightBaitProb1;
        else
            LeftBaitProb = LeftBaitProb2; %#ok<*NODEF>
            RightBaitProb = RightBaitProb2;
        end
        
        if value(varyProbability) % If we're baiting the ports probabillisticaly
            
            left_wtr_mult.value = 1;
            right_water_mult.value = 1;
            switch value(Trial_Type)
                case 'Free Trial'
                    LeftBaited.value = uint8(rand <= value(LeftBaitProb));
                    RightBaited.value = uint8(rand <= value(RightBaitProb));
                case 'Forced: Right'
                    LeftBaited.value = 0; %#ok<*STRNU>
                    RightBaited.value = uint8(rand <= value(RightBaitProb));
                case 'Forced: Left'
                    RightBaited.value = 0;
                    LeftBaited.value = uint8(rand <= value(LeftBaitProb));
                case 'Instructed' % If the trial is instructed, first decide which of the sides is better, then make a forced trial to that side
                    if LeftBaitProb > RightBaitProb
                        LeftBaited.value = uint8(rand <= value(LeftBaitProb));
                        RightBaited.value = 0;
                        Trial_Type.value = 'Forced: Left';
                    else
                        RightBaited.value = uint8(rand <= value(RightBaitProb));
                        LeftBaited.value = 0;
                        Trial_Type.value = 'Forced: Right';
                    end
            end
            
        else % we're baiting every port, every time, the only difference is the water quantity
            
            LeftBaited.value = 1;
            RightBaited.value = 1;
            switch value(Trial_Type)
                case 'Free Trial'
                    left_wtr_mult.value = value(LeftBaitProb);
                    right_wtr_mult.value = value(RightBaitProb); 
                case 'Forced: Right'
                    left_wtr_mult.value = 0;
                    right_wtr_mult.value = value(RightBaitProb);            
                case 'Forced: Left'
                    left_wtr_mult.value = value(LeftBaitProb);
                    right_wtr_mult.value = 0;
                case 'Instructed' % If the trial is instructed, first decide which of the sides is better, then make a forced trial to that side
                    if LeftBaitProb > RightBaitProb
                        left_wtr_mult.value = value(LeftBaitProb);
                        right_wtr_mult.value = 0;
                        Trial_Type.value = 'Forced: Left';
                    else
                        right_wtr_mult.value = value(RightBaitProb);
                        left_wtr_mult.value = 0;
                        Trial_Type.value = 'Forced: Right';
                    end
            end
            
        end
        
        % Check that water quantities are ok, if not, unbait the side with
        % too little water
        [lVol,rVol] = WaterValvesSection(obj,'get_water_volumes');
        
        if lVol*left_wtr_mult < value(min_water)
            LeftBaited.value = 0;
        end
        if rVol*right_wtr_mult < value(min_water)
            RightBaited.value = 0;
        end
        
        
    case 'first_trial'
        
        x = DriftSection(obj,'first_trial');
        
        if numel(x) == 4
            LeftBaitProb1.value = x(1);
            RightBaitProb1.value = x(2);
            LeftBaitProb2.value = x(3);
            RightBaitProb2.value = x(4);
        end
        
    case 'update_histories'
        
        switch value(Trial_Type)
            case 'Free Trial'
                tt = 'f';
            case 'Forced: Left'
                tt = 'l';
            case 'Forced: Right'
                tt = 'r';
            case 'Instructed'
                tt = 'i';
            otherwise 
                tt = 'x';
        end
        trial_type_history.value = [trial_type_history(:); tt];
        
        context_history.value = [context_history(:);value(Trial_Context)];
        
        left_prob1_history.value = [left_prob1_history(:);value(LeftBaitProb1)];
        right_prob1_history.value = [right_prob1_history(:);value(RightBaitProb1)];
        left_prob2_history.value = [left_prob2_history(:);value(LeftBaitProb2)];
        right_prob2_history.value = [right_prob2_history(:);value(RightBaitProb2)];
        
        left_baited_history.value = [left_baited_history(:);value(LeftBaited)];
        right_baited_history.value = [right_baited_history(:);value(RightBaited)];
        

        
    case 'enable_contexts'
        
        if value(enableContexts) % both contexts should be available
            
            enable(pContextOne);
            enable(RightBaitProb2);
            enable(LeftBaitProb2);
            enable(antibias_beta);
            enable(antibias_tau);
            SoundInterface(obj,'enable_all','Context2');
            
        else % Only context one is available
           
            Trial_Context.value = 0;
            disable(pContextOne);
            disable(RightBaitProb2);
            disable(LeftBaitProb2);
            disable(antibias_beta);
            disable(antibias_tau);
            SoundInterface(obj,'disable_all','Context2');
            
        end
        

        
    case 'normalize'
        
        % Make sure the probabilities of pChoice, pForceLeft, pForceRight
        % sum to one
        
        sumAll = value(pChoice) + value(pForceLeft) + value(pForceRight) + value(pInstructed);
        pChoice.value = value(pChoice) / sumAll;
        pForceLeft.value = value(pForceLeft) / sumAll;
        pForceRight.value = value(pForceRight) / sumAll;
        pInstructed.value = value(pInstructed) / sumAll;
        
    case 'get_histories'
        
        x.trial_type_history = value(trial_type_history);
        x.context_history = value(context_history);
        x.left_prob1_history = value(left_prob1_history);
        x.right_prob1_history = value(right_prob1_history);
        x.left_prob2_history = value(left_prob2_history);
        x.right_prob2_history = value(right_prob2_history);
        x.left_baited_history = value(left_baited_history);
        x.right_baited_history = value(right_baited_history);
        
    case 'get_better_side'
        
        if ~context_history(end)
            leftProb = left_prob1_history(end);
            rightProb = right_prob1_history(end);
        else
            leftProb = left_prob2_history(end);
            rightProb = right_prob2_history(end);
        end
        
        if leftProb > rightProb
            x = 'l';
        else
            x = 'r';
        end
        
    case 'get_baiting'
        
        if strcmp(value(Trial_Type),'Instructed') % SMA section doesn't know what to do with instructed - if the value is somehow instruced at this point, we'd better update the baiting to make it into one of the forced trial types
            BanditsSection(obj,'update_baiting');
        end
        
        x.trial_type = value(Trial_Type);
        x.left_baited = value(LeftBaited);
        x.right_baited = value(RightBaited);
        x.context = value(Trial_Context);
        x.left_wtr_mult = value(left_wtr_mult);
        x.right_wtr_mult = value(right_wtr_mult);
        
end;
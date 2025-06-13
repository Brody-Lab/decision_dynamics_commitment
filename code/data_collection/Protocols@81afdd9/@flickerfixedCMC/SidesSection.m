function [x, y] = SidesSection(obj, action, varargin)
% Edited to allow centerport translation June 2013 BBS

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        NumeditParam(obj, 'StepSize', 5, x, y, 'TooltipString', 'Increase to NosPos on each completed trial');
        next_row(y);
        NumeditParam(obj, 'StepNextTrial', 0, x, y, 'TooltipString', 'Increase to NosPos on each completed trial');
        next_row(y);
        NumeditParam(obj, 'microswitch_counter', 0, x, y, 'TooltipString', 'Increase to NosPos on each completed trial');
        next_row(y);
        NumeditParam(obj, 'NosPos', 0, x, y, 'TooltipString', 'Lick Tube Position')
        next_row(y);
        NumeditParam(obj, 'led_time', 0.005, x,y,'label','LED On Time','TooltipString','Duration of each flash');
        next_row(y);
        NumeditParam(obj, 'bin_size', 0.07, x,y,'label','ILI Time','TooltipString','Min. seperation between flashes');
        next_row(y);
        NumeditParam(obj, 'right_prob', 0.2, x,y,'label','Right Prob','TooltipString','Prob. of right LED flash in each interval.');
        next_row(y);
        NumeditParam(obj, 'left_prob', 0.2, x,y,'label','Left Prob','TooltipString','Prob. of left LED flash in each interval.');
        next_row(y);
        NumeditParam(obj, 'nic_time', 2, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj, 'wait_for_cpoke_timeout', 60, x,y,'label','Wait for Cpoke Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
        ToggleParam(obj,  'allow_nic_breaks', 0, x,y,'OffString','Punish NIC Viol','OnString','Ignore NIC Viol','TooltipString','After this time go to the timeout state');
        next_row(y);
        NumeditParam(obj, 'settling_time', 0.25, x,y,'label','Pre-Stim NIC time','TooltipString','Time in NIC before starting flickers');
        next_row(y);
        NumeditParam(obj, 'delay_time', 0.1, x,y,'label','Post-Stim NIC time','TooltipString','Time in NIC after ending flickers');
        next_row(y);
        MenuParam(obj, 'side_lights' ,{'none','both','correct side','anti side'},1, x,y,'label','Side Lights','TooltipString','Controls the side LEDs during wait_for_spoke');
        next_row(y);
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Response Timeout','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        NumeditParam(obj, 'reward_delay', 0.1, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        NumeditParam(obj, 'reward_exponent', 0, x,y,'label','Reward Exponent','TooltipString','water_time=valve_time*(total_nic_time^reward_exponent). Set to 0 for no effect.  May help with violation rates.');
        next_row(y);
        ToggleParam(obj, 'ignore_errors', 0, x,y,'OffString','Errors Punished','OnString','Errors Ignored','TooltipString','If ignore errors, then subject will eventually get the reward at the correct poke');
        next_row(y);
        NumeditParam(obj, 'error_iti', 10, x,y,'label','Error Timeout','TooltipString','ITI on error trials');
        next_row(y);
        
        NumeditParam(obj, 'violation_iti', 1, x,y,'label','Violation Timeout','TooltipString','ITI on error trials');
        
        next_column(x);
        y=5;
        NumeditParam(obj,'trials_in_stage',1,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
        next_row(y);
        ToggleParam(obj,'use_training',1,x,y,'OnString','Using Autotrain','OffString','Manual Settings');
        next_row(y);
        NumeditParam(obj, 'left_wtr_mult', 1, x, y, ...
            'TooltipString', 'all left reward times are multiplied by this number');
        next_row(y);
         NumeditParam(obj, 'right_wtr_mult', 1, x, y, ...
            'TooltipString', 'all right reward times are multiplied by this number');
        next_row(y);
        ToggleParam(obj, 'antibias_wtr_mult', 1, x,y,...
            'OnString', 'AB ON',...
            'OffString', 'AB OFF',...
            'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));
        next_row(y);
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'NosPos';'StepSize'; 'StepNextTrial'; 'training_stage';'led_time'; 'bin_size';'side_lights' ; 'ignore_errors';...
            'right_prob'; 'left_prob'; ...
            'nic_time'; 'wait_for_cpoke_timeout'; 'allow_nic_breaks' ; ...
            'settling_time'; 'delay_time'; ...
            'wait_for_spoke_timeout' ; 'reward_delay';'reward_exponent';'left_wtr_mult';...
            'error_iti';'violation_iti';'right_wtr_mult';'antibias_wtr_mult'});
        
         
      %   History of hit/miss:
      SoloParamHandle(obj, 'hit_history',      'value', []);
      SoloParamHandle(obj, 'deltaf_history',      'value', []);
      SoloParamHandle(obj, 'right_click_history',      'value', []);
      SoloParamHandle(obj, 'left_click_history',      'value', []);
      
      
      %   History of nose_in_center violations:
      SoloParamHandle(obj, 'violation_history', 'value', []);
      SoloParamHandle(obj, 'previous_sides', 'value', []);
    
    case 'update_trial_history',
        ps=value(previous_sides);
        ps(n_done_trials+1)=varargin{1};
        
        previous_sides.value=ps;
  
      
    case 'next_trial',
        
        %% update hit_history, previous_sides, etc
        was_viol=false;
        was_hit=false;
        if n_done_trials>0
        if ~isempty(parsed_events)
            if isfield(parsed_events,'states')
                if isfield(parsed_events.states,'violation_state')
                    was_viol=rows(parsed_events.states.violation_state)>0 || rows(parsed_events.states.timeout_state)>0;
                end
            end
            
        end
        
        violation_history.value=[violation_history(:); was_viol];
        
        if ~was_viol
            was_hit=rows(parsed_events.states.hit_state)>0;
            hit_history.value=[hit_history(:); was_hit];
            
        else
            % There was a violation or timeout
              hit_history.value=[hit_history(:); nan];
        end
            
            % Now calculate the deltaF and sides - this maybe interesting
            % even in a violation or timeout case.
            
            fn=fieldnames(parsed_events.states);
            led_states=find(strncmp('led',fn,3));
            deltaF=0;
            n_l=0;
            n_r=0;
            for lx=1:numel(led_states)
                lind=led_states(lx);
                if rows(parsed_events.states.(fn{lind}))>0
                    if fn{lind}(end)=='l'
                        deltaF=deltaF-1;
                        n_l=n_l+1;
                    elseif fn{lind}(end)=='r'
                        deltaF=deltaF+1;
                         n_r=n_r+1;
                    elseif fn{lind}(end)=='b'
                         n_l=n_l+1;
                         n_r=n_r+1;
                        
                    end
                end
                
            end
            
            % if deltaF>0 then a right poke is a hit
            % if deltaF<0 then a left poke is a hit
            
            
            deltaf_history.value=[deltaf_history(:); deltaF];
            right_click_history.value=[right_click_history(:); n_r];
            left_click_history.value=[left_click_history(:); n_l];
            
        
        end
        
        %% Update Nose Position
        if n_done_trials > 0 && isempty(parsed_events.pokes.D) && ~was_viol && was_hit
            StepNextTrial.value=1;
            NosPos.value=Value(NosPos)+Value(StepSize);
            microswitch_counter.value=0;
        elseif n_done_trials > 0 && ~isempty(parsed_events.pokes.D) && ~was_viol && was_hit
            StepNextTrial.value=0;
            microswitch_counter.value=value(microswitch_counter)+1;
        end
        %% Do the anti-bias
        
        
        if n_done_trials>25 && antibias_wtr_mult==1
            hh=hit_history(n_done_trials-24:n_done_trials);
            ps=previous_sides(n_done_trials-24:n_done_trials);
           
           right_hit=nanmean(hh(ps=='r'));
           left_hit=nanmean(hh(ps=='l'));
           
           if abs(right_hit-left_hit)<0.12
              left_wtr.mult.value=1;
              right_wtr.mult.value=1;
           else
           
           left_wtr_mult.value=min(right_hit/left_hit,4);
           right_wtr_mult.value=min(left_hit/right_hit,4);
           end
        end
           
        
        %% Now set up next_trial
        
        
        if use_training==1
           if ~was_viol && was_hit 
           trials_in_stage.value=trials_in_stage+1;
           end
           
           switch value(training_stage) %#ok<*NODEF>
               case 0,
                   settling_time.value=0.001;
                   delay_time.value=0.001;
                   allow_nic_breaks.value=1;
                   ignore_errors.value=1;
                   side_lights.value=3;
                   training_stage.value=3;
                   trials_in_stage.value=0;
                   bin_size.value=0.050;
                   wait_for_cpoke_timeout.value=600;
                   wait_for_spoke_timeout.value=600;
                   reward_delay.value=0.01;
                   error_iti.value=10;
                   left_prob.value=0.5;
                   right_prob.value=0.5;
                   nic_time.value=0;
                   NosPos.value=0;
                   antibias_wtr_mult.value=0;
                   
               case 3 % Earliest stage of training.  Light chase and move center port
                   antibias_wtr_mult.value=0;
                   if value(microswitch_counter)>9
                       training_stage.value=1;
                       trials_in_stage.value=0;
                   end
                       
                   
               case 1,  % Light chase and grow nose in center
                   StepSize.value=1;
                    
                    if ~was_viol  % if last trial was violation don't increment.
                        
                        
                        if settling_time<0.25
                            settling_time.value=settling_time+0.3;
                        else
                            delay_time.value=delay_time+0.3;
                        end
                        
                        if delay_time>0.05
                            allow_nic_breaks.value=0; %#ok<*STRNU>
                        else
                            allow_nic_breaks.value=1;
                        end
                        
                        
                        if delay_time>0.2
                            ignore_errors.value=0;
                        else
                            ignore_errors.value=1;
                        end
                        
                        
                        if delay_time>1.25 % increased this time to make the transition easier
                            training_stage.value=2;
                            trials_in_stage.value=0;
                            side_lights.value=1;
                        else
                            side_lights.value=3;
                        end
                    end
                    
                case 2, % start counting flashes
                    %turn antibias on
                    antibias_wtr_mult.value=1;
                     
                    bin_size.value=0.250;
                    if n_done_trials<10 %ramp up over the first 10 trials
                        nic_time.value=2*bin_size; %easy over the first 10 trials
                        settling_time.value=0.08*n_done_trials;%ramp up over the first 10 trials
                        delay_time.value=0.025*n_done_trials;  %ramp up over the first 10 trials
                    else
                    settling_time.value=1; %increased settling time for imaging
                    delay_time.value=0.5;
                    end
                    
                    if trials_in_stage<10
                        nic_time.value = 2*bin_size;
                        if rand>0.5
                            right_prob.value=0.9;
                            left_prob.value=0.1;
                            
                        else
                            left_prob.value=0.9;
                            right_prob.value=0.1;
                        end
                        led_time.value=0.03;
                    elseif trials_in_stage<30
                        nic_time.value = 3*bin_size;
                        if rand>0.5
                            right_prob.value=0.8;
                            left_prob.value=0.2;
                        else
                            left_prob.value=0.8;
                            right_prob.value=0.2;
                        end
                        led_time.value=0.02;
                    elseif trials_in_stage<50
                        nic_time.value = 4*bin_size;
                        if rand>0.5
                            right_prob.value=0.7;
                            left_prob.value=0.3;
                        else
                            left_prob.value=0.7;
                            right_prob.value=0.3;
                        end
                        led_time.value=0.01;
                        
                    elseif trials_in_stage<70
                        nic_time.value = 5*bin_size;
                        if rand>0.5
                            right_prob.value=0.7;
                            left_prob.value=0.3;
                        else
                            left_prob.value=0.7;
                            right_prob.value=0.3;
                        end
                        led_time.value=0.01;
                    else
                        nic_time.value = 6*bin_size;
                        if rand>0.5
                            right_prob.value=0.7;
                            left_prob.value=0.3;
                        else
                            left_prob.value=0.7;
                            right_prob.value=0.3;
                        end
                    end
            end
        end
        
        
   case 'get_water_mult'
      x=left_wtr_mult+0;
      y=right_wtr_mult+0;
        
    case 'make_and_send_summary'
       % reset anti-bias
        left_wtr_mult.value=1;
        right_wtr_mult.value=1;
       
              
        peh=cell2mat(parsed_events_history);
        hits=nan(size(peh));
        cpv=zeros(size(peh));
        ps=value(previous_sides(:));
        sides=nan(size(ps));
        sides(ps=='r')=1;
        sides(ps=='l')=-1;
        
        df=nan(size(peh));  % delta flashes
        nic=df;
        cout=extract_event(peh,'wait_for_cout(1,2)');
        cin=extract_event(peh,'wait_for_cpoke(end,2)');
        viol=extract_event(peh,'violation_state(1,1)');
        
        
        
        for px=1:numel(peh)
            
            
            if isnan(cout(px)) || ~isnan(viol(px))
                cpv(px)=1;
                hits(px)=nan;
            else
                r_pokes=peh(px).pokes.R(:,1);
                l_pokes=peh(px).pokes.L(:,1);
                
                firstrightpoke=r_pokes(find(r_pokes>cout(px),1,'first'));
                firstleftpoke=l_pokes(find(l_pokes>cout(px),1,'first'));
                if isempty(firstrightpoke), firstrightpoke=+inf; end
                if isempty(firstleftpoke), firstleftpoke=+inf; end
                P=[firstleftpoke firstrightpoke];
                
                if all(isinf(P))
                    hits(px)=nan;
                    cpv(px)=1;
                else
                    
                    [pt,pind]=min(P);  % Which poke was first?
                    pind=2*(pind-1)-1;
                    if sides(px)==pind
                        hits(px)=1;
                    else
                        hits(px)=0;
                    end
                end
            end
            
        end
        
        nt=min([numel(hits) numel(ps) numel(value(deltaf_history)) numel(cpv)]);
        cpv=cpv(1:nt);
        hits=hit_history(1:nt);
        csides=ps(1:nt);
        deltaf_history=deltaf_history(1:nt);
        n_left=left_click_history(1:nt);
        n_right=right_click_history(1:nt);
        
        pd.deltaF=deltaf_history(:);
        pd.n_left=n_left(:);
        pd.n_right=n_right(:);
        nic=cell2mat(get_history(nic_time));
        pre_nic=cell2mat(get_history(settling_time));
        post_nic=cell2mat(get_history(delay_time));
        pd.nic=nic(1:nt);
        pd.pre_nic=pre_nic(1:nt);
        pd.post_nic=post_nic(1:nt);
        pd.csides=csides;
        slh=get_history(side_lights);
        slh=slh(1:nt);
        csides(csides=='s' & strncmp('cor',slh,3))='r';
        csides(csides=='m' & strncmp('cor',slh,3))='l';
        
        pd.sides=csides(:);
        pd.hits=hits;
        pd.cpv=cpv;
       % pd.led_time_R=led_time_R;
       % pd.led_time_L=led_time_L;
       
        sendsummary(obj,'hits',hits,'sides',csides,'protocol_data',pd);
        
        
        
        
        
end



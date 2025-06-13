

function [x, y] = SidesSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        MenuParam(obj, 'cue_type', {'stereo','left','right','high'},1, x,y,'label','Cue Type','TooltipString','What is the cue for this trial');
        next_row(y);
        NumeditParam(obj, 'cue_prob', [.25 .30 .30 .15], x,y,'label','Cue Prob','TooltipString','[Stereo Left Right High]');
        next_row(y);
        NumeditParam(obj, 'cue_validity', [.8], x,y,'label','Cue Validity','TooltipString','Fraction of left/right cue trials where the gap (if there is one) is on the side indicated by the sound');
        next_row(y);
        NumeditParam(obj, 'side_reward_loc', 1, x,y,'label','Reward Location','TooltipString','-1=Left, 0=center, 1=Right');
        next_row(y);
        NumeditParam(obj, 'precue_dur', 0.25, x,y,'label','PreCue dur','TooltipString','Time in NIC before starting sound');
        next_row(y);
        NumeditParam(obj, 'cue_dur', 0.3, x,y,'label','Cue dur','TooltipString','Time in NIC of sound');
        next_row(y);
        
        NumeditParam(obj, 'postcue_dur', 0.4, x,y,'label','PostCue dur','TooltipString','Time in NIC after ending sound. i.e. Memory period');
        next_row(y);
        NumeditParam(obj, 'wait_for_cpoke_timeout', 240, x,y,'label','Wait for Cpoke Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
        NumeditParam(obj, 'wait_for_cout_timeout', 240, x,y,'label','Wait for Cpoke Out Timeout','TooltipString','After this time go to the timeout state');
        next_row(y);
       
        ToggleParam(obj, 'allow_nic_breaks', 0, x,y,'OffString','Punish NIC Viol','OnString','Ignore NIC Viol','TooltipString','If this is on, then NIC violations are ignored');
        next_row(y);
        
        NumeditParam(obj, 'reward_delay', 0.1, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        
        NumeditParam(obj, 'high_rew_mult', 0.3, x,y,'label','High Reward Mult','TooltipString','Reward multiplier for high reward trials');
        next_row(y);
        
        NumeditParam(obj, 'reward_exponent', 0, x,y,'label','Reward Exponent','TooltipString','water_time=valve_time*(total_nic_time^reward_exponent). Set to 0 for no effect.  May help with violation rates.');
        next_row(y);
        NumeditParam(obj, 'short_iti_dur', 10, x,y,'label','Short ITI','TooltipString','ITI on hit trials');
        next_row(y);
        
        NumeditParam(obj, 'long_iti_dur', 1, x,y,'label','Long ITI','TooltipString','ITI on error trials');
        
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
            'and uses hitfrac to adjust the water times.  Not sure antibias makes sense for this protocol']));
        next_row(y);
        
        smas={'SMA_train' 'SMA1'};  % Add the relevant variables to the two SMA functions, although may
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'cue_type';'precue_dur' ; 'postcue_dur'; 'cue_dur';...
            'side_reward_loc';...
             'wait_for_cout_timeout'; ...
             'wait_for_cpoke_timeout'; 'allow_nic_breaks' ; ...
             'high_rew_mult';...
            'reward_delay';'reward_exponent';'left_wtr_mult';...
            'short_iti_dur';'long_iti_dur';'right_wtr_mult';'antibias_wtr_mult'});
        
        
        SoloFunctionAddVars('SMA_train', 'ro_args', ...
            {'short_iti_dur';...
            'side_reward_loc';'postcue_dur';...
            'wait_for_cpoke_timeout'; 'wait_for_cout_timeout';...
            'reward_delay';'left_wtr_mult';...
            'right_wtr_mult'});
        
        
        
        %   History of hit/miss:
        SoloParamHandle(obj, 'hit_history', 'value', []);
        
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
                    was_viol=false;
                    if isfield(parsed_events.states,'violation_state')
                        was_viol=rows(parsed_events.states.violation_state)>0;
                    end
                    if isfield(parsed_events.states,'timeout_state')
                        was_viol=was_viol || rows(parsed_events.states.timeout_state)>0;
                    end
                    
                    violation_history.value=[violation_history(:); was_viol];
                    
                    if ~was_viol && isfield(parsed_events.states,'hit_state')
                        was_hit=rows(parsed_events.states.hit_state)>0;
                        hit_history.value=[hit_history(:); was_hit];
                    else
                        hit_history.value=[hit_history(:); nan];
                    end
                    
                end
                
            end
        end
        
%% antibias
        if n_done_trials>25 && antibias_wtr_mult==1
            hh=hit_history(n_done_trials-24:n_done_trials);
            ps=previous_sides(n_done_trials-24:n_done_trials);
        
            right_hit=nanmean(hh(ps==1));
            left_hit=nanmean(hh(ps==-1));
        
            if abs(right_hit-left_hit)<0.12
                left_wtr_mult.value=1;
                right_wtr_mult.value=1;
            else
                left_wtr_mult.value=min(right_hit/left_hit,4);
                right_wtr_mult.value=min(left_hit/right_hit,4);
            end
        end
        
        
        %% Now set up next_trial
        
        
        if use_training==1
            if was_viol==0 && was_hit
                trials_in_stage.value=trials_in_stage+1;
            end
            
            switch value(training_stage) %#ok<*NODEF>
                case 1,
                    % Earliest stage of training.
                    % Play a sound and then deliver water at that port.
                    % Water delivery is not contingent on poke.
                    % Long ITIs
                    
                    allow_nic_breaks.value=1;
                    antibias_wtr_mult.value=0;
                    left_wtr_mult.value=8;
                    right_wtr_mult.value=8;
                    
                    wait_for_cpoke_timeout.value=600;
                    wait_for_spoke_timeout.value=600;
                    reward_delay.value=0.01;
                    short_iti_dur.value=120;
                    long_iti_dur.value=20;
                    
                    side_reward_loc.value=2*(rand<0.5)-1;
                    SidesSection(obj,'update_trial_history',side_reward_loc+0);
                    short_iti_dur.value=30+rand*240;
                    if trials_in_stage>100
                        trials_in_stage.value=0;
                        training_stage.value=2;
                        
                    end
                    SMA_train(obj,'stage1');
                    
                    
                case 2,
                    % Water delivery is contingent on poking
                    % Grow noise in center.
                    % NIC violations just take you to beginning of trial
                    % NIC indicated by side lights.
                    % Grow NIC (flash1_dur) to 1.5 seconds
                    left_wtr_mult.value=4;
                    right_wtr_mult.value=4;
                    short_iti_dur.value=30+rand*60;
                    side_reward_loc.value=2*(rand<0.5)-1;
                    

                    SidesSection(obj,'update_trial_history',side_reward_loc+0);

                    
                    if trials_in_stage<4000
                        postcue_dur.value=trials_in_stage/2000+0.001;
                    end
                    
                    if trials_in_stage>1500 && waitforgo_dur>0.3
                        waitforgo_dur.value=waitforgo_dur-0.005;
                    end
                    
                    SMA_train(obj,'stage2')
                    
                    
                    
                    
                case 3, % start counting flashes
                    
                    
                    
                    if trials_in_stage<3000
                        if rand>0.5
                            right_prob.value=0.9;
                            left_prob.value=0.1;
                            
                        else
                            left_prob.value=0.9;
                            right_prob.value=0.1;
                        end
                        led_time.value=0.03;
                    elseif trials_in_stage<4500
                        if rand>0.5
                            right_prob.value=0.7;
                            left_prob.value=0.3;
                        else
                            left_prob.value=0.7;
                            right_prob.value=0.3;
                        end
                        led_time.value=0.01;
                    else
                        left_prob.value=rand;
                        right_prob.value=rand;
                        led_time.value=0.01;
                        
                    end
                otherwise
                    error('Do not know how to prepare this training stage')
            end
        end
        
        
    case 'get_water_mult'
        x=left_wtr_mult+0;
        y=right_wtr_mult+0;
        
    case 'make_and_send_summary'
        % reset anti-bias
        left_wtr_mult.value=1;
        right_wtr_mult.value=1;
        
        csides(previous_sides(:)==-1)='l';
        csides(previous_sides(:)==1)='r';
        pd.hits=hit_history(:);
        pd.sides=previous_sides(:);
        pd.trial_counter=cell2mat(get_history(trials_in_stage));
        pd.training_stage=cell2mat(get_history(training_stage));
        
        sendsummary(obj,'sides',csides(:),'protocol_data',pd)
        return;
        
        
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



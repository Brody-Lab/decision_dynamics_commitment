function [x, y] = SidesSection(obj, action, varargin)
% Edited to allow centerport translation June 2013 BBS
% Training stages modified April 2014 BBS have not updated to rig 4

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
        NumeditParam(obj, 'reward_delay', 0.2, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        next_column(x);
        y=5;
        NumeditParam(obj,'trials_in_stage',1,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
        next_row(y);
        NumeditParam(obj,'fix_dur',nan,x,y,'label','Fixation Times');
        next_row(y);
        NumeditParam(obj, 'wtr_mult', 0.3, x, y,'TooltipString', 'all left reward times are multiplied by this number');
        next_row(y);
        NumeditParam(obj, 'set_point', 0, x,y,'label','Set Point','TooltipString','Should be half the mean yesterdays fix time');
        next_row(y);
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'NosPos';'StepSize'; 'StepNextTrial'; 'training_stage';'microswitch_counter';'trials_in_stage'; ...
            'reward_delay';'wtr_mult'; 'set_point';});
       
        
    %case 'update_trial_history',

        
        
    case 'next_trial',
        
        %% update hit_history, previous_sides, etc

        
        %% Update Nose Position
        if n_done_trials > 0 && isempty(parsed_events.pokes.D)
            StepNextTrial.value=1;
            NosPos.value=Value(NosPos)+Value(StepSize);
            microswitch_counter.value=0;
            fix_dur.value=nan;
        elseif n_done_trials > 0 && ~isempty(parsed_events.pokes.D)
            StepNextTrial.value=0;
            microswitch_counter.value=value(microswitch_counter)+1;
            fix_dur.value=(parsed_events.states.nic_sound(2)-parsed_events.states.nic_sound(1));
        end
        
        
        
        %% Now set up next_trial
        
       
            trials_in_stage.value=trials_in_stage+1;
   
        
        switch value(training_stage) %#ok<*NODEF>
            case 0,
                side_lights.value=3;
                training_stage.value=1;
                trials_in_stage.value=0;
                reward_delay.value=0.01;
                NosPos.value=0;
                wtr_mult.value=0.3;
                
            case 1 % Earliest stage of training.  Light chase and move center port
                if value(microswitch_counter)<3 && value(microswitch_counter)>0
                    wtr_mult.value=0.6;
                elseif value(microswitch_counter)>2
                    training_stage.value=2;
                    trials_in_stage.value=0;
                    StepSize.value=0;
                end
                
                
            case 2,  % Light chase and nose in center
                if n_done_trials>0 && (log(value(fix_dur))+0.3-set_point)+1.5>0
                wtr_mult.value=(log(value(fix_dur))+0.3-set_point)+1.5;
                else 
                wtr_mult.value=0; 
                end
        end
        
        
    case 'make_and_send_summary'
        
        peh=cell2mat(parsed_events_history);
        hits=nan(n_done_trials,1);
        csides=nan(n_done_trials,1);
        pd.reward_delay=cell2mat(get_history(reward_delay));
        pd.water_mult=cell2mat(get_history(wtr_mult));
        pd.training_stage=cell2mat(get_history(training_stage));
        pd.fix_dur=cell2mat(get_history(fix_dur));
        pd.peh=cell2mat(parsed_events_history);
       
        sendsummary(obj,'hits',hits,'sides',csides,'protocol_data',pd);
        
end



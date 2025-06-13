function [x, y] = PunishSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

%%%%%%% LIST OF READ-ONLY VARIABLES %%%%%%%
% %from SideSection
% ThisSide_ro=value(ThisSide);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'


        x=varargin{1};
        y=varargin{2};


        
        
        NumeditParam(obj, 'incoherent_delay', 3, x,y,'label','Incoherent delay','TooltipString','Delay for errors on incoherent trials');
        next_row(y);
        
        ToggleParam(obj, 'longer_punish_incoh_trials', 1, x, y, ...
            'OffString', 'Same punish if incoherent', ...
            'OnString',  'Long punish if incoherent', ...
            'TooltipString', 'If on (black), error state lasts longer on incoherent trials; if off (brown), error state lasts the same on incoherent trials');
        next_row(y,2);
%         next_row(y,1.4);
        
        
        
        
        NumeditParam(obj, 'timeout_delay', 3, x,y,'label','Timeout delay','TooltipString','Delay after timeout at spoke, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_spoke_timeout', 4, x,y,'label','Timeout for spoke','TooltipString','Time after NIC to wait for a side poke');
        next_row(y);
        
        NumeditParam(obj, 'wait_for_cpoke_timeout', 600, x,y,'label','Timeout for cpoke','TooltipString','Timeout waiting for cpoke');
        next_row(y,2);
%         next_row(y,1.4);
        
        
        NumeditParam(obj, 'error_delay', 3, x,y,'label','Error delay','TooltipString','Delay after poking on wrong side');
        next_row(y);
        
        
        ToggleParam(obj, 'restart_if_error', 1, x, y, ...
            'OffString', 'Stay in trial if error', ...
            'OnString',  'Restart trial if error', ...
            'TooltipString', 'If on (black), start new trial upon wrong side choice; if off (brown), can choose again');
        next_row(y,2);
%         next_row(y,1.4);
        
        NumeditParam(obj, 'nic_delay', 3, x,y,'label','NIC violation delay','TooltipString','Delay after NIC violation, follows new trial');
        next_row(y);
        
        NumeditParam(obj, 'nose_in_center', 0.5, x, y,'label','NIC min. duration', ...
            'TooltipString', 'Duration (in sec) nose must be kept in center poke before side choice is allowed');
        next_row(y,2);
%         next_row(y,1.4);
        
        
        

        NumeditParam(obj, 'reward_delay', 0.001, x,y,'label','Reward Delay','TooltipString','Delay between side poke and reward delivery');
        next_row(y);
        
        NumeditParam(obj, 'settling_time', 0.25, x,y,'label','Pre-stimulus delay','TooltipString','Time in NIC before starting stimulus');
        next_row(y);
        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);



        SoloFunctionAddVars('SMA1', 'ro_args',...
            {'settling_time';'reward_delay';'nose_in_center' ;'nic_delay';...
            'restart_if_error';'error_delay';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay'});
        

        SoloFunctionAddVars('TrainingSection', 'rw_args',...
            {'settling_time';'reward_delay';'nose_in_center' ;'nic_delay';...
            'restart_if_error';'error_delay';...
            'wait_for_cpoke_timeout';'wait_for_spoke_timeout';'timeout_delay'; ...
            'longer_punish_incoh_trials'; 'incoherent_delay'});
        

    case 'next_trial',

        

    case 'get_delay_incoh'
        
        flag1=value(longer_punish_incoh_trials)==1;
        flag2=strcmp(value(stim_type),'Direction + Frequency');
        
        
        val1=value(ThisSideDirection);
        val2=value(ThisSideFrequency);    
        flag3=~strcmp(val1,val2);
        
        if(flag1 && flag2 && flag3)
            x=value(incoherent_delay);
        else
            x=0;
        end

    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       




end



function [x, y] = RewardSection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'


        x=varargin{1};
        y=varargin{2};


        NumeditParam(obj, 'overall_wtr_mult', 1, x,y,'label','Overall water mult');
        next_row(y);
        
        
        ToggleParam(obj, 'stim_during_cpoke_only', 1, x, y, ...
            'OffString', 'Stimulus stays on until response', ...
            'OnString',  'Stimulus only while NIC', ...
            'TooltipString', 'If on (black), stimulus stops if rats stops cpoking; if off (brown), stimulus stays on until spoke');
        next_row(y);
        
        ToggleParam(obj, 'helper_lights', 1, x, y, ...
            'OffString', 'Helper lights off', ...
            'OnString',  'Helper lights on', ...
            'TooltipString', 'If on (black), LED lights help indicate what to do; if off (brown), no helper LED lights');
        next_row(y);
        
        NumeditParam(obj, 'incoherent_reward', 1, x,y,'label','Incoherent reward','TooltipString','Reward multiplier on incoherent trials');
        next_row(y);
        
        ToggleParam(obj, 'higher_reward_incoh_trials', 1, x, y, ...
            'OffString', 'Same reward if incoherent', ...
            'OnString',  'Higher reward if incoherent', ...
            'TooltipString', 'If on (black), larger reward on incoherent trials; if off (brown), same reward on incoherent trials');
        next_row(y);
        
        

        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);


        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'stim_during_cpoke_only';'helper_lights'});

        SoloFunctionAddVars('TrainingSection', 'rw_args', {'higher_reward_incoh_trials';...
            'incoherent_reward';'stim_during_cpoke_only';'helper_lights'});
        


        

    case 'get_water_incoh'
        
        flag1=value(higher_reward_incoh_trials)==1;
        flag2=strcmp(value(stim_type),'Direction + Frequency');
        
        
        val1=value(ThisSideDirection);
        val2=value(ThisSideFrequency);    
        flag3=~strcmp(val1,val2);
        
        if(flag1 && flag2 && flag3)
            x=value(incoherent_reward);
        else
            x=1;
        end
        

        
        
    case 'get_overall_water_mult'

        x=value(overall_wtr_mult);



    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
               
        
end



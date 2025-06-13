function [x, y] = SidesSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,

    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------

    case 'init'
        x=varargin{1};
        y=varargin{2};


        
%         LogsliderParam(obj, 'LR_BiasTau_water', 30, 10, 400, x, y,'label','LR bias tau',...
%             'TooltipString', 'Number of trials back over which to compute Left/Right antibias');next_row(y);
%         NumeditParam(obj, 'LR_Beta_water', 0, x, y, ...
%             'TooltipString', 'Antibias weight for Left versus Right trials; trumps the antibias beta in soundtable');next_row(y);
%         DispParam(obj, 'left_wtr_mult',1, x, y,'label','left water','labelfraction', 0.7,'position', [x y 100 20],...
%             'TooltipString', 'all left reward times are multiplied by this number');
%         DispParam(obj, 'right_wtr_mult',1, x, y,'label','right water','labelfraction', 0.7,'position', [x+100 y 100 20],...
%             'TooltipString', 'all left reward times are multiplied by this number');next_row(y);
%         ToggleParam(obj, 'water_antibias_toggle', 1, x,y,...
%             'OnString', 'Water Antibias ON','OffString', 'Water Antibias OFF',...
%             'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
%             'and uses hitfrac to adjust the water times']));next_row(y);

        %%%% ANTIBIAS PARAMETERS
        LogsliderParam(obj, 'LR_BiasTau', 30, 10, 400, x, y,'label','LR bias tau',...
            'TooltipString', 'Number of trials back over which to compute Left/Right antibias');next_row(y);
        NumeditParam(obj, 'LR_Beta', 0, x, y, ...
            'TooltipString', 'Antibias weight for Left versus Right trials; trumps the antibias beta in soundtable');next_row(y);
        MenuParam(obj, 'MaxSame', {'1', '2', '3', '4', '5', '6', '7', '14', 'Inf'}, 3, ...
            x, y, 'TooltipString', 'Maximum number of times the same side (L or R) can appear');next_row(y);       

        
        %%%% WATER ANTIBIAS
        DispParam(obj, 'left_wtr_mult',1, x, y,'label','leftWat','position', [x y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');
        DispParam(obj, 'right_wtr_mult',1, x, y,'label','rightWat','position', [x+100 y 100 20],...
            'TooltipString', 'all left reward times are multiplied by this number');next_row(y);
        ToggleParam(obj, 'water_antibias_toggle', 1, x,y,...
            'OnString', 'Water Antibias ON','OffString', 'Water Antibias OFF',...
            'TooltipString', sprintf(['If on (black) then it disables the wtr_mult entries\n'...
            'and uses hitfrac to adjust the water times']));next_row(y);

        
        
         %%%% SIDE ANTIBIAS
        DispParam(obj, 'LeftP',0.5, x, y, 'labelfraction', 0.4,'position', [x y 100 20]);
        DispParam(obj, 'RightP',0.5, x, y, 'labelfraction', 0.4,'position', [x+100 y 100 20]);next_row(y);       
        ToggleParam(obj, 'side_antibias_toggle', 1, x,y,...
            'OnString', 'Side Antibias ON','OffString', 'Side Antibias OFF',...
            'TooltipString', sprintf('If on side antibias is on'));next_row(y);

        
        DispParam(obj, 'BiasL',0.5, x, y, 'labelfraction', 0.4,'position', [x y 100 20]);
        DispParam(obj, 'BiasR',0.5, x, y, 'labelfraction', 0.4,'position', [x+100 y 100 20]);next_row(y);       
        
        
        DispParam(obj, 'incoherent_trial', '0', x, y, 'position', [x y 200 20]);next_row(y);
        DispParam(obj, 'ThisSideFrequency', 'LEFT', x, y, 'position', [x y 200 20]);next_row(y);        
        DispParam(obj, 'ThisSideDirection', 'LEFT', x, y, 'position', [x y 200 20]);next_row(y);
        DispParam(obj, 'ThisSide', 'LEFT', x, y, 'position', [x y 200 20]);next_row(y);
        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);

        SoloFunctionAddVars('SMA1', 'ro_args', {'ThisSide'});
         
        SoloFunctionAddVars('StimulusSection', 'ro_args',{'ThisSideFrequency';'ThisSideDirection';});
         
        SoloFunctionAddVars('TrainingSection', 'rw_args', {'side_antibias_toggle';...
            'LR_Beta';'MaxSame';'LR_BiasTau';'water_antibias_toggle'});
        
        SoloFunctionAddVars('HistorySection', 'ro_args', {'ThisSide';'incoherent_trial'});
         
        SoloFunctionAddVars('RewardSection', 'ro_args',{'ThisSideFrequency';'ThisSideDirection';});
         
        SoloFunctionAddVars('PunishSection', 'ro_args',{'ThisSideFrequency';'ThisSideDirection';});
         

    case 'next_trial',
        
        
        
        %%%% ANTIBIAS %%%% (adapted from PBups protocol)
        
        %%% compute bias
        
        vec_sides = value(side_history);
        vec_hit=value(hit_history);
        % make sure the two vectors have same length
        vec_sides = vec_sides(1:length(vec_hit));


        %%% the kernel function decides how to weigh correct responses:
        %%% the last few trials are the most important
        %%% LR_BiasTau decides how many trials back matter
        kernel = exp(-(0:length(vec_hit)-1)/value(LR_BiasTau));
        kernel = kernel(end:-1:1);


        %%%% calculate an average of percent correct for left and right trials,
        %%%% weighted so that the last trials count more
        ul = find(vec_sides=='l');
        rl = find(vec_sides=='r');
        if(isempty(ul) || isempty(rl))
            fracs=[0.5 0.5];
        else
            bias_left = nansum(vec_hit(ul) .* kernel(ul))/sum(kernel(ul));        
            bias_right = nansum(vec_hit(rl) .* kernel(rl))/sum(kernel(rl));
            fracs=[bias_left bias_right];
        end;
        fracs=fracs./sum(fracs);
        
        
        val=fracs(1);
        val=round(val*100)/100;
        BiasL.value=val;
        
        val=fracs(2);
        val=round(val*100)/100;
        BiasR.value=val;
                
        if(value(LR_Beta) > 0)
            p = exp(-fracs*value(LR_Beta));
            p=p./sum(p);
            
            %%% round to the third decimal
            p=round(p*1000)/1000;
            
            if(value(side_antibias_toggle))
                choices=p;
                LeftP.value=p(1);
                RightP.value=p(2);
            else
                choices=[0.5 0.5];
                LeftP.value=0.5;
                RightP.value=0.5;
            end
            
            
            if(value(water_antibias_toggle))
                left_wtr_mult.value=p(1)*2;
                right_wtr_mult.value=p(2)*2;
            else
                left_wtr_mult.value=1;
                right_wtr_mult.value=1;
            end
        end
             
            

        this_side = '';
        %%% MaxSame rule applies
        if(~strcmpi(value(MaxSame), 'Inf') && value(MaxSame)<=n_started_trials)
            
            % if there's been a string of MaxSame guys all the same, force change
            if(all(vec_sides(end-value(MaxSame)+1:end) == vec_sides(end)))
                if(vec_sides(end) == 'l')
                    this_side = 'RIGHT';
                else
                    this_side = 'LEFT';
                end;
            elseif(~isempty(choices)) % if there is a trump LR_Beta, pick next side here
                if(rand(1) > value(LeftP))
                    this_side = 'RIGHT';
                else
                    this_side = 'LEFT';
                end;
            end;
        else
            %%% MaxSame rule does not apply
            if(rand(1) > value(LeftP))
                this_side = 'RIGHT';
            else
                this_side = 'LEFT';
            end;
        end
        
        
        %%%% Pick randomly side for the other task
        if(rand(1) > 0.5)
            this_side_other_task = 'RIGHT';
        else
            this_side_other_task = 'LEFT';
        end;
        
        
        %%% decide whether the current trial is incoherent
        if(strcmp(value(stim_type),'Direction + Frequency'))
            if(~strcmp(this_side,this_side_other_task))
                incoherent_trial.value=1;
            else
                incoherent_trial.value=0;
            end
        else
            incoherent_trial.value=NaN;
        end
        
        
        %%% set the side for current trial
        ThisSide.value=this_side;
        
        
        %%% set the freq and direction side for the current trial
        if(strcmp(value(ThisTask),'Direction'))
            ThisSideDirection.value=this_side;
            ThisSideFrequency.value=this_side_other_task;
        elseif(strcmp(value(ThisTask),'Frequency'))
            ThisSideFrequency.value=this_side;
            ThisSideDirection.value=this_side_other_task;
        else
            error('what task????')
        end
        
        
        
        
        
    case 'get_water_mult'

        x=value(left_wtr_mult);
        y=value(right_wtr_mult);


    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
       






end



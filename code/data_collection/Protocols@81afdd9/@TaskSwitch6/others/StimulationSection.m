

function [x, y] = StimulationSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action
    %%% init
    
    
    case 'init',
        % Save the figure and the position in the figure where we are
        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        SoloParamHandle(obj, 'base_station','value','');
        SoloParamHandle(obj,'sent_message_list','value',{});
        SoloParamHandle(obj,'received_message_list','value',{});
        SoloParamHandle(obj,'sent_message_list_trial','value',{});
        SoloParamHandle(obj,'received_message_list_trial','value',{});
        
        NumeditParam(obj,'p_both_stim',0.5,x,y);
        next_row(y);
        NumeditParam(obj,'laser_left_on',0,x,y);
        next_row(y);
        NumeditParam(obj,'laser_right_on',0,x,y);
        next_row(y);
%         NumeditParam(obj,'stim_limit_sec',10,x,y);
%         next_row(y);
        SubheaderParam(obj, 'title', 'Stimulation Section', x, y);
        next_row(y, 1.5);
    
        

        SoloFunctionAddVars('HistorySection', 'ro_args',{'laser_left_on';...
            'laser_right_on'});
        
        
%         
%         SoloFunctionAddVars('SMA1', 'ro_args',{'p_both_stim';...
%             'stim_limit_sec'});
% 
%         %%% send to the training section
%         SoloFunctionAddVars('SMA1', 'rw_args', {'laser_on'});

        
        

        % % % % % initialization (1.13 seconds)
        %%%%%%%%%%%% OPEN SERIAL PORT FOR BASE (w/ ethernet)
        base_station.value=serial('COM3');
        set(value(base_station),'BaudRate',57600);
        set(value(base_station),'terminator','')
        set(value(base_station),'timeout',.1)
        fopen(value(base_station))
        pause(.1)
        
        
        
        msg='N';
        sent_message_list.value = [value(sent_message_list);msg]; 
        sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials]; 
        try
            fprintf(value(base_station),msg)
        catch
        end
        
        pause(.1)
        
        xa = fscanf(value(base_station));
        disp(xa)
        [xa,tmp] = regexp(xa,'\r','split','match');
        xa=cellfun(@deblank,xa,'uniformoutput',false)';
        xa=xa(~cellfun(@isempty,xa));
        if ~isempty(xa)
            received_message_list.value = [value(received_message_list);xa];
            received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
        end
        
        pause(.1)
        %%%% NO PULSING, CONTINUOUS LASER
        msg='W,0,1500,0,1500,0';

%         %%%% PULSING 20Hz( like Thomas, Adrian)       
%         msg='W,0,10,40,1500,0';
        
%         %%%% PULSING 40Hz( like Chuck)       
%         msg='W,0,10,15,1500,0';
        
        
        sent_message_list.value = [value(sent_message_list);msg]; 
        sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials]; 
        try
            fprintf(value(base_station),msg)
        catch
        end
        
        pause(.1)
        
        
        xa = fscanf(value(base_station));
        disp(xa)
        [xa,tmp] = regexp(xa,'\r','split','match');
        xa=cellfun(@deblank,xa,'uniformoutput',false)';
        xa=xa(~cellfun(@isempty,xa));
        if ~isempty(xa)
            received_message_list.value = [value(received_message_list);xa];
            received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
        end
        
        
        pause(.1)
        
        msg='D,0,0';
        sent_message_list.value = [value(sent_message_list);msg]; 
        sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials]; 
        try
            fprintf(value(base_station),msg)
        catch
        end
        
        pause(.1)
        
        
        xa = fscanf(value(base_station));
        disp(xa)
        [xa,tmp] = regexp(xa,'\r','split','match');
        xa=cellfun(@deblank,xa,'uniformoutput',false)';
        xa=xa(~cellfun(@isempty,xa));
        if ~isempty(xa)
            received_message_list.value = [value(received_message_list);xa];
            received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
        end

        
        
    
    case 'trial_completed',
        
        
     
        xa = fscanf(value(base_station));
        disp(xa)
        [xa,tmp] = regexp(xa,'\r','split','match');
        xa=cellfun(@deblank,xa,'uniformoutput',false)';
        xa=xa(~cellfun(@isempty,xa));
        if ~isempty(xa)
            received_message_list.value = [value(received_message_list);xa];
            received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
        end
        
        
%         
%         % Decide what type of stim: both, or neither
%         r = rand;
%         p_both_stim.value=r;
%         if(r < 0.5) % Both Stim            
%             laser_left_on.value = 0;
%             laser_right_on.value = 0;
%             
%         elseif (r>=0.5 && r<0.75)
%             
%             laser_left_on.value = 1;
%             laser_right_on.value = 0;
%             
%         elseif (r>=0.75)
%             
%             laser_left_on.value = 0;
%             laser_right_on.value = 1;
%             
%         end

        
        % Decide what type of stim: both, or neither
        stimulate=mod(n_done_trials,3);
        if(stimulate==2) 
            r = rand;
            p_both_stim.value=r;
            
%             if(r < 0.5) % left
%                 laser_left_on.value = 1;
%                 laser_right_on.value = 0;
%             else %right
%                 laser_left_on.value = 0;
%                 laser_right_on.value = 1;
%             end

            if(r < 1/3) % left
                laser_left_on.value = 1;
                laser_right_on.value = 0;
            elseif(r>=1/3 && r<2/3) %right
                laser_left_on.value = 0;
                laser_right_on.value = 1;
            elseif(r>=2/3)
                laser_left_on.value = 1;
                laser_right_on.value = 1;
            else
                error('wtf')
            end

        
        else
            p_both_stim.value=-1;
            laser_left_on.value = 0;
            laser_right_on.value = 0;
        end
        
        
        
        
        
%         
%         msg='A';
%         sent_message_list.value = [value(sent_message_list);msg]; 
%         sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials]; 
%         try
%             fprintf(value(base_station),msg)
%         catch
%         end
%         
%         pause(.1)
%         
%         xa = fscanf(value(base_station));
%         disp(xa)
%         [xa,tmp] = regexp(xa,'\r','split','match');
%         xa=cellfun(@deblank,xa,'uniformoutput',false)';
%         xa=xa(~cellfun(@isempty,xa));
%         if ~isempty(xa)
%             received_message_list.value = [value(received_message_list);xa];
%             received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
%         end
        
        
        %%% LEFT , RIGHT
        laserpower=1000;
        msg=['D,' num2str(laserpower*value(laser_left_on)) ...
             ','  num2str(laserpower*value(laser_right_on)) ];
        sent_message_list.value = [value(sent_message_list);msg]; 
        sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials]; 
        try
            fprintf(value(base_station),msg)
        catch
        end    
        pause(.1)
        
        xa = fscanf(value(base_station));
        disp(xa)
        [xa,tmp] = regexp(xa,'\r','split','match');
        xa=cellfun(@deblank,xa,'uniformoutput',false)';
        xa=xa(~cellfun(@isempty,xa));
        if ~isempty(xa)
            received_message_list.value = [value(received_message_list);xa];
            received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
        end
        
        
        
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
        
end



end



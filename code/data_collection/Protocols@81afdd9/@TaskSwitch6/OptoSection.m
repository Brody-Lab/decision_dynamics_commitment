function [x, y] = OptoSection(obj, action, varargin)

GetSoloFunctionArgs(obj);


switch action,
    
    % ------------------------------------------------------------------
    %              INIT
    % ------------------------------------------------------------------
    
    
    %%% list all the way the rat can do well/bad : nose, perf etc.
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        ysave=y;
        
        ToggleParam(obj, 'opto_active', 0, x, y, 'position', [x y 200 20], ...
            'OffString', 'Opto OFF', 'OnString',  'Opto ON', ...
            'TooltipString', 'If on, sends opto pulses to cerebro');next_row(y,1);
        
        
        
        %%% percent hit left/ hit right/viol
        SubheaderParam(obj,'pa4', '0',x,y,'position', [x y 8 20]);
        DispParam(obj, 'nTrials_opto_0',0, x, y, 'labelfraction', 0.25,'label','T','position', [x+8+2 y 48 20]);
        DispParam(obj, 'percent_violations_opto_0',0, x, y, 'labelfraction', 0.25,'label','V','position', [x+8+48 y 48 20]);
        DispParam(obj, 'left_correct_opto_0',0, x, y, 'labelfraction', 0.25,'label','L','position', [x+8+48*2 y 48 20]);
        DispParam(obj, 'right_correct_opto_0',0, x, y, 'labelfraction', 0.25,'label','R','position', [x+8+48*3 y 48 20]);
        next_row(y,1);
        
        
        
        %%% percent hit left/ hit right/viol
        SubheaderParam(obj,'pa3', 'B',x,y,'position', [x y 8 20]);
        DispParam(obj, 'nTrials_opto_bi',0, x, y, 'labelfraction', 0.25,'label','T','position', [x+8+2 y 48 20]);
        DispParam(obj, 'percent_violations_opto_bi',0, x, y, 'labelfraction', 0.25,'label','V','position', [x+8+48 y 48 20]);
        DispParam(obj, 'left_correct_opto_bi',0, x, y, 'labelfraction', 0.25,'label','L','position', [x+8+48*2 y 48 20]);
        DispParam(obj, 'right_correct_opto_bi',0, x, y, 'labelfraction', 0.25,'label','R','position', [x+8+48*3 y 48 20]);
        next_row(y,1);
        
        
        %%% percent hit left/ hit right/viol
        SubheaderParam(obj,'pa2', 'R',x,y,'position', [x y 8 20]);
        DispParam(obj, 'nTrials_opto_right',0, x, y, 'labelfraction', 0.25,'label','T','position', [x+8+2 y 48 20]);
        DispParam(obj, 'percent_violations_opto_right',0, x, y, 'labelfraction', 0.25,'label','V','position', [x+8+48 y 48 20]);
        DispParam(obj, 'left_correct_opto_right',0, x, y, 'labelfraction', 0.25,'label','L','position', [x+8+48*2 y 48 20]);
        DispParam(obj, 'right_correct_opto_right',0, x, y, 'labelfraction', 0.25,'label','R','position', [x+8+48*3 y 48 20]);
        next_row(y,1);
        
        
        %%% percent hit left/ hit right/viol
        SubheaderParam(obj,'pa1', 'L',x,y,'position', [x y 8 20]);
        DispParam(obj, 'nTrials_opto_left',0, x, y, 'labelfraction', 0.25,'label','T','position', [x+8+2 y 48 20]);
        DispParam(obj, 'percent_violations_opto_left',0, x, y, 'labelfraction', 0.25,'label','V','position', [x+8+48 y 48 20]);
        DispParam(obj, 'left_correct_opto_left',0, x, y, 'labelfraction', 0.25,'label','L','position', [x+8+48*2 y 48 20]);
        DispParam(obj, 'right_correct_opto_left',0, x, y, 'labelfraction', 0.25,'label','R','position', [x+8+48*3 y 48 20]);
        next_row(y,1);
        
        SubheaderParam(obj,'lab7', 'Opto History',x,y); next_row(y);
        
        
        %         SubheaderParam(obj,'title',mfilename,x,y); next_row(y);
        
        
        
        
        %%%%%% COLUMN 3 %%%%%%
        next_column(x);y=ysave;
        
        
        %         next_row(y,1);
        
        
        %%% percent correct coh/incoh
        DispParam(obj, 'opto_left_power',0, x, y, 'labelfraction', 0.55,'label','L power','position', [x y 100 20]);
        DispParam(obj, 'opto_right_power',0, x, y, 'labelfraction', 0.55,'label','R power','position', [x+100 y 100 20]);next_row(y);
        
        %%% percent correct coh/incoh
        DispParam(obj, 'cere1',0, x, y, 'labelfraction', 0.05,'label','','position', [x y 40 20]);
        DispParam(obj, 'cere2',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40 y 40 20]);
        DispParam(obj, 'cere3',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*2 y 40 20]);
        DispParam(obj, 'cere4',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*3 y 40 20]);
        DispParam(obj, 'cere5',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*4 y 40 20]);next_row(y);
        
        SubheaderParam(obj,'lab1', 'cere1',x,y,'position', [x y 35 20]);
        SubheaderParam(obj,'lab2', 'cere2',x+40,y,'position', [x+40 y 35 20]);
        SubheaderParam(obj,'lab3', 'cere3',x+40*2,y,'position', [x+40*2 y 35 20]);
        SubheaderParam(obj,'lab4', 'cere4',x+40*3,y,'position', [x+40*3 y 35 20]);
        SubheaderParam(obj,'lab5', 'cere5',x+40*4,y,'position', [x+40*4 y 35 20]);next_row(y);
        
        %%% number of valid trials
        
        MenuParam(obj, 'opto_stop_ref', {'off';'cue'; 'stim';...
            'choice'}, 1, x, y, 'label', 'ref', 'TooltipString',...
            'opto stop ref', 'labelfraction',0.2,'position', [x y 100 20]);
        DispParam(obj, 'delay_stop',0, x, y, 'labelfraction', 0.55,'label','delay stop','position', [x+100 y 100 20]);
        next_row(y);
        
        MenuParam(obj, 'opto_start_ref', {'off';'cue'; 'stim';...
            'choice'}, 1, x, y, 'label', 'ref', 'TooltipString',...
            'opto start ref', 'labelfraction',0.2,'position', [x y 100 20]);
        DispParam(obj, 'delay_start',0, x, y, 'labelfraction', 0.55,'label','delay start','position', [x+100 y 100 20]);
        next_row(y);
        
        SubheaderParam(obj,'lab6', 'This Opto Pulse',x,y); next_row(y);
        
        
        
        
        
        %%%%%% COLUMN 3 %%%%%%
        next_column(x);y=ysave;
        
        %%%% Separate window for opto setup
        ToggleParam(obj, 'opto_setup', 0, x, y, 'OnString', 'Opto setup', ...
            'OffString', 'Opto setup', 'TooltipString', 'Show/Hide Opto setup panel');
        set_callback(opto_setup, {mfilename, 'show_hide_opto'});
        next_row(y);
        oldx=x; oldy=y;    parentfig=double(gcf);
        SoloParamHandle(obj, 'myfig_opto', 'value', double(figure('Position', [320 300 580 220], 'closerequestfcn',...
            [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none','Name', mfilename)), 'saveable', 0);
        set(gcf, 'Visible', 'off');
        x=10;y=10;
        
        
%         
%         PushbuttonParam(obj,'cerebro_stop', x, y, 'position', [x y 200 20],'label', 'stop');
%         set_callback(cerebro_stop, {mfilename, 'do_cerebro_stop'});
%         next_row(y);
%         
%         
%         PushbuttonParam(obj,'cerebro_trigger', x, y, 'position', [x y 200 20],'label', 'trigger');
%         set_callback(cerebro_trigger, {mfilename, 'do_cerebro_trigger'});
%         next_row(y);
%         
%         
%         
%         PushbuttonParam(obj,'cerebro_send_waveform', x, y, 'position', [x y 200 20],'label', 'send wave');
%         set_callback(cerebro_send_waveform, {mfilename, 'do_cerebro_send_waveform'});
%         next_row(y);
%         
%         
%         %%% percent correct coh/incoh
%         NumeditParam(obj, 'acere1',0, x, y, 'labelfraction', 0.05,'label','','position', [x y 40 20]);
%         NumeditParam(obj, 'acere2',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40 y 40 20]);
%         NumeditParam(obj, 'acere3',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*2 y 40 20]);
%         NumeditParam(obj, 'acere4',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*3 y 40 20]);
%         NumeditParam(obj, 'acere5',0, x, y, 'labelfraction', 0.05,'label','R power','position', [x+40*4 y 40 20]);next_row(y);
%         
%         SubheaderParam(obj,'alab1', 'cere1',x,y,'position', [x y 35 20]);
%         SubheaderParam(obj,'alab2', 'cere2',x+40,y,'position', [x+40 y 35 20]);
%         SubheaderParam(obj,'alab3', 'cere3',x+40*2,y,'position', [x+40*2 y 35 20]);
%         SubheaderParam(obj,'alab4', 'cere4',x+40*3,y,'position', [x+40*3 y 35 20]);
%         SubheaderParam(obj,'alab5', 'cere5',x+40*4,y,'position', [x+40*4 y 35 20]);next_row(y);
%         
%         
%         
%         PushbuttonParam(obj,'cerebro_send_power', x, y, 'position', [x y 200 20],'label', 'send power');
%         set_callback(cerebro_send_power, {mfilename, 'do_cerebro_send_power'});
%         next_row(y);
%         
%         %%% percent correct coh/incoh
%         NumeditParam(obj, 'aopto_left_power',0, x, y, 'labelfraction', 0.55,'label','L power','position', [x y 100 20]);
%         NumeditParam(obj, 'aopto_right_power',0, x, y, 'labelfraction', 0.55,'label','R power','position', [x+100 y 100 20]);next_row(y);
%         
%         PushbuttonParam(obj,'cerebro_connect', x, y, 'position', [x y 200 20],'label', 'connect');
%         set_callback(cerebro_connect, {mfilename, 'do_cerebro_connect'});
%         next_row(y);
        
        

        DispParam(obj, 'opto_status', '', x, y, 'labelfraction', 0.15, 'position', [x y 500 40]);next_row(y,3);
        

        PushbuttonParam(obj,'test_implant', x, y, 'position', [x y 500 100],...
            'BackgroundColor',[1 0.6 1],'label', 'TEST IMPLANT HERE');
        set(get_ghandle(test_implant),'Fontsize',22);
        set(get_ghandle(opto_status),'Fontsize',16);
        set_callback(test_implant, {mfilename, 'do_test_implant'});
        next_row(y);

        
        %%% back to the main window
        x=oldx; y=oldy;
        figure(parentfig);
        
        DispParam(obj, 'opto_connected', 0, x, y, 'position', [x y 200 20], ...
            'TooltipString', 'If 1, we are connected to cerebro');next_row(y,1);
        
        
        
        %%%% current task
        MenuParam(obj, 'opto_type', {'Full Trial'; 'First Half'; 'Second Half'}, 1, x, y, ...
            'TooltipString', 'the current type of opto'); next_row(y);
        
        
        NumeditParam(obj, 'max_left_opto_power',800, x, y, 'labelfraction', 0.55,'label','L power','position', [x y 100 20]);
        NumeditParam(obj, 'max_right_opto_power',800, x, y, 'labelfraction', 0.55,'label','R power','position', [x+100 y 100 20]);next_row(y);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% INTERNAL VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        SoloParamHandle(obj,'base_station','value','');
        SoloParamHandle(obj,'sent_message_list','value',{});
        SoloParamHandle(obj,'received_message_list','value',{});
        SoloParamHandle(obj,'sent_message_list_trial','value',{});
        SoloParamHandle(obj,'received_message_list_trial','value',{});
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% SEND OUT VARIBLES %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        %%% send to the history section
        SoloFunctionAddVars('HistorySection', 'ro_args', {'opto_left_power';...
            'opto_right_power';'opto_active'});
        
        SoloFunctionAddVars('HistorySection', 'rw_args', ...
            {'nTrials_opto_left';'percent_violations_opto_left';'left_correct_opto_left';'right_correct_opto_left';...
            'nTrials_opto_right';'percent_violations_opto_right';'left_correct_opto_right';'right_correct_opto_right';...
            'nTrials_opto_bi';'percent_violations_opto_bi';'left_correct_opto_bi';'right_correct_opto_bi';...
            'nTrials_opto_0';'percent_violations_opto_0';'left_correct_opto_0';'right_correct_opto_0'});
        
        
        
        
        
        
        
        
        
    case 'next_trial',
        
        
        if(value(opto_active) && value(opto_connected))
            
            xa = fscanf(value(base_station));
            disp(xa)
            [xa,tmp] = regexp(xa,'\r','split','match');
            xa=cellfun(@deblank,xa,'uniformoutput',false)';
            xa=xa(~cellfun(@isempty,xa));
            if ~isempty(xa)
                received_message_list.value = [value(received_message_list);xa];
                received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
            end
            
            
            
            
            
            stimulate=mod(n_done_trials,3);
            if(stimulate==2)
                
                % Decide what side of stim: both, or neither
                r = rand;
                
                if(r < 1/3) % left
                    opto_left_power.value = value(max_left_opto_power);
                    laser_right_on.value = 0;
                elseif(r>=1/3 && r<2/3) %right
                    laser_left_on.value = 0;
                    opto_right_power.value = value(max_right_opto_power);
                elseif(r>=2/3) %bi
                    opto_left_power.value = value(max_left_opto_power);
                    opto_right_power.value = value(max_right_opto_power);
                else
                    error('wtf')
                end
                
                
                
%                 
%                 %%%% current task
%                 MenuParam(obj, 'opto_type', {'Full Trial'; 'First Half'; 'Second Half'}, 1, x, y, ...
%                     'TooltipString', 'the current type of opto'); next_row(y);
%         
                
                
                % Decide what duration of stim: full,first half,second half
                r = rand;
                
                if(r < 1/3) 
                    opto_type.value = 'Full Trial';
                    msg_wave='W,0,1500,0,1500,0';
                elseif(r>=1/3 && r<2/3)                     
                    opto_type.value = 'First Half';
                    msg_wave='W,0,650,0,650,0';
                elseif(r>=2/3)
                    opto_type.value = 'Second Half';
                    msg_wave='W,650,650,0,650,0';
                else
                    error('wtf')
                end
                
                
                
                
                
                
            else
                opto_left_power.value = 0;
                opto_right_power.value = 0;
                msg_wave='W,0,1500,0,1500,0';
            end
            
            
            
            
            
            
            %%%% SEND WAVEFORM
            
            %%%% NO PULSING, CONTINUOUS LASER
            %         msg='W,0,1500,0,1500,0';
            %         %%%% PULSING 20Hz( like Thomas, Adrian)
            %         msg='W,0,10,40,1500,0';
            %         %%%% PULSING 40Hz( like Chuck)
            %         msg='W,0,10,15,1500,0';
%             msg='W,0,1500,0,1500,0';
            sent_message_list.value = [value(sent_message_list);msg_wave];
            sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials];
            try
                fprintf(value(base_station),msg_wave)
            catch
            end
            pause(.2)
            xa = fscanf(value(base_station));
            disp(xa)
            [xa,tmp] = regexp(xa,'\r','split','match');
            xa=cellfun(@deblank,xa,'uniformoutput',false)';
            xa=xa(~cellfun(@isempty,xa));
            if ~isempty(xa)
                received_message_list.value = [value(received_message_list);xa];
                received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
            end
            pause(.2)
            
            
            %%%% SEND POWER
            msg=['D,' num2str(value(opto_left_power)) ',' num2str(value(opto_right_power))];
            sent_message_list.value = [value(sent_message_list);msg];
            sent_message_list_trial.value = [value(sent_message_list_trial);n_done_trials];
            try
                fprintf(value(base_station),msg)
            catch
            end
            pause(.2)
            xa = fscanf(value(base_station));
            disp(xa)
            [xa,tmp] = regexp(xa,'\r','split','match');
            xa=cellfun(@deblank,xa,'uniformoutput',false)';
            xa=xa(~cellfun(@isempty,xa));
            if ~isempty(xa)
                received_message_list.value = [value(received_message_list);xa];
                received_message_list_trial.value = [value(received_message_list_trial);n_done_trials];
            end
            
            
            
            
        end
        
        
    case 'end_session'
        
        
        
    case 'get'
        
        val=varargin{1};
        
        eval(['x=value(' val ');']);
        
    case 'show_hide_opto',
        if opto_setup == 1, set(value(myfig_opto), 'Visible', 'on');
        else                   set(value(myfig_opto), 'Visible', 'off');
        end;
        
    case 'show_opto',
        if value(opto_active) == 1, set(value(myfig_opto), 'Visible', 'on');
        else                   set(value(myfig_opto), 'Visible', 'off');
        end;
        
        

        
    case 'do_test_implant',
        
        if(value(opto_connected)==0)
            
            com_port=bSettings('get', 'CEREBRO', 'com_port');
            
            a=instrhwinfo('serial');
            ports=a.AvailableSerialPorts;
            
            found=0;
            for i=1:length(ports)
                if(strcmp(ports{i},com_port))
                    found=1;
                end
            end
            
            if(found)
                base_station.value=serial(com_port);
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
                    xa=xa{1};
                    if(~isempty(strfind(xa,'Error communicating with Cerebro')))
                        disp(strfind(xa,'Error communicating with Cerebro'))
                        opto_connected.value=0;
                        opto_status.value='Error communicating with Cerebro';                        
                        set(get_ghandle(test_implant),'BackgroundColor',[1 0 0]);
                        fclose(value(base_station))
                    elseif(~isempty(strfind(xa,'Cerebro Version')))
                        opto_connected.value=1;                        
                        opto_status.value='CONNECTED!!!!!!';                        
                        set(get_ghandle(test_implant),'BackgroundColor',[0 1 0]);
                        pause(.1)
                        
                        
                        
                        
                        
                        %%%% SEND WAVEFORM
                        
                        %%%% NO PULSING, CONTINUOUS LASER
                        %         msg='W,0,1500,0,1500,0';                        
                        %         %%%% PULSING 20Hz( like Thomas, Adrian)
                        %         msg='W,0,10,40,1500,0';                        
                        %         %%%% PULSING 40Hz( like Chuck)
                        %         msg='W,0,10,15,1500,0';
                        msg='W,0,1500,0,1500,0';                        
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
                        
                        
                        %%%% SEND POWER
                        msg=['D,' num2str(value(max_left_opto_power)) ',' num2str(value(max_right_opto_power))];                        
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
                        
                        
                        %%%% TRIGGER PULSE
                        msg='T';
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
                        
                        
                        %%%% RESET POWER
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
                        pause(.1)
                        
                        
                        
                    else
                        error('wut?')
                    end
                end
            else
                opto_connected.value=0;
                opto_status.value='Error communicating with Base Station';
                
                set(get_ghandle(test_implant),'BackgroundColor',[1 0 0]);
                %             opto_connected.value='Not connected';
            end
        end
        
        
                
        
        
        
        
        
        
    case 'do_cerebro_connect',
        
        if(value(opto_connected)==0)
            
            com_port=bSettings('get', 'CEREBRO', 'com_port');
            
            a=instrhwinfo('serial');
            ports=a.AvailableSerialPorts;
            
            found=0;
            for i=1:length(ports)
                if(strcmp(ports{i},com_port))
                    found=1;
                end
            end
            
            if(found)
                base_station.value=serial(com_port);
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
                    xa=xa{1};
                    if(~isempty(strfind(xa,'Error communicating with Cerebro')))
                        disp(strfind(xa,'Error communicating with Cerebro'))
                        opto_connected.value=0;
                        fclose(value(base_station))
                    elseif(~isempty(strfind(xa,'Cerebro Version')))
                        opto_connected.value=1;
                    else
                        error('wut?')
                    end
                end
            else
                opto_connected.value=0;
                %             opto_connected.value='Not connected';
            end
        end
        
        
        
        
    case 'do_cerebro_send_waveform',
        
        cere1.value=value(acere1);
        cere2.value=value(acere2);
        cere3.value=value(acere3);
        cere4.value=value(acere4);
        cere5.value=value(acere5);
        
        if(value(opto_connected)==1)
            msg=['W,' num2str(value(cere1)) ',' num2str(value(cere2)) ',' num2str(value(cere3)) ',' ...
                num2str(value(cere4)) ',' num2str(value(cere5))];
            %%%% NO PULSING, CONTINUOUS LASER
            %         msg='W,0,1500,0,1500,0';
            
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
        end
        
        
        
    case 'do_cerebro_send_power',
        
        
        opto_left_power.value=value(aopto_left_power);
        opto_right_power.value=value(aopto_right_power);
        
        if(value(opto_connected)==1)
            msg=['D,' num2str(value(opto_left_power)) ',' num2str(value(opto_right_power))];
            
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
            
        end
        
        
        
        
        
    case 'do_cerebro_trigger',
        
        
        if(value(opto_connected)==1)
            msg='T';
            
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
            
        end
        
    case 'do_cerebro_stop',
        
        
        if(value(opto_connected)==1)
            msg='A';
            
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
            
        end
        
        
    case 'make_and_send_summary',
        %
        %         pd.hits       = value(hit_history);
        %         pd.sides      = value(side_history);
        %         pd.tasks      = value(task_history);
        %         pd.stage      = value(training_stage);
        %         sendsummary(obj, 'sides', pd.sides, 'protocol_data', pd);
        
        
end



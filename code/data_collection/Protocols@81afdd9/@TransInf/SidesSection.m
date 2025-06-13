function [x, y] = SidesSection(obj, action, varargin)
%transitive inference bbs Jan 2016

GetSoloFunctionArgs(obj);

switch action,
    
    case 'init'
        x=varargin{1};
        y=varargin{2};
        
        NumeditParam(obj, 'nic_time', .01, x,y,'label','NIC Time','TooltipString','Length of NIC');
        next_row(y);
        NumeditParam(obj,'trials_in_stage',0,x,y,'label','Trial Counter');
        next_row(y);
        NumeditParam(obj,'training_stage',1,x,y,'label','Training Stage');
        next_row(y);
        MenuParam(obj,'Lsound',{'A','B','C','D','E'},1,x,y,'label','Lsound')
        next_row(y);
        MenuParam(obj,'Rsound',{'A','B','C','D','E'},1,x,y,'label','Rsound')
        next_row(y);
        MenuParam(obj,'Corr',{'l','r','n'},1,x,y,'label','Correct Side')
        next_row(y);
        
        SoloFunctionAddVars('SMA1', 'ro_args', ...
            {'training_stage';'trials_in_stage';...
            'nic_time'; 'Lsound';'Rsound';'Corr'});
        
        %   Trial history
        SoloParamHandle(obj, 'hit_history', 'value', []);
        SoloParamHandle(obj, 'left_sound', 'value', []);
        SoloParamHandle(obj, 'right_sound', 'value', []);
        SoloParamHandle(obj, 'absolute_time', 'value', []);
        SoloParamHandle(obj, 'previous_sides', 'value', []);
        
    case 'trial_completed'
        
        if n_done_trials>0
            trials_in_stage.value = value(trials_in_stage) + 1;
            if ~isempty(parsed_events)
                if isfield(parsed_events.states,'in_cpoke')
                    
                    absolute_time.value=cat(1,value(absolute_time),fix(clock));
                    left_sound.value=[left_sound(:); value(Lsound)];
                    right_sound.value=[right_sound(:); value(Rsound)];
                    
                    if ~isempty(parsed_events.states.violation)
                        hit_history.value=[hit_history(:); nan];
                        previous_sides.value=[previous_sides(:); 'n'];
                    else
                        hit_history.value=[hit_history(:); ~isempty(parsed_events.states.reward)];
                        if ~isempty(parsed_events.states.reward) && strcmp('l',value(Corr))
                            previous_sides.value=[previous_sides(:); 'l'];
                        elseif ~isempty(parsed_events.states.error) && strcmp('r',value(Corr))
                            previous_sides.value=[previous_sides(:); 'l'];
                        elseif ~isempty(parsed_events.states.reward) && strcmp('r',value(Corr))
                            previous_sides.value=[previous_sides(:); 'r'];
                        elseif ~isempty(parsed_events.states.error) && strcmp('l',value(Corr))
                            previous_sides.value=[previous_sides(:); 'r'];
                        end
                    end
                    
                    
                    if value(training_stage)==1
                        increment=0.01*value(nic_time);% grow NIC by 10%; athena's suggestion
                        if increment<0.001
                            increment=0.001;
                        end
                        
                        
                        if isempty(parsed_events.states.violation)
                            nic_time.value=value(nic_time)+increment;
                        end
                    end
                    
                end
            end
        end
        
    case 'next_trial',
        %set up the stimuli for the next trial
        maxnic=1.8;
        trials_in_stage.value=+1;
        if value(training_stage)==1
            
            
            
            if value(nic_time)>maxnic
                training_stage.value=2;
                trials_in_stage.value=0;
                nic_time.value=maxnic;
            end
            
            RNX=rand;
            if      RNX<.5;
                Lsound.value = 'A'; Rsound.value = 'B'; Corr.value='l';
            elseif  RNX>=.5
                Lsound.value = 'B'; Rsound.value = 'A'; Corr.value='r';
            end
            
        elseif value(training_stage)==2
            nic_time.value=maxnic;
            RNX=rand*0.84;
            if RNX<0.1;                  Lsound.value = 'A'; Rsound.value = 'B'; Corr.value='l';
            elseif RNX>=0.1 && RNX<.2;   Lsound.value = 'B'; Rsound.value = 'A'; Corr.value='r';
            elseif RNX>=0.2 && RNX<.3;   Lsound.value = 'B'; Rsound.value = 'C'; Corr.value='l';
            elseif RNX>=0.3 && RNX<.4;   Lsound.value = 'C'; Rsound.value = 'B'; Corr.value='r';
            elseif RNX>=0.4 && RNX<.5;   Lsound.value = 'C'; Rsound.value = 'D'; Corr.value='l';
            elseif RNX>=0.5 && RNX<.6;   Lsound.value = 'D'; Rsound.value = 'C'; Corr.value='r';
            elseif RNX>=0.6 && RNX<.7;   Lsound.value = 'D'; Rsound.value = 'E'; Corr.value='l';
            elseif RNX>=0.7 && RNX<.8;   Lsound.value = 'E'; Rsound.value = 'D'; Corr.value='r';
            elseif RNX>=0.8 && RNX<.81;  Lsound.value = 'A'; Rsound.value = 'E'; Corr.value='l';
            elseif RNX>=0.81 && RNX<.82; Lsound.value = 'A'; Rsound.value = 'E'; Corr.value='r';
            elseif RNX>=0.82 && RNX<.83; Lsound.value = 'E'; Rsound.value = 'A'; Corr.value='l';
            else                         Lsound.value = 'E'; Rsound.value = 'A'; Corr.value='r';
            end
            
               elseif value(training_stage)==1.5
            nic_time.value=maxnic;
            RNX=rand*0.8;
            if RNX<0.1;                  Lsound.value = 'A'; Rsound.value = 'B'; Corr.value='l';
            elseif RNX>=0.1 && RNX<.2;   Lsound.value = 'B'; Rsound.value = 'A'; Corr.value='r';
            elseif RNX>=0.2 && RNX<.3;   Lsound.value = 'B'; Rsound.value = 'C'; Corr.value='l';
            elseif RNX>=0.3 && RNX<.4;   Lsound.value = 'C'; Rsound.value = 'B'; Corr.value='r';
            elseif RNX>=0.4 && RNX<.5;   Lsound.value = 'C'; Rsound.value = 'D'; Corr.value='l';
            elseif RNX>=0.5 && RNX<.6;   Lsound.value = 'D'; Rsound.value = 'C'; Corr.value='r';
            elseif RNX>=0.6 && RNX<.7;   Lsound.value = 'D'; Rsound.value = 'E'; Corr.value='l';
            elseif RNX>=0.7 && RNX<=.8;   Lsound.value = 'E'; Rsound.value = 'D'; Corr.value='r';
            end
              
        end
        
        
    case 'make_and_send_summary',
        
        peh=cell2mat(parsed_events_history);
        
        pd.sides = zeros(length(peh),1);
        pd.nic=cell2mat(get_history(nic_time));
        pd.training_stage=cell2mat(get_history(training_stage));
        pd.trials_in_stage = cell2mat(get_history(trials_in_stage));
        pd.right_sound = value(right_sound);
        pd.left_sound = value(left_sound);
        hits = value(hit_history);
        sides = value(previous_sides);
        pd.sides = sides;
        pd.hits = hits;
        sendsummary(obj,'hits',hits,'sides',sides,'protocol_data',pd);
end



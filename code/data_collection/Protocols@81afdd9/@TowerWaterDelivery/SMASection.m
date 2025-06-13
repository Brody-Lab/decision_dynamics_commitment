%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%
%            'prepare_next_trial'   Returns a @StateMachineAssembler
%                        object, ready to be sent to dispatcher, and a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
%            'get_state_colors'     Returns a structure where each
%                        fieldname is a state name, and each field content
%                        is a color for that state.
%
%
% RETURNS:
% --------
%
% [sma, prepstates]      When action == 'prepare_next_trial', sma is a
%                        @StateMachineAssembler object, ready to be sent to
%                        dispatcher, and prepstates is a a cell
%                        of strings containing the 'prepare_next_trial'
%                        states.
%
% state_colors           When action == 'get_state_colors', state_colors is
%                        a structure where each fieldname is a state name,
%                        and each field content is a color for that state.
%
%
%
% 
%



function [varargout] = SMASection(obj, action)
   
GetSoloFunctionArgs(obj);

switch action
    
%% prepare_next_trial
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------

  case 'prepare_next_trial',
    pause(1);
    waterdio = value(WaterDIO);
    leddio   = value(LEDDIO);
    actwater = value(ActiveWater);
    actleds  = sum(leddio(actwater == 1));
    waterdur = value(ValveOpenTimes);
    waterpas = value(WaterPulse);
    cycledur = value(CycleDur);
    trialdur = value(TrialDur);
      
    line_names = 'LCRlcrX';
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    sma = add_scheduled_wave(sma, 'name','trial_wave','preamble',trialdur,'sustain',100+cycledur+trialdur);
    sma = add_scheduled_wave(sma, 'name','cycle_wave','preamble',cycledur,'sustain',100+cycledur+trialdur);
        
    for i = 1:numel(waterdio)
        if ~isnan(waterdio(i))
            sma = add_scheduled_wave(sma, 'name',['water',num2str(i),'_wave'],...
                'preamble',0,...
                'sustain',waterdur(i),...
                'refraction',waterpas-waterdur(i),...
                'DOut',waterdio(i));
        end
    end
    
    twn = get_wavenumber(sma,'trial_wave');
    cwn = get_wavenumber(sma,'cycle_wave'); 
    
    hapnames = {'Lhi','Chi','Rhi','lhi','chi','rhi','Xhi'};
    poknames = {'Lin','Cin','Rin','lin','cin','rin','Xin'};
    
    names     = {'trial_wave_hi','cycle_wave_hi'};%,'lhi',      'chi',      'rhi',      'Xhi'};
    functions = {'wave_high',    'wave_high'};%,    'line_high','line_high','line_high','line_high'};
    numbers   = {twn,            cwn};%,            4,          5,          6,          7};

    sma = add_happening_spec(sma, struct(...
        'name',                 names, ...
        'detectorFunctionName', functions, ...
        'inputNumber',          numbers));
    
    sma = add_state(sma, 'name', 'start','self_timer',0.001,...
            'output_actions',{'SchedWaveTrig','trial_wave+cycle_wave';'DOut',actleds},...
            'input_to_statechange', {'Tup','pause';'Xhi','reset_state';'Xin','reset_state'});
    
    sma = add_state(sma, 'name', 'pause','self_timer',cycledur,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {'trial_wave_hi','trialend';'cycle_wave_hi','check1';'Tup','check1';...
            'Xhi','reset_state';'Xin','reset_state'});
        
    for i=1:6
        %if ~isnan(waterdio(i))
            if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
            else                                      nextstate = ['check',num2str(i+1)];
            end
            if actwater(i) == 1; waterstate = ['water',num2str(i)];
            else                 waterstate = nextstate;
            end
            if     i == 1; extra = {'SchedWaveTrig','cycle_wave'};
            elseif i == 2; extra = {};%{'SchedWaveTrig','cycle_wave'};
            else           extra = {};
            end

            sma = add_state(sma, 'name', ['check',num2str(i)],'self_timer',0.001,...
                'output_actions',{'DOut',actleds;extra{:}},...
                'input_to_statechange', {hapnames{i},waterstate;poknames{i},waterstate;'Tup',nextstate;...
                'Xhi','reset_state';'Xin','reset_state'}); %#ok<CCAT>
        %end
    end
    
    for i=1:6
        if ~isnan(waterdio(i))
            if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
            else                                      nextstate = ['check',num2str(i+1)];
            end

            sma = add_state(sma, 'name', ['water',num2str(i)],'self_timer',0.001,...
                'output_actions',{'DOut',actleds,'SchedWaveTrig', ['water',num2str(i),'_wave']},...
                'input_to_statechange', {'Tup',nextstate;'Xhi','reset_state';'Xin','reset_state'});
        end
    end    
 
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {'Tup','check_next_trial_ready';'Xhi','reset_state';'Xin','reset_state'});
    
    sma = add_state(sma, 'name', 'reset_state','self_timer',0.1,...
            'input_to_statechange', {'Tup','check_next_trial_ready'});    
    
    varargout{1} = sma;
    varargout{2} = {'trialend','reset_state'};    
        
    
%% manual_test               
  case 'manual_test'
    
    waterdio = value(WaterDIO);
    leddio   = value(LEDDIO);
    waterdur = value(ValveOpenTimes);
    waterdur((waterdur*3)>0.5) = 0.5/3;
    waterdur(waterdur < 0.02)  = 0.02;
    
    pulsetime = mean(waterdur)/2; 
    if pulsetime < 0.03; pulsetime = 0.03; end
    if pulsetime > 0.49; pulsetime = 0.49;  end
    
    BRK = value(IsBroken);
      
    line_names = 'LCRlcrX';
    line_names(find(isnan(waterdio)==1)) = '';
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
%     poke_in_names = cell(0);
%     poke_out_names = cell(0);
%     names = cell(0);
%     functions = cell(0);
%     numbers = cell(0);
%     
%     for i = 1:numel(line_names)
%         poke_in_names{ end+1} = [line_names(i),'in'];
%         poke_out_names{end+1} = [line_names(i),'out'];
%         
%         names{end+1}          = [line_names(i),'in'];
%         names{end+1}          = [line_names(i),'out'];
%         
%         functions{end+1}      = 'line_in';
%         functions{end+1}      = 'line_out';
%         
%         numbers{end+1}        = i;
%         numbers{end+1}        = i;
%     end
%     
%     names{end+1}     = 'Xhi';
%     functions{end+1} = 'line_high';
%     numbers{end+1}   = 7;
%         
%     sma = add_happening_spec(sma, struct(...
%         'name',                 names, ...
%         'detectorFunctionName', functions, ...
%         'inputNumber',          numbers));
    
    sma = add_state(sma,'name','waitforredbutton',...
        'input_to_statechange',{'Xout','earlypause'});
    
    sma = add_state(sma,'name','earlypause','self_timer',2,...
        'input_to_statechange',{'Tup','togglevalvesstart'});
    
    sma = add_state(sma,'name','togglevalvesstart','self_timer',0.01,...
        'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
    sma = add_state(sma,'name','togglevalves','self_timer',0.01,...
        'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
    for i = 1:numel(waterdio)
        sma = add_state(sma,'self_timer',1 - (waterdur(i)/2),...
            'output_actions',{'DOut',sum(leddio(i))},...
            'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
        sma = add_state(sma,'self_timer',waterdur(i)/2,...
            'output_actions',{'DOut',sum(leddio(i)) + sum(waterdio(i))},...
            'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
        
        sma = add_state(sma,'self_timer',0.5,...
            'output_actions',{'DOut',sum(leddio(i))},...
            'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    end
    
    sma = add_state(sma,'self_timer',0.01,...
        'input_to_statechange',{'Tup','togglevalvesstart';'Xout','trialend'});
        
    sma = add_state(sma, 'name', 'trialend','self_timer',1,...
        'input_to_statechange', {'Tup','trialendwait'}); 
    
    sma = add_state(sma, 'name', 'trialendwait','self_timer',4,...
        'input_to_statechange', {'Tup','good_finish';'Xout','reset_state'}); 
    
    sma = add_state(sma, 'name', 'reset_state','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'}); 
    
    sma = add_state(sma, 'name', 'good_finish','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'});
        
    varargout{1} = sma;
    varargout{2} = {'reset_state','good_finish'}; 

%     for i = 1:6
%         if ~isnan(waterdio(i))
%             if BRK(i) == 0 %ActiveWater(i) == 1
%                 sma = add_state(sma, 'name', ['wait_for_',num2str(i)],...
%                     'output_actions',{'DOut',leddio(i)},...
%                     'input_to_statechange', {poke_in_names{i},'current_state+1';'Xhi','reset_state';'Xin','reset_state'});
%                 
%                 sma = add_state(sma, 'name', ['poke_',num2str(i),'on'],'self_timer',(waterdur(i)*3),...
%                     'output_actions',{'DOut',leddio(i)+waterdio(i)},...
%                     'input_to_statechange', {poke_out_names{i},'current_state+2';'Xhi','reset_state';'Xin','reset_state';'Tup',['poke_',num2str(i),'off']});
%                 
%                 sma = add_state(sma, 'name', ['poke_',num2str(i),'off'],'self_timer',0.5-(waterdur(i)*3),...
%                     'output_actions',{'DOut',leddio(i)},...
%                     'input_to_statechange', {poke_out_names{i},'current_state+1';'Xhi','reset_state';'Xin','reset_state';'Tup',['poke_',num2str(i),'on']});
%             else
%                 sma = add_state(sma, 'name', ['wait_for_',num2str(i)],'self_timer',0.01,...
%                     'input_to_statechange', {'Tup','current_state+1';'Xhi','reset_state';'Xin','reset_state'});
%                 sma = add_state(sma, 'name', ['poke_',num2str(i),'in'],'self_timer',0.01,...
%                     'input_to_statechange', {'Tup','current_state+1';'Xhi','reset_state';'Xin','reset_state'});
%             end
%         end
%     end
%     sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
%         'input_to_statechange', {'Tup','check_next_trial_ready';'Xhi','reset_state';'Xin','reset_state'});
%     
%     sma = add_state(sma, 'name', 'reset_state','self_timer',0.1,...
%             'input_to_statechange', {'Tup','check_next_trial_ready'}); 
%        
%     varargout{1} = sma;
%     varargout{2} = {'trialend','reset_state'}; 
    
    
%% wait_for_reboot    
   case 'wait_for_reboot',
    pause(1);
    line_names = 'LCRlcrX';
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    %names     = {'Xin',    'Xout'};
    %functions = {'line_in','line_out'};
    %numbers   = {7,        7,};
    %
    %sma = add_happening_spec(sma, struct(...
    %    'name',                 names, ...
    %    'detectorFunctionName', functions, ...
    %    'inputNumber',          numbers));
    
    sma = add_state(sma, 'name', 'wait_for_xin',...
        'input_to_statechange', {'Xin','trialend'});
    
    
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'trialend'};    
    
    
%% final       
  case 'final',
    
    line_names = 'LCRlcrX';
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    sma = add_state(sma, 'name', 'wait','self_timer',1e6,...
        'input_to_statechange', {'Tup','trialend'});
    
    
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'trialend'};   
    
    
%% reinit    
  case 'reinit',
    currfig = double(gcf);

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end;



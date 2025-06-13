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
    waterdio   = value(WaterDIO);
    leddio     = value(LEDDIO);
    actwater   = value(ActiveWater);
    actleds    = sum(leddio(actwater == 1));
    waterdur   = value(ValveOpenTimes);
    waterpas   = value(WaterPulse);
    cycledur   = value(CycleDur);
    trialdur   = value(TrialDur);
    line_names = value(LineNames);
    
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    sma = add_scheduled_wave(sma, 'name','trial_wave','preamble',trialdur,'sustain',100+cycledur+trialdur);
    sma = add_scheduled_wave(sma, 'name','cycle_wave','preamble',cycledur,'sustain',100+cycledur+trialdur);
        
    for i = 1:numel(waterdio)
        if ~isnan(waterdio(i))
            sma = add_scheduled_wave(sma, 'name',['water',num2str(i),'_wave'],...
                'preamble',0,...
                'sustain',waterdur(i),...
                'DOut',waterdio(i));
            sma = add_scheduled_wave(sma, 'name',['refwater',num2str(i),'_wave'],...
                'preamble',0,...
                'sustain',waterpas-waterdur(i));
        end
    end
    
    twn = get_wavenumber(sma,'trial_wave');
    cwn = get_wavenumber(sma,'cycle_wave'); 
    
    hapnames = {'Lhi','Chi','Rhi','Dhi','Xhi'};
    poknames = {'Lin','Cin','Rin','Din','Xin'};
    
    sma = add_state(sma, 'name', 'start','self_timer',0.01,...
            'output_actions',{'SchedWaveTrig','trial_wave+cycle_wave';'DOut',actleds},...
            'input_to_statechange', {'Tup','pause';...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});
    
    sma = add_state(sma, 'name', 'pause','self_timer',cycledur,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {'trial_wave_Hi','trialend';...
                                     'trial_wave_In','trialend';...
                                     'cycle_wave_Hi','startnewcycle';...
                                     'cycle_wave_In','startnewcycle';...
                                     'Tup','startnewcycle';...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});
    
    sma = add_state(sma, 'name', 'startnewcycle','self_timer',0.01,...
            'output_actions',{'DOut',actleds,'SchedWaveTrig','-cycle_wave'},...
            'input_to_statechange', {'trial_wave_Hi','trialend';...
                                     'trial_wave_In','trialend';...
                                     'Tup','refcheck1';...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});    
        
    %First layer of states we check the state of the refwater waves. These 
    %will stay high for the refractory period. Only if the wave is low do 
    %we proceed to the next layer checking the poke
    for i=1:value(SnugCount)
        if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
        else,                                     nextstate = ['refcheck',num2str(i+1)];
        end
        %if actwater(i) == 1; checkstate = ['check',num2str(i)];
        %else,                checkstate = nextstate;
        %end
        checkstate = ['check',num2str(i)];
        if i == 1; extra = {'SchedWaveTrig','cycle_wave'};
        else,      extra = {};
        end

        sma = add_state(sma, 'name', ['refcheck',num2str(i)],'self_timer',0.01,...
            'output_actions',{'DOut',actleds;extra{:}},...
            'input_to_statechange', {['refwater',num2str(i),'_wave_Lo'],checkstate;...
                                     ['refwater',num2str(i),'_wave_Out'],checkstate;...
                                     'Tup',nextstate;...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});
    end
    
    %Second layer of states. You'll get to a check state only if the water
    %refractory wave is low. Now we check the poke. If it's in or high
    %we're good to deliver a water drop. Proceed to the next layer
    for i=1:value(SnugCount)
        if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
        else,                                     nextstate = ['refcheck',num2str(i+1)];
        end
        if actwater(i) == 1; waterstate = ['water',num2str(i)];
        else,                waterstate = nextstate;
        end

        sma = add_state(sma, 'name', ['check',num2str(i)],'self_timer',0.01,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {hapnames{i},waterstate;...
                                     poknames{i},waterstate;...
                                     'Tup',nextstate;...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});
    end
    
    %Third layer of states. You'll get here if the refwater wave is low and
    %a poke is in.
    for i=1:value(SnugCount)
        if ~isnan(waterdio(i))
            if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
            else,                                     nextstate = ['refcheck',num2str(i+1)];
            end

            sma = add_state(sma, 'name', ['water',num2str(i)],'self_timer',0.01,...
                'output_actions',{'DOut',actleds,'SchedWaveTrig', ['water',num2str(i),'_wave+refwater',num2str(i),'_wave']},...
                'input_to_statechange', {'Tup',nextstate;...
                                         %'Xhi','reset_state';...
                                         'Xin','reset_state'});
        end
    end    
 
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {'Tup','check_next_trial_ready';...
                                     %'Xhi','reset_state';...
                                     'Xin','reset_state'});
    
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
    
    is_rat_rig = bSettings('get', 'RIGS', 'ratrig');
    if ~is_rat_rig
        pulsetime = pulsetime * 10;
    end
    %BRK = value(IsBroken);
      
    line_names = value(LineNames);
    line_names(find(isnan(waterdio)==1)) = ''; %#ok<COMPNOP,FNDSB>
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',numel(line_names),'line_names',line_names);
    
    poke_in_names = cell(0);
    poke_out_names = cell(0);
    names = cell(0);
    functions = cell(0);
    numbers = cell(0);
    
    for i = 1:numel(line_names)
        poke_in_names{ end+1} = [line_names(i),'in']; %#ok<AGROW>
        poke_out_names{end+1} = [line_names(i),'out']; %#ok<AGROW>
        
        names{end+1}          = [line_names(i),'in']; %#ok<AGROW>
        names{end+1}          = [line_names(i),'out']; %#ok<AGROW>
        
        functions{end+1}      = 'line_in'; %#ok<AGROW>
        functions{end+1}      = 'line_out'; %#ok<AGROW>
        
        numbers{end+1}        = i; %#ok<AGROW>
        numbers{end+1}        = i; %#ok<AGROW>
    end
    
    names{end+1}     = 'Xhi';
    functions{end+1} = 'line_high';
    numbers{end+1}   = numel(line_names);
        
    sma = add_happening_spec(sma, struct(...
        'name',                 names, ...
        'detectorFunctionName', functions, ...
        'inputNumber',          numbers));
    
    sma = add_state(sma,'name','waitforredbutton',...
        'input_to_statechange',{'Xout','earlypause'});
    
    sma = add_state(sma,'name','earlypause','self_timer',2,...
        'input_to_statechange',{'Tup','togglevalvesstart'});
    
    sma = add_state(sma,'name','togglevalvesstart','self_timer',0.01,...
        'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
    sma = add_state(sma,'name','togglevalves','self_timer',0.01,...
        'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
    for i = 1:numel(waterdio)
        sma = add_state(sma,'self_timer',1 - pulsetime,...
            'output_actions',{'DOut',sum(leddio(i))},...
            'input_to_statechange',{'Tup','current_state+1';'Xout','trialend'});
    
        sma = add_state(sma,'self_timer',pulsetime,...
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

    
%% wait_for_reboot    
   case 'wait_for_reboot'
    pause(1);
    line_names = value(LineNames);
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    names     = {'Xin',            'Xout'};
    functions = {'line_in',        'line_out'};
    numbers   = {numel(line_names),numel(line_names),};

    sma = add_happening_spec(sma, struct(...
        'name',                 names, ...
        'detectorFunctionName', functions, ...
        'inputNumber',          numbers));
    
    sma = add_state(sma, 'name', 'wait_for_xin',...
        'input_to_statechange', {'Xin','trialend'});
    
    
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'trialend'};    
    
    
%% final       
  case 'final'
    
    line_names = value(LineNames);
    sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
    sma = add_state(sma, 'name', 'wait','self_timer',1e6,...
        'input_to_statechange', {'Tup','trialend'});
    
    
    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
        'input_to_statechange', {'Tup','check_next_trial_ready'});
    
    varargout{1} = sma;
    varargout{2} = {'trialend'};   
    
    
%% reinit    
  case 'reinit'
    currfig = double(gcf);

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);
    

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');

    % Restore the current figure:
    figure(currfig);
end



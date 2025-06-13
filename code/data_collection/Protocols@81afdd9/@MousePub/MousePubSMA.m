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
% written by Emily Jane Dennis based on TowerWaterDelivery 20190904

function [varargout] = MousePubSMA(obj, action)
   
GetSoloFunctionArgs(obj);

switch action
%% manual_test
    case 'manual_test'

    line_names = 'LCRF';
    poke_in_names = cell(0);
    poke_out_names = cell(0);
    names = cell(0);
    functions = cell(0);
    numbers = cell(0);
    
        for i = 1:numel(line_names)
            poke_in_names{ end+1} = [line_names(i),'in'];
            poke_out_names{end+1} = [line_names(i),'out'];

            names{end+1}          = [line_names(i),'in'];
            names{end+1}          = [line_names(i),'out'];

            functions{end+1}      = 'line_in';
            functions{end+1}      = 'line_out';

            numbers{end+1}        = i;
            numbers{end+1}        = i;
        end
        left1led      = bSettings('get', 'DIOLINES', 'left1led');
        left1water    = bSettings('get', 'DIOLINES', 'left1water');
		center1led         = bSettings('get', 'DIOLINES', 'center1led');
		center1water       = bSettings('get', 'DIOLINES', 'center1water');
		right1led       = bSettings('get', 'DIOLINES', 'right1led');
        right1water     = bSettings('get', 'DIOLINES', 'right1water');
		right2led     = bSettings('get', 'DIOLINES', 'right2led');
        right2water   = bSettings('get', 'DIOLINES', 'right2water');

            sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);
    
            
        % turn far left light on and wait for a poke
				sma = add_state(sma,    'name',                 'wait_for_poke_one',...
                                        'output_actions',       {'DOut', left1led}, ...
                                        'input_to_statechange', {'Lin','water_one'});

        % dispense water until un-poked while keeping the light on
                sma = add_state(sma,    'name',                 'water_one',...
                                        'self_timer',           1,...
                                        'input_to_statechange', {'Tup','wait_for_poke_two'},...
                                        'output_actions',       {'DOut',left1water+left1led});
                 
        % turn the first port's light and water off, turn light on and wait
        % for second poke
                sma = add_state(sma,    'name',                 'wait_for_poke_two',...
                                        'output_actions',       {'DOut', center1led}, ...
                                        'input_to_statechange', {'Cin','water_two'});

                sma = add_state(sma,    'name',                 'water_two',...
                                        'self_timer',           1,...
                                        'input_to_statechange', {'Tup','wait_for_poke_three'},...
                                        'output_actions',       {'DOut', center1water+center1led});
        % for third poke
                sma = add_state(sma,    'name',                 'wait_for_poke_three',...
                                        'output_actions',       {'DOut', right1led},...
                                        'input_to_statechange', {'Rin','water_three'});
                                    
                sma = add_state(sma,    'name',                 'water_three',...
                                        'self_timer',           1,...
                                        'input_to_statechange', {'Tup','wait_for_poke_four'},...
                                        'output_actions',       {'DOut', right1water+right1led});
        % for fourth poke
                sma = add_state(sma,    'name',                 'wait_for_poke_four',...
                                        'output_actions',       {'DOut', right2led},...
                                        'input_to_statechange',{'Fin','water_four'});
                                    
                sma = add_state(sma,    'name',                 'water_four',...
                                        'self_timer',           1,...
                                        'input_to_statechange', {'Tup','end_of_manual'},...
                                        'output_actions',       {'DOut',right2water+right2led});
        % when finished, put all lights on for 2 seconds
                sma = add_state(sma,    'name',                 'end_of_manual',...
                                        'self_timer',           1,...
                                        'input_to_statechange', {'Tup','check_next_trial_ready'},...
                                        'output_actions',       {'DOut',left1led+center1led+right1led+right2led});

    varargout{1} = sma;
    varargout{2} = 'end_of_manual';
      
% -----------------------------------------------------------------------
%
%         START WAIT
%
% ------------------------      
    case 'start_wait',
        pause(1);
        
        sma = StateMachineAssembler('full_trial_structure');

          sma = add_state(sma, 'name', 'trialend','self_timer',1,...
                'input_to_statechange', {'Tup','check_next_trial_ready'});
    
      varargout{1} = sma;
      varargout{2} = {'trialend'};
      
% -----------------------------------------------------------------------
%
%         START CALLBACK
%
% ------------------------      
    case 'start_callback',
    pause(1);
    %each of the four ports in a BPod Pub needs a name
    % so I made them Left Center Right FarRight
    line_names = 'LCRF';
        sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);

          sma = add_state(sma, 'name', 'trialend','self_timer',0.01,...
                'input_to_statechange', {'Tup','check_next_trial_ready'});
    
      varargout{1} = sma;
      varargout{2} = {'trialend'};
      
% -----------------------------------------------------------------------
%
%         PREPARE_NEXT_TRIAL
%
% -----------------------------------------------------------------------
        
  case 'prepare_next_trial',
    waterdio = value(WaterDIO);
    leddio   = value(LEDDIO);
    actwater = value(ActiveWater);
    actleds  = sum(leddio(actwater == 1));
    waterdur = value(ValveOpenTimes);
    waterpas = value(WaterPulse);
    cycledur = value(CycleDur);
    trialdur = value(TrialDur);
    
    %each of the four ports in a BPod Pub needs a name
    % so I made them Left Center Right FarRight
        line_names = 'LCRF';
        sma = StateMachineAssembler('full_trial_structure','use_happenings',1,'n_input_lines',length(line_names),'line_names',line_names);

        % trial wave lasts for the trial duration and makes it such that
        % every value(TrialDur) seconds there will be a new trial wave that
        % activates and deactivates ports (both LED and water) if animals are finished drinking.
    	sma = add_scheduled_wave(sma, 'name','trial_wave','preamble',trialdur,'sustain',100+cycledur+trialdur);
        % cycle waves happen many times per trial, and continually check if
        % the animals are in or out of the ports and are actually
        % responsible for opening the valves
        % the refraction period allows the pause to be long enough that no
        % matter how many things must occur, all of them can occur before
        % the next cycle starts (sometimes only one port is opening/closing
        % while other times all 4 ports will open/close and going through
        % this loop takes different time in numbers of ms
        sma = add_scheduled_wave(sma, 'name','cycle_wave','preamble',cycledur,'sustain',100+cycledur+trialdur);
        
%this makes a wave called water1_wave water2_wave water3_wave and
%water4_wave that turns on the water for water duration
    for i = 1:numel(waterdio)
        if ~isnan(waterdio(i))
            sma = add_scheduled_wave(sma, 'name',['water',num2str(i),'_wave'],...
                'preamble',0,...
                'sustain',waterdur(i),...
                'DOut',waterdio(i));%                REFRACTION DOES NOT WORK ON BPOD 

        end
    end

    %twn = get_wavenumber(sma,'trial_wave');
    %cwn = get_wavenumber(sma,'cycle_wave');
    %
    hapnames = {'Lhi','Chi','Rhi','Fhi'};
    poknames = {'Lin','Cin','Rin','Fin'};
    %
    %
    %names     = {'trial_wave_hi','cycle_wave_hi'};
    %functions = {'wave_high',    'wave_high'};
    %numbers   = {twn,            cwn};
    %
    %sma = add_happening_spec(sma, struct(...
    %    'name',                 names, ...
    %    'detectorFunctionName', functions, ...
    %    'inputNumber',          numbers));
        
        

% when a cycle or trial starts, turn on lights for active leds until the
% end of the trial, then trigger the pause state
    sma = add_state(sma, 'name', 'start','self_timer',1,...
            'output_actions',...
                {'SchedWaveTrig','trial_wave+cycle_wave';...
                'DOut',actleds},...
            'input_to_statechange',...
                {'Tup','pause'});

% wait with active port LEDs on
    sma = add_state(sma, 'name', 'pause','self_timer',cycledur,...
            'output_actions',...
                {'DOut',actleds},...
            'input_to_statechange', {   'trial_wave_Hi','trialend';...
                                        'cycle_wave_Hi','check1';...
                                        'Tup','check1'});
        

% for each water DIO line

    for i = 1:4
        % if 
            % set next state: if this is the last port, enter a pause state
            % otherwise check the next port
            if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
            else                                      nextstate = ['check',num2str(i+1)];
            end
            
            %set the water state: 
            % if this water port is on the active list, make a state for
            %this port called water1 or similar. If not, move to the next
            %state (which is either pause or check the next port)
            if actwater(i) == 1; waterstate = ['water',num2str(i)];
            else                 waterstate = nextstate;
            end
            
            % 
            if     i == 1; extra = {'SchedWaveTrig','cycle_wave'};
            elseif i == 2; extra = {};%{'SchedWaveTrig','cycle_wave'};
            else           extra = {};
            end

%make a state called check1 check2 check3 or check4
            sma = add_state(sma, 'name', ['check',num2str(i)],'self_timer',0.01,...
                'output_actions',       {'DOut',actleds;extra{:}},...
                'input_to_statechange', {hapnames{i},waterstate;...
                                        poknames{i},waterstate;...
                                        'Tup',nextstate}); %#ok<CCAT>
    end 
    for i = 1:4
        if ~isnan(waterdio(i))
            if i==find(~isnan(waterdio)==1,1,'last'); nextstate = 'pause';
            else                                      nextstate = ['check',num2str(i+1)];
            end

            sma = add_state(sma, 'name', ['water',num2str(i)],'self_timer',0.01,...
                'output_actions',{'DOut',actleds,'SchedWaveTrig', ['water',num2str(i),'_wave']},...
                'input_to_statechange', {'Tup',nextstate});
        end
    end     

    sma = add_state(sma, 'name', 'trialend','self_timer',0.1,...
            'output_actions',{'DOut',actleds},...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
    
      varargout{1} = sma;
      varargout{2} = {'trialend'};
       
%% final       
  case 'final',
    
    line_names = 'LCRF';
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



% DMS State Machine Assmbler (SMA) for spoke
%
% quickly written by JRB on 7/20/22. This is an SMA that allows
% the animal to get reward every time they side poke unless
% they are in an inter trial interval. Goal is to use for
% timid animals so they get some water in the rig for 15-20
% minutes and then can start with cpoke.


function [varargout] = SMA_spoke(obj, action)

GetSoloFunctionArgs;


switch action

    %---------------------------------------------------------------%
    %          init                                                 %
    %---------------------------------------------------------------%
	case 'init'
        
    %---------------------------------------------------------------%
    %          prepare_next_trial                                   %
    %---------------------------------------------------------------%
	case 'prepare_next_trial'

        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% SETUP THE HARDWARE %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%

        %%% minimum time
        min_time= 2.5E-4;  % This is less than the minumum time allowed for a state transition.

        %%% define LEDs and water lines
        left1led    = bSettings('get', 'DIOLINES', 'left1led');
        center2led  = bSettings('get', 'DIOLINES', 'center1water');
        center1led  = bSettings('get', 'DIOLINES', 'center1led');
        right1led   = bSettings('get', 'DIOLINES', 'right1led');
        left1water  = bSettings('get', 'DIOLINES', 'left1water');
        right1water = bSettings('get', 'DIOLINES', 'right1water');

        %%% define state machine assembler
        sma = StateMachineAssembler('full_trial_structure','use_happenings', 1);

        %%% get water valve opening times (based on calibration)
        [LeftWValveTime, RightWValveTime] = WaterValvesSection(obj, 'get_water_times');
        
        %%% set the water reward
%         if strcmp(value(current_side), 'LEFT') 
%             correct_response   = 'Lhi';
%             incorrect_response = 'Rhi';
%             retry_incorrect_response = 'Rin';
%             reward_water_dio   = left1water;
%             reward_light_dio   = left1led;
%             reward_valve_time  = LeftWValveTime;
% 
%         elseif strcmp(value(current_side), 'RIGHT')
%             correct_response   = 'Rhi';
%             incorrect_response = 'Lhi';
%             retry_incorrect_response = 'Lin';
%             reward_water_dio   = right1water;
%             reward_light_dio   = right1led;
%             reward_valve_time  = RightWValveTime;
%         end
        
        %%% skipping scale water reward too
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%       STATES       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%
  
        
        sma = add_state(sma, 'name', 'wait_for_spoke',...
                             'input_to_statechange', {'Rin', 'right_hit_state';...
                                                      'Lin', 'left_hit_state'});
        sma = add_state(sma, 'name', 'left_hit_state',...
                             'self_timer', LeftWValveTime,...
                             'output_actions', {'DOut', left1water + left1led},...
                             'input_to_statechange', {'Tup', 'left_drink_state'});
                         
        sma = add_state(sma, 'name', 'right_hit_state',...
                             'self_timer', RightWValveTime,...
                             'output_actions', {'DOut', right1water + right1led},...
                             'input_to_statechange', {'Tup', 'right_drink_state'});
                           
        sma = add_state(sma, 'name', 'left_drink_state',...
                             'self_timer', value(drinking_dur),...
                             'output_actions', {'DOut', left1led},...
                             'input_to_statechange', {'Tup', 'hit_state'});
                         
        sma = add_state(sma, 'name', 'right_drink_state',...
                             'self_timer', value(drinking_dur),...
                             'output_actions', {'DOut', right1led},...
                             'input_to_statechange', {'Tup', 'hit_state'}); 
                         
        sma = add_state(sma, 'name', 'hit_state',...
                             'self_timer', min_time,...
                             'input_to_statechange', {'Tup', 'general_final_state'});
                         
        sma = add_state(sma, 'name','general_final_state',...
                             'self_timer', value(inter_trial_dur),...
                             'input_to_statechange', {'Tup', 'check_next_trial_ready'});
        
        % send SMA output back to DMS.m where dispatcher is called
        varargout{1} = sma;
        varargout{2} = {'hit_state'};                
     
    %---------------------------------------------------------------%
    %          reinit                                               %
    %---------------------------------------------------------------%
    case 'reinit'
        currfig = double(gcf);
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'],...
            'fullname', ['^' mfilename]);

		% Reinitialise at the original GUI position and figure:
		feval(mfilename, obj, 'init');

		% Restore the current figure:
		figure(currfig)
    %---------------------------------------------------------------%
    %          otherwise                                            %
    %---------------------------------------------------------------%
    otherwise
        error('Called action: %s, which is undefined.', action);

end % function end
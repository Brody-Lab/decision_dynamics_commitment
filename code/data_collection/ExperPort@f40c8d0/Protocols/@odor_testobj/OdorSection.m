function [x, y] = OdorSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   olf = value(olf_meter);
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      % Old call to initialise Olfactometer:
      NumeditParam(obj, 'ValveID1', 1, x,y);
      next_row(y);
      NumeditParam(obj, 'ValveID2', 2, x,y);
      next_row(y);
      % specify flowrate of each bank
      NumeditParam(obj, 'ActiveBank1ID', 3, x, y);
      next_row(y);
      NumeditParam(obj, 'ActiveBank2ID', 4, x, y);
      next_row(y);
      NumeditParam(obj, 'carrier_id', 4, x, y);
      next_row(y);
      NumeditParam(obj, 'FlowRate1', 50, x,y);
      next_row(y);
      NumeditParam(obj, 'FlowRate2', 50, x,y);
      next_row(y);
      NumeditParam(obj, 'Carrier_FR', 900, x,y);
      next_row(y);
      NumeditParam(obj, 'log_aux', 0, x, y, 'label', 'Log_on?');
      next_row(y);
      NumeditParam(obj, 'fv_dur', 0.5, x, y, 'label','Final valve duration'); next_row(y);
      NumeditParam(obj, 'final_valve_delay', 0.4, x, y);
      next_row(y);
      DispParam(obj, 'total_odor_dur', 0, x, y);
      next_row(y,1.5);
      DispParam(obj, 'current_valve_delay', 0, x, y);
      next_row(y, 1.5);
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
      SoloParamHandle(obj, 'odor_valve_delay', 'value', 0); 
      SoloParamHandle(obj, 'analog_scan','value',[]);
 
      % write specified parameters to olfactometer
  % ***** Determine the bank ID **************************************
      [status, hostname] = system('hostname');
      hostname = lower(hostname);
      hostname = hostname(~isspace(hostname));
      switch hostname
          case 'cnmc7' % C1 (upper box)
              ActiveBank1ID.value = 1; ActiveBank2ID.value = 2;
              carrier_id.value = 3;
          case 'cnmc8' % C2 (lower box)
              ActiveBank1ID.value = 3; ActiveBank2ID.value = 4;
              carrier_id.value = 4;
      end
      % *******************************************************************
      % *******************************************************************
      set_callback({FlowRate1, FlowRate2, ActiveBank1ID, ActiveBank2ID, ValveID1,ValveID2, Carrier_FR}, {mfilename, 'write_olf'});
      OdorSection(obj, 'write_olf');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'ValveID1','ValveID2','ActiveBank1ID','ActiveBank2ID','fv_dur', 'log_aux','final_valve_delay'});
      SoloParamHandle(obj, 'counts', 'value', 0);
 
   case 'write_olf'
          % if value(Carrier3_FR) ~= 1000-(Bank3_FR+Bank4_FR)
          %      Carrier3_FR.value = 1000-(Bank3_FR+Bank4_FR);
          % end
          Carrier_FR.value = 1000 - (FlowRate1+FlowRate2);
          if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
              Write(olf, ['Carrier' num2str(value(carrier_id)) '_Actuator'], value(Carrier_FR));
              Write(olf, ['BankFlow' num2str(value(ActiveBank1ID)) '_Actuator'], value(FlowRate1));
              Write(olf, ['BankFlow' num2str(value(ActiveBank2ID)) '_Actuator'], value(FlowRate2));
              % SetLogging(olf, valve_name,1);
              %SetLogging(olf, 'AuxAI',1);
          end
    case 'end_of_trial'
        total_odor_dur.value = 0.01+ value(final_valve_delay)+ value(fv_dur) + 0.5;
        counts.value = counts + 1;
        if value(counts) >= 5
            counts.value = 0;
            % final_valve_delay.value = final_valve_delay + 0.03;
        end
            
    case 'update_within_trial'
         % Parse the events from the last trial:
     % prevtrial.value = parse_trial(value(LastTrialEvents),
     % RealTimeStates);
%      analog_scan.value = GetDAQScans(value(FSM));
      % Take the current raw events and push them into the history:
        Event = GetParam('rpbox', 'event', 'user');
        LastTrialEvents.value = [value(LastTrialEvents) ; Event];
       
    case 'get_valve_delay' % get olfactometer log
        if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
            olf_log = GetLog(olf);
            x = find(cell2mat(olf_log(:,4))> 4); % find the index where AuxAI becomes high 
            for xi=1:length(x),
          % make sure we get the log of AuxAI and it not the log of the tail of
          % previous center poke.
             if (strncmp(olf_log{x(xi),2}, 'Aux', 3)) && (x(xi)~=xi)...
                   && (olf_log{x(xi)-1,4}>0 && olf_log{x(xi)-1,4}<5)
                   i = x(xi);
                else 
                   continue;
                end;
                while i < size(olf_log, 1)
                i = i +1;
                % make sure we are counting odor channels but not channel 0.
                if strncmp(olf_log{i,2},'Bank', 4) && ~strcmpi(olf_log{i,3},'RawCh00') && (olf_log{i,4}>0)
                   dl = olf_log{i,1} - olf_log{x(xi),1};
                   current_valve_delay.value = dl;
                   odor_valve_delay.value = [value(odor_valve_delay) dl];
                   if dl>0.05
                  %      keyboard;
                   end
                   i = size(olf_log, 1);
                end
                end
                break;
            end
        end
        
    case 'reinit',       % ---------- CASE REINIT -------------
      currfig = gcf; 

      % Get the original GUI position and figure:
      x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

      % Delete all SoloParamHandles who belong to this object and whose
      % fullname starts with the name of this mfile:
      delete_sphandle('owner', ['^@' class(obj) '$'], ...
                      'fullname', ['^' mfilename]);

      % Reinitialise at the original GUI position and figure:
      [x, y] = feval(mfilename, obj, 'init', x, y);

      % Restore the current figure:
      figure(currfig);      
   end;
        
      
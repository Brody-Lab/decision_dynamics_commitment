function [x, y] = OdorSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   
   if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
       olf = value(olf_meter);
   end
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      NumeditParam(obj, 'Carrier_FR', 920, x,y);
      next_row(y, 1.5);
      
      % determine which carrier and bank to use (rig-dependent)
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
          [carriers, banks] = GetOlfHardware(olf);
          active_carrier = carriers(1); % in case there are >1 carriers
          active_bank = banks(1); % in case there are >1 banks
      else
          active_carrier = 1;
          active_bank = 1;
      end
          
      NumeditParam(obj, 'ValveID', 4, x,y);
      next_row(y);
      
      DispParam(obj, 'ActiveBankID', active_bank, x, y); % only requires 1 bank
      next_row(y);

      DispParam(obj, 'ActiveCarrierID', active_carrier, x, y); % only requires 1 carrier
      next_row(y);

      NumeditParam(obj, 'Preodor_Trials', 10, x,y);
      next_row(y, 1.5);
      
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
      
      SoloParamHandle(obj, 'odor_updated', 'value', 0);
      SoloParamHandle(obj, 'odor_valve_delay', 'value', 0);      
      set_callback({ActiveBankID, ValveID, Carrier_FR, Preodor_Trials}, {mfilename, 'set_odor'});
      
      OdorSection(obj, 'set_odor');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'ValveID','ActiveBankID', 'Preodor_Trials'})
   
          
   % store olfactometer params in intermediate sphs       
   case 'set_odor'
       active_bank.value = value(ActiveBankID);
       valve_id.value = value(ValveID);
       carrier_flowrate.value = value(Carrier_FR);
       odor_updated.value = 0;
       OdorSection(obj, 'odor_update');
       
   case 'update_odor'
      if value(odor_updated) == 0
          
          odor_flow = 1000 - value(Carrier_FR);

          if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected

              % set flow rates (these won't actually change across trials)
              Write(olf, ['BankFlow' num2str(value(ActiveBankID)) '_Actuator'], odor_flow);

              Write(olf, ['Carrier' num2str(value(ActiveCarrierID)) '_Actuator'], value(Carrier_FR));

          end

          odor_updated.value = 1;
      end
    case 'get_valve_delay' % get olfactometer log
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
               %     keyboard;
                end
                i = size(olf_log, 1);
            end
           end
          break;
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

              
        
        
      
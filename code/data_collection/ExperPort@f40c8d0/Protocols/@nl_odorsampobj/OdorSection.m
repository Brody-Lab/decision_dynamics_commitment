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
      % Old call to initialise Olfactometer:
      NumeditParam(obj, 'ValveID', 9, x,y);
      next_row(y);
      
      % specify flowrate of each bank
      NumeditParam(obj, 'Bank3_FR', 50, x,y);
      next_row(y);
      NumeditParam(obj, 'Bank4_FR', 50, x,y);
      next_row(y);
      NumeditParam(obj, 'ActiveBankID', 4, x, y); %only one bank needed for odorsamp task
      next_row(y);
      
      NumeditParam(obj, 'Carrier3_FR', 900, x,y);
      next_row(y);
            
      next_row(y, 1.5);
      
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
      
      SoloParamHandle(obj, 'bank3_flowrate');
      SoloParamHandle(obj, 'bank4_flowrate');
      SoloParamHandle(obj, 'active_bank');
      SoloParamHandle(obj, 'valve_id');
      SoloParamHandle(obj, 'carrier_flowrate');
      SoloParamHandle(obj, 'odor_updated', 'value', 0);
            
      set_callback({Bank3_FR, Bank4_FR, ActiveBankID, ValveID, Carrier3_FR}, {mfilename, 'set_odor'});
      
      OdorSection(obj, 'set_odor');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'valve_id','active_bank'})
   
          
   % store olfactometer params in intermediate sphs       
   case 'set_odor'
       if value(Carrier3_FR) ~= 1000-(Bank3_FR+Bank4_FR)
          Carrier3_FR.value = 1000-(Bank3_FR+Bank4_FR);
       end
       bank3_flowrate.value = value(Bank3_FR);
       bank4_flowrate.value = value(Bank4_FR);
       active_bank.value = value(ActiveBankID);
       valve_id.value = value(ValveID);
       carrier_flowrate.value = value(Carrier3_FR);
       odor_updated.value = 0;
       OdorSection(obj, 'odor_update');
       
   case 'odor_update'
      if value(odor_updated) == 0
          odor_flowrate = eval(['value(bank' num2str(value(active_bank)) '_flowrate)']);
          if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
              Write(olf, ['BankFlow3_Actuator'], value(bank3_flowrate));
              Write(olf, ['BankFlow4_Actuator'], value(bank4_flowrate));
              Write(olf, ['Carrier3_Actuator'], value(carrier_flowrate));
              valve_name = ['Bank' num2str(value(ActiveBankID)) '_Valves'];
          end
          odor_updated.value = 1;
      end
      return;
      
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
    end
      
      
   
      
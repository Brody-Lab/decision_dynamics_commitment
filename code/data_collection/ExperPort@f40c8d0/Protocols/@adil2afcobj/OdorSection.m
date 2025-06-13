function [x, y] = OdorSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
       olf = value(olf_meter);
   end
   % olf = SimpleOlfClient(value(OLF_IP));
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Save the figure and the position in the figure where we are
      fig = gcf;
      MenuParam(obj, 'Olf_Meter', {'hidden', 'view'}, 1, x, y); next_row(y);
      oldx = x;  oldy = y; x = 5; y = 5;
      SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
      
      DispParam(obj, 'carr_flow', 0, x, y, 'label', 'Carrier Flow Rate');   next_row(y);
      DispParam(obj, 'bk3_flow',  0, x, y, 'label', 'Bank3 Flow Rate');     next_row(y);
      DispParam(obj, 'bk4_flow',  0, x, y, 'label', 'Bank4 Flow Rate');     next_row(y);
      DispParam(obj, 'bk3_valve', 0, x, y, 'label', 'Bank3_Valve'); next_row(y);
      DispParam(obj, 'bk4_valve', 0, x, y, 'label', 'Bank4_Valve'); next_row(y);
      
      set(value(myfig), 'Visible', 'off', 'MenuBar', 'none', 'Name', 'Monitoring Olfactometer',...
          'NumberTitle','off', 'CloseRequestFcn', ...
          ['OdorSection(' class(obj) '(''empty''), ''hide'')']);
      set_size(value(myfig), [200 130]);
      x = oldx; y = oldy; figure(fig);
      set_callback({Olf_Meter}, {'OdorSection', 'view'});
      
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      % Old call to initialise Olfactometer:
      NumeditParam(obj, 'Carrier_FR', 920, x,y);
      next_row(y);
      
      % Initialize odor settings
      [status, hostname] = system('hostname');
      hostname = lower(hostname);
      hostname = hostname(~isspace(hostname));
      switch hostname
          case 'cnmc3' % N1 (upper box)
              active_bank = 1;
          case 'cnmc4' % N0 (lower box)
              active_bank = 3;
          otherwise
              active_bank = 4; % non-olf-associated, or newly hooked up boxes
      end
          
      DispParam(obj, 'ActiveBankID', active_bank, x, y); % only use 1 bank for this version of the 2AFC (no mixtures possible)
      next_row(y);

      NumeditParam(obj, 'R_valve', 1, x, y);
      next_row(y);

      NumeditParam(obj, 'L_valve', 8, x, y);
      next_row(y);
            
      % a menu listing odor names. You can add more odors here....
      load('OdorNames.mat');
      SoloParamHandle(obj, 'odor_name', 'value', odor_name);
      DispParam(obj, 'left_odor', odor_name{value(L_valve)}, x, y, 'position',[x y 100 40],'label', 'Left Odor',...
          'labelpos','top');
      DispParam(obj, 'right_odor',  odor_name{value(R_valve)}, x, y, 'position',[x+100 y 100 40],'label', 'Right Odor',...
          'labelpos','top');
      
      if strcmpi(value(left_odor), value(right_odor)),
          warning('The odor names for left and right are the same!');
      end;
      
      next_row(y,2.5);
      
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
            
      set_callback({L_valve, R_valve, Carrier_FR}, {mfilename, 'update_odor'});
      
      OdorSection(obj, 'update_odor');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'ActiveBankID', 'L_valve', 'R_valve'})
   
   case 'monitor_olf'
        if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
          bk3_valve.value = Read(olf, 'Bank3_Valves');
          bk4_valve.value = Read(olf, 'Bank1_Valves');
          bk3_flow.value = Read(olf, 'BankFlow3_Sensor');
          bk4_flow.value = Read(olf, 'BankFlow1_Sensor');
          carr_flow.value = Read(olf, 'Carrier1_Sensor');
        end 
      
   case 'update_odor'
      L_valve.value = ceil(2.*rand(1,1))+5;
      R_valve.value = ceil(2.*rand(1,1))+3;
      left_odor.value = odor_name{value(L_valve)};
      right_odor.value = odor_name{value(R_valve)};
       
       
       odor_flow = 1000 - value(Carrier_FR);
      
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
                   
          % set flow rates (these won't actually change across trials)
          Write(olf, ['BankFlow' num2str(value(ActiveBankID)) '_Actuator'], odor_flow);
          
          
          if value(ActiveBankID) == 4 % only carrier 4 is hooked up (carrier 3 is a passive flow)
            Write(olf, ['Carrier4_Actuator'], value(Carrier_FR));
          end
     
      end
    
    case 'view', % ------ CASE VIEW
        switch value(Olf_Meter),
            case 'hidden', set(value(myfig), 'Visible', 'off');
            case 'view',
                set(value(myfig), 'Visible', 'on');
            end;

    case 'hide', % ------ CASE HIDE
        Olf_Meter.value = 'hidden';
        set(value(myfig), 'Visible', 'off');

    
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
  
      
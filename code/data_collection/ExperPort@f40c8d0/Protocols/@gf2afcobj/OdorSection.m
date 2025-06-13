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
      NumeditParam(obj, 'Carrier3_FR', 900, x,y);
      next_row(y);
      
      % Initialize odor settings
      MenuParam(obj, 'right_bk',{1, 2, 3, 4}, 4, x, y, 'position', [x y 100 20], 'label', 'Right Bank',...
          'labelpos', 'left', 'labelfraction', 0.6);      
      NumeditParam(obj, 'R_valve', 7, x, y, 'position', [x+100 y 100 20],...
          'label', 'R_Valve#', 'labelpos', 'left');
      next_row(y);
      
      MenuParam(obj, 'left_bk',{1, 2, 3, 4}, 4, x, y, 'position', [x y 100 20], 'label', 'Left Bank',...
          'labelpos', 'left', 'labelfraction', 0.6);
      NumeditParam(obj, 'L_valve', 7, x, y, 'position', [x+100 y 100 20],...
          'label', 'L_Valve#', 'labelpos', 'left');
      
      next_row(y);
      
      % Initialize task difficulty (odor mixture ratio)
      NumeditParam(obj, 'left_frac', 20, x, y, 'position', [x y 140 20]);
      DispParam(obj, 'right_frac',['/   ' num2str(20) '     '], x, y,...
          'position', [x+70 y 130 20], 'label', 'Ratio', 'labelfraction', 0.4);
      
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
            
      set_callback({left_frac, L_valve, R_valve, Carrier3_FR}, {mfilename, 'write_olf'});
      
      OdorSection(obj, 'update_odor');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'L_valve','R_valve'})
   
   case 'monitor_olf'
        if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
          bk3_valve.value = Read(olf, 'Bank3_Valves');
          bk4_valve.value = Read(olf, 'Bank4_Valves');
          bk3_flow.value = Read(olf, 'BankFlow3_Sensor');
          bk4_flow.value = Read(olf, 'BankFlow4_Sensor');
          carr_flow.value = Read(olf, 'Carrier3_Sensor');
        end 
      
   case 'update_odor'
      % Suppose bank3 is for left odor, bank4 is for right odor. Update
      % flow rate according to next side
      R_valve.value = ceil(6.*rand(1,1));
      left_odor.value = odor_name{value(L_valve)};
      right_odor.value = odor_name{value(R_valve)};
      side = side_list(n_done_trials+1);
      left = get_generic('side_list_left');
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
      if side == left
          Write(olf, ['Bank' num2str(value(left_bk)) '_Valves'], value(L_valve));
          %if value(left_frac)<50
           %   left_frac.value = 100 - left_frac;
          %end
      elseif side == 1-left
          Write(olf, ['Bank' num2str(value(right_bk)) '_Valves'], value(R_valve));
  %        if value(left_frac)>50
   %           left_frac.value = 100 - left_frac;
    %      end
      end
      end
     % right_frac.value = ['/ ' num2str(100-value(left_frac))];
      odor_flow = 1000 - value(Carrier3_FR);
   %   L_bank_flow = odor_flow*(value(left_frac)/100);
   %   R_bank_flow = odor_flow - L_bank_flow;
   
   case 'write_olf'
       %odor_flow = 1000 - value(Carrier4_FR);
       carrier_flow = 1000 - value(odor_flow);
       if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
          % set flow rates
          Write(olf, ['BankFlow' num2str(value(left_bk)) '_Actuator'], odor_flow);
          Write(olf, ['BankFlow' num2str(value(right_bk)) '_Actuator'], odor_flow);
          Write(olf, ['Carrier3_Actuator'], value(Carrier3_FR));
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
  
      
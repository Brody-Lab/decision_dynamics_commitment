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
      NumeditParam(obj, 'R_valve', 2, x, y, 'position', [x+100 y 100 20],...
          'label', 'R_Valve#', 'labelpos', 'left');
      next_row(y);
      
      MenuParam(obj, 'left_bk',{1, 2, 3, 4}, 3, x, y, 'position', [x y 100 20], 'label', 'Left Bank',...
          'labelpos', 'left', 'labelfraction', 0.6);
      NumeditParam(obj, 'L_valve', 2, x, y, 'position', [x+100 y 100 20],...
          'label', 'L_Valve#', 'labelpos', 'left');
      
      next_row(y);
      
      % Initialize task difficulty (odor mixture ratio)
      NumeditParam(obj, 'left_frac', 80, x, y, 'position', [x y 140 20]);
      DispParam(obj, 'right_frac',['/   ' num2str(20) '     '], x, y,...
          'position', [x+70 y 130 20], 'label', 'Ratio', 'labelfraction', 0.4);
      
      next_row(y);
      
      % a menu listing odor names. You can add more odors here....
      MenuParam(obj, 'left_odor', {'Hex', 'CA'}, 1, x, y, 'position',[x y 100 40],'label', 'Left Odor',...
          'labelpos','top');
      MenuParam(obj, 'right_odor', {'Hex', 'CA'}, 2, x, y, 'position',[x+100 y 100 40],'label', 'Right Odor',...
          'labelpos','top');
      
      if strcmpi(value(left_odor), value(right_odor)),
          warning('The odor names for left and right are the same!');
      end;
      
      next_row(y,2.5);
      
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
            
      set_callback({left_frac, L_valve, R_valve, Carrier3_FR}, {mfilename, 'update_odor'});
      
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
      side = side_list(n_done_trials+1);
      left = get_generic('side_list_left');
      if side == left
          if value(left_frac)<50
              left_frac.value = 100 - left_frac;
          end
      elseif side == 1-left
          if value(left_frac)>50
              left_frac.value = 100 - left_frac;
          end
      end
      right_frac.value = ['/ ' num2str(100-value(left_frac))];
      odor_flow = 1000 - value(Carrier3_FR);
      L_bank_flow = odor_flow*(value(left_frac)/100);
      R_bank_flow = odor_flow - L_bank_flow;
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
          Write(olf, ['BankFlow' num2str(value(left_bk)) '_Actuator'], L_bank_flow);
          Write(olf, ['BankFlow' num2str(value(right_bk)) '_Actuator'], R_bank_flow);
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

      
    %------------------------------------------------------%
    %    To get the odor valve delay with logging method   %
    %    Not active in this protocol. No one is calling it %
    %------------------------------------------------------%
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
  
      
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
      NumeditParam(obj, 'odor_flow', 80, x,y, 'label', 'Odor FlowRate');
      set_callback({odor_flow}, {mfilename, 'write_olf'});
      
      next_row(y);
      
      % Initialize Olfactometer settings
      MenuParam(obj, 'right_bk',{1, 2, 3, 4}, 3, x, y, 'position', [x y 100 20], 'label', 'Right Bank',...
          'labelpos', 'left', 'labelfraction', 0.6);      
      NumeditParam(obj, 'R_valve', 2, x, y, 'position', [x+100 y 100 20],...
          'label', 'R_Valve#', 'labelpos', 'left'); % set the vavle ID for the 'right' odors, even numbers
      next_row(y);
      
      MenuParam(obj, 'left_bk',{1, 2, 3, 4}, 3, x, y, 'position', [x y 100 20], 'label', 'Left Bank',...
          'labelpos', 'left', 'labelfraction', 0.6);
      NumeditParam(obj, 'L_valve', 1, x, y, 'position', [x+100 y 100 20],...
          'label', 'L_Valve#', 'labelpos', 'left'); % valve ID for the 'left' odors, odd numbers.

      % ***** for one bank olf meter **************************************
      [status, hostname] = system('hostname');
      hostname = lower(hostname);
      hostname = hostname(~isspace(hostname));
      switch hostname
          case 'cnmc7' % C1 (upper box)
              left_bk.value = 4; right_bk.value = 4;
          case 'cnmc8' % C2 (lower box)
              left_bk.value = 3; right_bk.value = 3;
      end
      % *******************************************************************
      % *******************************************************************
      
      next_row(y);
      
      SoloParamHandle(obj, 'active_bank', 'value', 3);    % determined by side_list 
      SoloParamHandle(obj, 'active_valve', 'value', 0);  % determined by side_list 
      
      % Initialize task difficulty (odor mixture ratio)
      MenuParam(obj, 'target_frac', {10, 5, 1,0.5, 0.3,100}, 3 , x, y, 'position', [x y 140 20]);
      DispParam(obj, 'bgrd_frac',['/   ' num2str(100) '     '], x, y,...
          'position', [x+70 y 130 20], 'label', 'Tgt / bgrd', 'labelfraction', 0.4);
      
      next_row(y);
      
      % Background and target odor names and IDs. You can add more odors here....
      MenuParam(obj, 'bgrd_ID', {1,2,3,4,5,6,7}, 1, x, y, 'position', [x y 100 20],...
          'labelfraction',0.6);
      load('bgnames');
      SoloParamHandle(obj,'Bgrd_Names','value',bgnames);
      DispParam(obj, 'bgrd_name', Bgrd_Names{1}, x, y,'position', [x+40 y 160 20],'label','bgrd_Odors');
      SoloFunctionAddVars('BlockControl', 'rw_args', {'Bgrd_Names','bgrd_name','bgrd_ID','L_valve','R_valve'});
      
      set_callback({bgrd_ID}, {'BlockControl', 'user_specify'});
      next_row(y);  
      
      MenuParam(obj, 'left_target', {'E.B.', 'Prop'}, 1, x, y, 'position',[x y 100 40],...
          'label', 'Left Target',  'labelpos','top');
      MenuParam(obj, 'right_target', {'E.B.', 'Prop'}, 2, x, y, 'position',[x+100 y 100 40],...
          'label', 'Right Target', 'labelpos','top');
      
      next_row(y,2.5);
      
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
            
      set_callback({target_frac, L_valve, R_valve, left_bk, right_bk}, {mfilename, 'update_odor'});
      % OdorSection(obj, 'update_odor');
      OdorSection(obj, 'write_olf');
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'active_bank','active_valve'})
   
   case 'monitor_olf'
        if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
          bk3_valve.value = Read(olf, 'Bank3_Valves');
          bk4_valve.value = Read(olf, 'Bank4_Valves');
          bk3_flow.value = Read(olf, 'BankFlow3_Sensor');
          bk4_flow.value = Read(olf, 'BankFlow4_Sensor');
          carr_flow.value = Read(olf, 'Carrier3_Sensor');
        end 
   
   case 'write_olf'
       %odor_flow = 1000 - value(Carrier3_FR);
       carrier_flow = 1000 - value(odor_flow);
       if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
              Write(olf, ['Carrier' num2str(value(active_bank)) '_Actuator'], carrier_flow);
              Write(olf, ['BankFlow' num2str(value(active_bank)) '_Actuator'], value(odor_flow));
       end
        
   case 'update_odor'
      % Background and odor valve ID are specified and updated in
      % BlockControl.m
      blk = value(block_count); % just for easy typing
      bgrd_ID.value = block(blk).bgrd;
      bgrd_name.value = Bgrd_Names{value(bgrd_ID)};
      L_valve.value = bgrd_ID*2-1;
      R_valve.value = bgrd_ID*2;
      side = side_list(n_done_trials+1);
      left = get_generic('side_list_left');
      if side == left
          active_bank.value = value(left_bk);
          active_valve.value = value(L_valve);
      elseif side == 1-left
          active_bank.value = value(right_bk);
          active_valve.value = value(R_valve);
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
  
      
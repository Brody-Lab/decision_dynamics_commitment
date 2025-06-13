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
      oldx = x;  oldy = y; x = 5; y = 5;
      
      % create a figure for displaying the olfactometer parameters.
      SoloParamHandle(obj, 'myfig1', 'value', figure, 'saveable', 0);
      set_size(value(myfig1), [200 130]);
      set(value(myfig1), 'Visible', 'off', 'MenuBar', 'none', 'Name', 'Monitoring Olfactometer',...
          'NumberTitle','off', 'CloseRequestFcn',['OdorSection(' class(obj) '(''empty''), ''hide'')']);
      DispParam(obj, 'carr_flow', 0, x, y, 'label', 'Carrier Flow Rate');   next_row(y);
      DispParam(obj, 'bk3_flow',  0, x, y, 'label', 'Bank3 Flow Rate');     next_row(y);
      DispParam(obj, 'bk4_flow',  0, x, y, 'label', 'Bank4 Flow Rate');     next_row(y);
      DispParam(obj, 'bk3_valve', 0, x, y, 'label', 'Bank3_Valve'); next_row(y);
      DispParam(obj, 'bk4_valve', 0, x, y, 'label', 'Bank4_Valve'); next_row(y);
      
      % create a figure for the odor parameters and block control
      x = 5; y = 5;
      SoloParamHandle(obj, 'myfig2', 'value', figure, 'savable', 0);
      set(value(myfig2), 'Position', [1150 100 250 400], 'MenuBar', 'none',...
          'Name', 'Odor Parameters', 'NumberTitle','off', ...
          'CloseRequestFcn',['OdorSection(' class(obj) '(''empty''), ''hide'')']);
      % now fill in the odor parameters
        % Initialize Olfactometer settings
      MenuParam(obj, 'Olf_Meter', {'hidden', 'view'}, 1, x, y); next_row(y);
      NumeditParam(obj, 'odor_flow', 80, x,y, 'label', 'Odor FlowRate');
      set_callback({odor_flow}, {mfilename, 'write_olf'});
      next_row(y);
      NumeditParam(obj, 'R_valve', 2, x, y, 'label', 'Right_Valve ID', 'labelpos', 'left'); 
      next_row(y);
      NumeditParam(obj, 'L_valve', 1, x, y, 'label', 'Left_Valve ID', 'labelpos', 'left'); 
      next_row(y);
      NumeditParam(obj, 'active_bank', 4, x,y, 'labelpos','left'); next_row(y); % Determined  by the rig id.
      SoloParamHandle(obj, 'active_valve', 'value', 0);  % determined by side_list 
      % Initialize task difficulty (odor mixture ratio)
      MenuParam(obj, 'target_frac', {'10/100','5/100','2/100','1/100','vary'}, 1, x, y, ...
          'label', 'Tgt-Bgrd Ratio','labelpos','left');
      next_row(y);
      MenuParam(obj, 'ratio_variable', {'fixed', 'varying'}, 1, x, y, 'labelpos','left');
      next_row(y);
      % specify the set of background odors, and set callback.
      load('OdorSet');
      SoloParamHandle(obj, 'odorset', 'value', odorset);
      
      %%%%%%%%%%%%%%%%%%%%% Note, valve_set sequence of BANK 4 is different!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      SoloParamHandle(obj, 'valve_set', 'value', {(1:15), (1:15), (1:15), [(1:9) (13:15) (10:12)]});
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      NumeditParam(obj, 'bg7', 7, x, y, 'position', [x y 100 20],'label','BG 7','labelpos','left');
      MenuParam(obj, 'probe7', {'on', 'off'},2, x, y,'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y); 
      NumeditParam(obj, 'bg6', 6, x, y, 'position', [x y 100 20], 'label','BG 6','labelpos','left');
      MenuParam(obj, 'probe6', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      NumeditParam(obj, 'bg5', 5, x, y, 'position', [x y 100 20], 'label','BG 5','labelpos','left');
      MenuParam(obj, 'probe5', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      NumeditParam(obj, 'bg4', 4, x, y, 'position', [x y 100 20], 'label','BG 4','labelpos','left');
      MenuParam(obj, 'probe4', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      NumeditParam(obj, 'bg3', 3, x, y, 'position', [x y 100 20], 'label','BG 3','labelpos','left');
      MenuParam(obj, 'probe3', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      NumeditParam(obj, 'bg2', 2, x, y, 'position', [x y 100 20], 'label','BG 2','labelpos','left');
      MenuParam(obj, 'probe2', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      NumeditParam(obj, 'bg1', 1, x, y, 'position', [x y 100 20], 'label','BG 1','labelpos','left');
      MenuParam(obj, 'probe1', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      SoloParamHandle(obj, 'probe_bg','value', []);
      OdorID_bg = [value(bg1); value(bg2); value(bg3); value(bg4); value(bg5); value(bg6); value(bg7)];
      OdorID_bg(find(OdorID_bg == 0)) = [];
 %      for i = 2:length(OdorID_bg), bgids=[bgids ; i]; end;
      odorset(1,2) = {'Pure'}; % redifine the first odor in the odorset list as pure target odor.
      bgnames = odorset(OdorID_bg,2);
      set_callback({bg1, bg2, bg3, bg4, bg5, bg6, bg7,probe1,probe2,probe3,probe4,...
          probe5,probe6,probe7}, {mfilename, 'write_olf'});
      
      MenuParam(obj, 'bgrd_ID', {1,2,3,4,5,6,7}, 1, x, y, 'position', [x y 100 20],...
          'label','Current Bkgrd','labelpos', 'left', 'labelfraction',0.7);
      SoloParamHandle(obj,'Bgrd_Names','value',bgnames);
      DispParam(obj, 'bgrd_name', Bgrd_Names{1}, x, y,'position', [x+100 y 100 20],'label','','labelfraction',0.05);
      SoloFunctionAddVars('BlockControl', 'rw_args', {'Bgrd_Names','bgrd_name','bgrd_ID','L_valve','R_valve'});
      
      set_callback({bgrd_ID}, {'BlockControl', 'user_specify'});
      next_row(y);  
      
      MenuParam(obj, 'left_target', {'Ethyl Butyrate','1-Hexanol'},1, x, y, 'position',[x y 100 40],...
          'label', 'Left Target',  'labelpos','top');
      MenuParam(obj, 'right_target', {'1-Propanol','Caproic acid'},1, x, y, 'position',[x+100 y 100 40],...
          'label', 'Right Target', 'labelpos','top');
      set_callback({ratio_variable, L_valve, R_valve, active_bank}, {mfilename, 'update_odor'});
      
      
      x = oldx; y = oldy; figure(fig);
      set_callback({Olf_Meter}, {'OdorSection', 'view'});
      
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      
      SoloParamHandle(obj, 'carrier_id', 'value', 3);
      % ***** for one bank olf meter **************************************
      [status, hostname] = system('hostname');
      hostname = lower(hostname);
      hostname = hostname(~isspace(hostname));
      switch hostname
          case 'cnmc7' % C1 (upper box)
              active_bank.value = 1; % right_bk.value = 1;
              carrier_id.value = 3;
          case 'cnmc8' % C2 (lower box)
              active_bank.value = 3; % right_bk.value = 3;
              carrier_id.value = 4;
      end
      % *******************************************************************
      % *******************************************************************
      
      next_row(y);
   
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
              Write(olf, ['Carrier' num2str(value(carrier_id)) '_Actuator'], carrier_flow);
              Write(olf, ['BankFlow' num2str(value(active_bank)) '_Actuator'], value(odor_flow));
       end
       OdorID_bg = [value(bg1); value(bg2); value(bg3); value(bg4); value(bg5); value(bg6); value(bg7)];
       OdorID_bg(find(OdorID_bg == 0)) = [];
       bgnames = odorset(OdorID_bg,2); 
       Bgrd_Names.value = bgnames;
       probe_bg.value = [];
       for i = 1:length(OdorID_bg) % determine which bgrd is for probe trial
           if strcmp(value(eval(['probe' num2str(i)])), 'on')
               probe_bg.value = [value(probe_bg) i];
           end;
       end;
               
   case 'update_odor'
      % Background and odor valve ID are specified and updated in
      % BlockControl.m
      blk = value(block_count); % just for easy typing
      if strcmp(value(block_update),'random_bg') && ~value(userspecify)
        % Bgrds are randomly presented. Chose the first one of a random pool 
        % as next bg_ID. Then eliminate the first component.  
          bgrd_ID.value = randrepeatpool(1);
          randrepeatpool(1) = []; %disp(size(value(randrepeatpool),2));
          disp(size(value(randrepeatpool),2));
          % Determine whether next would be probe trial 
          if ismember(value(bgrd_ID), value(probe_bg))
               WaterDelivery.value = 4; % 'probe'
          else
               WaterDelivery.value = 3; % 'only if nxt pk correct'
          end;
      else
          bgrd_ID.value = block(blk).bgrd;
          userspecify.value = 0;
      end
      bgrd_name.value = Bgrd_Names{value(bgrd_ID)};
      if strcmpi(value(ratio_variable), 'varying')
           target_frac.value = ceil(value(bgrd_ID)/2);
      end   
      % Determine the odor valve ID to be opened.
      effective_valve_set = valve_set{value(active_bank)};
      L_valve.value = effective_valve_set(bgrd_ID*2-1);
      R_valve.value = effective_valve_set(bgrd_ID*2);
      side = side_list(n_done_trials+1);
      left = get_generic('side_list_left');
      if side == left
          active_valve.value = value(L_valve);
      elseif side == 1-left
          active_valve.value = value(R_valve);
      end
      
     
    case 'view', % ------ CASE VIEW
        switch value(Olf_Meter),
            case 'hidden', set(value(myfig1), 'Visible', 'off');
            case 'view',
                set(value(myfig1), 'Visible', 'on');
            end;

    case 'hide', % ------ CASE HIDE
        Olf_Meter.value = 'hidden';
        set(value(myfig1), 'Visible', 'off');

      
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
  
      
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
      %MenuParam(obj, 'target_frac', {'10/100','5/100','2/100','1/100','vary'}, 1, x, y, ...
       %   'label', 'Tgt-Bgrd Ratio','labelpos','left');
      %next_row(y);
      %MenuParam(obj, 'ratio_variable', {'fixed', 'varying'}, 1, x, y, 'labelpos','left');
      %next_row(y);
      % specify the set of background odors, and set callback.
      %load('OdorSet');
      %SoloParamHandle(obj, 'odorset', 'value', odorset);
      
      %%%%%%%%%%%%%%%%%%%%% Note, valve_set sequence of BANK 4 is different!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %SoloParamHandle(obj, 'valve_set', 'value', {(1:15), (1:15), (1:15), (1:15)}); %[(1:9) (13:15) (10:12)]});
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %{
      NumeditParam(obj, 'mix7', 0, x, y, 'position', [x y 70 20],'label','Mix7','labelpos','left');
      MenuParam(obj, 'probe7', {'on', 'off'},2, x, y,'position', [x+70, y, 90, 20],'label','probe','labelpos','left');
      NumeditParam(obj, 'valve_pair7', 0, x, y, 'position', [x+160, y, 75, 20],'label','valve_pair','labelpos','left','labelfraction',0.7);
      next_row(y); 
      NumeditParam(obj, 'mix6', 0, x, y, 'position', [x y 70 20], 'label','Mix6','labelpos','left');
      MenuParam(obj, 'probe6', {'on', 'off'},2, x, y, 'position', [x+70, y, 90, 20],'label','probe','labelpos','left');
      NumeditParam(obj, 'valve_pair6', 0, x, y, 'position', [x+160, y, 75, 20],'label','valve_pair','labelpos','left','labelfraction',0.7);
      next_row(y);
      NumeditParam(obj, 'mix5', 0, x, y, 'position', [x y 70 20], 'label','Mix5','labelpos','left');
      MenuParam(obj, 'probe5', {'on', 'off'},2, x, y, 'position', [x+70, y, 90, 20],'label','probe','labelpos','left');
      NumeditParam(obj, 'valve_pair5', 0, x, y, 'position', [x+160, y, 75, 20],'label','valve_pair','labelpos','left','labelfraction',0.7);
      next_row(y);
      
      NumeditParam(obj, 'mix4', 4, x, y, 'position', [x y 100 20], 'label','Mix4','labelpos','left');
      MenuParam(obj, 'probe4', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y);
      % specify vavle id for each
      NumeditParam(obj, 'vl4', 0, x, y, 'position', [x, y, 100, 20],'label','left_valve','labelpos','left','labelfraction',0.7);
      NumeditParam(obj, 'vr4', 0, x, y, 'position', [x+100, y, 100, 20],'label','right_valve','labelpos','left','labelfraction',0.7);
      next_row(y);
      %}
      % assign 2 valve IDs to each left odor or right odor. Then randomly
      % choose one of the 2 valve for delivery in each trial
      % vl3_1 means: valve left of mixture 3, valve id 1.
     
      NumeditParam(obj, 'vr2_4', 0, x, y, 'position', [x+120, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr2_3', 0, x, y, 'position', [x+80, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr2_2', 0, x, y, 'position', [x+40, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr2_1', 4, x, y, 'position', [x, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      next_row(y);
      NumeditParam(obj, 'vl2_4', 0, x, y, 'position', [x+120, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl2_3', 0, x, y, 'position', [x+80, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl2_2', 0, x, y, 'position', [x+40, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl2_1', 3, x, y, 'position', [x, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      next_row(y);
      NumeditParam(obj, 'mix2', 60, x, y, 'position', [x y 100 20], 'label','Mix2','labelpos','left');
      MenuParam(obj, 'probe2', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y,1.5);
      
      NumeditParam(obj, 'vr1_4', 0, x, y, 'position', [x+120, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr1_3', 0, x, y, 'position', [x+80, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr1_2', 0, x, y, 'position', [x+40, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vr1_1', 2, x, y, 'position', [x, y, 80, 20],'label','R_vid','labelpos','left','labelfraction',0.5);
      next_row(y);
      NumeditParam(obj, 'vl1_4', 0, x, y, 'position', [x+120, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl1_3', 0, x, y, 'position', [x+80, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl1_2', 0, x, y, 'position', [x+40, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      NumeditParam(obj, 'vl1_1', 1, x, y, 'position', [x, y, 80, 20],'label','L_vid','labelpos','left','labelfraction',0.5);
      next_row(y);
      NumeditParam(obj, 'mix1', 100, x, y, 'position', [x y 100 20], 'label','Mix1','labelpos','left');
      MenuParam(obj, 'probe1', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
      next_row(y,1.5);
      
      SoloParamHandle(obj, 'probe_mix','value', []);
      SoloParamHandle(obj, 'all_mix', 'value', []);
      SoloParamHandle(obj, 'valve_sets', 'value', []);
      all_mix.value = [value(mix1); value(mix2)]; %  value(mix4) value(mix5); value(mix6); value(mix7)];
      all_mix(find(all_mix == 0)) = [];
      
 %      for i = 2:length(OdorID_bg), bgids=[bgids ; i]; end;
  %    odorset(1,2) = {'Pure'}; % redifine the first odor in the odorset list as pure target odor.
     % bgnames = odorset(OdorID_bg,2);
      set_callback({mix1, mix2, probe1,probe2...
          vl1_1,vl1_2,vl1_3,vl1_4,vr1_1,vr1_2,vr1_3,vr1_4, vl2_1,vl2_2,vl2_3,vl2_4,...
          vr2_1,vr2_2,vr2_3,vr2_4}, {mfilename, 'write_olf'});
      
      MenuParam(obj, 'target_pair1', {'EB/Prop','Oct(+)/Oct(-)','Hex/CA'},1, x, y, 'position',[x y 100 40],...
          'label', 'TargetPair1',  'labelpos','top');
      MenuParam(obj, 'target_pair2', {'EB/Prop','Oct(+)/Oct(-)','Hex/CA'},2, x, y, 'position',[x+100 y 100 40],...
          'label', 'TargetPair2', 'labelpos','top'); next_row(y,2);
      SoloParamHandle(obj, 'target_pair', 'value', { value(target_pair1),value(target_pair2)});
      MenuParam(obj, 'mix_ID', {1,2}, 1, x, y, 'position', [x y 100 20],...
          'label','Current Mix','labelpos', 'left', 'labelfraction',0.7);
      DispParam(obj, 'mix_name', target_pair{1}, x, y,'position', [x+100 y 100 20],'label','','labelfraction',0.05);
      
      SoloParamHandle(obj, 'mix_diff', 'value', all_mix(1));
      next_row(y);
      % SoloParamHandle(obj,'Bgrd_Names','value',bgnames);
      
      
      SoloFunctionAddVars('BlockControl', 'rw_args', {'all_mix','mix_diff','mix_ID','mix_name','L_valve','R_valve'});
      
      set_callback({mix_ID}, {'BlockControl', 'user_specify'});
      next_row(y);  
      set_callback({L_valve, R_valve, active_bank}, {mfilename, 'update_odor'});
      
      
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
          case 'cnmc9' % C3 (upper box)
              active_bank.value = 3;
              carrier_id.value = 4;
          case 'cnmc10' % C4 (upper box)
              active_bank.value = 1;
              carrier_id.value = 3;
      end
      % *******************************************************************
      % *******************************************************************
      
      next_row(y);
      % OdorSection(obj, 'update_odor');
      OdorSection(obj, 'write_olf');
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'active_bank','active_valve'});
   
   case 'write_olf'
       %odor_flow = 1000 - value(Carrier3_FR);
       carrier_flow = 1000 - value(odor_flow);
       if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
              Write(olf, ['Carrier' num2str(value(carrier_id)) '_Actuator'], carrier_flow);
              Write(olf, ['BankFlow' num2str(value(active_bank)) '_Actuator'], value(odor_flow));
       end
       all_mix.value = [value(mix1); value(mix2)];%   value(mix4) value(mix5); value(mix6); value(mix7)];
       all_mix(find(all_mix == 0)) = [];
       valve1_l = [value(vl1_1) value(vl1_2) value(vl1_3) value(vl1_4)]; valve1_l(valve1_l(:)==0)=[];
       valve1_r = [value(vr1_1) value(vr1_2) value(vr1_3) value(vr1_4)]; valve1_r(valve1_r(:)==0)=[];
       valve2_l = [value(vl2_1) value(vl2_2) value(vl2_3) value(vl2_4)]; valve2_l(valve2_l(:)==0)=[];
       valve2_r = [value(vr2_1) value(vr2_2) value(vr2_3) value(vr2_4)]; valve2_r(valve2_r(:)==0)=[];
        
       valve_sets.value = {{valve1_l, valve1_r}, {valve2_l, valve2_r}};
       probe_mix.value = [];
       for i = 1:length(value(all_mix)) % determine which mix is for probe trial
           if strcmp(value(eval(['probe' num2str(i)])), 'on')
               probe_mix.value = [value(probe_mix) i];
           end;
       end;
               
   case 'update_odor'
      % Background and odor valve ID are specified and updated in
      % BlockControl.m
      blk = value(block_count); % just for easy typing
      if strcmp(value(block_update),'interlv') && ~value(userspecify)
        % Bgrds are randomly presented. Chose the first one of a random pool 
        % as next bg_ID. Then eliminate the first component.  
          mix_ID.value = randrepeatpool(1); %disp(value(randrepeatpool));
          randrepeatpool(1) = []; %disp(size(value(randrepeatpool),2));
          % disp(size(value(randrepeatpool),2)); temp = value(randrepeatpool);
          if size(value(randrepeatpool),2) < 1
              block_update.value = 2;
          end;
          % Determine whether next would be probe trial 
          if ismember(value(mix_ID), value(probe_mix))
               WaterDelivery.value = 4; % 'probe'
          else
               WaterDelivery.value = 3; % 'only if nxt pk correct'
          end;
      else
          mix_ID.value = block(blk).mix_id;
          userspecify.value = 0;
      end
      mix_diff.value = all_mix(value(mix_ID));
      mix_name.value = target_pair{value(mix_ID)}; 
      % Determine the odor valve ID to be opened.
      % effective_valve_set = valve_set{value(active_bank)};
      
      % randomly choose one of 4 caditate valve ids for either left or
      % right odors.
      kl = size(valve_sets{value(mix_ID)}{1},2);
      v_idx_L = ceil(kl.*rand);
      kr = size(valve_sets{value(mix_ID)}{2},2);
      v_idx_R = ceil(kr.*rand);
      L_valve.value = valve_sets{value(mix_ID)}{1}(v_idx_L);
      R_valve.value = valve_sets{value(mix_ID)}{2}(v_idx_R);
      
      side = side_list(n_done_trials+1);
      left = get_generic('side_list_left');
      if side == left
          active_valve.value = value(L_valve);
      elseif side == 1-left
          active_valve.value = value(R_valve);
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
  
      
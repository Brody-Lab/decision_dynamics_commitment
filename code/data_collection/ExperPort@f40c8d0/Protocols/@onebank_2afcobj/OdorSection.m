function [x, y] = OdorSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
       olf = value(olf_meter);
   end
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % going to start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
      % Old call to initialise Olfactometer:
      NumeditParam(obj, 'Carrier_FR', 920, x,y);
      next_row(y);
            
      % Initialize odor settings
      
      % determine which carrier and bank to use (rig-dependent)
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
          [carriers, banks] = GetOlfHardware(olf);
          active_carrier = carriers(1); % in case there are >1 carriers
          active_bank = banks(1); % in case there are >1 banks
      else
          active_carrier = 1;
          active_bank = 1;
      end
          
      DispParam(obj, 'ActiveBankID', active_bank, x, y); % only use 1 bank for this version of the 2AFC (no mixtures possible)
      next_row(y);

      DispParam(obj, 'ActiveCarrierID', active_carrier, x, y); % only use 1 carrier for this version of the 2AFC (no mixtures possible)
      next_row(y);

      % User sets the number of odors (1 thru max_odors possible); odor parameters to be
      % determined in separate window
      
      MenuParam(obj, 'num_pairs', {1:value(max_odors)}, 3, x,y);
      next_row(y);

      MenuParam(obj, 'odor_params', {'hide', 'view'}, 1, x, y);
      next_row(y);

      % Make separate figure for odor parameters
      
      fig = gcf; % first save current (main) figure
      
      SoloParamHandle(obj, 'odor_params_fig', 'value', figure, 'saveable', 0);
      
      set(value(odor_params_fig), 'Visible', 'off', 'MenuBar', 'none', 'Name', 'Odor parameters',...
          'NumberTitle','off', 'CloseRequestFcn', ...
          ['OdorSection(' class(obj) '(''empty''), ''hide'')']);

      set_size(value(odor_params_fig), [800 300]);

      % set values for layout of SPH chart of odor parameters
      init_x = 75;
      init_y = 200;
      vert_buff = 5;
      hor_buff = 5;
      window_size = [100 25];
      odor_menu = {'+Oct', '-Oct', '+Carv', '-Carv', 'Hex', 'CA', 'Other'};
      
      for ind = 1:value(max_odors)
          
          col_num = 1; % initialize
          
          % Names of odors
          SoloParamHandle(obj, strcat('odor_name', num2str(ind)), 'type', 'menu', 'string', odor_menu,...
              'value', 5, 'position', [init_x (init_y - ((ind-1) * (window_size(2) + vert_buff))) window_size]);
          col_num = col_num + 1;
         
          % Probability of reward for L poke following each odor
          SoloParamHandle(obj, strcat('L_prob', num2str(ind)), 'type', 'numedit',...
              'value', 1, 'position', [(init_x + ((col_num - 1) * (window_size(1) + hor_buff)))...
              (init_y - ((ind-1) * (window_size(2) + vert_buff))) window_size]);
          col_num = col_num + 1;
          
          % Probability of reward for R poke following each odor
          SoloParamHandle(obj, strcat('R_prob', num2str(ind)), 'type', 'numedit',...
              'value', 0, 'position', [(init_x + ((col_num - 1) * (window_size(1) + hor_buff)))...
              (init_y - ((ind-1) * (window_size(2) + vert_buff))) window_size]);
          col_num = col_num + 1;
          
          % Odor valve associated with the odor
          SoloParamHandle(obj, strcat('odor_valve', num2str(ind)), 'type', 'numedit',...
              'value', 0, 'position', [(init_x + ((col_num - 1) * (window_size(1) + hor_buff)))...
              (init_y - ((ind-1) * (window_size(2) + vert_buff))) window_size]);
          col_num = col_num + 1;
          
          % Fraction of trials with this odor
          SoloParamHandle(obj, strcat('trials_fraction', num2str(ind)), 'type', 'numedit',...
              'value', (1 / value(max_odors)), 'position', [(init_x + ((col_num - 1) * (window_size(1) + hor_buff)))...
              (init_y - ((ind-1) * (window_size(2) + vert_buff))) window_size]);
          
          SoloFunctionAddVars('SidesSection', 'ro_args',...
            {strcat('L_prob', num2str(ind)), strcat('R_prob', num2str(ind)), strcat('trials_fraction', num2str(ind))});

          SoloFunctionAddVars('RewardsSection', 'ro_args',...
            {strcat('odor_name', num2str(ind)), strcat('trials_fraction', num2str(ind))});

          SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
            strcat('odor_valve', num2str(ind)));
      
          eval(strcat('set_callback({L_prob', num2str(ind),...
              ', R_prob', num2str(ind),...
              ', trials_fraction', num2str(ind), ...
              '}, {''SidesSection'', ''set_future_sides''});'));

      end
      
      % add text labels
      text_buff = 10;
      whole_fig = axes('Position', [0 0 1 1]);
      set(gca, 'Visible', 'off');
      
      fig_position = get(value(odor_params_fig), 'Position');
      
      % label rows
      for ind = 1:value(max_odors)
          
          % get position, in pixel units of first column solo param handles
          tmp = eval(strcat('get(get_ghandle(odor_name', num2str(ind), '), ''Position'')'));
          
          % determine text position, in noramalized units
          x_pos = (tmp(1)  - text_buff) ./ fig_position(3);
          y_pos = tmp(2) ./ fig_position(4);
          
          % create text labelling each row
          text(x_pos, y_pos, strcat('Odor #', num2str(ind)), 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom');
          
      end
      
      % label columns
      col_labels = {'Name', 'L prob', 'R prob', 'Valve', 'fraction of Trials'};
      for ind = 1:col_num
          
          x_pos = ((init_x + ((ind - 1) * (window_size(1) + hor_buff)))) ./ fig_position(3);
          y_pos = (init_y + window_size(2) + text_buff) ./ fig_position(4);

          % create text labelling each column
          text(x_pos, y_pos, col_labels{ind}, 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom');
          
      end
      
      % return to the main figure
      figure(fig);
      
      % Display the odor number for the current trial
      DispParam(obj, 'current_odor', 0, x, y); % (at initialization, display 0)
      next_row(y);

      
      set_callback({odor_params}, {'OdorSection', 'view_odor_params'});
            
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
            
      set_callback(Carrier_FR, {mfilename, 'update_odor'});
      
      OdorSection(obj, 'update_odor');
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'ActiveBankID'})

   case 'update_odor'
      odor_flow = 1000 - value(Carrier_FR);
      
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
                   
          % set flow rates (these won't actually change across trials)
          Write(olf, ['BankFlow' num2str(value(ActiveBankID)) '_Actuator'], odor_flow);

          Write(olf, ['Carrier' num2str(value(ActiveCarrierID)) '_Actuator'], value(Carrier_FR));
     
      end
    
      % update which odor is presented on this trial
      if exist('odor_list') % this sph doesn't exist at initialization
        ol = value(odor_list);
        current_odor.value = ol(n_done_trials + 1);
      end
      
    case 'view_odor_params', % ------ CASE VIEW ODOR PARAMETERS
        switch value(odor_params),
            case 'hide'
                set(value(odor_params_fig), 'Visible', 'off');
            case 'view'
                set(value(odor_params_fig), 'Visible', 'on');
            end;

    case 'hide', % ------ CASE HIDE (used during Close routine)
        odor_params.value = 'hide';
        set(value(odor_params_fig), 'Visible', 'off');

    
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
  
      
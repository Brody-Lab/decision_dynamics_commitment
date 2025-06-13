function [x, y] = OdorSection(obj, action, x, y)
   
   GetSoloFunctionArgs;
   if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
       olf = value(olf_meter);
   end
   
   switch action
    case 'init',   % ---------- CASE INIT -------------
      
      % Start adding GUI elements:
      SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

      % Initialize odor settings

      NumeditParam(obj, 'Carrier_FR', 920, x,y);
      next_row(y);
  
      
      DispParam(obj, 'DivertValve', 0, x, y); % 
      next_row(y);
     
      
      % determine which carrier and bank to use (rig-dependent)
      if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
          [carriers, banks] = GetOlfHardware(olf);
          active_carrier = carriers(1); % in case there are >1 carriers
          active_banks = banks(1:2); % in case there are >2 banks
      else
          active_carrier = 1;
          active_banks = [1 2];
      end
          
      DispParam(obj, 'ActiveBank2ID', active_banks(2), x, y); % use 2 banks for mixtures
      next_row(y);

      DispParam(obj, 'ActiveBank1ID', active_banks(1), x, y); % use 2 banks for mixtures
      next_row(y);

      DispParam(obj, 'ActiveCarrierID', active_carrier, x, y); % only use 1 carrier
      next_row(y);

      set_callback(Carrier_FR, {mfilename, 'update_odor'});
      
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
          {'ActiveBank1ID', 'ActiveBank2ID', 'DivertValve'});

      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Odor parameters to be determined in separate window
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      MenuParam(obj, 'odor_params', {'hide', 'view'}, 1, x, y);
      next_row(y);

      % Make separate figure for odor parameters
      
      fig = gcf; % first save current (main) figure
      
      SoloParamHandle(obj, 'odor_params_fig', 'value', figure, 'saveable', 0);
      
      set(value(odor_params_fig), 'Visible', 'off', 'MenuBar', 'none', 'Name', 'Odor parameters',...
          'NumberTitle','off', 'CloseRequestFcn', ...
          ['OdorSection(' class(obj) '(''empty''), ''hide'')']);

      set(value(odor_params_fig), 'Position', [420 250 800 700]);

      % set values for layout of SPH chart of odor parameters
      init_x = 75;
      init_y = 600;
      vert_buff = 5;
      hor_buff = 5;
      window_size = [100 25];
      odor_menu = {'+Oct', '-Oct', '+Carv', '-Carv', 'Hex', 'CA', 'Other'};
      


      % set the odor name, L_prob, R_prob, bank, and odor valve associated
      % with each pure odor, and the fraction of trials associated with
      % each mixutre
      
      row_height = window_size(2) + vert_buff;
      col_width = window_size(1) + hor_buff;
      odors_section_height = row_height * 2 + (vert_buff * 8);
          
      for ind1 = 1:max_odor_pairs
          
          for ind2 = 1:2 % '2' b/c there are 2 odors per pair

              col_num = 1; % initialize

              sph_num = ((ind1 - 1) * 2) + ind2;
              
              % Names of odors
              SoloParamHandle(obj, strcat('odor_name', num2str(sph_num)), 'type', 'menu', 'string', odor_menu,...
                  'value', 5, 'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size]);
              col_num = col_num + 1;

              % Olfactometer bank associated with the odor
              SoloParamHandle(obj, strcat('odor_bank', num2str(sph_num)), 'type', 'disp',...
                  'value', eval(strcat('value(ActiveBank', num2str(ind2), 'ID)')), 'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size]);
              col_num = col_num + 1;

              % Probability of reward for L poke following each odor
              SoloParamHandle(obj, strcat('L_prob', num2str(sph_num)), 'type', 'numedit',...
                  'value', 1, 'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size]);
              col_num = col_num + 1;

              % Probability of reward for R poke following each odor
              SoloParamHandle(obj, strcat('R_prob', num2str(sph_num)), 'type', 'numedit',...
                  'value', 0, 'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size]);
              col_num = col_num + 1;

              % Odor valve associated with the odor
              SoloParamHandle(obj, strcat('odor_valve', num2str(sph_num)), 'type', 'numedit',...
                  'value', 0, 'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size]);
              col_num = col_num + 1;


              SoloFunctionAddVars('SidesSection', 'ro_args',...
                {strcat('L_prob', num2str(sph_num)), strcat('R_prob', num2str(sph_num))});

              SoloFunctionAddVars('RewardsSection', 'ro_args',...
                {strcat('odor_name', num2str(sph_num))});

              SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args',...
                {strcat('odor_bank', num2str(sph_num)), strcat('odor_valve', num2str(sph_num))});

              eval(strcat('set_callback(odor_valve', num2str(sph_num),...
                  ', {''OdorSection'', ''assign_divert_valve''});')); % update the divert valve if any odor valves are changed

              eval(strcat('set_callback({L_prob', num2str(sph_num),...
                  ', R_prob', num2str(sph_num),...
                  '}, {''SidesSection'', ''set_future_sides''});')); % update the odor and side lists if probabilities are changed

              if ind2 == 1  % set the fraction of trials devoted to each mixture (but only once per pair)
                  
                  SoloParamHandle(obj, strcat('pair_trials_fraction', num2str(ind1)), 'type', 'numedit', ...
                      'value', (1 / value(max_odor_pairs)),  'position', [init_x + ((col_num - 1) * col_width)...
                  (init_y - (((ind1 - 1) * odors_section_height) + ((ind2 - 1) * row_height))) window_size],...
                  'TooltipString', 'These fractions need not add to 1; they will be rescaled');

                  SoloFunctionAddVars('SidesSection', 'ro_args', strcat('pair_trials_fraction', num2str(ind1)));

                  eval(strcat('set_callback(pair_trials_fraction', num2str(ind1),...
                      ', {''SidesSection'', ''set_future_sides''});'));
              
              end
                        
          end

      end


      % add text labels to 'odor pairs' section of plot
      
      text_buff = 10;
      axes('Position', [0 0 1 1]);
      set(gca, 'Visible', 'off');
      
      fig_position = get(value(odor_params_fig), 'Position');
      
      % label rows
      for ind = 1:(max_odor_pairs * 2)
          
          % get position, in pixel units of first column solo param handles
          tmp = eval(strcat('get(get_ghandle(odor_name', num2str(ind), '), ''Position'')'));
          
          % determine text position, in noramalized units
          x_pos = (tmp(1)  - text_buff) ./ fig_position(3);
          y_pos = tmp(2) ./ fig_position(4);
          
          % create text labelling each row
          text(x_pos, y_pos, strcat('\bfOdor #', num2str(ind)), 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom');
          
          if mod(ind, 2) == 1 % also label the pair number (only once per pair)
              
              y_pos = (tmp(2) + window_size(2) + text_buff) ./ fig_position(4);
              text(x_pos, y_pos, strcat('\bfPAIR #', num2str(ceil(ind / 2))), 'HorizontalAlignment', 'Right',...
                  'VerticalAlignment', 'Bottom', 'FontSize', 12);
              
          end
          
      end
      
      % label columns
      col_labels = {'Name', 'Bank', 'L prob', 'R prob', 'Valve', 'Fraction of trials (per pair)'};
      for ind = 1:col_num
          
          x_pos = ((init_x + ((ind - 1) * (window_size(1) + hor_buff)))) ./ fig_position(3);
          y_pos = (init_y + window_size(2) + text_buff) ./ fig_position(4);

          % create text labelling each column
          text(x_pos, y_pos, strcat('\bf', col_labels{ind}), 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom');
          
      end
      
      
      
      % set the mixture ratios and fraction of trials for each mixture
      
      init_y = init_y - (max_odor_pairs * odors_section_height) - (10 * vert_buff);
      ratio_section_width = col_width * 2 + (hor_buff * 24);
          
      for ind1 = 1:max_odor_pairs
          
          for ind2 = 1:max_mixture_fractions

              col_num = 1; % initialize

              sph_num = ((ind1 - 1) * max_mixture_fractions) + ind2;
              
              % mixture ratio (as percentage of odor A)
              SoloParamHandle(obj, strcat('odor_A_percent', num2str(sph_num)), 'type', 'numedit',...
                  'value', 95, 'position', [(init_x + ((ind1 - 1) * ratio_section_width) + ((col_num - 1) * col_width))...
                  (init_y - ((ind2 - 1) * row_height)) window_size],...
                  'TooltipString', 'Do not enter 0 or 100; the flowmeters don''t like flow rates of 0');
              col_num = col_num + 1;

             % Fraction of trials with this odor
             SoloParamHandle(obj, strcat('mix_trials_fraction', num2str(sph_num)), 'type', 'numedit',...
                 'value', (1 / value(max_mixture_fractions)), 'position',...
                 [(init_x + ((ind1 - 1) * ratio_section_width) + ((col_num - 1) * col_width))...
                 (init_y - ((ind2 - 1) * row_height)) window_size],...
                 'TooltipString', 'These fractions need not add to 1; they will be rescaled');

              SoloFunctionAddVars('RewardsSection', 'ro_args',...
                {strcat('mix_trials_fraction', num2str(sph_num))});

              SoloFunctionAddVars('SidesSection', 'ro_args',...
                  {strcat('odor_A_percent', num2str(sph_num)), strcat('mix_trials_fraction', num2str(sph_num))});

              SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', strcat('odor_A_percent', num2str(sph_num)));

              SoloFunctionAddVars('RewardsSection', 'ro_args', strcat('odor_A_percent', num2str(sph_num)));

              eval(strcat('set_callback(mix_trials_fraction', num2str(sph_num),...
                  ', {''SidesSection'', ''set_future_sides''});'));

          end

          
          % add text labels to 'mixture fraction' section of plot

          axes('Position', [0 0 1 1]);
          set(gca, 'Visible', 'off');

          % label rows
          for ind2 = (((ind1 - 1) * max_mixture_fractions) + 1):(((ind1 - 1) * max_mixture_fractions) + max_mixture_fractions)

              % get position, in pixel units of first column solo param handles
              tmp = eval(strcat('get(get_ghandle(odor_A_percent', num2str(ind2), '), ''Position'')'));

              % determine text position, in noramalized units
              x_pos = (tmp(1)  - text_buff) ./ fig_position(3);
              y_pos = tmp(2) ./ fig_position(4);

              % create text labelling each row
              text(x_pos, y_pos, strcat('\bfStim #', num2str(ind2)), 'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Bottom');

              if mod(ind2, max_mixture_fractions) == 1 % also label the pair number (only once per pair)

                  y_pos = (tmp(2) + window_size(2) + text_buff) ./ fig_position(4);
                  text(x_pos, y_pos, strcat('\bfPAIR #', num2str(ceil(ind2 / max_mixture_fractions))), 'HorizontalAlignment', 'Right',...
                      'VerticalAlignment', 'Bottom', 'FontSize', 12);

              end

          end

          % label columns
          col_labels = {'% odor A', 'Frac. trials (per mix.)'};
          for ind2 = 1:col_num

              x_pos = ((init_x + ((ind1 - 1) * ratio_section_width) + ((ind2 - 1) * (window_size(1) + hor_buff)))) ./ fig_position(3);
              y_pos = (init_y + window_size(2) + text_buff) ./ fig_position(4);

              % create text labelling each column
              text(x_pos, y_pos, strcat('\bf', col_labels{ind2}), 'HorizontalAlignment', 'Left', 'VerticalAlignment', 'Bottom');

          end

      end

      % reassign the divert valve, now that odor valves have been assigned
      OdorSection(obj, 'assign_divert_valve');

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % End of separate window; return to the main figure
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      figure(fig);
      
      % Display the odor number for the current trial
      DispParam(obj, 'current_odor', 0, x, y); % (at initialization, display 0)
      next_row(y);

      % let make_and_upload_state_matrix see stimulus on current trial
      SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', 'current_odor');

      
      set_callback({odor_params}, {'OdorSection', 'view_odor_params'});
            
      SubheaderParam(obj, 'title', 'Odor Parameters', x, y);
      next_row(y, 1.5);
            
      OdorSection(obj, 'update_odor');
      

   case 'update_odor'
       
      if exist('odor_list') % this sph doesn't exist at initialization

          % update which odor is presented on this trial
          ol = value(odor_list);
          current_odor.value = ol(n_done_trials + 1);

          odor_flow = 1000 - value(Carrier_FR);

          bank1_flow = (eval(strcat('odor_A_percent', num2str(value(current_odor)))) / 100) * odor_flow;
          bank2_flow = (1 - (eval(strcat('odor_A_percent', num2str(value(current_odor)))) / 100)) * odor_flow;
          
          if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected

              % set bank flow rates
              DIVERTED_BANK_FLOW = 50; % what to set the bank flow rate to when it will be diverted (b/c we shouldn't set flow to 0)

              if bank1_flow ~= 0
                  Write(olf, ['BankFlow' num2str(value(ActiveBank1ID)) '_Actuator'], bank1_flow);
              else % if the flow should be zero, actually make the flow something nonzero, but through the divert valve
                  Write(olf, ['BankFlow' num2str(value(ActiveBank1ID)) '_Actuator'], DIVERTED_BANK_FLOW);
              end
                  
              if bank2_flow ~= 0
                  Write(olf, ['BankFlow' num2str(value(ActiveBank2ID)) '_Actuator'], bank2_flow);
              else % if the flow should be zero, actually make the flow something nonzero, but through the divert valve
                  Write(olf, ['BankFlow' num2str(value(ActiveBank2ID)) '_Actuator'], DIVERTED_BANK_FLOW);
              end
                  
              % set carrier flow rate (though it will not change across trials)
              Write(olf, ['Carrier' num2str(value(ActiveCarrierID)) '_Actuator'], value(Carrier_FR));

          end
      
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

    
    case 'assign_divert_valve',   % --------CASE ASSIGN_DIVERT_VALVE -------

       % find the lowest unused valve # to be the divert valve (the valve
       % that air flow will be diverted through for pure odors, since
       % setting a flowrate to 0 is not desirable)
       used_valves = [];
       for odor_ind = 1:(max_odor_pairs * 2)
           used_valves = [used_valves eval(strcat('value(odor_valve', num2str(odor_ind), ')'))];
       end
       
       NUM_VALVES = 16; % each bank has 16 valves
       x = ones(1, NUM_VALVES);
       x(used_valves + 1) = 0; % '+1' b/c valves are numbered from 0-15
       
       y = min(find(x == 1)) - 1;
       if ~isempty(y)
           DivertValve.value = y; 
       else
           error('All valves used for odors! None remain for divert_valve! See OdorSection.assign_divert_value');
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
  
      
function [x, y] = OdorSection(obj, action, x, y)

GetSoloFunctionArgs;
if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
    olf = value(olf_meter);
end

switch action
    case 'init',   % ---------- CASE INIT -------------
        % determine the bank and carrier ID using GetOlfHardware function
        % (according to the host machine).
        if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connected
          [carriers, banks] = GetOlfHardware(olf);
        else
          carriers = 3; banks = [1 2];
        end;

        % Save the figure and the position in the figure where we are
        fig = gcf;
        oldx = x;  oldy = y; x = 5; y = 5;

        % create a figure for the odor parameters and block control
        x = 5; y = 5;
        SoloParamHandle(obj, 'myfig2', 'value', figure, 'savable', 0);
        set(value(myfig2), 'Position', [1120 145 254 461], 'MenuBar', 'none',...
            'Name', 'Odor Parameters', 'NumberTitle','off', ...
            'CloseRequestFcn',['OdorSection(' class(obj) '(''empty''), ''hide'')']);
        % now fill in the odor parameters
        % Initialize Olfactometer settings
 %       MenuParam(obj, 'Olf_Meter', {'hidden', 'view'}, 1, x, y); next_row(y, 1.5);

        NumeditParam(obj, 'bk3_L', banks(1), x, y, 'position', [x y 100 20],'label', 'Bank_L ','labelpos','left');
        NumeditParam(obj, 'bk3_R', banks(2), x, y, 'position', [x+100 y 100 20],'label', 'Bank_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'ch3_L', 5, x, y, 'position', [x y 100 20], 'label', 'Chan_L ','labelpos','left');
        NumeditParam(obj, 'ch3_R', 6, x, y, 'position', [x+100 y 100 20], 'label', 'Chan_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'diff3', 12, x, y, 'label', 'Ratio Diff.', 'position', [x y 100 20], 'labelpos', 'left');
        MenuParam(obj, 'probe3', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
        next_row(y);
        MenuParam(obj, 'mix3', {'EB/Prop','Cav(+)/Cav(-)','Oct(+)/Oct(-)','none'},3, x, y,'label','Mixture 3  ','labelpos','left');
        next_row(y,1.5);

        NumeditParam(obj, 'bk2_L', banks(1), x, y, 'position', [x y 100 20],'label', 'Bank_L ','labelpos','left');
        NumeditParam(obj, 'bk2_R', banks(2), x, y, 'position', [x+100 y 100 20],'label', 'Bank_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'ch2_L', 3, x, y, 'position', [x y 100 20], 'label', 'Chan_L ','labelpos','left');
        NumeditParam(obj, 'ch2_R', 4, x, y, 'position', [x+100 y 100 20], 'label', 'Chan_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'diff2', 12, x, y, 'label', 'Ratio Diff.', 'position', [x y 100 20], 'labelpos', 'left');
        MenuParam(obj, 'probe2', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
        next_row(y);
        MenuParam(obj, 'mix2', {'EB/Prop','Cav(+)/Cav(-)','Oct(+)/Oct(-)','none'},2, x, y,'label','Mixture 2  ','labelpos','left');
        next_row(y,1.5);

        NumeditParam(obj, 'bk1_L', banks(1), x, y, 'position', [x y 100 20],'label', 'Bank_L ','labelpos','left');
        NumeditParam(obj, 'bk1_R', banks(2), x, y, 'position', [x+100 y 100 20],'label', 'Bank_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'ch1_L', 1, x, y, 'position', [x y 100 20], 'label', 'Chan_L ','labelpos','left');
        NumeditParam(obj, 'ch1_R', 2, x, y, 'position', [x+100 y 100 20], 'label', 'Chan_R ','labelpos','left');
        next_row(y);
        NumeditParam(obj, 'diff1', 12, x, y, 'label', 'Ratio Diff.', 'position', [x y 100 20], 'labelpos', 'left');
        MenuParam(obj, 'probe1', {'on', 'off'},2, x, y, 'position', [x+100, y, 100, 20],'label','probe','labelpos','left');
        next_row(y);
        MenuParam(obj, 'mix1', {'EB/Prop','Cav(+)/Cav(-)','Oct(+)/Oct(-)','none'},1, x, y,'label','Mixture 1  ','labelpos','left');
        next_row(y,1.5);

        % next define a bunch of solo variables to store parameters of all 3
        % mixtures.
        SoloParamHandle(obj, 'mix_names', 'value', {});
        SoloParamHandle(obj, 'probe_mix','value', []);
        SoloParamHandle(obj, 'mix_diff', 'value', []);
        SoloParamHandle(obj, 'bank_left', 'value', []); SoloParamHandle(obj, 'bank_right', 'value', []);
        SoloParamHandle(obj, 'chan_left', 'value', []); SoloParamHandle(obj, 'chan_right', 'value', []);
        %     SoloParamHandle(obj, 'valve_sets', 'value', []);
        mix_diff.value = [value(diff1); value(diff2); value(diff3)];

        DispParam(obj, 'bk_flow_L', 56, x,y, 'position', [x y 100 20], 'label','L_Flow  ','labelpos','left','labelfraction',0.7);
        DispParam(obj, 'bk_flow_R', 44, x,y, 'position', [x+100 y 100 20],'label','R_Flow  ','labelpos','left','labelfraction',0.7);
        next_row(y);
        DispParam(obj, 'L_valve', 1, x, y, 'position', [x y 100 20],'label','L_Ch_ID  ', 'labelpos', 'left','labelfraction',0.7);
        DispParam(obj, 'R_valve', 2, x, y, 'position', [x+100 y 100 20],'label', 'R_Ch_ID  ', 'labelpos', 'left','labelfraction',0.7);
        next_row(y);
        DispParam(obj, 'bk_L', banks(1), x, y, 'position', [x y 100 20], 'label', 'L_Bank  ', 'labelpos', 'left', 'labelfraction', 0.7);
        DispParam(obj, 'bk_R', banks(2), x, y, 'position', [x+100 y 100 20], 'label', 'R_Bank  ', 'labelpos', 'left', 'labelfraction', 0.7);
        next_row(y);

        % SoloParamHandle(obj, 'active_valve', 'value', 0);  % determined by side_list

        DispParam(obj, 'mix_name','EB/Prop', x, y,'position', [x y 100 20],'labelpos','left');
        DispParam(obj, 'curr_diff', 12, x, y, 'position', [x+100 y 100 20], 'labelpos','left');
        next_row(y);
        MenuParam(obj, 'mix_ID', {1,2,3}, 1, x, y, 'position', [x y 150 20],...
            'label','Current Mixture','labelpos', 'left', 'labelfraction',0.7);
        SoloFunctionAddVars('BlockControl', 'ro_args', {'mix_names'});
        SoloFunctionAddVars('BlockControl', 'rw_args', {'curr_diff','mix_ID','L_valve','R_valve'});
        SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'mix_ID','bk_L','bk_R','L_valve','R_valve'});

        set_callback({mix_ID}, {'BlockControl', 'user_specify'});
        set_callback({mix1,mix2,mix3, diff1, diff2, diff3,  probe1,probe2,probe3...
            bk1_L,bk2_L,bk3_L,bk1_R,bk2_R,bk3_R, ch1_L,ch2_L,ch3_L, ch1_R,ch2_R,ch3_R}, {mfilename, 'write_olf'});

        %     SoloParamHandle(obj, 'slp', 'value', 0);   % The slopes and intercepts for calibrating the flow controller
        %     SoloParamHandle(obj, 'intc', 'value', 0);

        x = oldx; y = oldy; figure(fig);
%        set_callback({Olf_Meter}, {'OdorSection', 'view'});

        % going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

        SoloParamHandle(obj, 'carrier_id', 'value', carriers);
        next_row(y);
        % OdorSection(obj, 'update_odor');
        OdorSection(obj, 'write_olf');

    case 'write_olf'
        %odor_flow = 1000 - value(Carrier3_FR);
        mix_names.value = {value(mix1), value(mix2), value(mix3)};
        mix_names(strcmp(value(mix_names), 'none'))= [];
        mix_diff.value = [value(diff1) value(diff2) value(diff3)];
        probe_mix.value = [];
        for i = 1:length(value(mix_diff)) % determine which mix is for probe trial
            if strcmp(value(eval(['probe' num2str(i)])), 'on')
                probe_mix.value = [value(probe_mix) i];
            end;
        end;
        % Determine whether next would be probe trial
        if ismember(value(mix_ID), value(probe_mix))
            WaterDelivery.value = 4; % 'probe'
        else
        %    WaterDelivery.value = 3; % 'only if nxt pk correct'
        end;

        bank_left.value = [value(bk1_L) value(bk2_L) value(bk3_L)];
        bank_right.value = [value(bk1_R) value(bk2_R) value(bk3_R)];
        chan_left.value = [value(ch1_L) value(ch2_L) value(ch3_L)];
        chan_right.value = [value(ch1_R) value(ch2_R) value(ch3_R)];

        curr_diff.value = mix_diff(value(mix_ID)); mix_name.value = mix_names{value(mix_ID)};

        bk_L.value = bank_left(value(mix_ID)); bk_R.value = bank_right(value(mix_ID));
        L_valve.value = chan_left(value(mix_ID)); R_valve.value = chan_right(value(mix_ID));

        side = side_list(n_done_trials+1);
        left = get_generic('side_list_left');
        if side == left
            L_valve.value = chan_left(value(mix_ID));
            bk_flow_L.value = 50 + value(curr_diff)/2;
            bk_flow_R.value = 100 - value(bk_flow_L);
            %  active_valve.value = value(L_valve);
        elseif side == 1-left
            R_valve.value = chan_right(value(mix_ID));
            bk_flow_L.value = 50 - value(curr_diff)/2;
            bk_flow_R.value = 100 - value(bk_flow_L);
            %   active_valve.value = value(R_valve);
        end;
       %{
       % next decide the command flow_rate according to coefficients of
       % calibration.
       bk_flow_L.value = bk_flow_L*slp(value(bk_L))+intc(value(bk_L));
       bk_flow_R.value = bk_flow_R*slp(value(bk_R))+intc(value(bk_R));
       %}
       carrier_flow = 900;
       if ~strcmpi(value(OLF_IP), 'nan'), % if the olfactometer is connectable
              Write(olf, ['Carrier' num2str(value(carrier_id)) '_Actuator'], carrier_flow);
              Write(olf, ['BankFlow' num2str(value(bk_L)) '_Actuator'], value(bk_flow_L));
              Write(olf, ['BankFlow' num2str(value(bk_R)) '_Actuator'], value(bk_flow_R));
       end

   case 'update_odor'
      % Background and odor valve ID are specified and updated in
      % BlockControl.m
      blk = value(block_count); % just for easy typing
      if strcmp(value(block_update),'interlv') && ~value(userspecify)
        % Bgrds are randomly presented. Chose the first one of a random pool
        % as next bg_ID. Then eliminate the first component.
          mix_ID.value = randrepeatpool(1);
          randrepeatpool(1) = [];
          if size(value(randrepeatpool),2) < 1
              block_update.value = 2;
          end;
      else
          mix_ID.value = block(blk).mix_id;
          userspecify.value = 0;
      end

      % Determine the odor valve ID to be opened.
      % effective_valve_set = valve_set{value(active_bank)};

      % randomly choose one of 4 caditate valve ids for either left or
      % right odors.
      % kl = size(valve_sets{value(mix_ID)}{1},2);
      % v_idx_L = ceil(kl.*rand);
      % kr = size(valve_sets{value(mix_ID)}{2},2);
      % v_idx_R = ceil(kr.*rand);


      
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
    otherwise,
        error(['Don''t know how to handle action ' action]);

end;


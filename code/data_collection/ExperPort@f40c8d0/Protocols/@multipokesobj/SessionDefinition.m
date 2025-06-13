function [] = SessionDefinition(obj, action, x, y)
%
% ro_args = fig;

GetSoloFunctionArgs;

switch action
    case 'init'   % ------- CASE 'INIT' ----------
        figure(value(myfig));
        parentfig_x = x; parentfig_y =  y;
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);

        ToggleParam(obj, 'session_show', 0, x, y, ...
                    'position', [x y 100 20], ...
                    'label', 'Session Ctrl show', 'TooltipString', ...
                    'Show/hide SessionModel window'); next_row(y);
        set_callback(session_show, {'SessionDefinition','hide_show'});
        
        SoloParamHandle(obj, 'nopoke_trials',   'value', 0);
        SoloParamHandle(obj, 'poke_trials',     'value', 0);
        SoloParamHandle(obj, 'good_streak',     'value', 0);
        SoloParamHandle(obj, 'reminder_starts', 'value', []);
        
        % new popup window
        SoloParamHandle(obj, 'sessionfig', 'value', figure, 'saveable', 0);
        x = 5; y = 5;   % coordinates for popup window

        set(value(sessionfig), 'Position', [3 100 720 400], 'Menubar', 'none', 'Toolbar', 'none');
        set(value(sessionfig),'CloseRequestFcn','');
        PushbuttonParam(obj, 'reinit', 200, 3, 'position', [400 10 70 20]);
        set_callback(reinit, {'SessionDefinition', 'reinit'});

        PushbuttonParam(obj, 'insert_from_file', 350, 10, 'position', ...
                        [495, 10, 100, 20]);
        set_callback(insert_from_file, {mfilename, 'insert_from_file'});
        PushbuttonParam(obj, 'save_to_file', 480, 10, 'position', ...
                        [605, 10, 100, 20]);
        set_callback(save_to_file, {mfilename, 'save_to_file'});
        next_row(y, 0.5);

        % Top Left-hand side: Show all available variables
        SubheaderParam(obj, 'var_hdr', 'Parameters', 0, 0);
        set(get_ghandle(var_hdr), 'Position', [5 370 200 20]);
        ListboxParam(obj, 'var_names', GetSoloFunctionArgList(['@' class(obj)], 'SessionModel'), 1, x, y, ...
            'position', [5 260 250 100]);
        set(get_ghandle(var_names), 'BackgroundColor', 'w');
        PushbuttonParam(obj,'add_var_btn', 0, 0, 'label', '+');
        set(get_ghandle(add_var_btn), 'Position', [200 370 30 20],'BackgroundColor', 'g', 'FontWeight','bold', 'FontSize', 11);
        set_callback(add_var_btn, {'SessionDefinition', 'add_var'});

        % Top Right-hand side: Display training stages
        SubheaderParam(obj, 'list_hdr', 'Training Stages', 0, 0);
        set(get_ghandle(list_hdr), 'Position', [290 370 350 20], 'FontSize', 9);
        ListboxParam(obj, 'train_list', {'#1', '#2', '#3'}, 1, 0, 0);
        set(get_ghandle(train_list), 'Position', [290 260 350 100], ...
                          'FontSize', 9); 
        set_callback(train_list, {mfilename, 'train_list'});
        
        % Bottom: Show training string
        TextBoxParam(obj, 'train_string_display', '', 20, 10, 'labelpos', 'top', 'nlines', 20, 'label', '***');
        set(get_ghandle(train_string_display), 'Position', [10 50 600 180], 'HorizontalAlignment', 'left');
        set(get_lhandle(train_string_display), 'Position', [10 230 300 20]);

        % Buttons at bottom:
        ToggleParam(obj, 'show_train', 0, 0, 0, 'label', 'Training string');
        set(get_ghandle(show_train), 'Position', [5 20 100 20], 'FontSize', 9, 'FontWeight','bold');
        set_callback(show_train, {'SessionDefinition', 'show_train_string'});

        ToggleParam(obj, 'show_complete', 0, 0, 0, 'label', 'Completion Test');
        set(get_ghandle(show_complete), 'Position', [105 20 100 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_complete, {'SessionDefinition', 'show_complete_string'});
        
        ToggleParam(obj, 'show_name', 0, 0, 0, 'label', 'Name');
        set(get_ghandle(show_name), 'Position', [205 20 85 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_name, {'SessionDefinition', 'show_name'});

        ToggleParam(obj, 'show_vars', 0, 0, 0, 'label', 'Vars');
        set(get_ghandle(show_vars), 'Position', [290 20 85 20],'FontSize', 9, 'FontWeight', 'bold');
        set_callback(show_vars, {'SessionDefinition', 'show_vars'});
        
        PushButtonParam(obj, 'add_string', 0, 0, 'label', '+');
        set(get_ghandle(add_string), 'Position', [350 230 40 20], 'FontAngle','italic', 'FontSize', 10, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(add_string, {'SessionDefinition', 'add'});

        PushButtonParam(obj, 'update_string', 0, 0, 'label', 'U');
        set(get_ghandle(update_string), 'Position', [400 230 40 20], 'FontAngle','italic', 'FontSize', 10, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(update_string, {'SessionDefinition', 'test_update'});

        PushButtonParam(obj, 'delete_string', 0, 0, 'label', '-');
        set(get_ghandle(delete_string), 'Position', [450 230 40 20], 'FontAngle','italic', 'FontSize', 10, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(delete_string, {'SessionDefinition', 'delete_stage'});

        PushButtonParam(obj, 'flush_string', 0, 0, 'label', 'FLUSH');
        set(get_ghandle(flush_string), 'Position', [500 230 60 20], 'FontAngle','italic', 'FontSize', 10, 'BackgroundColor', [0.8 0 0.2], 'ForegroundColor', 'w');
        set_callback(flush_string, {'SessionDefinition', 'flush_all'});
        
        PushButtonParam(obj, 'change_active_stage', 0, 0, 'label', ...
                        'Change Active Stage');
        set(get_ghandle(change_active_stage), 'Position', [570 230 100 20],...
                       'FontAngle','italic', 'FontSize', 10, ...
                       'BackgroundColor', [0.8 0 0.2], 'ForegroundColor','w');
        set_callback(change_active_stage, ...
                     {'SessionDefinition', 'change_active_stage'});


        SoloParamHandle(obj, 'display_type', 'value', 0);
        SoloParamHandle(obj, 'training_stages', 'value', {}, 'type', 'saveable_nonui');
        set_callback(training_stages, {'SessionDefinition', 'define_train_stages'});

        SoloParamHandle(obj, 'active_stage', 'value', 0, 'type','saveable_nonui');
        set_callback(active_stage, {'SessionDefinition', 'set_active_stage'});

        sm = SessionModel('param_owner', obj);
        SoloParamHandle(obj, 'my_session_model', 'value', sm, 'saveable', 0);

        SoloParamHandle(obj, 'last_file_loaded', 'value', '', 'type', ...
                        'saveable_nonui');
        
        % finally, tracker variables that can be used by the autoset
        % strings
        SoloParamHandle(obj, 'last_change', 'value', 0);
        SoloParamHandle(obj, 'practice_tracker','value', 0);       
        SoloParamHandle(obj, 'last_change_tracker', 'value', zeros(1000,1)); 
        SoloParamHandle(obj, 'stay_here','value', 0);       
        SoloParamHandle(obj, 'stay_here_tracker', 'value', zeros(1000,1)); 
        
        x = parentfig_x; y = parentfig_y;
        set(0,'CurrentFigure', value(myfig));

        SessionDefinition(obj,'define_train_stages');
        SessionDefinition(obj,'hide_show');
   
        
        
     % --------- CASE DEFINE_TRAIN_STAGES  ------------------------------------
        
    case 'define_train_stages',
        ts = value(training_stages);
        sm = value(my_session_model);
        my_session_model.value = remove_all_training_stages(sm);
        sm = value(my_session_model);

        if ~isempty(ts)
          my_session_model.value = add_training_stage_many(sm, value(training_stages));          
        end;
        SessionDefinition(obj,'mark_complete');

        
     % --------- CASE MARK_COMPLETE  ------------------------------------
 
    case 'mark_complete'
        sm = value(my_session_model);
        ts = get_training_stages(sm);

        if ~isempty(ts)
            curr = get_current_training_stage(sm);
            str = cell(0,0);
            for r = 1:rows(ts)
                str{r,1} = ['#' num2str(r) ': ' ts{r,4}];
                if ts{r,3} > 0, str{r,1} = [str{r,1} '   (Complete)'];end;
            end;
            if curr <= rows(ts)
                str{curr,1} = ['#' num2str(curr) ': ' ts{curr,4} '  (ACTIVE)'];
            end;
        else
            str = '-- No training stages currently specified --';
        end;

        if get(get_ghandle(train_list), 'Value') > rows(str)    % last value deleted
            set(get_ghandle(train_list), 'Value', rows(str));
        end;
        set(get_ghandle(train_list),'String', str);
        val = get(get_ghandle(train_list), 'Value');        
       
        if value(display_type) == 1
           set(get_lhandle(train_string_display), 'String', ['Showing: Stage #' num2str(val) ': Training string']);
           if ~isempty(ts), 
              set(get_ghandle(train_string_display), 'String', ts{val, 1});
           end;
        elseif value(display_type) == 2
           set(get_lhandle(train_string_display), 'String', ...
                   ['Showing: Stage #' num2str(val) ': Completion string']);
           if ~isempty(ts), 
              set(get_ghandle(train_string_display), 'String', ts{val, 2});
           end;
        end;

        
        
     % --------- CASE NEXT_TRIAL  ------------------------------------
 
        
   case 'next_trial'
        
   
        sm = compute_next_trial(value(my_session_model));
        my_session_model.value = sm;
        training_stages.value = get_training_stages(sm);
        active_stage.value = get_current_training_stage(sm);
        SessionDefinition(obj, 'mark_complete');

        
     % --------- CASE ADD_VAR  ------------------------------------
 
        
    case 'add_var'
        str = value(train_string_display);
        temp = str(rows(str),:);
        if rows(str) == 1
            str = [temp ' ' value(var_names)];
        else
            str = char(str(1:end-1,:), [temp ' ' value(var_names)]);
        end;
        train_string_display.value = str;


     % --------- CASE TRAIN_LIST  ------------------------------------
        
 case 'train_list',
   switch value(display_type),
    case 1,
      feval(mfilename, obj, 'show_train_string');
      
    case 2, 
      feval(mfilename, obj, 'show_complete_string');

    case 4,
      feval(mfilename, obj, 'show_name');
    
    case 5,
      feval(mfilename, obj, 'show_vars');
    
    otherwise,
      fprintf(1,'\n\nSessionDefinition: don''t know display type %g!!!\n\n',...
              value(display_type));
   end;
   
    
              
    % --------- CASE SHOW_TRAIN_STRING  ------------------------------------
 
        
    case 'show_train_string'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,1}; end;
        display_type.value = 1;
        set(get_lhandle(train_string_display), 'String', ...
                          ['Showing: Stage #' num2str(v) ': Training string']);
        show_train.value = 1; show_complete.value = 0; 
        show_name.value  = 0; show_vars.value     = 0;
        
     % --------- CASE SHOW_COMPLETE_STRING  ---------------------------------
         
        
    case 'show_complete_string'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,2}; end;
        display_type.value = 2;
        set(get_lhandle(train_string_display), 'String', ...
                       ['Showing: Stage #' num2str(v) ': Completion string']);
        show_train.value = 0; show_complete.value = 1;
        show_name.value  = 0; show_vars.value     = 0;

        
    % --------- CASE SHOW_NAME ---------------------------------   
            
    case 'show_name'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,4}; end;
        display_type.value = 4;
        set(get_lhandle(train_string_display), 'String', ...
                          ['Showing: Stage #' num2str(v) ': Name']);        
        show_train.value = 0; show_complete.value = 0;
        show_name.value  = 1; show_vars.value     = 0;


    % --------- CASE SHOW_VARS ---------------------------------   
            
    case 'show_vars'
        v = get(get_ghandle(train_list),'Value');
        val = value(my_session_model); ts = get_training_stages(val);
        if ~isempty(ts), train_string_display.value = ts{v,5}; end;
        display_type.value = 5;
        set(get_lhandle(train_string_display), 'String', ...
                          ['Showing: Stage #' num2str(v) ': Vars']);        
        show_train.value = 0; show_complete.value = 0; 
        show_name.value  = 0; show_vars.value     = 1;

        
    % --------- CASE ADD ---------------------------------   
            
    case 'add'
        sm = value(my_session_model);
        ts = get_training_stages(sm);
        new_num = rows(ts) + 1;
        ans = questdlg(['Are you SURE you wish to add training string #' num2str(new_num) '?'], ...
            ['Adding training string #' num2str(new_num)], 'Yes', 'No', 'Yes');

        if strcmpi(ans, 'yes')
            sm = value(my_session_model);
            my_session_model.value = add_training_stage(sm, 'train_string', value(train_string_display));
            SessionDefinition(obj, 'mark_complete');
            msgbox({'Addition successful!', '', 'To add a completion string:', ...
                '1. Click ''Completion Test''.',...
                '2. Type a statement that evaluates to TRUE when the training stage is complete.', ...
                '3. Click the ''UPDATE'' button. Do NOT click ''add''!'}, 'To add a Completion Test');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));            
        end;

        
    % --------- CASE TEST_UPDATE ---------------------------------   

        
    case 'test_update'
        lnum = get(get_ghandle(train_list),'Value');
        if value(display_type) == 0,
            errordlg('Nothing to update!', 'Not a recognised training/completion string');
            return;
        elseif value(display_type) == 1,
            update_type = 'training string';
            utype = 'train_string';
        elseif value(display_type) == 2,
            update_type = 'completion string';
            utype = 'completion_string';
        elseif value(display_type) == 4,
            update_type = 'the name for';
            utype = 'name';
        elseif value(display_type) == 5,
            update_type = 'the vars for';
            utype = 'vars';
        end;

        ans = questdlg(['Are you SURE you wish to update ' update_type ' #' num2str(lnum) '?'], ...
            ['Updating ' update_type ' #' num2str(lnum)], 'Yes', 'No', 'Yes');

        if strcmpi(ans, 'yes')
            my_session_model.value = ...
                update_training_stage(value(my_session_model), lnum, ...
                value(train_string_display), 'utype', utype);
            msgbox('Update successful!', 'Confirmation');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
            if strcmpi(utype,'name'),
               SessionDefinition(obj,'mark_complete');
            end;
        end;

        
        
    % --------- CASE DELETE_STAGE ---------------------------------   

        
    case 'delete_stage'
        lnum = get(get_ghandle(train_list),'Value');
        ans = questdlg(['Are you SURE you wish to delete stage #' num2str(lnum) '?'], ...
            ['DELETE stage #' num2str(lnum)], 'Yes', 'No', 'No');

        if strcmpi(ans, 'yes')
            sm = value(my_session_model);
            my_session_model.value = remove_training_stage(sm, lnum);
            SessionDefinition(obj, 'mark_complete');
            msgbox({'Deletion successful!', '', ['The active stage is now: #' num2str(get_current_training_stage(sm))]}, ...
                'Deletion successful');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
        end;

        
        
    % --------- CASE FLUSH_ALL ---------------------------------   
        
    case 'flush_all'
        ans = questdlg({'Are you SURE you wish to DELETE ALL training stages??', ...
            'This action cannot be undone!'}, ...
            ['DELETE ALL STAGES'], 'Yes', 'No', 'No');

        if strcmpi(ans, 'yes')
            sm = value(my_session_model);
            my_session_model.value = remove_all_training_stages(sm);
            SessionDefinition(obj, 'mark_complete');
            msgbox('All training stages have been successfully deleted.', ...
                'Deletion successful');
            training_stages.value = get_training_stages(value(my_session_model));
            active_stage.value = get_current_training_stage(value(my_session_model));
        end;

        
    % --------- CASE SET_ACTIVE_STAGE ---------------------------------   
        
        
    case 'set_active_stage',
        sm = value(my_session_model);
        sm = set_current_training_stage(sm, value(active_stage));
        my_session_model.value = sm;
        SessionDefinition(obj, 'mark_complete');
        
        
    % --------- CASE CHANGE_ACTIVE_STAGE ---------------------------------   
        
    case 'change_active_stage'

      v = get(get_ghandle(train_list),'Value');
      
      ans = questdlg({['Are you SURE you wish to make STAGE #' num2str(v) ...
                       ' the ACTIVE stage?'], ...
                      'This action cannot be undone!'}, ...
                     ['CHANGE ACTIVE STAGE'], 'Yes', 'No', 'No');
      
      if strcmpi(ans, 'yes')
         sm = value(my_session_model);
         my_session_model.value = jump(sm, 'to', v);
         training_stages.value =get_training_stages(value(my_session_model));
         active_stage.value = ...
             get_current_training_stage(value(my_session_model));         
         SessionDefinition(obj, 'mark_complete');
      end;

        
    % --------- CASE HIDE_SHOW ---------------------------------   
        
    case 'hide_show'
        if session_show==1          
            set(value(sessionfig), 'Visible', 'on');
        else
            set(value(sessionfig),'Visible','off');
         
        end;
        
        
    % --------- CASE REINIT ---------------------------------   
    
    case 'reinit',
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        delete(value(sessionfig));
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        feval(mfilename, obj, 'init', x, y);

     
    % --------- CASE INSERT_FROM_FILE ---------------------------------   
        
   case 'insert_from_file',
     if isempty(value(last_file_loaded)),
        [fname, pname] = uigetfile({'*.m'}, 'Insert from file');
     else
        [fname, pname] = uigetfile({'*.m'}, 'Insert from file', ...
                                   value(last_file_loaded)); 
     end;
     if fname,
        try,           
           sm = load_from_file(value(my_session_model), [pname fname]);
           last_file_loaded.value = [pname fname];
        catch,
           lasterr,
           return;
        end;
        training_stages.value = get_training_stages(sm);
        feval(mfilename, obj, 'define_train_stages');
        feval(mfilename, obj, 'show_train_string');
     end;

        
    % --------- CASE SAVE_TO_FILE ---------------------------------   
        
   case 'save_to_file',
     if isempty(value(last_file_loaded)),
        [fname, pname] = uiputfile({'*.m'}, 'Save to file');
     else
        [fname, pname] = uiputfile({'*.m'}, 'Save to file', ...
                                   value(last_file_loaded)); 
     end;
     if fname,
        try,           
           write_to_file(value(my_session_model), [pname fname]);
           last_file_loaded.value = [pname fname];
        catch,
           lasterr,
           return;
        end;
     end;

        
    % --------- CASE DELETE ---------------------------------   
        
    case 'delete'            ,
        delete(value(sessionfig));
        
     % ---------------------------------------------
     %
     % ---------------------------------------------
        
    otherwise
        error('Unknown action');
end;

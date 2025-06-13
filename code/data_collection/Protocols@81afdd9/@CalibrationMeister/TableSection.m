function [] = TableSection(obj, action)
    GetSoloFunctionArgs(obj);
    switch action
        case 'init'            
            btnFlushToday_pos=[100 10];
            btnFlushToday_size=[110 30];
            btnFlushToday_font_size=12;
            btnFlushToday_bgcolor=[51 117 156]/255;
            btnFlushToday_fgcolor=[0 0 0];
            btnFlushToday_string='Simple Flush';
            
            btnFlushAll_pos=[210 10];
            btnFlushAll_size=[110 30];
            btnFlushAll_font_size=12;
            btnFlushAll_bgcolor=[202 128 38]/255;
            btnFlushAll_fgcolor=[0 0 0];
            btnFlushAll_string='Deep Flush';
            
            btnValidateEntry_pos=[520 10];
            btnValidateEntry_size=[200 25];
            btnValidateEntry_font_size=12;
            btnValidateEntry_bgcolor=[64 185 42]/255;
            btnValidateEntry_fgcolor=[0 0 0];
            btnValidateEntry_string='Validate Selected Entry';
            
            btnInvalidateEntry_pos=[720 10];
            btnInvalidateEntry_size=[200 25];
            btnInvalidateEntry_font_size=12;
            btnInvalidateEntry_bgcolor=[221 52 42]/255;
            btnInvalidateEntry_fgcolor=[0 0 0];
            btnInvalidateEntry_string='Invalidate Selected Entry';
            
            SoloParamHandle(obj,'btnWaterTable_size','value',[150 25]);
            SoloParamHandle(obj,'btnWaterTable_font_size','value',12);
            SoloParamHandle(obj,'btnWaterTable_show_bgcolor','value',[51 117 156]/255);
            SoloParamHandle(obj,'btnWaterTable_hide_bgcolor','value',[29 61 70]/255);
            SoloParamHandle(obj,'btnWaterTable_fgcolor','value',[0 0 0]);
            
            extWaterTable_pos=[10 60];
            extWaterTable_size=[1028 335];
            extWaterTable_font_type='Courier';
            extWaterTable_font_size=12;
            
            fig_pos=[500 200];
            fig_width_height=[1040 400];
            fig_name='WATER TABLE';
            fig_bgcolor=[51 155 106]/255;

            ToggleParam(obj, 'btnWaterTable', 0, 300, 20, 'OnString', 'Showing Water Table', ...
                'OffString', 'Hiding Water Table');
            mh=get_ghandle(btnWaterTable);
            set(mh,'FontSize', value(btnWaterTable_font_size),'BackgroundColor', value(btnWaterTable_hide_bgcolor),'ForegroundColor',value(btnWaterTable_fgcolor));
            set_callback(btnWaterTable, {mfilename, 'showhide'});
            
            SoloParamHandle(obj, 'myfig', 'value', ...
                figure('Position',[fig_pos fig_width_height],'MenuBar','none','Name',fig_name,'Resize','off', 'CloseRequestFcn',...
                [mfilename '(' class(obj) ', ''hide'')'], 'MenuBar', 'none','Color',fig_bgcolor), 'saveable', 0);
            
            % Create Water Table: Start
            ListboxParam(obj, 'extWaterTable', {''}, 1, 600, 45, 'position', [extWaterTable_pos extWaterTable_size], 'FontName', extWaterTable_font_type, ...
                'FontSize', extWaterTable_font_size, 'saveable', 0);
            % Create Water Table: Stop
            
            PushbuttonParam(obj, 'btnFlushToday', 150, 250, 'TooltipString', 'Flushes all calibration data of this rig belonging to today ONLY');
            mh=get_ghandle(btnFlushToday);
            set(mh,'Position', [btnFlushToday_pos btnFlushToday_size],'FontSize', btnFlushToday_font_size,...
                'String', btnFlushToday_string,'BackgroundColor', btnFlushToday_bgcolor,'ForegroundColor',btnFlushToday_fgcolor);
            set_callback(btnFlushToday,{mfilename,'flushTodayCalibData'});
            
            PushbuttonParam(obj, 'btnFlushAll', 150, 250, 'TooltipString', 'Flushes all calibration data of this rig since inception. RISKY!!!');
            mh=get_ghandle(btnFlushAll);
            set(mh,'ButtonDownFcn','','Position', [btnFlushAll_pos btnFlushAll_size],'FontSize', btnFlushAll_font_size,...
                'String', btnFlushAll_string,'BackgroundColor', btnFlushAll_bgcolor,'ForegroundColor',btnFlushAll_fgcolor);
            set_callback(btnFlushAll,{mfilename,'flushAllCalibData'});
            
            PushbuttonParam(obj, 'btnValidateEntry', 150, 250, 'TooltipString', 'Validates the selected entry.');
            mh=get_ghandle(btnValidateEntry);
            set(mh,'ButtonDownFcn','','Position', [btnValidateEntry_pos btnValidateEntry_size],'FontSize', btnValidateEntry_font_size,...
                'String', btnValidateEntry_string,'BackgroundColor', btnValidateEntry_bgcolor,'ForegroundColor',btnValidateEntry_fgcolor);
            set_callback(btnValidateEntry,{mfilename,'validateCalibEntry'});
            
            PushbuttonParam(obj, 'btnInvalidateEntry', 150, 250, 'TooltipString', 'Invalidates the selected entry.');
            mh=get_ghandle(btnInvalidateEntry);
            set(mh,'ButtonDownFcn','','Position', [btnInvalidateEntry_pos btnInvalidateEntry_size],'FontSize', btnInvalidateEntry_font_size,...
                'String', btnInvalidateEntry_string,'BackgroundColor', btnInvalidateEntry_bgcolor,'ForegroundColor',btnInvalidateEntry_fgcolor);
            set_callback(btnInvalidateEntry,{mfilename,'invalidateCalibEntry'});
            
            SoloParamHandle(obj,'user_override','value',0);
            
            SoloFunctionAddVars('CalibrationMeister','rw_args',{'btnWaterTable'});
            SoloFunctionAddVars('setDefaultPulseTime','ro_args',{'user_override'});

            set(value(myfig), 'Visible', 'off');
            
        case 'refreshTable'
            formatstring='| %6s | %4s | %20s | %6s | %10s | %11s | %7s | %4s | %6s |';
            WaterCalibrationTableStr{1} = sprintf(formatstring, '#ID','User', 'Date', 'Valve', 'Time(secs)', [char(hex2dec('B5')), 'L/Dispense'], 'IsValid','Type','Target');
            WaterCalibrationTableStr{2}=sprintf('------------------------------------------------------------------------------------------------------');
            sqlstr=sprintf('select count(*) as num_records from bdata.new_calibration_info_tbl where rig_id="%s" and datediff(curdate(),dateval)<%d',value(rig_id),value(calib_data_history));
            num_records=bdata(sqlstr);
            
            if num_records>0
                booleanstr = {'no', 'yes'};
                sqlstr=sprintf('select calibrationid,initials,dateval,valve,timeval,dispense,isvalid,validity,target from bdata.new_calibration_info_tbl where rig_id="%s" and datediff(curdate(),dateval)<%d order by dateval desc',value(rig_id),value(calib_data_history));
                [id,user,date,valve,dispense_time,dispense_amount,isvalid,validity,target]=bdata(sqlstr);
                for i=1:length(id)
                    if strcmpi(valve(i),'left1water')
                        valve{i}='LEFT';
                    elseif strcmpi(valve(i),'right1water')
                        valve{i}='RIGHT';
                    elseif strcmpi(valve(i),'center1water')
                        valve{i}='CENTER';
                    end
                    WaterCalibrationTableStr{i+2}=sprintf(formatstring,num2str(id(i)),user{i},strtrim(datestr(date(i))),strtrim(valve{i}),strtrim(num2str(dispense_time(i))),strtrim(num2str(dispense_amount(i))),booleanstr{isvalid(i)+1},strtrim(validity{i}),strtrim(target{i}));
                end
            end
            set(get_ghandle(extWaterTable), 'string', WaterCalibrationTableStr);
            extWaterTable.value=length(WaterCalibrationTableStr);
            
        case 'showhide'
            if btnWaterTable==1,  %#ok<NODEF>
                mh=get_ghandle(btnWaterTable);
                set(mh,'FontSize', value(btnWaterTable_font_size),'BackgroundColor', value(btnWaterTable_show_bgcolor),'ForegroundColor',value(btnWaterTable_fgcolor));
                feval(mfilename, obj, 'refreshTable');
                set(value(myfig), 'Visible', 'on');
            else
                mh=get_ghandle(btnWaterTable);
                set(mh,'FontSize', value(btnWaterTable_font_size),'BackgroundColor', value(btnWaterTable_hide_bgcolor),'ForegroundColor',value(btnWaterTable_fgcolor));
                set(value(myfig), 'Visible', 'off');
            end;
            
            %% case hide
        case 'hide'
            btnWaterTable.value = 0;
            mh=get_ghandle(btnWaterTable);
            set(mh,'FontSize', value(btnWaterTable_font_size),'BackgroundColor', value(btnWaterTable_hide_bgcolor),'ForegroundColor',value(btnWaterTable_fgcolor));
            set(value(myfig), 'Visible', 'off');
            
        case 'flushTodayCalibData'
            sqlstr=sprintf('select count(*) as num_records from bdata.new_calibration_info_tbl where rig_id="%s" and datediff(curdate(),dateval)=0',value(rig_id));
            num_records=bdata(sqlstr);
            if num_records>0
                questiontoAsk='Are you sure you want to flush today''s calibration data for this rig?';
                answer = questdlg(questiontoAsk, 'Confirmation', 'YES', 'NO', 'NO');
                if strcmpi(answer, 'YES')
                    sqlstr=sprintf('call bdata.flush_today_only("%s")',value(rig_id));
                    bdata(sqlstr);
                    feval(mfilename, obj, 'refreshTable');
                    CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
                    disable(btnCalibHighTarget);
                    enable(btnCalibLowTarget);
                    updateCalibrationStatusLabel(obj);
                    setDefaultPulseTime(obj);
                end
            end
        
        case 'flushAllCalibData'
            sqlstr=sprintf('select count(*) as num_records from bdata.new_calibration_info_tbl where rig_id="%s"',value(rig_id));
            num_records=bdata(sqlstr);
            if num_records>0
                questiontoAsk='Are you sure you want to flush the entire calibration data for this rig?';
                answer = questdlg(questiontoAsk, 'Confirmation', 'YES', 'NO', 'NO');
                if strcmpi(answer, 'YES')
                    sqlstr=sprintf('call bdata.flush_all_calib_info("%s")',value(rig_id));
                    bdata(sqlstr);
                    feval(mfilename, obj, 'refreshTable');
                    CALIBRATION_HIGH_OR_LOW_CONST.value='LOW';
                    disable(btnCalibHighTarget);
                    enable(btnCalibLowTarget);
                    updateCalibrationStatusLabel(obj);
                    setDefaultPulseTime(obj);
                end
            end
            
        case 'validateCalibEntry'
            isvalid=1;
            listbox_complete_string=get(get_ghandle(extWaterTable), 'string');
            listbox_selected_value=get(get_ghandle(extWaterTable), 'value');
            if listbox_selected_value>2
                listbox_selected_item=char(listbox_complete_string(listbox_selected_value));
                calibrationid=str2num(listbox_selected_item(2:8));
                sqlstr=sprintf('call bdata.set_calib_flags(%d,%d)',calibrationid,isvalid);
                bdata(sqlstr);
                feval(mfilename, obj, 'refreshTable');
                user_override.value=1;
                setDefaultPulseTime(obj);
                user_override.value=0;
                updateCalibrationStatusLabel(obj);
            end
            
        case 'invalidateCalibEntry'
            isvalid=0;
            listbox_complete_string=get(get_ghandle(extWaterTable), 'string');
            listbox_selected_value=get(get_ghandle(extWaterTable), 'value');
            if listbox_selected_value>2
                listbox_selected_item=char(listbox_complete_string(listbox_selected_value));
                calibrationid=str2num(listbox_selected_item(2:8));
                sqlstr=sprintf('call bdata.set_calib_flags(%d,%d)',calibrationid,isvalid);
                bdata(sqlstr);
                feval(mfilename, obj, 'refreshTable');
                user_override.value=1;
                setDefaultPulseTime(obj);
                user_override.value=0;
                updateCalibrationStatusLabel(obj);
            end
    end
end
function []=setDefaultPulseTime(obj)
    GetSoloFunctionArgs(obj);
    polyfit_degree=1;
    
    %Set all the variables: Start
    if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW')
        target_dispense=value(low_target_dispense);
    elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH')
        target_dispense=value(high_target_dispense);
    end

    valves_clogged=[NaN,NaN,NaN];
    valves_negslope=[NaN,NaN,NaN];
    valves_with_negative_pulsetime_estimates=[NaN,NaN,NaN];
    valves_est_pulse_times=[value(pulse_time_default),value(pulse_time_default),value(pulse_time_default)];
    %Set all the variables: Stop

    % Guess the pulse time based on 5-pass algorithm: Start
    for i=1:length(valves_names)
        if valves_used(i)
            sqlstr=sprintf('select timeval from bdata.new_calibration_info_tbl where datediff(curdate(),dateval)=0 and isvalid=1 and validity="PERM" and valve="%s" and target="%s" and rig_id="%s" having max(dateval)',valves_dionames{i},CALIBRATION_HIGH_OR_LOW_CONST,rig_id);
            [timeval]=bdata(sqlstr);
            if ~isempty(timeval) && length(timeval)==1
                valves_est_pulse_times(i)=timeval;
            else
                sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where datediff(curdate(),dateval)=0 and isvalid=1 and validity="TEMP" and valve="%s" and target="%s" and rig_id="%s"',valves_dionames{i},CALIBRATION_HIGH_OR_LOW_CONST,rig_id);
                [timeval,dispense]=bdata(sqlstr);
                if ~isempty(timeval)
                    if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW')
                        if length(timeval)==1 && ~value(user_override)% After getting the first low temp, invalidate all high temps, but subsequently the user can validate and use them
                            sqlstr=sprintf('call bdata.invalidate_temp_values("%s","HIGH","%s")',rig_id,valves_dionames{i}); % Instead of deleting invalidate the temp values of high target
                            bdata(sqlstr);
                        end
                        sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where datediff(curdate(),dateval)=0 and isvalid=1 and valve="%s" and target="HIGH" and rig_id="%s" having max(dateval)',valves_dionames{i},rig_id);
                        % This will end up fetching only the HIGH PERMs belonging to today by default
                    elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH')
                        if length(timeval)==1 && ~value(user_override)% After getting the first high temp, invalidate all low temps, but subsequently the user can validate and use them
                            sqlstr=sprintf('call bdata.invalidate_temp_values("%s","LOW","%s")',rig_id,valves_dionames{i}); % Instead of deleting invalidate the temp values of low target
                            bdata(sqlstr);
                        end
                        sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where datediff(curdate(),dateval)=0 and isvalid=1 and valve="%s" and target="LOW" and rig_id="%s" having max(dateval)',valves_dionames{i},rig_id);
                        % This will end up fetching only the LOW PERMs belonging to today  by default
                    end
                    TableSection(obj,'refreshTable');
                    [y,x]=bdata(sqlstr); % Now we get all valid values of the opposite target
                    y=[y timeval'];x=[x dispense']; % Merge all valid values of both targets
                    if length(x)==1 % If we still end up with one data point then interpolate using the origin
                        x=[0, dispense'];y=[0, timeval'];
                    end
                    p=polyfit(x,y,polyfit_degree);
                    valves_est_pulse_times(i)=polyval(p,target_dispense);
                else
                    if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'LOW')
                        sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where rig_id="%s" and valve="%s" and target="HIGH" and isvalid=1 and datediff(curdate(),dateval)=0',rig_id,valves_dionames{i});
                        [timeval,dispense]=bdata(sqlstr);
                        % Trying to find current day's high perms/temps to
                        % estimate low target pulse time. If we don't find
                        % them then we fetch most recent perms below (both high
                        % and low) to estimate low target pulse times.
                        if isempty(timeval)
                            sqlstr=sprintf('call bdata.get_recent_perm_valid_values("%s","%s")',rig_id,valves_dionames{i});
                            [timeval,dispense]=bdata(sqlstr);
                        end
                        if ~isempty(timeval)
                            x=[dispense'];y=[timeval'];
                            if length(x)==1
                                x=[0,dispense']; y=[0,timeval'];
                            end
                            p=polyfit(x,y,polyfit_degree);
                            valves_est_pulse_times(i)=polyval(p,target_dispense);
                        end
                    elseif strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH')
                        sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where rig_id="%s" and valve="%s" and target="LOW" and isvalid=1 and datediff(curdate(),dateval)=0',rig_id,valves_dionames{i});
                        [timeval,dispense]=bdata(sqlstr);
                        if ~isempty(timeval)
                            x=[dispense'];y=[timeval'];
                            if length(x)==1
                                x=[0,dispense']; y=[0,timeval'];
                            end
                            p=polyfit(x,y,polyfit_degree);
                            valves_est_pulse_times(i)=polyval(p,target_dispense);
                        end
                    end
                end
            end
        end 
        if strcmpi(value(CALIBRATION_HIGH_OR_LOW_CONST), 'HIGH')
            if valves_used(i)
                sqlstr=sprintf('select timeval,dispense from bdata.new_calibration_info_tbl where datediff(curdate(),dateval)=0 and isvalid=1 and validity="PERM" and valve="%s" and target="LOW" and rig_id="%s" having max(dateval)',valves_dionames{i},rig_id);
                [low_target_perm_time_val,low_target_perm_dispense]=bdata(sqlstr);
                if length(low_target_perm_time_val)==1
                    slope=(valves_est_pulse_times(i)-low_target_perm_time_val)/(target_dispense-low_target_perm_dispense);
                    if slope<0
                        valves_negslope(i)=1;
                    end
                end
            end
        end
        if valves_est_pulse_times(i)>value(pulse_time_upper_threshold)
            valves_clogged(i)=1;
        end
        if valves_est_pulse_times(i)<value(pulse_time_lower_threshold)
            valves_with_negative_pulsetime_estimates(i)=1;
        end
        if ~isnan(valves_clogged(i)) || ~isnan(valves_negslope(i)) || ~isnan(valves_with_negative_pulsetime_estimates(i))
            valves_est_pulse_times(i)=pulse_time_default;
            sqlstr=sprintf('call bdata.invalidate_temp_values("%s","%s","%s")',rig_id,CALIBRATION_HIGH_OR_LOW_CONST,valves_dionames{i});
            bdata(sqlstr);
            TableSection(obj,'refreshTable');
        end
    end
    % Guess the pulse time based on 5-pass algorithm: Stop

    %Insert the pulse times into the GUI: Start
    est_left_pulse_time.value=sprintf('%.3f',valves_est_pulse_times(1));
    est_center_pulse_time.value=sprintf('%.3f',valves_est_pulse_times(2));
    est_right_pulse_time.value=sprintf('%.3f',valves_est_pulse_times(3));
    %Insert the pulse times into the GUI: Stop

    % Create a warning message dialog if required: Start
    valves_neg_slope_warningstring='';
    valves_clogged_warningstring='';
    valves_with_negative_pulsetime_estimates_warning_string='';
    for i=1:length(valves_dionames)
        if valves_used(i)
            if ~isnan(valves_negslope(i))
                valves_neg_slope_warningstring=sprintf('%s %s',valves_neg_slope_warningstring,valves_names{i});
            end
            if ~isnan(valves_clogged(i))
                valves_clogged_warningstring=sprintf('%s %s',valves_clogged_warningstring,valves_names{i});
            end
            if ~isnan(valves_with_negative_pulsetime_estimates(i))
                valves_with_negative_pulsetime_estimates_warning_string=sprintf('%s %s',valves_with_negative_pulsetime_estimates_warning_string,valves_names{i});
            end
        end
    end

    if ~isempty(valves_neg_slope_warningstring)
        valves_neg_slope_warningstring=sprintf('Problem: Negative Slope warning for the following valve(s)- %s\nSolution: Calibrate carefully by entering proper weights!!!',valves_neg_slope_warningstring);
    end

    if ~isempty(valves_clogged_warningstring)
        valves_clogged_warningstring=sprintf('Problem: The following valve(s) might be clogged- %s\nSolution: Clean the valve(s) before proceeding and enter proper weights!!!',valves_clogged_warningstring);
    end

    if ~isempty(valves_with_negative_pulsetime_estimates_warning_string)
        valves_with_negative_pulsetime_estimates_warning_string=sprintf('Problem: Negative Pulse Time warning for the following valve(s)- %s.\nThe pulse times are reset to default values. Be careful while entering the weights',valves_with_negative_pulsetime_estimates_warning_string);
    end

    complete_warningstring=strtrim(sprintf('%s\n%s\n%s',valves_neg_slope_warningstring,valves_clogged_warningstring,valves_with_negative_pulsetime_estimates_warning_string));

    if ~isempty(complete_warningstring)
        waitfor(warndlg(complete_warningstring,'Warning','modal'));
    end
    % Create a warning message dialog if required: Stop
end
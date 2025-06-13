% various callbacks related to  flow controller calibration

function [] = fc_callbacks(obj, action)

GetSoloFunctionArgs;

switch action
    
    case 'reset_flow' % reset the flow rate (to 0)

        flow_rate.value = 0;
        
        
    case 'increment_voltage' % add current entry to table; increase the voltage by the voltage increment
        
         add_calibration_pair(obj);
        
         desired_voltage = value(voltage) + value(voltage_increment);
         
         if desired_voltage <= 5 % 5 is the max voltage
             voltage.value = desired_voltage;
             fc_callbacks(obj, 'reset_flow');
         end


    case 'check_previous' % check the previously saved calibration table for this flow controller

        % get name of machine
        [status, hostname] = system('hostname');

        if exist(strcat(pwd, '\Calibration_', hostname, '\flow_controller', num2str(value(flow_controller)), '_calibration_info.mat'))
            
            load(strcat(pwd, '\Calibration_', hostname, '\flow_controller', num2str(value(flow_controller)), '_calibration_info.mat'));
            
            figure;
            
            % plot the data
            plot(voltages, flow_rates, 'ko');
        
            % plot the best fit line
            hold on;
            
            if length(voltages) > 1 % if more than 1 entry
            
                coeffs = polyfit(voltages, flow_rates, 1);

                x_plot = [0:5];

                y_fit = (coeffs(1) .* x_plot) + coeffs(2);

                plot(x_plot, y_fit, 'r-');
                
            end

            % set  axes limits and labels
            if length(voltages) > 0
                min_y = min(0, min(flow_rates));
                max_y = max(100, max(flow_rates));
            else
                min_y = 0;
                max_y = 100;
            end
            set(gca, 'XLim', [0 5], 'YLim', [min_y max_y]);

            xlabel('voltage');
            ylabel('flow rate');
            axis square;
            title([save_info.date, ' -- ', save_info.calibrator]);

        else
            
            errordlg('No table saved for this FC.', 'Calibration error message');
            
        end

        
    case 'help' % open web browser with instructions

        web http://zwiki.cshl.edu/wiki/index.php/Flow_controller_calibration_instructions -browser;
        
         
    otherwise
                         
        error(['Don''t know how to handle action ' action]);

end;

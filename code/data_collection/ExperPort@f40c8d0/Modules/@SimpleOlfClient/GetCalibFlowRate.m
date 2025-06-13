% function [calib_val] = GetCalibFlowRate(olf, component, target_val);
%    Uses a lookup table to convert the desired flow rate into the optimal commanded flow rate.
%    Lookup table assumes a linear relationship between voltage and flow rate.
%    Called by Write.m.
%    GF 5/1/07

function [calib_val] = GetCalibFlowRate(olf, component, target_val)

    % identify the flow controller number
    fc_num = component(9);
    
    % get name of machine
    [status, hostname] = system('hostname');


    if exist(strcat('Calibration_', hostname, '\flow_controller', num2str(fc_num), '_calibration_info.mat')) % if calibration table exists

        load(strcat('Calibration_', hostname, '\flow_controller', num2str(fc_num), '_calibration_info.mat'));

        voltage_bounds = [0 5];
        flow_bounds = (fit_coeffs(1) .* voltage_bounds) + fit_coeffs(2);

        if target_val > flow_bounds(1) & target_val <= flow_bounds(2) % if target flow rate is within calibrated range

            calib_val = 20 *...
                ((((target_val - flow_bounds(1)) / (flow_bounds(2) - flow_bounds(1))) * (voltage_bounds(2) - voltage_bounds(1))) + voltage_bounds(1));

        else

            warning('Desired flow out of range. Closest possible flow used instead.');

            if target_val <= flow_bounds(1)

                calib_val = voltage_bounds(1) * 20;

            elseif target_val > flow_bounds(2);

                calib_val = voltage_bounds(2) * 20;

            end

        end

    else % if no calibration table exists for this flow controller

        calib_val = target_val;

    end

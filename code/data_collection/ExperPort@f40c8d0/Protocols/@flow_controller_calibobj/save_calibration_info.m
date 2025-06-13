% GF 4/30/07

function [] = save_calibration_info(obj)
   
GetSoloFunctionArgs;

if size(lookup_table, 2) <= 1
    
    errordlg('You must enter at least 2 voltage-flow pairs.', 'Calibration error message');
    
    return
    
end


voltages = lookup_table(1, :);
flow_rates = lookup_table(2, :);

flow_controller_num = value(flow_controller);

% get the fit
fit_coeffs = polyfit(voltages, flow_rates, 1);

% calculate the fit flow values
x_plot = [0:5];
fit_flow = (fit_coeffs(1) .* x_plot) + fit_coeffs(2);

save_info.date = value(date);
save_info.calibrator = value(initials);
save_info.flow_controller_num = flow_controller_num;

read_me = 'fit_flow based on voltages of [0:5]';

% save the info

do_save = 1;

% find out name of machine (to ensure that CVS doesn't overwrite
% calibration info across machines)
[status, hostname] = system('hostname');

if exist(strcat(pwd, '\Calibration_', hostname, '\flow_controller', num2str(flow_controller_num), '_calibration_info.mat'))
    
    do_save = 0;
    
    a = questdlg('Calibration info for this flow controller already exists (press prev. calib. button to view). Are you sure you want to overwrite it?');
    
    if strcmp(a, 'Yes')
        
        do_save = 1;
        
        % add previously saved calibration info to calibration 'archives'
        
        % 'protect' new info, then load old info and repackage into struct
        % for archiving, then 'unprotect' new info
        
        % protect
        fit_coeffs_new = fit_coeffs;
        flow_rates_new = flow_rates;
        voltages_new = voltages;
        save_info_new = save_info;
        
        load(strcat('Calibration_', hostname, '\flow_controller', num2str(flow_controller_num), '_calibration_info'));
        
        calibration_info.fit_coeffs = fit_coeffs;
        calibration_info.flow_rates = flow_rates;
        calibration_info.voltages = voltages;
        calibration_info.save_info = save_info;
                
        if exist(strcat('Calibration_', hostname, '\archived_flow_controller', num2str(flow_controller_num), '_calibration_info.mat'))
            
            load(strcat('Calibration_', hostname, '\archived_flow_controller', num2str(flow_controller_num), '_calibration_info'));
            archived_calibration_info{length(archived_calibration_info) + 1} = calibration_info;
            
        else % archive hasn't been created yet
            
            archived_calibration_info{1} = calibration_info;
           
        end
            
        save(strcat('Calibration_', hostname, '\archived_flow_controller', num2str(flow_controller_num), '_calibration_info'), ...
            'archived_calibration_info');
        
        % unprotect
        fit_coeffs = fit_coeffs_new;
        flow_rates = flow_rates_new;
        voltages = voltages_new;
        save_info = save_info_new;
        
    end
    
end
   
if do_save == 1
    
    if ~exist(strcat('Calibration_', hostname))
        mkdir(strcat('Calibration_', hostname));
    end
    
    % save current calibration info
    save(strcat(pwd, '\Calibration_', hostname, '\flow_controller', num2str(flow_controller_num), '_calibration_info'),...
        'voltages', 'flow_rates', 'fit_coeffs', 'save_info');

    sprintf('Data saved.')

else
    
    sprintf('Data not saved.')
    
end

function [] = PID_DAQ(obj, action);
GetSoloFunctionArgs;
switch action
    case 'init'
        % store PID data to an SPH, which is a cell array. The data matrix 
        % acquired in each trial will be stored as a component in this cell array. 
        SoloParamHandle(obj, 'pid_data', 'value', {});
        %SoloFunctionAddVars('state35','rw_args', {'pid_data'});
    case 'update'
        scans = GetDAQScans(rpbox('getstatemachine'));
        save(['C:\Home\PID_testing\Scan' num2str(value(n_done_trials))], 'scans');
        figure(10); plot(scans(:,1), scans(:,4));
        pid_data.value = [value(pid_data) scans];
        push_history(LastTrialEvents); LastTrialEvents.value = [];
        % StopDAQ(rpbox('getstatemachine'));
end
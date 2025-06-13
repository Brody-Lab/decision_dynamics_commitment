function [] = FSM_DAQ(obj, action);
GetSoloFunctionArgs;
switch action
    case 'init'
        % store PID data to an SPH, which is a cell array. The data matrix 
        % acquired in each trial will be stored as a component in this cell array. 
        SoloParamHandle(obj, 'ai_scans', 'value', {});
        %SoloFunctionAddVars('state35','rw_args', {'pid_data'});
    case 'update'
        scans = GetDAQScans(rpbox('getstatemachine'));
        % save(['C:\Home\PID_testing\Scan' num2str(value(n_done_trials))], 'scans');
        figure(10); set(gcf, 'Position',[504    87   919   482]);
        if size(scans,1)>1.5e4, pltrng = (1:1.5e4); else, pltrng = (1:size(scans,1));end;
        scans(:,8) = scans(:,8)-scans(1,8);
        plot(scans(pltrng,1)-scans(1,1), scans(pltrng,8));
        axis([0 4 0 max(scans(:,8))]);
         
        % keyboard;
        ai_scans.value = [value(ai_scans); scans(pltrng, [1 value(pid_daq_channel)])];
        push_history(LastTrialEvents); LastTrialEvents.value = [];
        % StopDAQ(rpbox('getstatemachine'));
end
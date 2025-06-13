function [] = air_flow(obj, action, x, y)

GetSoloFunctionArgs;

% if the olfactometer is connected, allow it to be controlled
if ~strcmpi(value(OLF_IP), 'nan')
   olf = value(olf_meter);
end

switch action
 case 'init'
%    SoloParamHandle(obj, 'state_matrix');
%    make_and_upload_state_matrix(obj, 'stop_matrix');
   return;
   
 case 'stop_flow',
     
   fc_num = value(flow_controller);
   
   if ~strcmpi(value(OLF_IP), 'nan')
       Write(olf, ['Bank' num2str(fc_num) '_Valves'], 0);
   end

 case 'start_flow'

   ov = value(valve);
   fc_num = value(flow_controller);
   volt = value(voltage);

   if volt > 5 % 5 is max voltage
       errordlg('Voltage must be <=5', 'Calibration error message');
       
   % send the flow rate command to the olfactometer (if it is connected)
   elseif ~strcmpi(value(OLF_IP), 'nan')
       WriteRaw(olf, ['BankFlow' num2str(fc_num) '_Actuator'], volt);
       Write(olf, ['Bank' num2str(fc_num) '_Valves'], ov);
   end   

 otherwise
   error('Invalid action!');
end;



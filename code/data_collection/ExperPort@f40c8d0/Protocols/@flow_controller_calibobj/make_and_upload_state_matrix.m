function [] = make_and_upload_state_matrix(obj, action, x, y)

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
   
 case 'stop_matrix',
     
   fc_num = value(flow_controller);
   
   Write(olf, ['Bank' num2str(fc_num) '_Valves'], 0);


%    stm = [ ; ...
%            0 0   0 0   0 0   40 0.01   0 0  0; ...
%            1 1   1 1   1 1   35 0.5    0 0  0];
% 
%    stm = [stm ; zeros(40-rows(stm), cols(stm))];
%    stm = [stm ; 40 40   40 40   40 40  40 1  0 0 0];
%    stm = [stm ; zeros(512-rows(stm), cols(stm))];
%    
%    % this code is necessary to control the odor valves via the state matrix
%    fsm = rpbox('getstatemachine');
%    fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
%           struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(fc_num) ' %v']);...
%           struct('type','noop','data','')});
%    rpbox('setstatemachine', fsm);
% 
%    rpbox('send_matrix', stm, 1);
%    rpbox('ForceState0');
%    state_matrix.value = stm;
%    return;
   
 case 'start_matrix'

%    global center1water; 
%    fv = center1water; % Final valve (for odor, despite the name)

   ov = value(valve);
   fc_num = value(flow_controller);
   volt = value(voltage);

   % send the flow rate command to the olfactometer (if it is connected)
   if ~strcmpi(value(OLF_IP), 'nan')
       WriteRaw(olf, ['BankFlow' num2str(fc_num) '_Actuator'], volt);
       Write(olf, ['Bank' num2str(fc_num) '_Valves'], ov);
   end
   
%    stm = [ ; ...
%            0 0   0 0   0 0   40 0.01   0 0 0 ; ...
%            1 1   1 1   1 1   35 5    0 0 0 ];
% 
%    stm = [stm ; zeros(40-rows(stm), cols(stm))];
% 
%    stm(36, :) = [35 35 35 35 35 35 35 100 0 0 0];
%    
%    b = size(stm, 1);
%    
%         % Cin     Cout   Lin    Lout    Rin    Rout    Tup         Timer   Dout  Bank      Aout
%     stm = [stm ; ...
%            b       b      b      b       b      b       35           2     4     ov         0; ... % state 40: keep odor valve and final valve open
% 
%            ];
   
%    b = rows(stm);
%    stm = [stm ; ...
%           b b   b b   b b   35 0.01  0 0 0];

    %% now pad and send off!
%     stm = [stm ; zeros(512-size(stm,1), size(stm, 2))];
% 
%     % this code is necessary to control the odor valves via the state matrix
%     fsm = rpbox('getstatemachine');
%     fsm = SetOutputRouting(fsm, {struct('type', 'dout', 'data', '0-15');...
%            struct('type', 'tcp', 'data', [value(OLF_IP) ':3336:SET BANK ODOR Bank' num2str(fc_num) ' %v']);...
%            struct('type','noop','data','')});
%     rpbox('setstatemachine', fsm);
% 
%     rpbox('send_matrix', stm, 1);
%     state_matrix.value = stm;



%    stm = [stm ; zeros(512-rows(stm), cols(stm))];
%    
%    rpbox('send_matrix', stm);
%    rpbox('ForceState0');
%    state_matrix.value = stm;
%    global fake_rp_box;
%    if isempty(fake_rp_box) | fake_rp_box==0,  % If on RM1s, simulate
%       rpbox('runrpx');                        % Clicking twice on 'Run'...
%       rpbox('runrpx');
%    end;
%    return;
 
 otherwise
   error('Invalid action!');
end;



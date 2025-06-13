function [] = make_and_upload_state_matrix(obj, action, x, y)

GetSoloFunctionArgs;

switch action
 case 'init'
   SoloParamHandle(obj, 'state_matrix');
   make_and_upload_state_matrix(obj, 'stop_matrix');
   return;
   
 case 'stop_matrix',
   stm = [ ; ...
           0 0   0 0   0 0   40 0.01   0 0  ; ...
           1 1   1 1   1 1   35 0.5    0 0];

   stm = [stm ; zeros(40-rows(stm), cols(stm))];
   stm = [stm ; 40 40   40 40   40 40  40 1  0 0];
   stm = [stm ; zeros(512-rows(stm), cols(stm))];
   
   rpbox('send_matrix', stm);
   rpbox('ForceState0');
   state_matrix.value = stm;
   return;
   
 case 'start_matrix'
   shorter = min(left_time, right_time);
   extra   = max(left_time, right_time) - shorter;
   
   global left1water;  lvid = left1water;
   global right1water; rvid = right1water;
   BOTH_PORTS = bitor(lvid, rvid);

   num_trains = 1; iti = ipi;
   
   if left_time == shorter, longer_port = rvid;
   else                     longer_port = lvid;
   end;

   stm = [ ; ...
           0 0   0 0   0 0   40 0.01   0 0  ; ...
           1 1   1 1   1 1   35 5    0 0];

   stm = [stm ; zeros(40-rows(stm), cols(stm))];
   for i=1:num_trains,
      for j=1:num_pulses,
         if shorter> 0,
            b = rows(stm);
            stm = [stm ; ...
                   b b   b b   b b   b+1  shorter BOTH_PORTS 0 ];
         end;
      
         if left_time ~= right_time
            b = rows(stm);
            stm = [stm; ...
                   b b   b b   b b   b+1  extra   longer_port 0 ];
         end;

         b = rows(stm);
         if j==num_pulses, rest = iti; else rest = ipi; end;
         stm = [ stm ; ...
                 b b   b b   b b   b+1  rest 0 0 ];
      end;
   end;
   b = rows(stm);
   stm = [stm ; ...
          b b   b b   b b   35 0.01  0 0];
   stm = [stm ; zeros(512-rows(stm), cols(stm))];
   
   rpbox('send_matrix', stm);
   rpbox('ForceState0');
   state_matrix.value = stm;
   global fake_rp_box;
   if isempty(fake_rp_box) | fake_rp_box==0,  % If on RM1s, simulate
      rpbox('runrpx');                        % Clicking twice on 'Run'...
      rpbox('runrpx');
   end;
   return;
 
 otherwise
   error('Invalid action!');
end;



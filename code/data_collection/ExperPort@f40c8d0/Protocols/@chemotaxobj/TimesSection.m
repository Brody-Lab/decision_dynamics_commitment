function [x, y, iti_list, RewardAvail] = TimesSection(obj, action, x, y)

% SoloFunction('TimesSection','ro_args', ...
%     {'n_done_trials', 'n_started_trials', 'maxtrials'});


GetSoloFunctionArgs;

switch action
 case 'init',
   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
   
   
   NumeditParam(obj,'RewardAvail', 20, x, y);
   next_row(y); 
   
   NumeditParam(obj,'TrialLength', 30, x, y, 'TooltipString', ...
                'Actually, time (in s) that a trial will continue following entry into state b');
   next_row(y); 

   NumeditParam(obj,'StdITI', 0, x, y, 'position', [x y 100 20], 'TooltipString', ...
                ['Standard dev. of the inter-trial interval ' ...
                 'distribution']); 
   NumeditParam(obj, 'MeanITI', 1.5, x, y,'position', [x+100 y 100 20],  ...
                'TooltipString', ['Mean of the distribution of ' ...
                       'inter-trial intervals']); next_row(y);   

   %% min and max of odor delay (between odor poke in and final valve on)
   NumeditParam(obj, 'od_min', 0.01, x, y, 'position', [x y 100 20], ...
       'TooltipString', ['min. of uniform distrib of odor delay (accounting for odor_travel_time)']);
   
   NumeditParam(obj, 'od_max', 0.01, x, y, 'position', [x+100 y 100 20], ...
       'TooltipString', ['max. of uniform distrib of odor delay (accounting for odor_travel_time)']);
   next_row(y);

   NumEditParam(obj, 'odor_travel_time', 0.2, x, y, 'TooltipString', ['Delay following odor valve on'...
       'to allow odor concentration to stabilize before opening final valve.'...
       'Must be empirically determined.']);
   next_row(y);
   
   NumeditParam(obj, 'valid_samp_time', 0.25, x, y, 'TooltipString',...
       'time that the rat has to stay in the center for valid odor sampling');
   next_row(y);
   
   NumeditParam(obj, 'max_odor_time', 2, x, y, 'TooltipString',...
       'Maximum time odor valve will stay open');
   next_row(y);
   
   %% min and max of reward delay (between water poke in and water valve on)
   NumeditParam(obj, 'rd_min', 0.2, x, y, 'position', [x y 100 20], ...
       'TooltipString', ['min. of uniform distrib of reward delay (between water poke in and water valve on)']);
   
   NumeditParam(obj, 'rd_max', 0.25, x, y, 'position', [x+100 y 100 20], ...
       'TooltipString', ['max. of uniform distrib of reward delay (between water poke in and water valve on)']);
   next_row(y);

   SubheaderParam(obj, 'tm_sbh', 'ITI & Reward Avail.', x, y);next_row(y);
   
 
   SoloParamHandle(obj, 'iti_list', 'value', zeros(maxtrials,1));
   SoloParamHandle(obj, 'odor_delay_list','value',zeros(maxtrials,1));
   SoloParamHandle(obj, 'reward_delay_list','value',zeros(maxtrials,1));
   
   set_callback({MeanITI, StdITI, od_min, od_max, rd_min, rd_max}, {'TimesSection', 'compute_intervals'});
   
   TimesSection(obj, 'compute_intervals');

   SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'TrialLength', 'valid_samp_time', 'od_min', 'od_max',...
       'odor_travel_time', 'max_odor_time', 'odor_delay_list', 'reward_delay_list'});
   

  case 'update' % (do nothing)
%    %TimesSection(obj, 'compute_intervals');
%    if odor_delay_list(n_done_trials+1)< 0.05
%        odor_delay_list(n_done_trials+1) = 0.05;
%    elseif delay_list(n_done_trials+1)>0.5
%        delay_list(n_done_trials+1) = 0.5;
%    end 
%    %CurrentITI.value = iti_list(n_done_trials+1);
%    %odor_delay.value = delay_list(n_done_trials+1);
   

case 'compute_intervals'
   
    % iti
   temp = value(iti_list);
   len = maxtrials-n_done_trials;
   temp(n_done_trials+1:end) = ...
       (randn(len,1) .* value(StdITI)) + value(MeanITI);
   temp(find(temp(n_done_trials+1:end)) <= 0.1) = 0.1;
   iti_list.value = temp;
   
   % odor delay
   temp1 = value(odor_delay_list);
   temp1(n_done_trials+1:end) =  value(od_min) + ((value(od_max) - value(od_min)) * rand(len, 1));
   odor_delay_list.value = temp1;
   
   % reward delay
   temp2 = value(reward_delay_list);
   temp2(n_done_trials+1:end) =  value(rd_min) + ((value(rd_max) - value(rd_min)) * rand(len, 1));
   reward_delay_list.value = temp2;
   
 case 'reinit',    % ------------- CASE 'REINIT' ------------
   currfig = gcf; 
   
   % Get the original GUI position and figure:
   x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
   
   % Delete all SoloParamHandles who belong to this object and whose
   % fullname starts with the name of this mfile:
   delete_sphandle('owner', ['^@' class(obj) '$'], ...
                   'fullname', ['^' mfilename]);
   
   % Reinitialise at the original GUI position and figure:
   [x, y] = feval(mfilename, obj, 'init', x, y);
   
   % Restore the current figure:
   figure(currfig);      

 
 otherwise
   error('Unknown action');
end;

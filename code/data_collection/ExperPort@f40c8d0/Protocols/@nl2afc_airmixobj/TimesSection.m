function [x, y, iti_list, RewardAvail] = TimesSection(obj, action, x, y)

% SoloFunction('TimesSection','ro_args', ...
%     {'n_done_trials', 'n_started_trials', 'maxtrials'});


GetSoloFunctionArgs;

switch action
 case 'init',
   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
   
   
   NumeditParam(obj,'RewardAvail', 4, x, y, 'TooltipString', ...
                ['Time (in sec.) after GO signal for which correct ' ...
                 'poke will get a reward']); next_row(y); 
   NumeditParam(obj,'StdITI', 0.5, x, y, 'position', [x y 100 20], 'TooltipString', ...
                ['Standard dev. of the inter-trial interval ' ...
                 'distribution']); 
   NumeditParam(obj, 'MeanITI', 6, x, y,'position', [x+100 y 100 20],  ...
                'TooltipString', ['Mean of the distribution of ' ...
                       'inter-trial intervals']); next_row(y);   
   DispParam(obj, 'CurrentITI', 0, x, y); next_row(y);
   
   
   NumeditParam(obj, 'MeanRandmDelay', 0.2, x, y, 'TooltipString', ['Mean of the distribution of'...
       'odor valve delay']); next_row(y);
   
   DispParam(obj, 'rand_valve_delay', 0, x, y, 'TooltipString',...
       'an exponentially random delay between nose poke and final valve open');
   next_row(y);
 %  NumeditParam(obj, 'odor_travel_time', 0.4, x, y, 'TooltipString',...
 %      'time after odor bank on but before final valve on'); % allow odor travel from filter to final valve.
 %  next_row(y);
   NumeditParam(obj, 'valid_samp_time', 0.05, x, y, 'TooltipString',...
       'time that the rat has to stay in the center for valide odor sampling');
   next_row(y);
   
   SoloFunctionAddVars('make_and_upload_state_matrix', 'ro_args', {'valid_samp_time', 'rand_valve_delay'});
   
   SubheaderParam(obj, 'tm_sbh', 'ITI & Reward Avail.', x, y);next_row(y);
   
   SoloParamHandle(obj, 'iti_list', 'value', zeros(maxtrials,1));
   SoloParamHandle(obj, 'delay_list','value',zeros(maxtrials,1));
   
   set_callback({MeanITI, StdITI}, {'TimesSection', 'comput_intervals'});
   
   
   TimesSection(obj, 'update');
   
 case 'comput_intervals'
   temp = value(iti_list); len = maxtrials-n_done_trials;
   temp(n_done_trials+1:end) = ...
       (randn(len,1) .* value(StdITI)) + value(MeanITI);
   temp(find(temp(n_done_trials+1:end)) <= 0.1) = 0.1;
   iti_list.value = temp;
   
   temp1 = value(delay_list); len1 = maxtrials-n_done_trials;
   temp1(n_done_trials+1:end) =  exprnd(value(MeanRandmDelay),[len1 1]);
   
   delay_list.value = temp1;
   
 case 'update'
   TimesSection(obj, 'comput_intervals');
   if delay_list(n_done_trials+1)< 0.05
       delay_list(n_done_trials+1) = 0.05;
   elseif delay_list(n_done_trials+1)>0.5
       delay_list(n_done_trials+1) = 0.5;
   end 
   CurrentITI.value = iti_list(n_done_trials+1);
   rand_valve_delay.value = delay_list(n_done_trials+1);
   
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

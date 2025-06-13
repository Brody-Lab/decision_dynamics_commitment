function [x, y, iti_list, RewardAvail] = TimesSection(obj, action, x, y)

% SoloFunction('TimesSection','ro_args', ...
%     {'n_done_trials', 'n_started_trials', 'maxtrials'});


GetSoloFunctionArgs;

switch action
 case 'init',
   % Save the figure and the position in the figure where we are
   % going to start adding GUI elements:
   SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
   
   
   NumeditParam(obj,'RewardAvail', 3, x, y, 'TooltipString', ...
                ['Time (in sec.) after GO signal for which correct ' ...
                 'poke will get a reward']); next_row(y); 
   NumeditParam(obj,'StdITI', 1, x, y, 'TooltipString', ...
                ['Standard dev. of the inter-trial interval ' ...
                 'distribution']); next_row(y); 
   NumeditParam(obj, 'MeanITI', 3, x, y, ...
                'TooltipString', ['Mean of the distribution of ' ...
                       'inter-trial intervals']); next_row(y);   
   DispParam(obj, 'CurrentITI', 0, x, y); next_row(y);
   
   next_row(y,0.5);
   SubheaderParam(obj, 'tm_sbh', 'ITI & Reward Avail.', x, y);next_row(y);
   
   
   SoloParamHandle(obj, 'iti_list', 'value', zeros(maxtrials,1));
   
   set_callback({MeanITI, StdITI}, {'TimesSection', 'compute_iti'});
   
   TimesSection(obj, 'compute_iti');
   TimesSection(obj, 'update');
   
 case 'compute_iti'
   temp = value(iti_list); len = maxtrials-n_done_trials;
   temp(n_done_trials+1:end) = ...
       (randn(len,1) .* value(StdITI)) + value(MeanITI);
   temp(n_done_trials+find(temp(n_done_trials+1:end) <= 0.1)) = 0.1;
   
   iti_list.value = temp;
   TimesSection(obj, 'update');

   
 case 'update'
   CurrentITI.value = iti_list(n_done_trials+1);
   
 
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

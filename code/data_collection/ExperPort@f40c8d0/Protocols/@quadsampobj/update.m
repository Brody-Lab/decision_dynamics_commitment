function [] = update(obj)
tic;
GetSoloFunctionArgs;
% SoloFunction('update', 'ro_args', 'within_trial_update_actions');

for i=1:length(within_trial_update_actions),
   if debugging==1, tic; end;
   eval(within_trial_update_actions{i});
   if debugging==1,
      fp = fopen('debugging.log', 'a');
      fprintf(fp, 'update: Doing "%s" took time : %g\n', ...
              within_trial_update_actions{i}, toc);
      fclose(fp);
   end;
end;
% toc;



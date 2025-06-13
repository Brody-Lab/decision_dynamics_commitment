function [private_t] = trial_selection(private_selstr, private_pevs, trialnum)

   if isempty(private_selstr), private_t=true; return; end;
   
   %     This line catenates lines of the select string into one line if
   %       they are separated as in e.g. ['ab' ; 'cd'].
   private_selstr = private_selstr'; private_selstr = private_selstr(:)';
   
   states = private_pevs.states;
   pokes  = private_pevs.pokes;
   
   
   % If fieldnames of states and pokes don't collide, allow using those directly:
%    if isempty(intersect(setdiff(fieldnames(states), {'starting_state', 'ending_state'}), ...
%        setdiff(fieldnames(pokes), {'starting_state', 'ending_state'}))),
%      private_fnames = setdiff(fieldnames(states), {'starting_state', 'ending_state'});
%      for private_i = 1:length(private_fnames),
%        eval([private_fnames{private_i} ' = states.(private_fnames{private_i});']);
%      end;
%      private_fnames = setdiff(fieldnames(pokes), {'starting_state', 'ending_state'});
%      for private_i = 1:length(private_fnames),
%        eval([private_fnames{private_i} ' = pokes.(private_fnames{private_i});']);
%      end;
%    end;

   ps = private_pevs.states;
   pk = private_pevs.pokes;
   if isfield(private_pevs, 'spikes')
     pc = private_pevs.spikes;
   end;

   
   try
     private_t = logical(eval(private_selstr));
     return;
      
   catch
      [lerrstr, lerrid] = lasterr;
      if strcmp(lerrid, 'MATLAB:m_invalid_lhs_of_assignment'),
         try
            eval([private_selstr ';']);
         catch
            fprintf(1, ['\nWARNING --  This string could not be evaluated:' ...
                        '\n"%s"\n    error was "%s"\n'], ...
                        private_selstr, lasterr);
            private_t = false; return;
         end;
      else
         fprintf(1, ['\nWARNING --  This string could not be evaluated:' ...
                     '\n"%s"\n    error was "%s"\n'], ...
                     private_selstr, lasterr);
         private_t = false; return;         
      end;

      if exist('this_trial', 'var') && isscalar(this_trial),
         private_t = logical(this_trial);
      else
         private_t = false;
      end;
      return;
   end;
   

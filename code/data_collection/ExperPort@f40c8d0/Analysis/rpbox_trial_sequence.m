function [sseq] = rpbox_trial_sequence(saved)

   rtrials = saved.trial_events(:,1);
   rtimes  = saved.trial_events(:,2);
   rstates = saved.trial_events(:,3);
   revents = saved.trial_events(:,4);
   
   seq = [];
   u = [0 ; find(diff(rtrials))];
   
   for i=1:length(u)-1,
       myguys = u(i)+1:u(i+1);
       firstport_index = min(find(rstates(myguys)==45  &  (revents(myguys)==3  |  revents(myguys)==5)));
       if revents(myguys(firstport_index))==3,
           seq = [seq ; rtrials(myguys(1)) rtimes(myguys(1)) double('L')];
       else
           seq = [seq ; rtrials(myguys(1)) rtimes(myguys(1)) double('R')];
       end;
   end;
   
   if nargout > 0, sseq = seq; end;
   
   
   
   
   

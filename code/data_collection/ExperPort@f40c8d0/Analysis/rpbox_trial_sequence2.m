function [sseq] = rpbox_trial_sequence2(saved)

   eventnames; statenames;
   
   rtrials = saved.trial_events(:,1);
   rtimes  = saved.trial_events(:,2);
   rstates = saved.trial_events(:,3);
   revents = saved.trial_events(:,4);
   
   seq = {'trial'  'trialstart' 'trialend' ...
           'validcpoketime' 'validcpokedur' 'nimpatientcpokes' 'impatientcpoketime' 'impatientcpokedur' ...
           'portside' 'hit'};
   u = [0 ; find(diff(rtrials))];
   
   for i=1:length(u)-1,
       myguys = u(i)+1:u(i+1); id = (1:length(myguys))';
       trialstart = rtimes(myguys(1));
       
       z0 = min(find(rstates(myguys)==WaitForCPoke));  % First time we are set up and ready to go
       if nargin > 1, minid = z0; else minid = 1; end; 
       z1 = find(id >= minid  &  rstates(myguys)<WaitForSPoke  &  revents(myguys)==Cin);   % all the center pokes before rew/error
       impatientcpoketime = []; impatientcpokedur = [];
       if length(z1)>1, % last one will be the valid one, don't treat that
           z1 = z1(1:end-1); impatientcpoketime = zeros(1, length(z1)); impatientcpokedur = zeros(1, length(z1));
           for j=1:length(z1),
               z2 = min(find(id > z1(j)  &  revents(myguys)==Cou));
               impatientcpoketime(j) = rtimes(myguys(z2)); impatientcpokedur(j) = rtimes(myguys(z2))-rtimes(myguys(z1(j)));
           end;
       end;
       
       z1 = max(find(rstates(myguys)==WaitForCPoke  &  revents(myguys)==Cin)); % last center in
       z2 = min(find(id > z1  &  revents(myguys)==Cou));                       % corresponding poke out
       validcpoketime = rtimes(myguys(z1)); validcpokedur = rtimes(myguys(z2)) - rtimes(myguys(z1));
       
       zf = min(find(rstates(myguys)==45  &  (revents(myguys)==Lin  |  revents(myguys)==Rin))); % first valid port
       if revents(myguys(zf))==Lin, portside = 'L'; else portside = 'R'; end; trialend = rtimes(myguys(zf));
       
       z = find(id > zf  &  RewardStart<=rstates(myguys) & rstates(myguys)<ItiStart);
       if ~isempty(z), hit = 1; else hit = 0; end;
       
       seq = [seq ; {rtrials(myguys(1)) trialstart trialend ...
                   validcpoketime validcpokedur ...
               length(impatientcpoketime) impatientcpoketime impatientcpokedur ...
               portside hit}];
               
    end;
   
   if nargout > 0, sseq = seq; end;
   
   
   
   
   

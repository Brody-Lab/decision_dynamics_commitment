function [sseq] = rpboxevents2trialdata(saved)

   if ~isfield(saved.protocolname), saved.protocolname = 'sigmoidsamp5'; end; % For backwards compatibility
   
   seq = feval(['rpboxevents2trialdata_' saved.protocolname], saved);
   
   if nargout > 0, sseq = seq; end;
   
   
   
   
   

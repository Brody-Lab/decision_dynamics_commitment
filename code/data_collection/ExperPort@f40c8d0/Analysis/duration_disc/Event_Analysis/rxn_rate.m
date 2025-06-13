function [rxn_rt] = rxn_rate(events, numtrials, ispitch)

cumtrials = cumsum(numtrials);
rxn_rt=[];
for s = 1:length(numtrials)
    if s ==1, sidx=1;
    else sidx = cumtrials(s-1)+1;end;
    eidx = cumtrials(s);
  %  fprintf(1,'Trials %i to %i\n',sidx,eidx);
    
    % focus on a session
    p = events(sidx:eidx);
    rxn = rxn_time(p, 'ispitch', ispitch,'suppress_stdout',1);
 
    rxn_rt = horzcat(rxn_rt, mean(rxn));
end;
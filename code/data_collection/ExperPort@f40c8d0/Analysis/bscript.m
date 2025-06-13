clf;

seq = rpboxevents2trialdata(saved); 
% seq = seq([1 100:end],:);
validcpoketime = getvals(seq, 'validcpoketime');
validcpokedur  = getvals(seq, 'validcpokedur');
trialend       = getvals(seq, 'trialend');
hit            = getvals(seq, 'hit');

uh = find(hit);  hhits = plot(validcpoketime(uh), validcpokedur(uh), 'g.'); hold on;
um = find(~hit); hmiss = plot(validcpoketime(um), validcpokedur(um), 'r.'); hold on;

l = [vlines(getvals(seq, 'trialend'), 0.1, 0.4); vlines(getvals(seq, 'trialend'), 0.8, 0.6)];

set(l, 'Color', 0.7*[1 1 1]);

for i=1:size(seq,1)-1,
    nimp = getvalue(seq, i, 'nimpatientcpokes');
    ntim = getvalue(seq, i, 'impatientcpoketime');
    ndur = getvalue(seq, i, 'impatientcpokedur');
    
    plot(ntim, ndur, 'k.'); hold on;
end;

nimp     = getvals(seq, 'nimpatientcpokes');
portside = getvals(seq, 'portside');

fprintf(1, 'Mean impatient pokes before hit = %g, before miss = %g\n', mean(nimp(uh)), mean(nimp(um)));

ul = find(portside=='L');
ur = find(portside=='R');

ulh = find(portside=='L' & hit);
ulm = find(portside=='L' & ~hit);
urh = find(portside=='R' & hit);
urm = find(portside=='R' & ~hit);

fprintf(1, 'Mean LEFT  impatient pokes before hit = %g, before miss = %g\n', mean(nimp(ulh)), mean(nimp(ulm)));
fprintf(1, 'Mean RIGHT impatient pokes before hit = %g, before miss = %g\n', mean(nimp(urh)), mean(nimp(urm)));
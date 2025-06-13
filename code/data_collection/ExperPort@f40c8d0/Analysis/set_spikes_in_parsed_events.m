function [] = set_spikes_in_parsed_events(pe, spiketimes)

if ~strcmp(get_name(pe), 'parsed_events'), 
  error('Can only run this function on a SoloParamHandle with name "parsed_events"');
end;

peh = get_history(pe);

for i=1:length(peh),
  pehi = peh{i};
  start = pehi.states.state_0(1,2);
  stop  = pehi.states.state_0(2,1);
  u = find(start<=spiketimes & spiketimes<=stop);
  pehi.spikes = spiketimes(u);
  if ~isempty(u), spiketimes = spiketimes(u+1:end); end;
  peh{i} = pehi;
end;

set_history(pe, peh);


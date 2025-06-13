% [] = vertical_shift(ghandles, deltay)    

function [] = vertical_shift(ghandles, deltay)    

  for guys = {'states' 'pokes'},
    fnames = fieldnames(ghandles.(guys{1}));
    for j=1:length(fnames),
      myghandles = ghandles.(guys{1}).(fnames{j});
      for k=1:length(myghandles),
        if ishandle(myghandles(k)),
          set(myghandles(k), 'YData', get(myghandles(k), 'YData') + deltay);
        end;
      end; 
    end; 
  end;
  
  if isfield(ghandles, 'spikes') && ~isempty(ghandles.spikes) && ishandle(ghandles.spikes),
    set(ghandles.spikes, 'YData', get(ghandles.spikes, 'YData') + deltay);
  end;


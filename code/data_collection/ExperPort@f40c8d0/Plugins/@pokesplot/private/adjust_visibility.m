function [] = adjust_visibility(trial_info)

for guys = {'states' 'pokes'},
  fnames = fieldnames(trial_info.ghandles.(guys{1}));
  for j=1:length(fnames),
    ghandles = trial_info.ghandles.(guys{1}).(fnames{j});
    if trial_info.visible == 1, set(ghandles, 'Visible', 'on');
    else                        set(ghandles, 'Visible', 'off');
    end;
  end;
end; % for guys
% Now spikes:
ghandles = trial_info.ghandles;
if isfield(ghandles, 'spikes') && ~isempty(ghandles.spikes) && ishandle(ghandles.spikes),
  if trial_info.visible == 1, set(ghandles.spikes, 'Visible', 'on');
  else                        set(ghandles.spikes, 'Visible', 'off');
  end;
end;

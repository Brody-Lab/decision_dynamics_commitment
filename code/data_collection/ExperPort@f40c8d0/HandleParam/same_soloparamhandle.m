% [t] = same_soloparamhandle(sph, cell_of_sphs)
%
% Returns a matrix t that is the same size as the cell cell_of_sphs. For
% every element of cell_of_sphs that is the same SoloParamHandle as sph
% (in the sense of @SoloParamHandle/is_same_soloparamhandle.m), t will have
% a 1; else t will have a 0. Every element of "cell_of_sphs" must be a
% SoloParamHandle object.
%

function [t] = same_soloparamhandle(sph, cell_of_sphs)

if ~iscell(cell_of_sphs),
  error(['2nd arg, cell_of_sphs, must be a cell, every element of which ' ...
    'is a SoloParamHandle object']);
end;

t = zeros(size(cell_of_sphs));

for i=1:prod(size(cell_of_sphs)),
  if ~isa(cell_of_sphs{i}, 'SoloParamHandle'),
    % if not an SPH, just ignore for now:
    % error(['Element number ' num2str(i) ' of cell_of_sphs is not a SoloParamHandle object.']);
  else
    t(i) = is_same_soloparamhandle(sph, cell_of_sphs{i});
  end;
end;

return;

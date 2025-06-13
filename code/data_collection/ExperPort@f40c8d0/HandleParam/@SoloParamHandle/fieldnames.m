% fnames = fieldnames(sph)
%
% equivalent to fieldnames(value(sph))
%

function fnames = fieldnames(sph)

if isstruct(value(sph)),
  fnames = fieldnames(value(sph));
else
  error('The value of the passed SoloParamHandle is not a struct');
end;


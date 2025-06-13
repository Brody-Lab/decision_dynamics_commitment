function expname=get_experimenter(instring)

%
% expname=get_experimenter(instring)
%

if ~iscell(instring), str{1}=instring; else str=instring; end

expname=cell(size(str));

for k=1:length(str)
  switch upper(str{k}(1))
    case 'A'
      expname{k}='Amanda';
    case 'B'
      expname{k}='Bing';
    case 'C'
      expname{k}='Carlos';
    case 'J'
      expname{k}='Jeff';
    case 'K'
      expname{k}='Chuck';
    case 'M'
      expname{k}='Max';
    case 'S'
      expname{k}='Ben';
    case 'T'
      expname{k}='Tim';
    case 'Z'
      expname{k}='Joe';
    otherwise
      expname{k}='';
  end
end
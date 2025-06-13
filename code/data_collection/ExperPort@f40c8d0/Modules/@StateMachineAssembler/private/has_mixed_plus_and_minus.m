%  t = has_mixed_plus_and_minus(str)


function [t] = has_mixed_plus_and_minus(str)

if isempty(str), t=0; return; end;

if (isletter(str(1)) || ~isempty(strfind(str, '+'))) && ~isempty(strfind(str, '-')),
  t = 1;
else
  t = 0;
end;



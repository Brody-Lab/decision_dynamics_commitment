% function [coeffs_vector] = GetCoeffs(olf, pidflow)
%    Returns the coefficients for a PID-style flow controller.
%    See also List method to list components; SetCoeffs to
%    set coefficients.
function [out] = GetCoeffs(olf, comp)
    out = [];
    lines = DoQueryCmd(olf, sprintf('GET COEFFS %s', comp));
    for i=1:size(lines,1),
        l = lines(i,:);
        while true,
            [str, l] = strtok(l);
            if (isempty(str)), break; end;
            num = str2num(str);
            if (~isempty(num)), str = num; end;
            out = horzcat(out, num);
        end;
    end;
 
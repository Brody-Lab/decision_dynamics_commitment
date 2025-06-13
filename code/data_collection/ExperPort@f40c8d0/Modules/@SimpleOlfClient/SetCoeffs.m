% function [res] = SetCoeffs(olf, pidflow, coeffs_vector)
%    Returns the coefficients for a PID-style flow controller.
%    See also List method to list components; GetCoeffs to
%    get coefficients.
function [res] = SetCoeffs(olf, comp, vec)
    if (~isnumeric(vec) | ~size(vec,1) == 1), error('Vector parameter must be a 1xN vector!!'); end;
    vecstr = [];
    for i=1:size(vec,2),
        vecstr = horzcat(vecstr, sprintf('%d ', vec(1,i)));
    end;
    res = DoSimpleCmd(olf, sprintf('SET COEFFS %s %s', comp, vecstr));

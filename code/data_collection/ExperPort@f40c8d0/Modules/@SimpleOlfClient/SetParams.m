% function [res] = SetParams(olf, controlable, vector)
%    The control params for a controlable object to vector.
%    See also List method to list which components are controlable; GetParams to
%    get control params.
function [res] = SetParams(olf, comp, vec)
    if (~isnumeric(vec) | ~size(vec,1) == 1), error('Vector parameter must be a 1xN vector!!'); end;
    vecstr = [];
    for i=1:size(vec,2),
        vecstr = horzcat(vecstr, sprintf('%d ', vec(1,i)));
    end;
    res = DoSimpleCmd(olf, sprintf('SET CONTROL PARAMS %s %s', comp, vecstr));

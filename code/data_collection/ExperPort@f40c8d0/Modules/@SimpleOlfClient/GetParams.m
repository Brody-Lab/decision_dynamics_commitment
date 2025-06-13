% function [params_vector] = GetParams(olf, controlable)
%    Returns the control params for a controlable object.
%    See also List method to list which components are controlable; SetParams to
%    set control params.
function [out] = GetParams(olf, comp)
    out = [];
    lines = DoQueryCmd(olf, sprintf('GET CONTROL PARAMS %s', comp));
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
    
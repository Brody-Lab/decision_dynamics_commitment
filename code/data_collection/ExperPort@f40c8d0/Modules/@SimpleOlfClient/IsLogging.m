% function [res] = IsLogging(olf, comp)
%    Returns true iff a logable object is being logged
%    See also List method to list which components are logable.
function [out] = IsLogging(olf, component)
    out = DoQueryCmd(olf, sprintf('IS DATA LOGGING %s any', component));    
    out = str2num(out);

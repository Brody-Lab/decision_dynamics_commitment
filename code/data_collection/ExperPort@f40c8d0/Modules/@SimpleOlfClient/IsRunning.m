% function [out] = IsRunning(olf, runnable)
%    Returns true iff a runnable object is started
%    See also List method to list which components are runnable.
function [out] = IsRunning(olf, component)
    out = DoQueryCmd(olf, sprintf('RUNNING %s', component));    
    out = str2num(out);

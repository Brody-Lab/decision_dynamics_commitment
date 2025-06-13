% function [count] = LogCount(olf, runnable)
%    Returns the number of events in the olfactometer's log event memory.
%    A call to GetLog() will retreive these events
%    See also List method to list which components are logable; GetLog to
%    retreive the log.
function [out] = LogCount(olf)
    out = DoQueryCmd(olf, sprintf('DATA LOG COUNT'));    
    out = str2num(out);

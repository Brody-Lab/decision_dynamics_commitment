% function [res] = ClearLog(olf)
%    Unconditionally deletes all the data log entries
%    See also List method to list which components are logable, GetLog and LogCount for other log manipulators.
function [res] = ClearLog(olf)
    res = DoSimpleCmd(olf, sprintf('CLEAR DATA LOG'));    

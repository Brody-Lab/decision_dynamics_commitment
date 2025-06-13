% function [res] = Start(olf, component)
%    Start a runnable component.
%    See also IsRunning, Stop and List methods.
function [res] = Start(olf, component)
    res = DoSimpleCmd(olf, sprintf('START %s', component));
    
 
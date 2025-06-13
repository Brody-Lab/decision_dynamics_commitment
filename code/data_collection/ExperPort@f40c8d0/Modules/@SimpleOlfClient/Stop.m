% function [res] = Stop(olf, component)
%    Start a runnable component.
%    See also IsRunning, Start and List methods.
function [res] = Stop(olf, component)
    res = DoSimpleCmd(olf, sprintf('STOP %s', component));
    
 
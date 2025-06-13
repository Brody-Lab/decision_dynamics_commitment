% function [res] = WriteRaw(olf, component, val)
%    Write a 'raw' value to a component named 'component'
%    See also Write and List methods.
function [res] = WriteRaw(olf, component, val)
    res = DoSimpleCmd(olf, sprintf('RWRITE %s %d', component, val));
    
 
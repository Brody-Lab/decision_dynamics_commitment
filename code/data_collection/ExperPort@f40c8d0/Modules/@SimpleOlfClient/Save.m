% function [res] = Save(olf, saveable_component)
%    Save the parameters for a saveable component.
%    See also List to find out which components are saveable.
function [res] = Save(olf, component)
    res = DoSimpleCmd(olf, sprintf('SAVE %s', component));
    
    
 
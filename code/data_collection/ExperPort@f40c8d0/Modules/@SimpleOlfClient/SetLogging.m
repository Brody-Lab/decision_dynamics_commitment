% function [res] = SetLogging(olf, comp, bool_flg)
%    Enable disable data logging for a particular logable component
%    See also List method to list which components are logable.
function [out] = SetLogging(olf, component, bool_flg)
    out = DoSimpleCmd(olf, sprintf('SET DATA LOGGING %s any %d', component, bool_flg));    

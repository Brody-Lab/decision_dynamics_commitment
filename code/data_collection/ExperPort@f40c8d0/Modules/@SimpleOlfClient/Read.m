% function [out] = Read(olf, component)
%    Read 'cooked' data from a component named component
%    See also ReadRaw and List methods.
function [out] = Read(olf, component)
    out = DoQueryCmd(olf, sprintf('READ %s', component));    
    out = str2num(out);
    
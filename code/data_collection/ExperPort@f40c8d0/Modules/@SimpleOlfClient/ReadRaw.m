% function [out] = ReadRaw(olf, component)
%    Read 'raw' data from a component named component
%    See also Read and List methods.
function [out] = ReadRaw(olf, component)
    out = DoQueryCmd(olf, sprintf('RREAD %s', component));    
    out = str2num(out);

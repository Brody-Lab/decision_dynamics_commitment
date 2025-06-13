%function [olf] = Close(olf)
%Close the olfactometer and end the connection
%
function [olf] = Close(olf)

    if (olf.handle > -1), TCPClient('destroy', olf.handle); end;
    olf.handle = -1;
    
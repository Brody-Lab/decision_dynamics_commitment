% function [res] = DoSimpleCmd(olf, cmd)
%   Do not call, internal to olfactometer
function [res] = DoSimpleCmd(olf, cmd)

     olf = ChkCon(olf);
     res = TCPClient('sendstring', olf.handle, sprintf('%s\n', cmd));
     if (isempty(res)), error(sprintf('Empty result for simple command %s, connection down?', cmd)); end;
     ReceiveOK(olf, cmd);

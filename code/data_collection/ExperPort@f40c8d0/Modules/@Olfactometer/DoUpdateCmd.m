% pass in a cmd and a cell array of strings (one per row) for the series of
% lines to send to the server in the PUT/UPDATE cmd.  Each line in the cell
% array should end in a newline (\n).
function olf = DoUpdateCmd(olf, cmd, lines)

     olf = ChkCon(olf);
     res = TCPClient('sendstring', olf.handle, sprintf('%s\n', cmd));
     if (isempty(res)), error(sprintf('Empty result for update command %s, connection down?', cmd)); end;
     ReceiveREADY(olf, cmd);
     for i=1:size(lines,1),         
         line = lines{i,1};
         res = TCPClient('sendstring', olf.handle, line);         
         if (isempty(res)), error(sprintf('Empty result for update command %s, connection down?', cmd)); end;
     end;
     ReceiveOK(olf, cmd);
     

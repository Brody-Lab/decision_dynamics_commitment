% Internal to olfactometer -- receives OK
function [] = ReceiveOK(olf, cmd)
  lines = TCPClient('readlines', olf.handle);
  [m,n] = size(lines);
  if (m < 1),
      error('Server sent no lines in ReceiveOK.  Is the connection down?');
  end;
  line = lines(1,1:n);
  if isempty(findstr('OK', line)),  error(sprintf('Server did not send OK after %s command. Got: %s', cmd, line)); end;

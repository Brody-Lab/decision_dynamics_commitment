% Internal to olfactometer -- receives READY
function [] = ReceiveREADY(olf, cmd)
  lines = TCPClient('readlines', olf.handle);
  [m,n] = size(lines);
  line = lines(1,1:n);
  if isempty(findstr('READY', line)),  error(sprintf('Server did not send READY after %s command. Got: %s', cmd, line)); end;


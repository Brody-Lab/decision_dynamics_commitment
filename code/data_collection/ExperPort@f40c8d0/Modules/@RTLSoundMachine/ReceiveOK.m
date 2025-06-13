% [] = ReceiveOK(@RTLSoundMachine::sm, const char cmd)   Checks to see if SoundServer replied with an "OK"
%
% Waits for a line from the SoundServer; if the line contains the string
% "OK", then does nothing. If the string "OK" is not found, then throws an
% error, reporting what the SoundServer line was.
%
% The cmd parameter is assumed to be the last command sent to the FSMServer
% and is used merely to report it if there is an error.
%

function [] = ReceiveOK(sm, cmd)
  lines = SoundTrigClient('readlines', sm.handle);
  [m,n] = size(lines);
  line = lines(1,1:n);
  if isempty(findstr('OK', line)),  
    warning('RTLSoundMachine:ServerNotOK', ['RTLinux SoundServer did not send OK after "%s" command, ' ...
      'instead it sent "%s".', cmd, line]); 
  end;
end

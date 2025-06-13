% function [res] = DoQueryCmd(olf, cmd)
% function [res] = DoQueryCmd(olf, cmd, numlines)
%
% takes 2 or 3 args.  If third arg is present, it signifies the minimum
% number of lines *before* the OK to read.  Note specifying a large value
% here can cause infinite hangs, so be *sure* the server will return arg3 +
% 1 lines (the +1 is for the OK).
%
% numlines + 1 lines are read (an extra line is read for the 'OK'!)
% returns a Mx1 cell column where each cell is a character string
% if you don't pass numlines, simply reads 2 lines.
function [res] = DoQueryCmd(varargin)
  if (nargin < 2 | nargin > 3), error('Please specify at least olf, cmd as 2 args to this function, and no morre than 3 args!'); end;
  olf = varargin{1};
  if (~isa(olf, 'Olfactometer')), error('First arg must be a class Olfactometer object!'); end;
  cmd = varargin{2};
  if (~ischar(cmd)), error('Second arg must be a string!'); end;
  numLines = 10000000;
  numLinesGot = 0;
  if (nargin == 3), numLines = varargin{3}+1; end;
  if (~isscalar(numLines)), error('Third arg must be a scalar number!'); end;
  olf = ChkCon(olf);
  res = TCPClient('sendstring', olf.handle, sprintf('%s\n', cmd));
  if (isempty(res)) error(sprintf('%s error, cannot send string!', cmd)); end;
  lines = {};
  m = 0; n = 0;
  while(numLinesGot < numLines), 
      theseLines = TCPClient('readlines', olf.handle);
      if (isempty(theseLines)), error(sprintf('%s error, empty result! Is the connection down?', cmd)); end;
      lines = vertcat(lines,cellstr(theseLines));
      [m, n] = size(lines);
      numLinesGot = m;
      vec = findstr(char(lines{m}), 'ERROR');
      if (~isempty(vec) & vec(1) < 2), 
          error(sprintf('Unexpected response from server on query command "%s":\n\n%s', cmd, lines{m, 1:n})); 
      end;
      vec = findstr(char(lines{m}), 'OK');
      if (~isempty(vec) & vec(1) < 2), 
          % ok received
          break;
      end;
  end;
  respos = numLinesGot;
  vec = findstr(char(lines{respos}), 'OK');  
  if (isempty(vec) | vec(1) > 1), 
      ReceiveOK(olf, cmd); respos = respos + 1; 
  end; 
  res = char(lines{1:respos-1,1:n});

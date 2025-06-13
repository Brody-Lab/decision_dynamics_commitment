% function [res] = DoQueryCellCmd(olf, cmd, delim)
%
% takes 3 args.  Third arg specifies the delimiter per line for
% splitting lines into columns of the output cell matrix
%
function [res] = DoQueryCellCmd(varargin)
  if (nargin ~= 3), error('Please specify args: olf, cmd, delims!'); end;
  olf = varargin{1};
  if (~isa(olf, 'SimpleOlfClient')), error('First arg must be a class SimpleOlfClient object!'); end;
  cmd = varargin{2};
  if (~ischar(cmd)), error('Second arg must be a string!'); end;
  numLines = 10000000;
  numLinesGot = 0;
  delim = varargin{3};
  if (~ischar(delim)), error('Third arg must be a string!'); end;
  olf = ChkCon(olf);
  res = TCPClient('sendstring', olf.handle, sprintf('%s\n', cmd));
  if (isempty(res)) error(sprintf('%s error, cannot send string!', cmd)); end;
  lines = {};
  m = 0; n = 0;
  needok = 1;
  while(numLinesGot < numLines), 
      thisCell = TCPClient('readLinesAndSplitToCellMatrix', olf.handle, ...
                           delim);
      if (isempty(thisCell)), error(sprintf('%s error, empty result! Is the connection down?', cmd)); end;
      
      while (size(thisCell,2) < size(lines,2)), % occasionally 'OK' appears in a 1x1 cell by itself, so pad with empties..
          thisCell = horzcat(thisCell, [0]); 
      end;

      lines = vertcat(lines,thisCell);
      [m, n] = size(lines);
      numLinesGot = m;
      if (regexp(char(lines{m,1}), '^ERROR:?\s+')), 
          error(sprintf('Unexpected response from server on query command "%s":\n\n%s', cmd, char(lines{m,1:n}))); 
      end;
      if (regexp(char(lines{m,1}), '^OK\s*$')), 
          % ok received
          needok = 0;
          break;
      end;
  end;
  respos = numLinesGot;
  if (needok),
    ReceiveOK(olf, cmd); respos = respos + 1; 
  end; 
  res = lines(1:respos-1,1:n);

% function [olf] = SimpleOlfClient(host)
% function [olf] = SimpleOlfClient(host, port)
%
% Connect to the olfactometer at host:port, and instantiate a new SimpleOlfClient
function [olf] = SimpleOlfClient(varargin)

    if (nargin < 1), error('Please pass a hostname'); end;
    if (nargin > 2), error('Too many arguments'); end;
    host = varargin{1};
    port = 3336;
    if (nargin == 2), port = varargin{2}; end;
    if (~isnumeric(port)), error('Port argument needs to be numeric'); end;
    if (~ischar(host)),  error('Host argument needs to be a string'); end;

    olf = struct( ...
                 'handle', -1, ...
                 'host', host, ...
                 'port', port ...
                 );
    olf = class(olf, 'SimpleOlfClient');
    olf.handle = TCPClient('create', olf.host, olf.port);    
    ok = TCPClient('connect', olf.handle);    
    if (isempty(ok) | ~ok),
      olf = Close(olf);
      error(sprintf('Connection to %s:%d failed.\n', olf.host, olf.port)); 
    end;
    
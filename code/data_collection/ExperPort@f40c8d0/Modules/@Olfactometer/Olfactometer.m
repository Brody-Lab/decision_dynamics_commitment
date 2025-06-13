%function [ olf ] = Olfactometer( varargin )
% Constructs an olfactometer and attempts to connect to the server.  Pass
% hostname, port as 2 args.  
% If no port arg is specified 3336 is used by default.
function [ olf ] = Olfactometer( varargin )
    if (nargin < 1), error('Please pass a hostname'); end;
    if (nargin > 2), error('Too many arguments'); end;
    host = varargin{1};
    port = 3336;
    if (nargin == 2), port = varargin{2}; end;
    if (~isnumeric(port)), error('Port argument needs to be numeric'); end;
    if (~ischar(host)),  error('Host argument needs to be a string'); end;
    
    olf = struct( ...
                'host', host, ...
                'port', port, ...
                'name', '', ...
                'description', '', ...
                'handle',-1, ...
                'banks', [],  ...
                'mixes', []   ...
                );    
    olf = class(olf, 'Olfactometer');
    
    olf.handle = TCPClient('create', olf.host, olf.port);    
    ok = TCPClient('connect', olf.handle);
    if (isempty(ok)), 
         olf = Close(olf);
         error(sprintf('Connection to %s:%d failed.\n', olf.host, olf.port)); 
    end;
    olf = ServerGetConfig(olf);
        
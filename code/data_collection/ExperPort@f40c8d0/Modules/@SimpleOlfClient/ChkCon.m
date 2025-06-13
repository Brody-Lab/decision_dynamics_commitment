% function [ olf ] = ChkCon( olf )
% Internal to olfactometer -- checks the status of the connection
function [ olf ] = ChkCon( olf )

    if (olf.handle < 0), error('Attempt to use an already-closed olfactometer!'); end;
    
    try 
        TCPClient('sendString', olf.handle, sprintf('NOOP\n'));
        ReceiveOK(olf, 'NOOP');
    catch
        TCPClient('disconnect', olf.handle);
        ok = TCPClient('connect', olf.handle);        
        if (isempty(ok) | isempty(TCPClient('sendString', olf.handle, sprintf('NOOP\n')))),
            error('ChkCon failed -- is the connection down?');
        end;
        ReceiveOK(olf);
    end;
    
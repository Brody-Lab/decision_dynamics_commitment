function [hash,mssg] = DataHash(file,hash_type)
    % calculates a cryptographic hash of a file for checking data
    % integrity.
    % uses the windows certutil function so is only supported on windows.
    % first input is the full file path, optional second input is the hash
    % type (SHA1 by default).
    %
    % output is the hash as a hex string. Optional second output is the output message of the certutil call.
    
    % Adrian Bondy, 5/2023
    
    % validate os
    if ~ispc
        error('DataHash only supported for Windows.');
    end
    
    % validate filename
    try
        if ~isfile(file)
            error('First function argument is not a valid filename.');
        end
    catch
        error('First function argument is not a valid filename.');        
    end
    
    % validate hash type
    if nargin>1
        validatestring(hash_type,{'MD2','MD4','MD5','SHA1','SHA256','SHA384','SHA512'},'DataHash','hash_type');
    else
        hash_type = 'SHA1';
    end
    
    % call certutil
    call_str = sprintf('certutil -hashfile %s %s',file,hash_type);
    [a,mssg] = system(call_str);
    
    % parse output
    if a~=0
        error(mssg);
    else
        parsed_mssg = strsplit(mssg,'\n');        
        hash = parsed_mssg{2};
    end
end

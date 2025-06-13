function [status]=check_connection(srvr)
% We decided to override this check: ---
status = 1;
return;
% -- end override

global global_check_flag;
% [status]=check_connection(srvr)
%
% This function uses ping to see if there is a connection to srvr
% if ping does not exist in the path, this will fail and report a failed
% connection.

if global_check_flag==0
   fprintf(2,'In check_connection global_check_flag set to 0, skipping check\n'); 
   status=1;
   return;
end

try
    if ispc
        s=1;
        cnt=0;
        while s==1 && cnt<3
            [s,r]=system(['ping -n 1 '  srvr]);
            cnt=cnt+1;
        end
    elseif strcmp(computer,'MAC') % there is no ismac function on old versions of matlab!
        [s,r]=system(['ping -c 10 -o '  srvr]);
        % on mac ping has an option to exit after the first
        % successful ping "-o".  This means that we will wait up to 10 seconds
        % or until the first successful ping, whichever comes first.
    else
        s=1;
        cnt=0;
        while s==1 && cnt<3
            [s,r]=system(['ping -c 1 '  srvr]);
            cnt=cnt+1;
        end
    end

    if s==0
        status=1;
    else
        status=0;
    end

catch
    status=1;
end
function varargout=bdata(sqlstr, varargin)
%function bdata
% connection_id=bdata
% out=bdata(sqlstr)
% out=bdata('connect',host,user,pass)
% connects to sql server via mym and maintains a connection id.
%
% See also MYM
%
%
% This bdata is compatible with mym 1.36 which returns a single struct output with each requested column as a fieldname.
% earlier versions of mym (<=1.0.9) will not work with this.
%

persistent CON_ID
persistent IP_ADDR
mhost='bdata00.pni.princeton.edu';

if ~isempty(CON_ID) && usejava('jvm')
    cur_addr=java.net.InetAddress.getLocalHost.getHostAddress;
    if ~isequal(cur_addr, IP_ADDR)
        CON_ID=[];
        fprintf(2,'IP address changed, discarding previous connection\n');
    end
end

try

    if nargin==0
        varargout{1}=CON_ID;
        return;
    end

    % first check that the server is there
    if ~check_connection(mhost)
        warning('bdata:noserver','Server is not accessible')
        CON_ID=[];
        varargout{1}=-1;
        return;
    end

    action=lower(strtok(sqlstr,' '));

    switch action,

        %% connect
        case 'connect'
            if nargin<4
                muser='user';
                mpass='pass';
            else
                mhost=varargin{1};
                muser=varargin{2};
                mpass=varargin{3};
            end

            try

                % mym supports multiple simultaneous connections.
                % Passing -1 asks for the next available connection id.
                setenv('LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN', '1')
                CON_ID=mym(-1, 'open',mhost,muser, mpass);
                mym(CON_ID,'use bdata');
                display('connected')
                varargout{1}=CON_ID;
                if usejava('jvm')
                    IP_ADDR = java.net.InetAddress.getLocalHost.getHostAddress;
                else
                    IP_ADDR=1;
                end
            catch me
                varargout{1}=-1;
                showerror(me);
                varargout{2}=me;
            end


            %% close
        case 'close'
            if isempty(CON_ID)
                warning('bdata:nohandle','No handle to bdata server')
            else
                varargout{1}=mym(CON_ID, 'close');
            end
            CON_ID=[];
            IP_ADDR=[];
            %% status
        case 'status'
            varargout{1}=mym(CON_ID, 'status');
            %% sql
        case {'select','insert','show','explain','describe','call','update'}  % this is an sql statment. 
            % by only allowing select and insert it means that properly
            % inserted data cannot be corrupted.

            if isempty(CON_ID)
                not_connected=1;
                fprintf(1,'First time connecting with bdata server since matlab start.\n');
            else
                not_connected=mym(CON_ID, 'status');
                if not_connected
                    warning('bdata:lostconnection','May have lost connection with mysql server');
                end
            end
            if not_connected
                [cid]=bdata('connect');

                % This prevents the code from looping endlessly if the server
                % isn't up.
                if cid==-1
                    warning('bdata:noserver','Failed to connect to bdata server');
                    return;
                end

            end


            %       mym can  be used like sprintf where place holders like "{S}"
            %       are placed in the sql statement and those are filled by a comma
            %       seperated list of variables.

            varlist='';
            if nargin>1
                vs=varargin;
%                 for vx=1:numel(vs)
%                     if (isscalar(vs{vx}) && isnan(vs{vx})) || isempty(vs{vx})
%                         vs{vx}='NULL';
%                     end
%                 end
                varlist=',vs{1}';
                for vx=2:numel(vs)
                    varlist=[varlist ', vs{' num2str(vx) '} '];
                end
            end

            %       When mym is used with no outputs it prints out a table.  However,
            %       we need to contruct a varargout string for the case where outputs
            %       are requested.
            %
            if nargout>0
                outstr='S=';
            else
                outstr='';
            end


            evalstr=[outstr 'mym(CON_ID,''' sqlstr ''''  varlist ');'];
            eval(evalstr)

            if nargout>0
                fn=fieldnames(S);
                for ox=1:nargout
                    varargout{ox}=S.(fn{ox});
                end
            end


        otherwise
            warning('Mysql:bdata',['The interface does not support the action: ' action])

    end

catch me
    if ~exist('evalstr','var')
        evalstr='';
    end
    fprintf(2,'ERROR in bdata: %s\n',evalstr);
    showerror(me)
end
end


function showerror(le)
    fprintf(1,'\n%s \n%s\n',le.identifier, le.message);
    for xi=1:numel(le.stack)
        fprintf(1,'On line %i of %s\n',le.stack(xi).line, le.stack(xi).file);
    end
end

function [obj, varargout] = runrats_wrapper(varargin)
%Wrapper for runrats with error reporting functionality:
%   Sundeep Tuteja, 2010-04-05


nout = max(nargout, 1) - 1;
if nout>=1
    output_args = cell(1, nout);
end
[do_debug, errID] = bSettings('get', 'GENERAL', 'do_debug');
if errID
    do_debug = false;
end

if do_debug
    if nargout>1
        [obj, output_args{:}] = runrats(varargin{:});
        varargout = output_args;
    elseif nargout==1
        obj = runrats(varargin{:});
    elseif nargout==0
        runrats(varargin{:});
    end
else
    try
        if nargout>1
            [obj, output_args{:}] = runrats(varargin{:});
            varargout = output_args;
        elseif nargout==1
            obj = runrats(varargin{:});
        elseif nargout==0
            runrats(varargin{:});
        end
    catch ME
        reporterror(ME);
        
        [unhandled_error_protocol errID] = bSettings('get', 'GENERAL', 'unhandled_error_protocol');
        if errID
            unhandled_error_protocol = false;
        end
        
        
        if unhandled_error_protocol
            try
                protocol_obj = dispatcher('get_protocol_object');
                if ismethod(protocol_obj, 'unhandled_error')
                    unhandled_error(protocol_obj, ME);
                end
            catch
                warning('Could not execute function unhandled_error');
            end
        end
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reporterror(ME)
%ME: MATLAB Exception object
rig_id = num2str(bSettings('get', 'RIGS', 'Rig_ID'));
identifier = ME.identifier;
message = ME.message;
message = strrep(message, '\', '\\');
message = strrep(message, '"', '\"');
datetimeval = datestr(now, 'yyyy-mm-dd HH:MM:SS');
file_path = ME.stack(1).file;
file_path = strrep(file_path, '\', '\\');
function_name = ME.stack(1).name;
line_number = num2str(ME.stack(1).line);

%Obtaining the complete error stack available
%stack_information is a cell array of strings having the format:
%"Line X, file C:\ratter\ExperPort\...\*.m, function <function_name>"
stack_information = cell(length(ME.stack), 1);
for ctr = 1:length(stack_information)
    stack_information{ctr} = ['Line ' num2str(ME.stack(ctr).line) ', File ' ME.stack(ctr).file ', Function ' ME.stack(ctr).name];
end

% sqlstr = ['INSERT INTO bdata.rig_error_log (rig_id, identifier, message, datetimeval, file_path, function_name, line_number) ' ...
%     'VALUES (' rig_id ', "' identifier '", "' message '", "' datetimeval '", "' file_path '", "' function_name '", ' line_number ')'];
% bdata(sqlstr);

contact_email_list={};
%Emailing the error to the experimenter and subscribe all users if applicable
[dummy1, dummy2, ratname] = runrats('get_experimenter_ratname_info');
sqlstr = ['SELECT DISTINCT contact FROM ratinfo.rats WHERE ratname="' ratname '"'];
contact_netid_list = bdata(sqlstr);
if ~isempty(contact_netid_list)
    contact_netid_list = regexprep(contact_netid_list, '\s+', '');
    ctr2 = 1;
    for ctr=1:length(contact_netid_list)
        contact_netid_list{ctr} = splitstr(contact_netid_list{ctr}, ',');
        for netid = contact_netid_list{ctr}
            contact_email_list{ctr2} = [netid{1} '@princeton.edu']; %#ok<AGROW>
            ctr2 = ctr2 + 1;
        end
    end
    %Retrieve email addresses of people that are set to subscribe_all
    sqlstr = 'SELECT DISTINCT email FROM ratinfo.contacts WHERE subscribe_all=TRUE AND is_alumni=0';
    contact_email_list = unique(lower([contact_email_list; bdata(sqlstr)]));
end

%Retrieve email addresses of people that are set to be the computer tech
sqlstr = 'SELECT DISTINCT email FROM ratinfo.contacts WHERE tech_computer=TRUE AND is_alumni=0';
contact_email_list = unique(lower([contact_email_list; bdata(sqlstr)]));

    
%Send email
if ~isempty(contact_email_list)
    oldpref_SMTP_Server = getpref('Internet', 'SMTP_Server');
    oldpref_E_mail = getpref('Internet', 'E_mail');
    setpref('Internet', 'SMTP_Server', 'sonnabend.princeton.edu');
    setpref('Internet', 'E_mail', 'root@sonnabend.princeton.edu');
    subjectstr = ['Unhandled exception encountered: Rig ' rig_id ', ' ratname];
    messagecellstr = {['Identifier: ' identifier], ...
        ['Message: ' sprintf(message)], ...
        ['Timestamp: ' datetimeval], ...
        ['File Path: ' sprintf(file_path)], ...
        '', ...
        '===============================' ...
        'Stack Information' ...
        '===============================' ...
        stack_information{:} ...
        };
        
    sendmail(contact_email_list, subjectstr, messagecellstr);
    setpref('Internet', 'SMTP_Server', oldpref_SMTP_Server);
    setpref('Internet', 'E_mail', oldpref_E_mail);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
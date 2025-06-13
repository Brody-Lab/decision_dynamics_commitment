% <~> function: contact_experimenter
%     sends email to the experimenter whose name is provided
%
%     This function is written for the Brody Lab configuration, as it uses
%       our MySQL tables. (Setting check:  GENERAL;Lab;Brody)
%
%     Expects three arguments, all strings:
%
%       strExp      name of the experimenter (case insensitive)
%       strSubject  subject of the email
%       strMessage  body of the email
%
%     Example call:
%       contact_experimenter('Chuck','error in your protocol', ...
%           'blah blah blah blah. error description.');
%
function [errID errmsg] = contact_experimenter(strExp,strSubject,strMessage)
%     Check Lab flag.
if ~bSettings('compare','GENERAL','Lab','Brody'),
    errID = 1; errmsg = 'contact_experimenter is only intended for the Brody Lab. (The setting GENERAL;Lab; is not set to Brody.)';
    warning(errmsg); %#ok<WNTAG>
    return;
end;
errID = -1; errmsg = ''; %#ok<NASGU>


%     Constants
nameContactTable      = getZutConstant('nameContactTable');

%     Argument Checking.
%     We need three arguments, each of which is a string.
error(nargchk(3,3,nargin,'struct'));
if ~ischar(strExp) || ~ischar(strSubject) || ~ischar(strMessage),
    errID = 1; errmsg = 'contact_experimenter requires three string arguments: experimenter, subject, and message body.'; %#ok<NASGU>
    error(errmsg);
end;

%     Clean the string of all characters that aren't letters, numbers, or
%       the underscore. Report an error if the name contains unusual
%       characters.
strExp_clean = textscan(strExp,'%[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890]');
if         isempty(strExp_clean)                ...
        || isempty(strExp_clean{1})             ...
        || isempty(strExp_clean{1}{1})          ...
        || ~strcmp(strExp_clean{1}{1},strExp),
    errID = 1; errmsg = 'contact_experimenter expects experimenter names that consist only of letters, numbers, and the underscore character.'; %#ok<NASGU>
    error(errmsg);
end;


%     Fetch email address.
try
    strEmailAddress = bdata(['select email from ' nameContactTable ' where experimenter="' lower(strExp) '"']);
    strEmailAddress = strEmailAddress{1};
catch
    strEmailAddress = '';
    structLastErr = lasterror;
    warning(structLastErr);
end;

%     Return with an error ID == 1 if we couldn't get an email address.
if isempty(strEmailAddress),
    display('Not sending email.');
    errID = 1;
    errmsg = ['Unable to fetch experimenter email from the contact information mysql table (' nameContactTable '). Not sending email.'];
    return;
end;


%     Make sure that the MATLAB settings are set such that sending email
%       will work.
prefsI = getpref('Internet');
noNetPrefs = isempty(prefsI); %     If the group 'Internet' is empty,
if ~noNetPrefs,
    try
        getpref('Internet','SMTP_Server');
        getpref('Internet','E_mail');
    catch                     %     or if there is no SMTP_Server or E_mail setting,
        noNetPrefs = 1;
    end;
end;
if noNetPrefs,                %     then we should set those two settings ourselves.
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',[get_hostname '@brodylab.princeton.edu']);
    set_email_sender
end;



%     Send the email to the experimenter.
sendmail(strEmailAddress,strSubject,strMessage);

errID = 0;

end %     end of function contact_experimenter

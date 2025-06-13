function send_text_message(message,subject,recipient)

if nargin < 3; disp('Must supply message, subject, and recipient.'); return; end

[T,C,M] = bdata(['select telephone, phone_carrier, email from ratinfo.contacts where experimenter="',recipient,'" and is_alumni=0']);

if isempty(C) || (iscell(C) && isempty(C{1}))
    disp('Recipient has no phone carrier specified.');
    return;
end

M = M{1};
C = C{1};


switch lower(C)
    case 'alltel';    emailto = strcat(num2str(T),'@message.alltel.com');
    case 'att';       emailto = strcat(num2str(T),'@txt.att.net');
    case 'boost';     emailto = strcat(num2str(T),'@myboostmobile.com');
    case 'cingular';  emailto = strcat(num2str(T),'@cingularme.com');
    case 'cingular2'; emailto = strcat(num2str(T),'@mobile.mycingular.com');
    case 'cricket';   emailto = strcat(num2str(T),'@sms.mycricket.com');
    case 'google';    emailto = strcat(num2str(T),'@msg.fi.google.com');
    case 'metropcs';  emailto = strcat(num2str(T),'@mymetropcs.com');
    case 'nextel';    emailto = strcat(num2str(T),'@messaging.nextel.com');
    case 'sprint';    emailto = strcat(num2str(T),'@messaging.sprintpcs.com');
    case 'ting';      emailto = strcat(num2str(T),'@message.ting.com');
    case 'tmobile';   emailto = strcat(num2str(T),'@tmomail.net');
    case 'verizon';   emailto = strcat(num2str(T),'@vtext.com');
    case 'virgin';    emailto = strcat(num2str(T),'@vmobl.com');
    case 'email';     emailto = M;
    otherwise;        emailto = '';
end

emailto(strcmp(emailto,'')) = [];

set_email_sender

sendmail(emailto,subject,message)




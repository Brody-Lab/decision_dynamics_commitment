function send_emergency_alert(message,name,varargin)

%[E,T,C,M] = bdata('select experimenter, telephone, phone_carrier, email from ratinfo.contacts where is_alumni=0');
E = bdata('select experimenter from ratinfo.contacts where is_alumni=0');

if nargin < 1
    message = ['This is a test of the Brody Lab Emergency Text Alert System. If you are receiving ',...
               'this message it is because you are listed as a current member of the Brody Lab.  ',...
               'Do not respond to this text.  Please send a confirmation text to Chuck.'];
end
if nargin < 2; name = 'Unknown'; end

subject = ['BrodyLab Emergency from ',name];

for i = 1:numel(E)
    send_text_message(message,subject,E{i})
end

return
% E(strcmp(C,'')) = [];
% T(strcmp(C,'')) = [];
% M(strcmp(C,'')) = [];
% C(strcmp(C,'')) = [];
% 
% for i = 1:numel(E)
%     switch lower(C{i})
%         case 'alltel';    emailto{i} = strcat(num2str(T(i)),'@message.alltel.com');
%         case 'att';       emailto{i} = strcat(num2str(T(i)),'@txt.att.net');
%         case 'boost';     emailto{i} = strcat(num2str(T(i)),'@myboostmobile.com');
%         case 'cingular';  emailto{i} = strcat(num2str(T(i)),'@cingularme.com');
%         case 'cingular2'; emailto{i} = strcat(num2str(T(i)),'@mobile.mycingular.com');
%         case 'cricket';   emailto{i} = strcat(num2str(T(i)),'@sms.mycricket.com');
%         case 'metropcs';  emailto{i} = strcat(num2str(T(i)),'@metropcs.sms.us');
%         case 'nextel';    emailto{i} = strcat(num2str(T(i)),'@messaging.nextel.com');
%         case 'sprint';    emailto{i} = strcat(num2str(T(i)),'@messaging.sprintpcs.com');
%         case 'tmobile';   emailto{i} = strcat(num2str(T(i)),'@tmomail.net');
%         case 'verizon';   emailto{i} = strcat(num2str(T(i)),'@vtext.com');
%         case 'virgin';    emailto{i} = strcat(num2str(T(i)),'@vmobl.com');
%         case 'email';     emailto{i} = M{i};
%         otherwise;        emailto{i} = '';
%     end
% end
% emailto(strcmp(emailto,'')) = [];
% 
% set_email_sender
% sendmail(emailto,subject,message)




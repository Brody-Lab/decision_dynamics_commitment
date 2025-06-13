function send_massdrop_text(handles,mas)

str = get(handles.ratname_list,'string');
rtn = get(handles.ratname_list,'value');

if isempty(str) || rtn == 0; return; end
temp = str{rtn};

ratname = temp(1:4);

cnt = bdata(['select contact from ratinfo.rats where ratname="',ratname,'"']);
cnt = cnt{1};

brks = find(cnt == ',' | cnt == ' ');
brks = [0,brks,numel(cnt)+1];
N = cell(0);
for i = 1:numel(brks)-1
    temp = cnt(brks(i)+1:brks(i+1)-1);
    if ~isempty(temp)
        N{end+1} = temp; %#ok<AGROW>
    end
end

if isempty(N); return; end

[E,M,T,C,I] = bdata('select experimenter, email, telephone, phone_carrier, initials from ratinfo.contacts where is_alumni=0');

t = []; e = cell(0); c = cell(0); m = cell(0);
for i = 1:numel(N)
    for j = 1:numel(M)
        if strcmp(M{j}(1:find(M{j}=='@',1,'first')-1),N{i})
            t(end+1) = T(j); %#ok<AGROW>
            e{end+1} = E{j}; %#ok<AGROW>
            c{end+1} = C{j}; %#ok<AGROW>
            m{end+1} = M{j}; %#ok<AGROW>
        end
    end
end

subject = [ratname,' Mass Drop'];

emailto = cell(0);
for i = 1:numel(e)
    switch lower(c{i})
        case 'alltel';    emailto{i} = strcat(num2str(t(i)),'@message.alltel.com');
        case 'att';       emailto{i} = strcat(num2str(t(i)),'@txt.att.net');
        case 'boost';     emailto{i} = strcat(num2str(t(i)),'@myboostmobile.com');
        case 'cingular';  emailto{i} = strcat(num2str(t(i)),'@cingularme.com');
        case 'cingular2'; emailto{i} = strcat(num2str(t(i)),'@mobile.mycingular.com');
        case 'cricket';   emailto{i} = strcat(num2str(t(i)),'@sms.mycricket.com');
        case 'google';    emailto{i} = strcat(num2str(t(i)),'@msg.fi.google.com');
        case 'metropcs';  emailto{i} = strcat(num2str(t(i)),'@metropcs.sms.us');
        case 'nextel';    emailto{i} = strcat(num2str(t(i)),'@messaging.nextel.com');
        case 'sprint';    emailto{i} = strcat(num2str(t(i)),'@messaging.sprintpcs.com');
        case 'ting';      emailto{i} = strcat(num2str(t(i)),'@message.ting.com');
        case 'tmobile';   emailto{i} = strcat(num2str(t(i)),'@tmomail.net');
        case 'verizon';   emailto{i} = strcat(num2str(t(i)),'@vtext.com');
        case 'virgin';    emailto{i} = strcat(num2str(t(i)),'@vmobl.com');
        case 'email';     emailto{i} = m{i};
        otherwise;        emailto{i} = '';
    end
end
emailto(strcmp(emailto,'')) = [];

if isempty(emailto); return; end

set_email_sender

%ndt = bdata(['select n_done_trials from sessions where sessiondate>"',datestr(now-4,'yyyy-mm-dd'),'" and ratname="',ratname,'"']);
%mas = bdata(['select mass from ratinfo.mass where date>"',datestr(now-4,'yyyy-mm-dd'),'" and ratname="',ratname,'"']);

if numel(mas) > 4; mas(5:end) = []; end
mas = mas(end:-1:1);

if numel(mas) > 1
    
    p = num2str((round(((mas(end-1)-mas(end))/mas(end-1))*1e3))/10);
    message = [ratname,' dropped by ',num2str(mas(end-1)-mas(end)),'g, ',...
               p,'%. Contact ',E{strcmp(I,handles.active_user)},' ',...
               num2str(T(strcmp(I,handles.active_user))),...
               ' if this is a problem. Previous mass: ',num2str(mas')];

    sendmail(emailto,subject,message);
end



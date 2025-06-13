function view_your_rats(experimenter_name)

email = bdata(['select email from ratinfo.contacts where experimenter="',experimenter_name,'"']);
email = email{1};
contact = email(1:find(email=='@')-1);

allrats = bdata(['select ratname from ratinfo.rats where extant=1 and contact like "%',contact,'%"']);

[HN,RN] = bdata(['select hostname, ratname from sess_started where sessiondate="',...
    datestr(now,'yyyy-mm-dd'),'" and was_ended=0']);

for i = 1:numel(RN)
    if sum(strcmp(allrats,RN{i}))>0
        R = str2num(HN{i}(find(HN{i}=='g')+1:end));

        disp(['Viewing ',RN{i},' on Rig ',num2str(R)]);

        IP = bdata(['select ip_addr from ratinfo.riginfo where rigid=',num2str(R)]);
        system(['vncviewer ',IP{1},':5900 &']);
    end
end
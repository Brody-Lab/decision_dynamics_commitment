function checkscheduleproblems

try 
    try 
        riglist = bdata(['SELECT DISTINCT rig FROM ratinfo.schedule WHERE date="',datestr(now, 29),'"']);
    catch %#ok<CTCH>
        bdata('connect');
        riglist = bdata(['SELECT DISTINCT rig FROM ratinfo.schedule WHERE date="',datestr(now, 29),'"']);
    end

    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['ScheduleMeister',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    rigs = riglist.rig;

    notextant          = cell(0);
    freewatertrain     = cell(0);
    doublerigsameslot  = cell(0);
    notextantcagemate  = cell(0);
    unbalancedcagemate = cell(0);
    mateislate         = cell(0);
    mateisearly        = cell(0);
    waterislate        = cell(0);

    output = []; %#ok<NASGU>

    for slot = 1:6
        for rig = rigs'

            temp1 = bdata(['SELECT DISTINCT ratname FROM ratinfo.schedule WHERE timeslot="',num2str(slot),'" AND rig="',num2str(rig),'" AND date="',datestr(now,29),'"']);
            if isempty(temp1.ratname); continue; end
            ratname = temp1.ratname{1};
            if isempty(ratname); continue; end

            temp2 = bdata(['SELECT DISTINCT extant FROM ratinfo.rats WHERE ratname="',ratname,'"']);
            extant = temp2.extant;

            if extant == 0; notextant{end+1} = ratname; end %#ok<AGROW>

            temp3 = bdata(['SELECT DISTINCT forceFreeWater FROM ratinfo.rats WHERE ratname="',ratname,'"']);
            freewater = temp3.forceFreeWater;

            if freewater == 1; freewatertrain{end+1} = ratname; end %#ok<AGROW>

            temp4 = bdata(['SELECT DISTINCT rig FROM ratinfo.schedule WHERE ratname="',ratname,'" AND timeslot="',num2str(slot),'" AND date="',datestr(now,29),'"']);
            rigtemp = temp4.rig;

            if length(rigtemp) > 1; doublerigsameslot{end+1} = ratname; end %#ok<AGROW>
            
            temp5 = bdata(['SELECT DISTINCT cagemate FROM ratinfo.rats WHERE ratname="',ratname,'"']);
            if ~isempty(temp5.cagemate); cagemate = temp5.cagemate{1};
            else                         cagemate = '';
            end
            
            temp9 = bdata(['SELECT DISTINCT forceDepWater FROM ratinfo.rats WHERE ratname="',ratname,'"']);
            ratwater = temp9.forceDepWater;
            
            if length(cagemate) > 1 
                temp6 = bdata(['SELECT DISTINCT extant FROM ratinfo.rats WHERE ratname="',cagemate,'"']);
                extantmate = temp6.extant;
                
                if extantmate == 0; notextantcagemate{end+1} = ratname; end %#ok<AGROW>
                
                temp7 = bdata(['SELECT DISTINCT cagemate FROM ratinfo.rats WHERE ratname="',cagemate,'"']);
                cagematemate = temp7.cagemate{1};
                
                if isempty(cagematemate) || ~strcmp(cagematemate,ratname); unbalancedcagemate{end+1} = ratname; end  %#ok<AGROW>
                
                temp8 = bdata(['SELECT DISTINCT timeslot FROM ratinfo.schedule WHERE ratname="',cagemate,'" AND date="',datestr(now,29),'"']);
                mateslot = temp8.timeslot;
                
                if ~isempty(mateslot)
                    if     slot     == 1 && mateslot >= 3; mateislate{end+1} = ratname; %#ok<AGROW>
                    elseif mateslot == 1 && slot     >= 3; mateisearly{end+1} = ratname;  %#ok<AGROW>
                    end
                end
                
                temp10 = bdata(['SELECT DISTINCT forceDepWater FROM ratinfo.rats WHERE ratname="',cagemate,'"']);
                matewater = temp10.forceDepWater;
                if matewater > ratwater; ratwater = matewater; end
                
            end

            if slot == 1 && ratwater >= 3; waterislate{end+1} = ratname; end %#ok<AGROW>
        end
    end

    doublerigsameslot = unique(doublerigsameslot);
    BadRats = cell(0);
    for i = 1:length(notextant);          BadRats{end+1} = notextant{i};          end %#ok<AGROW>
    for i = 1:length(freewatertrain);     BadRats{end+1} = freewatertrain{i};     end %#ok<AGROW>
    for i = 1:length(doublerigsameslot);  BadRats{end+1} = doublerigsameslot{i};  end %#ok<AGROW>
    for i = 1:length(notextantcagemate);  BadRats{end+1} = notextantcagemate{i};  end %#ok<AGROW>
    for i = 1:length(unbalancedcagemate); BadRats{end+1} = unbalancedcagemate{i}; end %#ok<AGROW>
    for i = 1:length(mateislate);         BadRats{end+1} = mateislate{i};         end %#ok<AGROW>
    for i = 1:length(mateisearly);        BadRats{end+1} = mateisearly{i};        end %#ok<AGROW>
    for i = 1:length(waterislate);        BadRats{end+1} = waterislate{i};        end %#ok<AGROW>
    BadRats = unique(BadRats);

    x = bdata('SELECT DISTINCT email FROM ratinfo.contacts');
    Exp = x.email;
    
    for e = 1:length(Exp)
        expname = bdata(['SELECT DISTINCT experimenter FROM ratinfo.contacts WHERE email="',Exp{e},'"']);
        expname = expname.experimenter{1};
        tempemail = Exp{e}(1:find(Exp{e} == '@',1,'first')-1);
        rattemp = cell(0);
        for r = 1:length(BadRats)
            sqlstr = ['SELECT DISTINCT contact FROM ratinfo.rats WHERE ratname="',BadRats{r},'"'];
            z = bdata(sqlstr);
            expswap = parse_emails(z.contact{1});
            if sum(strcmp(expswap,tempemail)) > 0
                rattemp{end+1} = BadRats{r}; %#ok<AGROW>
            end
        end
        if isempty(rattemp); continue; end
        
        message = cell(0);

        for j = 1:length(notextant); 
            if sum(strcmp(rattemp,notextant{j})) > 0
                message{end+1} = [notextant{j},' is on the schedule but is listed as not extant in the registry.']; %#ok<AGROW>
            end
        end
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(freewatertrain); 
            if sum(strcmp(rattemp,freewatertrain{j})) > 0
                message{end+1} = [freewatertrain{j},' is on the schedule but is currently receiving free water.']; %#ok<AGROW>
            end
        end
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(doublerigsameslot);
            if sum(strcmp(rattemp,doublerigsameslot{j})) > 0
                message{end+1} = [doublerigsameslot{j},' is scheduled to train in two rigs in the same session.']; %#ok<AGROW>
            end
        end
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(notextantcagemate);
            if sum(strcmp(rattemp,notextantcagemate{j})) > 0
                message{end+1} = [notextantcagemate{j},' has a cagemate who is listed as not extant.']; %#ok<AGROW>
            end
        end
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(unbalancedcagemate);
            if sum(strcmp(rattemp,unbalancedcagemate{j})) > 0
                message{end+1} = [unbalancedcagemate{j},' has a cagemate whose cagemate is not ',unbalancedcagemate{j},'.']; %#ok<AGROW>
            end
        end   
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(mateislate);
            if sum(strcmp(rattemp,mateislate{j})) > 0
                message{end+1} = [mateislate{j},' runs in shift 1 while his cagemate runs after shift 2.']; %#ok<AGROW>
            end
        end  
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(mateisearly);
            if sum(strcmp(rattemp,mateisearly{j})) > 0
                message{end+1} = [mateisearly{j},' runs after shift 2 while his cagemate runs in shift 1.']; %#ok<AGROW>
            end
        end  
        message{end+1} = '  '; %#ok<AGROW>
        for j = 1:length(waterislate);
            if sum(strcmp(rattemp,waterislate{j})) > 0
                message{end+1} = [waterislate{j},' runs in shift 1 but gets water after shift 2.']; %#ok<AGROW>
            end
        end 
                
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = 'Please fix these problems prompty.'; %#ok<AGROW>
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = 'Thanks,'; %#ok<AGROW>
        message{end+1} = 'The Schedule Meister'; %#ok<AGROW>
        message{end+1} = '  ';                                                              %#ok<AGROW>
        message{end+1} = '  ';                                                              %#ok<AGROW>
        message{end+1} = 'This email was generated by the Brody Lab Automated Email System.'; %#ok<AGROW>

        IP = get_network_info;
        message{end+1} = ' '; %#ok<AGROW>
        if ischar(IP); message{end+1} = ['Email generated by ',IP]; %#ok<AGROW>
        else           message{end+1} = 'Email generated by an unknown computer!!!'; %#ok<AGROW>
        end

        message = remove_duplicate_lines(message);
        sendmail(Exp{e},'Scheduler Problems Detected',message);
        eval(['output.',expname,' = message;']);

    end
    

    %if ~isempty(output)
        LTR = 'abcdefghijklmnopqrstuvwxyz';
        for ltr = 1:26
            file = ['C:\Automated Emails\Schedule\Problems\',yearmonthday,LTR(ltr),'_ScheduleProblem_Email.mat'];
            if ~exist(file,'file'); save(file,'output'); break; end    
        end
    %end
catch     %#ok<CTCH>
    senderror_report;
end

    
    
    

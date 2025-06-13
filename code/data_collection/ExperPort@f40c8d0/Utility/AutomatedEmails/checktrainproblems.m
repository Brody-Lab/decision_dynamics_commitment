function checktrainproblems

try 
    rigs = bdata(['SELECT DISTINCT rig FROM ratinfo.schedule WHERE date="',datestr(now, 29),'"']);

    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['ScheduleMeister',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    istodaysunday = strcmp(datestr(now,'ddd'),'Sun');

    morning = cell(0);
    evening = cell(0);

    output = [];

    for slot = 1:6
        for rig = rigs'
            temp = bdata(['SELECT DISTINCT ratname FROM ratinfo.schedule WHERE rig="',num2str(rig),'" AND timeslot="',num2str(slot),'" AND date="',datestr(now,29),'"']);
            if isempty(temp.ratname); continue; end
            ratname = temp.ratname{1};
            if isempty(ratname); continue; end
            
            contact = bdata(['SELECT DISTINCT contact FROM ratinfo.rats WHERE ratname="',ratname,'"']);
            contact = parse_emails(contact.contact{1});
            Expname = cell(0);
            for e = 1:length(contact)
                temp = bdata(['SELECT DISTINCT experimenter FROM ratinfo.contacts WHERE email="',[contact{e},'@princeton.edu'],'"']);
                Expname{e} = temp.experimenter{1};
            end
            temp = bdata('SELECT DISTINCT experimenter FROM ratinfo.contacts WHERE subscribe_all=1');
            Expname(end+1:end+length(temp.experimenter)) = temp.experimenter;
            Expname = unique(Expname);
            
            for e = 1:length(Expname)
                expname = Expname{e};
                if ~isfield(output,expname); eval(['output.',expname,' = cell(0);']); end

                temp = bdata(['SELECT DISTINCT starttime FROM sess_started WHERE ratname="',ratname,'" AND sessiondate="',datestr(now,29),'"']);
                if isempty(temp.starttime); Ts = ''; else Ts = temp.starttime{1}; end
                if isempty(Ts)
                    mtemp = [ratname,' was scheduled to run in rig ',num2str(rig),' session ',num2str(slot),' but did not appear to run anywhere.'];
                    if slot <= 3; morning{end+1} = mtemp;  %#ok<AGROW>
                    else          evening{end+1} = mtemp;  %#ok<AGROW>
                    end
                    eval(['output.',expname,'{end+1} = mtemp;']);
                    continue;
                end

                temp = bdata(['SELECT DISTINCT Hostname FROM sess_started WHERE ratname="',ratname,'" AND sessiondate="',datestr(now,29),'"']);
                if isempty(temp.Hostname); Rg{1} = 'Rig00'; else Rg = temp.Hostname; end

                RealRg = [];
                for r = 1:length(Rg)
                    if     length(Rg{r}) == 5; RealRg(r) = str2num(Rg{r}(4:5));  %#ok<AGROW,ST2NM>
                    elseif length(Rg{r}) >  5; RealRg(r) = str2num(Rg{r});       %#ok<AGROW,ST2NM>
                    end
                end

                if sum(RealRg) == 0
                    mtemp = [ratname,' started today at ',Ts,' and was scheduled to run in rig ',num2str(rig),' session ',num2str(slot),' but no RigID was logged in the sess_started table.']; %#ok<NASGU>
                    eval(['output.',expname,'{end+1} = mtemp;']);
                elseif all(RealRg ~= rig)
                    mtemp = [ratname,' ran in rig ',num2str(RealRg),' today but was scheduled to run in rig ',num2str(rig),' session ',num2str(slot),'.']; %#ok<NASGU>
                    eval(['output.',expname,'{end+1} = mtemp;']);
                end

                temp = bdata(['SELECT DISTINCT was_ended FROM sess_started WHERE ratname="',ratname,'" AND sessiondate="',datestr(now,29),'"']);
                if isempty(temp.was_ended); was_ended = []; else was_ended = temp.was_ended; end
                if was_ended == 0
                    mtemp = [ratname,' was started in rig ',num2str(rig),' session ',num2str(slot),' at ',Ts,' but has not ended.']; %#ok<NASGU>
                    eval(['output.',expname,'{end+1} = mtemp;']);
                    continue;
                elseif isempty(was_ended); continue;
                end

                temp = bdata(['SELECT DISTINCT Endtime FROM sessions WHERE ratname="',ratname,'" AND sessiondate="',datestr(now,29),'"']);
                Te = temp.Endtime;
                temp = bdata(['SELECT DISTINCT starttime FROM sess_started WHERE ratname="',ratname,'" AND sessiondate="',datestr(now,29),'"']);
                Ts = temp.starttime;
                total_runtime = []; inslot = [];
                for i = 1:length(Te)
                    total_runtime(i) = round(timediff(Ts{i},Te{i},2) / 60); %#ok<AGROW>
                    inslot(i) = checkruninslot(Ts{i},Te{i},slot); %#ok<AGROW>
                end
                
                TN1 = bdata('select technotes from technician_notes_tbl where ratname="{S}" and sessiondate="{S}"',ratname,datestr(now,29));
                TN2 = bdata('select technotes from technician_notes_tbl where rig_id="{Si}" and sessiondate="{S}"',rig,    datestr(now,29));
                
                clear TN3
                for r = 1:length(RealRg)
                    TN3{r} = bdata('select technotes from technician_notes_tbl where rig_id="{Si}" and sessiondate="{S}"',RealRg(r), datestr(now,29)); %#ok<AGROW>
                end
                
                if all(total_runtime < 60) %in minutes
                    mtemp = [ratname,' ran for only ',num2str(max(total_runtime)),' minutes today in session ',num2str(slot),'.']; %#ok<NASGU>
                    eval(['output.',expname,'{end+1} = mtemp;']);
                end

                if istodaysunday == 0
                    if all(inslot ~= 0)
                        for i = 1:length(inslot)
                            if inslot(i) == -1
                                mtemp = [ratname,' ran from ',Ts{i},' to ',Te{i},' which is before his scheduled time of session ',num2str(slot)]; %#ok<NASGU>
                                eval(['output.',expname,'{end+1} = mtemp;']);
                            end
                            if inslot(i) == 1
                                mtemp = [ratname,' ran from ',Ts{i},' to ',Te{i},' which is after his scheduled time of session ',num2str(slot)]; %#ok<NASGU>
                                eval(['output.',expname,'{end+1} = mtemp;']);
                            end
                        end
                    end
                end

                if ~isempty(TN1)
                    for n = 1:length(TN1)
                        if ~isempty(TN1{n})
                            mtemp = [ratname,' TechNotes: ',TN1{n}]; %#ok<NASGU>
                            eval(['output.',expname,'{end+1} = mtemp;']);
                        end
                    end
                elseif ~isempty(TN2)
                    for n = 1:length(TN2)
                        if ~isempty(TN2{n})
                            mtemp = ['Rig ',num2str(rig),' TechNotes: ',TN2{n}]; %#ok<NASGU>
                            eval(['output.',expname,'{end+1} = mtemp;']);
                        end
                    end
                elseif ~isempty(TN3)
                    for n = 1:length(TN3)
                        if ~isempty(TN3{n})
                            mtemp = ['Rig ',num2str(RealRg),' TechNotes: ',TN3{n}]; %#ok<NASGU>
                            eval(['output.',expname,'{end+1} = mtemp;']);
                        end
                    end
                end
                
            end
            
        end
    end
    
    
    BadE = fields(output);
    
    for E = 1:length(BadE);
        eval(['test1 = isempty(output.',BadE{E},');']);
        if test1 == 1; continue; end
        
        x = bdata(['SELECT DISTINCT email FROM ratinfo.contacts WHERE experimenter="',BadE{E},'"']);
        email = x.email;
        
        eval(['message = output.',BadE{E},';']);
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = 'If a message claims a rat started but has not ended it is likely the rig broke during the run.'; %#ok<AGROW>
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = 'Thanks,'; %#ok<AGROW>
        message{end+1} = 'The Schedule Meister'; %#ok<AGROW>
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = '  '; %#ok<AGROW>
        message{end+1} = 'This email was generated by the Brody Lab Automated Email System.'; %#ok<AGROW>

        message = remove_duplicate_lines(message);
        sendmail(email,'Potential Training Problems',message);            
       
    end
    
    for S = 1:2
        if S == 1; message = morning;
            E = bdata('SELECT DISTINCT email FROM ratinfo.contacts WHERE tech_morning=1');
            email = E.email;
            temp = bdata('SELECT DISTINCT email FROM ratinfo.contacts WHERE subscribe_all=1');
            email(end+1:end+length(temp.email)) = temp.email;
            email = unique(email);
        else       message = evening;
            E = bdata('SELECT DISTINCT email FROM ratinfo.contacts WHERE tech_afternoon=1');
            email = E.email;
            temp = bdata('SELECT DISTINCT email FROM ratinfo.contacts WHERE subscribe_all=1');
            email(end+1:end+length(temp.email)) = temp.email;
            email = unique(email);
        end
        
        if ~isempty(message)
            message{end+1} = '  '; %#ok<AGROW>
            message{end+1} = '  '; %#ok<AGROW>
            message{end+1} = 'It is possible these rats did train but their data was not committed to the server.'; %#ok<AGROW>
            message{end+1} = 'If you believe that to be the case please contact the appropriate experimenter.'; %#ok<AGROW>
            message{end+1} = '  '; %#ok<AGROW>
            message{end+1} = 'Thanks,'; %#ok<AGROW>
            message{end+1} = 'The Schedule Meister'; %#ok<AGROW>
            message{end+1} = '  '; %#ok<AGROW>
            message{end+1} = '  '; %#ok<AGROW>
            message{end+1} = 'This email was generated by the Brody Lab Automated Email System.'; %#ok<AGROW>
            
            if ~istodaysunday
                %Dont send emails on Sunday to the regular techs, but the
                %message is still logged.
                
                message = remove_duplicate_lines(message);
                sendmail(email,'Possible Rats Did Not Run',message);
            
                for e = 1:length(email)
                    temp = bdata(['SELECT DISTINCT experimenter FROM ratinfo.contacts WHERE email="',email{e},'"']);
                    eval(['output.',temp.experimenter{1},' = message;']);
                end
            else
                if S == 1; output.Sunday_Morning = message;
                else       output.Sunday_Evening = message;
                end
            end
        end
    end
    
    LTR = 'abcdefghijklmnopqrstuvwxyz';
    for ltr = 1:26
        file = ['C:\Automated Emails\Schedule\NoRun\',yearmonthday,LTR(ltr),'_TrainProblem_Email.mat'];
        if ~exist(file,'file'); save(file,'output'); break; end    
    end
catch %#ok<CTCH>
    senderror_report;
end






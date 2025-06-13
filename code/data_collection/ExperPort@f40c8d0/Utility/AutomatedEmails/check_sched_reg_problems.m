function check_sched_reg_problems

try 
    [Rigs,RatSC,Slots]                     = bdata(['select rig, ratname, timeslot from ratinfo.schedule where date="',datestr(now, 29),'"']);
    [Contacts,RatR,extant,DepWR,FreeWR,CM] = bdata('select contact, ratname, extant, forceDepWater, forceFreeWater, cagemate from ratinfo.rats');
    [Exps,Emails,Alum,LM]                  = bdata('select experimenter, email, is_alumni, lab_manager from ratinfo.contacts');
    
    set_email_sender
        
    AllRats = unique([RatSC;RatR]); AllRats(strcmp(AllRats,'')) = [];
    
    WL = WM_rat_water_list(1,[],'all',datestr(now,'yyyy-mm-dd'),1,2);
    
    for i = 1:length(Emails); emailid{i} = Emails{i}(1:find(Emails{i}=='@',1,'first')-1); end
    
    %Check all extant rats
    for i = 1:length(AllRats)
        ratname = AllRats{i};
        
        if strcmp(ratname,'') || strcmp(ratname,'sen1') || strcmp(ratname,'sen2') || ratname(1) == '0'; continue; end
        
        M = cell(0);
        train = strcmp(RatSC,ratname);
        regpos = strcmp(RatR,ratname);
        
        cm = CM{regpos};
        cmtrain = strcmp(RatSC,cm);
                
        if sum(train) > 0
            for z = 1:1 %Use a loop so its easy to break out
                %This is a training rat, check for training problems
                slot = Slots(train);
                
                %Is this rat on the schedule but marked as extant = 0?
                if extant(regpos) == 0
                    M{end+1} = [ratname,' is on the schedule to train but is listed as not extant in the registry.'];
                    break;
                end
                
                %Is this rat on the schedule but makred to get free water?
                if FreeWR(regpos) == 1
                    M{end+1} = [ratname,' is on the schedule to trian but is listed to receive free water in the registry.'];
                end
                
                %Is this rat scheduled to train in 2 rigs in the same session?
                if sum(train) > 1 && length(slot) > length(unique(slot))
                    M{end+1} = [ratname,' is scheduled to train in two rigs in the same session.'];
                end
                
                %Does this rat run in any shift 1-3 but get water after shift 3?
                if min(slot) <= 3 && (sum(strcmp(ratname,WL{1}(:))) == 0 && sum(strcmp(ratname,WL{2}(:))) == 0 && sum(strcmp(ratname,WL{3}(:))) == 0)
                    M{end+1} = [ratname,' is scheduled to trian before session 4 but receive water after session 3.'];
                end
                
                %Does this rat run in shift 4 but get water after shift 5?
                if slot(1) == 4 && (sum(strcmp(ratname,WL{4}(:))) == 0 && sum(strcmp(ratname,WL{5}(:))) == 0)
                    M{end+1} = [ratname,' is scheduled to trian in session 4 but receive water after session 5.'];
                end
                
                if strcmp(cm,'') == 0 && sum(cmtrain) > 0
                    %The cagemate trains as well, check for conflicts
                    cmslot = Slots(cmtrain);
                    
                    %Does this rat train in session 4 and his cagemate trains after session 4?
                    if any(slot == 4) && all(cmslot > 4)
                        M{end+1} = [ratname,' is scheduled to train in session 4 but his cagemate trains after session 4.'];
                    end
                    
                    %Does this rat train in session 1-3 and his cagemate trains after session 3?
                    if any(slot <= 3) && all(cmslot > 3)
                        M{end+1} = [ratname,' is scheduled to train before session 4 but his cagemate trains after session 3.'];
                    end
                    
                    %Is this rat scheduled to run in a different session from his cagemate?
                    if length(slot) ~= length(cmslot) || any(slot ~= cmslot)
                        M{end+1} = [ratname,' is scheduled to train in a different session from his cagemate.'];
                    end
                end
            end
        end
        
        if extant(strcmp(RatR,ratname))==1 
            cmregpos = strcmp(RatR,cm);

            %Does this rat have a non-extant cagemate?
            if strcmp(cm,'')==0 && sum(strcmp(RatR,cm)) > 0 && extant(cmregpos) == 0
                M{end+1} = [ratname,' has a cagemate in the registry who is listed as not extant.'];
            end

            %Is the cagemate not in the registry?
            if strcmp(cm,'')==0
                if sum(cmregpos) == 0
                    M{end+1} = [ratname,' has a cagemate who is not in the registry.'];
                else
                    %Does this rat have a cagemate whose cagemate is not him?
                    cmm = CM{cmregpos};
                    if strcmp(cmm,ratname) == 0
                        M{end+1} = [ratname,' has a cagemate whose cagemate is not him.'];
                    end
                end
            end

            %Is no one watching this rat?
            ratcontact = Contacts{regpos}; ratcontact(ratcontact == ' ') = '';
            RC = cell(0);          
            st = 1;
            for j = 2:length(ratcontact)
                if ratcontact(j) == ',';    RC{end+1} = ratcontact(st:j-1); st = j+1; end
                if j == length(ratcontact); RC{end+1} = ratcontact(st:j);             end
            end
            if strcmp(ratcontact,'') == 1
                M{end+1} = [ratname,' has no contact listed in the registry.'];
            else
                foundcontact = 0; nonalum = 0;
                for j = 1:length(RC)
                    contactpos = strcmp(emailid,RC{j});
                    if sum(contactpos) ~= 0;  foundcontact = 1; end
                    if any(Alum(contactpos) == 0); nonalum = 1; end
                end
                if foundcontact == 0
                    M{end+1} = [ratname,' has no matching contact in the Contacts List.'];
                elseif nonalum == 0
                    M{end+1} = [ratname,' has no current member of the lab listed as a contact.'];
                end
            end
        end
                
        %Check for this rat is done. Log the message if there is one
        if ~isempty(M); eval(['X.',ratname,' = M;']); end        
    end
    
    
    %Now we loop through all the lab personel and construct each email
    if ~exist('X','var'); disp('No Problems Found'); return; end
    badrats = fields(X);
    for i = 1:length(Exps)
        M = cell(0);
        email = Emails{i}(1:find(Emails{i} == '@')-1);
        
        %Loop through the rats with problems
        for j = 1:length(badrats)
            
            %Find out who owns the rat
            ratcontact = cell(0); RC = cell(0);
            temp = strcmp(RatR,badrats{j});
            if sum(temp) ~= 0; ratcontact = Contacts(temp); end 
            for k = 1:length(ratcontact)
                temp = ratcontact{k};
                temp(temp == ' ') = '';
                st = 1;
                for m = 2:length(temp)
                    if temp(m) == ',';    RC{end+1} = temp(st:m-1); st = m+1; end
                    if m == length(temp); RC{end+1} = temp(st:m);             end
                end
            end
            
            %Loop through the owners
            for k = 1:length(RC)
                %If this is the owner of the rat send them the info
                if sum(strcmp(email,RC{k})) > 0 
                    M(end+1:end+length(eval(['X.',badrats{j},';']))) = eval(['X.',badrats{j},';']);
                end

                %If there is no owner, send it to the lab manager
                if (sum(strcmp(emailid,RC{k})) == 0 || Alum(strcmp(emailid,RC{k}))) && LM(i) == 1
                    M(end+1:end+length(eval(['X.',badrats{j},';']))) = eval(['X.',badrats{j},';'])';
                end
            end
            
            %If the owner is empty, send it to the lab manager
            if isempty(RC) && LM(i) == 1
                M(end+length(eval(['X.',badrats{j},';']))) = eval(['X.',badrats{j},';']);
            end
                
        end
        
        %If there is a message send it
        if ~isempty(M) && ~Alum(i)
            M = remove_duplicate_lines2(M);
            M{end+1} = ' ';
            M{end+1} = 'These problems were detected in the schedule and/or registry.';
            M{end+1} = 'Please fix them promptly.';
            M{end+1} = ' ';
            M{end+1} = 'This email was generated by the Brody Lab Automated Email System';
            
            IP = get_network_info;
            M{end+1} = ' ';
            if ischar(IP); M{end+1} = ['Email generated by ',IP];
            else           M{end+1} = 'Email generated by an unknown computer!!!';
            end
            
            M{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\check_sched_reg_problems.m';
            
            disp(Exps{i}); disp(' '); for j = 1:length(M); disp(M{j}); end; disp(' '); disp(' ');
            sendmail(Emails{i},'Registry and Schedule Problems',M);  
        end
    end
    
    %save the output structure
    LTR = 'abcdefghijklmnopqrstuvwxyz';
    for ltr = 1:26
        file = ['C:\Automated Emails\Schedule\',yearmonthday,LTR(ltr),'_SchedRegProblem_Email.mat'];
        if ~exist(file,'file'); save(file,'X'); break; end    
    end
catch %#ok<CTCH>
    senderror_report;
end 
    

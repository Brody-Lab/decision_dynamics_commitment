function checktrainproblems2(outtype,day,varargin)

try 
    
    if nargin < 1; outtype = 'full'; end
    if nargin < 2; day = now; end
    
    do_sendmail = 1;
    
    [Rigs,RatSC,Slots]                = bdata(['select rig, ratname, timeslot from ratinfo.schedule where date="',datestr(day, 29),'"']);
    [Contacts,RatR,DepWR]             = bdata( 'select contact, ratname, forceDepWater from ratinfo.rats where extant="1"');
    [StartTs,RatSS,Hosts]             = bdata(['select starttime, ratname, hostname from sess_started where sessiondate="',datestr(day, 29),'"']);
    [RatS,EndTs]                      = bdata(['select ratname, endtime from sessions where sessiondate="',datestr(day, 29),'"']);
    [RatN,RigN,SlotN,ExpN,InN,Notes]  = bdata(['select ratname, rigid, timeslot, experimenter, techinitials, note from ratinfo.technotes where datestr="',datestr(day,29),'"']);
    [Wst Wet RatW Wdate]              = bdata(['select starttime, stoptime, rat, date from ratinfo.water where date>="',datestr(day,29),'"']);
    CompRats                          = bdata(['select ratname from ratinfo.rigwater where dateval="',datestr(day,'yyyy-mm-dd'),'" and complete=1']);
    [RigM,RigNote,BrokePer,BrokeDate] = bdata( 'select rigid, note, broke_person, broke_date from ratinfo.rig_maintenance where isbroken=1');

    [Exps,Emails,LMs,SAs,TMs,TAs,TOs,TCs,Ins,Alum] = bdata('select experimenter, email, lab_manager, subscribe_all, tech_morning, tech_afternoon, tech_overnight, tech_computer, initials, is_alumni from ratinfo.contacts');
    
    
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['ScheduleMeister',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    %Check all extant rats
    for i = 1:length(RatR)
        ratname = RatR{i};
        
        if strcmp(ratname,'sen1') || strcmp(ratname,'sen2') || ratname(1) == '0' || numel(ratname) ~= 4; continue; end
        
        M = cell(0);
        train = strcmp(RatSC,ratname);
        if sum(train) > 0
            for z = 1:1 %Use a loop so its easy to break out
                %This is a training rat, check for training problems
                rig  = Rigs(train);
                slot = Slots(train);

                %If this is a session 1-3 rat, they don't train on Sunday, so skip this analysis
                if strcmp(datestr(day,'ddd'),'Sun') && any(slot <= 3); break; end
                
                %Problem 1: Did the rat train? Check if a start time was logged
                temp = strcmp(RatSS,ratname);
                if sum(temp) > 0; st = StartTs(temp);
                else              M{end+1} = [ratname,' was scheduled to run in rig ',num2str(horz(rig)),' session ',num2str(horz(slot)),' but did not appear to run anywhere.']; %#ok<AGROW>
                                  if ~strcmp(outtype,'full'); M = cell(0); end
                                  break;
                end

                %Problem 2: Did the rat run in the correct rig? Compare hostname to schedule
                realrig = Hosts(temp); RR = zeros(size(realrig));
                for j = 1:length(realrig)
                    if length(realrig{j}) == 5; RR(j) = str2num(realrig{j}(4:5)); %#ok<ST2NM>
                    else                        RR(j) = 0;
                    end
                end
                RR = unique(RR);
                if all(RR ~= rig(1)); M{end+1} = [ratname,' ran in rig ',num2str(RR'),' but was scheduled to run in rig ',num2str(horz(rig)),' session ',num2str(horz(slot)),'.']; end %#ok<AGROW>

                %Problem 3: Did the rig crashed while running the rat? Check for end time in sessions
                temp = strcmp(RatS,ratname);
                if sum(temp) > 0; ed    = EndTs(temp);
                else              ed{1} = nan;
                                  M{end+1} = [ratname,' was training in rig ',num2str(horz(rig)),' session ',num2str(horz(slot)),' but the rig crashed.']; %#ok<AGROW>
                end

                %Problem 4: Did the rat run for at least 1 hour? Compare start and end times
                for j=1:length(st); try runtime(j) = ceil(timediff(st{j},ed{j},2) / 60); catch; runtime(j) = nan; end; end %#ok<CTCH,AGROW>
                runtime = nansum(runtime);
                if runtime < 60; M{end+1} = [ratname,' ran for only ',num2str(max(runtime)),' minutes today in session ',num2str(horz(slot)),'.']; end %#ok<AGROW>

                %Problem 5: Did the rat run in the wrong session? Compare run time to session standard
                clear inslot
                for j=1:length(st); try inslot(j) = checkruninslot(st{j},ed{j},slot(1)); catch; inslot(j) = nan; end; end %#ok<CTCH,AGROW>
                if strcmp(datestr(day,'ddd'),'Sun') == 0 && all(inslot ~= 0)
                    for j = 1:length(inslot)
                        if inslot(j) == -1; M{end+1} = [ratname,' ran from ',st{j},' to ',ed{j},' which is before his scheduled time of session ',num2str(horz(slot))]; end %#ok<AGROW>
                        if inslot(j) ==  1; M{end+1} = [ratname,' ran from ',st{j},' to ',ed{j},' which is after his scheduled time of session ', num2str(horz(slot))]; end %#ok<AGROW>
                    end
                end
                
                %Problem 6: Was the rat supposed to get water but didn't?
                %If there are multiple water entries, let's take the most recent
                waterpos = find(strcmp(RatW,ratname) == 1,1,'last');
                if isempty(waterpos) && sum(strcmp(CompRats,ratname))==0 
                    M{end+1} = [ratname,' trained in session ',num2str(horz(slot)),' but was not watered today.'];  %#ok<AGROW>
                end
                
                %Problem 7: Did the rat get his 30 minute break between training and watering?
                if (strcmp(datestr(day,'ddd'),'Sat') && any(slot == 9)) ||...
                   (strcmp(datestr(day,'ddd'),'Sun') && any(slot <= 3))
                    %We ignore this for session 9 rats on Saturday (they get less than 30 minute break) 
                    %and session 1-3 rats on Sunday since they don't train
                else
                    if ~isempty(waterpos)
                        wst = Wst{waterpos};
                        breaktime = ceil(timediff(ed{end},wst,2) / 60);
                        if breaktime < 0 && datenum(Wdate(waterpos),'yyyy-mm-dd') - day > 0
                            %This rat was watered on the date after his training, flip breaktime
                            breaktime = (24 * 60) + breaktime;
                        end
                        if any(slot == 9)
                            %for now session 9 rats can have a 15 minute break
                            if     breaktime < 0;  
                                M{end+1} = [ratname,' was watered while training in session ',num2str(horz(slot)),'??']; %#ok<AGROW>
                            elseif breaktime < 10; M{end+1} = [ratname,' only had a ',num2str(breaktime),' minute break between training in session ',num2str(horz(slot)),' and watering.'];  %#ok<AGROW>
                            end
                        else
                            if     breaktime < 0;  
                                M{end+1} = [ratname,' was watered while training in session ',num2str(horz(slot)),'??']; %#ok<AGROW>
                            elseif breaktime < 20; M{end+1} = [ratname,' only had a ',num2str(breaktime),' minute break between training in session ',num2str(horz(slot)),' and watering.'];  %#ok<AGROW>
                            end
                        end
                    end
                end
                
                %If we are not doing a full output, remove all previous error messages
                if ~strcmp(outtype,'full'); M = cell(0); end
                
                %Check for technotes for the rats realrig
                for j = 1:length(RR)
                    n = find(RigN == RR(j));
                    for k=1:length(n)
                        if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end %#ok<AGROW>
                        M{end+1} = ['TechNote by ',upper(InN{n(k)}),' for Rig ',num2str(RR(j)),': ',char(Notes{n(k)})'];  %#ok<AGROW>
                    end
                end
                
            end

            %Check for technotes for the rats scheduled rig
            for j = 1:length(rig)
                %Here we look through technotes
                n = find(RigN == rig(j));
                for k=1:length(n)
                    if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end %#ok<AGROW>
                    M{end+1} = ['TechNote by ',upper(InN{n(k)}),' for Rig ',num2str(rig(j)),': ',char(Notes{n(k)})'];  %#ok<AGROW>
                end
                
                %Here we look through maintenance logs if the rig is broken
                n = find(RigM == rig(j));
                for k = 1:length(n)
                    if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end %#ok<AGROW>
                    if length(BrokeDate{n(k)}) > 10; BrokeDate{n(k)} = BrokeDate{n(k)}(1:10); end
                    M{end+1} = ['Rig ',num2str(rig(j)),' flagged as broken on ',BrokeDate{n(k)},' by ',BrokePer{n(k)},': ',char(RigNote{n(k)})'];  %#ok<AGROW>
                end
            end

            %Check for technotes for the rats slot
            for slotn = 1:length(slot)
                n = find(SlotN == slot(slotn));
                for j=1:length(n)
                    if isempty(M); M{end+1} = ['Notes relevant for ',ratname]; end %#ok<AGROW>
                    M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Session ',num2str(slot(slotn)),': ',char(Notes{n(j)})'];  %#ok<AGROW>
                end
            end
        else
            %This is a non-training rat.
            
            %Problem 8: If he is free water, was he checked?
            regpos = find(strcmp(RatR,ratname) == 1,1,'first');
            if ~isempty(regpos) && DepWR(regpos) == 0
                if sum(strcmp(RatW,ratname))==0; M{end+1} = [ratname,' is a free water rat but was not checked today.']; end %#ok<AGROW>
            end
            
            %If we are not doing a full output, remove all previous error messages
            if ~strcmp(outtype,'full'); M = cell(0); end
        end
        
        %Check for technotes for the rat
        n = find(strcmp(RatN,ratname));
        for j=1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for ',ratname,': ',char(Notes{n(j)})']; end %#ok<AGROW>
        
        %Check for this rat is done. Log the message if there is one
        if ~isempty(M); eval(['X.rat.',ratname,' = M;']); end
    end
    
    %check all used rigs
    UR = unique(Rigs);
    for i = 1:length(UR)
        M = cell(0);
        
        %Check for technotes for the rig
        n = find(RigN == UR(i));
        for j = 1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Rig ',num2str(UR(i)),': ',char(Notes{n(j)})']; end %#ok<AGROW>
        
        %Check for Maintenance log for the rig
        n = find(RigM == UR(i));
        for j = 1:length(n)
            if length(BrokeDate{n(j)}) > 10; BrokeDate{n(j)} = BrokeDate{n(j)}(1:10); end
            M{end+1} = ['Rig ',num2str(UR(i)),' flagged as broken on ',BrokeDate{n(j)},' by ',BrokePer{n(j)},': ',char(RigNote{n(j)})'];  %#ok<AGROW>
        end
                
        %Check for this rig is done. Log the message if there is one
        if ~isempty(M); eval(['X.rig.R',num2str(UR(i)),' = M;']); end
    end
    
    %check all used sessions
    US = unique(Slots);
    for i = 1:length(US)
        M = cell(0);
        
        %Check for technotes for the session
        n = find(SlotN == US(i));
        for j = 1:length(n); M{end+1} = ['TechNote by ',upper(InN{n(j)}),' for Session ',num2str(US(i)),': ',char(Notes{n(j)})']; end %#ok<AGROW>
        
        %Check for this session is done. Log the message if there is one
        if ~isempty(M); eval(['X.session.S',num2str(US(i)),' = M;']); end
    end
    
    
    %Now we loop through all the lab personel and construct each email
    if ~exist('X','var'); disp('No Problems Found'); return; end
    if isfield(X,'rat');     badrats = sortrows(fields(X.rat));                                                 else badrats = []; end
    if isfield(X,'rig');     br = fields(X.rig);     for i=1:length(br); badrigs(i)=str2num(br{i}(2:end)); end; else badrigs = []; end %#ok<ST2NM,AGROW>
    if isfield(X,'session'); bs = fields(X.session); for i=1:length(bs); badsess(i)=str2num(bs{i}(2:end)); end; else badsess = []; end %#ok<ST2NM,AGROW>
    for i = 1:length(Exps)
        M = cell(0);
        email = Emails{i}(1:find(Emails{i} == '@')-1);
        
        %Loop through the rats with problems
        didheader = 0;
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
                    if temp(m) == ',';    RC{end+1} = temp(st:m-1); st = m+1; end %#ok<AGROW>
                    if m == length(temp); RC{end+1} = temp(st:m);             end %#ok<AGROW>
                end
            end
            
            %If this is the owner of the rat, the lab manager, someone who has subscribed to all, 
            %carlos, or the tech who trained the rat, send them the info
            temp = find(strcmp(RatSC,badrats{j}) == 1); if ~isempty(temp); S = Slots(temp); else S = nan; end
            if sum(strcmp(email,RC)) > 0 || LMs(i) == 1 || SAs(i) == 1 || strcmp(email,'brody') ||...
                    (TMs(i) == 1 && any(S >= 4 & S <= 6)) || (TAs(i) == 1 && any(S >= 7 & S <= 9))
                Mtemp = eval(['X.rat.',badrats{j},';']);
                for k = 1:length(Mtemp)
                    if k==1 && didheader==0; M{end+1} ='RAT ISSUES'; M{end+1} =' '; didheader=1; end %#ok<AGROW>
                    M{end+1} = Mtemp{k}; %#ok<AGROW>
                end 
                if ~isempty(Mtemp); M{end+1} = ' '; end %#ok<AGROW>
            end
        end
        
        %Loop through the rigs with problems
        didheader = 0;
        for j = 1:length(badrigs)
            
            %If this is the lab manager, someone who has subscribed to all,
            %the computer tech, or carlos, send them the info
            if (LMs(i) == 1 || SAs(i) == 1 || TCs(i) == 1 || strcmp(email,'brody')) && Alum(i)==0
                Mtemp = eval(['X.rig.R',num2str(badrigs(j)),';']);
                for k = 1:length(Mtemp)
                    if k==1 && didheader==0; M{end+1} =' '; M{end+1} =' '; M{end+1}='RIG ISSUES'; M{end+1} =' '; didheader=1; end %#ok<AGROW>
                    M{end+1} = Mtemp{k};  %#ok<AGROW>
                end 
            end
        end
        
        %Loop through the sessions with problems
        didheader = 0;
        for j = 1:length(badsess)
            
            %If this is the lab manager, someone who has subscribed to all,
            % or carlos, send them the info
            if (LMs(i) == 1 || SAs(i) == 1 || strcmp(email,'brody')) && Alum(i)==0
                Mtemp = eval(['X.session.S',num2str(badsess(j)),';']);
                for k = 1:length(Mtemp); 
                    if k==1 && didheader==0; M{end+1} =' '; M{end+1} =' '; M{end+1} ='SESSION ISSUES'; M{end+1} =' '; didheader=1; end %#ok<AGROW>
                    M{end+1} = Mtemp{k};  %#ok<AGROW>
                end 
            end
        end
        
        %Add any technotes directed at this person
        n = find(strcmpi(ExpN,Exps{i}) == 1);
        for j = 1:length(n); 
            if j == 1; M{end+1}=' '; M{end+1}=' '; M{end+1}='PERSONAL NOTES'; M{end+1}=' '; end %#ok<AGROW>
            M{end+1} = ['TechNote entered by ',upper(InN{n(j)}),' for ',ExpN{n(j)},': ',char(Notes{n(j)})'];  %#ok<AGROW>
        end
        
        %Add any general notes
        n = find((strcmp(RatN,'') & isnan(RigN) & isnan(SlotN) & strcmp(ExpN,'')) == 1);
        for j = 1:length(n); 
            if j == 1; M{end+1}=' '; M{end+1}=' '; M{end+1}='GENERAL NOTES'; M{end+1}=' '; end %#ok<AGROW>
            M{end+1} = ['General TechNote entered by ',upper(InN{n(j)}),': ',char(Notes{n(j)})'];  %#ok<AGROW>
        end
        
        %If there is a message, and the person has initials in the contacts page (used as a subscribe to email flag), send it
        if ~isempty(M) && ~Alum(i)
            M = remove_duplicate_lines2(M);
            
            IP = get_network_info;
            M{end+1} = ' '; %#ok<AGROW>
            if ischar(IP); M{end+1} = ['Email generated by ',IP]; %#ok<AGROW>
            else           M{end+1} =  'Email generated by an unknown computer!!!'; %#ok<AGROW>
            end
            
            M{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\checktrainproblems2.m';
            
            disp(Exps{i}); disp(' '); for j = 1:length(M); disp(M{j}); end; disp(' '); disp(' ');
            if do_sendmail== 1; sendmail(Emails{i},'Potential Training Problems',M); end
        end
    end
    
    %save the output structure
    LTR = 'abcdefghijklmnopqrstuvwxyz';
    for ltr = 1:26
        file = ['C:\Automated Emails\Schedule\',yearmonthday,LTR(ltr),'_TrainProblem_Email.mat'];
        if ~exist(file,'file'); save(file,'X'); break; end    
    end
catch %#ok<CTCH>
    senderror_report;
end    
         



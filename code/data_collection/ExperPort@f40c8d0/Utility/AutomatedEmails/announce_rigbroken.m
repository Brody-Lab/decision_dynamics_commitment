function announce_rigbroken

%complete rewrite on 7/25/2019 by Chuck
%New version:
%   -only emails experimenters in the lab actively training rats
%   inclusing Carlos, Jovanna, and Klaus
%   -includes all rigs up to 37 and pub snugs
%   -identifies the experimenter responsible for repairing the
%   rig or snug

try
    %pull out the broken rig IDs and the date they are flagged as broken
    [allbroke,datebroken] = bdata('select rigid, broke_date from ratinfo.rig_maintenance where isbroken=1');
    
    %Rigs in the training room stop at 38
    rigpos = find(allbroke <= 38);
    rigs = allbroke(rigpos);
    rigdate = datebroken(rigpos);
    
    %snugs are the individual pub watering units numbered in the 300s
    snugpos = find(allbroke > 299 & allbroke < 399);
    snugs = allbroke(snugpos);
    snugdate = datebroken(snugpos);
    
    %Let's run through the list of rigs and snugs and delete duplicates
    %only keeping the oldest entry
    ur = unique(rigs);
    brokedate = cell(0);
    for i = 1:numel(ur)
        if sum(rigs == ur(i)) > 1
            dates = rigdate(rigs == ur(i));
            dn = [];
            for j = 1:numel(dates)
                dn(j) = datenum(dates{j},'yyyy-mm-dd HH:MM:SS');
            end
            brokedate{i} = dates{find(dn == min(dn))};
        else
            brokedate{i} = rigdate{find(rigs == ur(i))};
        end
    end
    rigs = ur;
    rigdate = brokedate;
    
    for i = 1:numel(rigdate)
        rigbrokefor(i) = ceil(now - datenum(rigdate{i},'yyyy-mm-dd HH:MM:SS'));
    end
    
    us = unique(snugs);
    brokedate = cell(0);
    for i = 1:numel(us)
        if sum(snugs == us(i)) > 1
            dates = snugdate(snugs == us(i));
            dn = [];
            for j = 1:numel(dates)
                dn(j) = datenum(dates{j},'yyyy-mm-dd HH:MM:SS');
            end
            brokedate{i} = dates{find(dn == min(dn))};
        else
            brokedate{i} = snugdate{find(snugs == us(i))};
        end
    end
    snugs = us;
    snugdate = brokedate;
    
    for i = 1:numel(snugdate)
        snugbrokefor(i) = ceil(now - datenum(snugdate{i},'yyyy-mm-dd HH:MM:SS'));
    end
           
    [Srats,Srigs] = bdata(['select ratname, rig from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    [Rrats,Rcont] = bdata('select ratname, contact from ratinfo.rats where extant=1');
    [Experimenters,Emails,FixRigs] = bdata('select experimenter, email, tech_shifts from ratinfo.contacts where is_alumni=0');
    
    contactid = cell(0);
    for i = 1:numel(Emails)
        contactid{i} = Emails{i}(1:find(Emails{i}=='@',1,'first')-1);
    end
    
    repair = cell(0);
    for i = 1:numel(FixRigs)
        responsiblefor = str2num(FixRigs{i});
        for j = 1:numel(responsiblefor)
            repair{responsiblefor(j)} = Experimenters{i};
        end
    end
    for i = 1:336
        if isempty(repair{i}); repair{i} = 'No one'; end
    end
    
    %No we loop through each experimenter and draft an email to them
    for i = 1:numel(Experimenters)
        
        %Check if this experimenter trains any rats
        ownsrats = 0;
        for k = 1:numel(Srats)
            temp = find(strcmp(Rrats,Srats{k}) == 1,1,'first');
            if isempty(temp); continue; end

            ratcontact = Rcont{temp};
            spcs = find(ratcontact == ' ' | ratcontact == ',');
            spcs = [0,spcs,numel(ratcontact)+1];
            for m = 1:numel(spcs)-1
                tempcontact = ratcontact(spcs(m)+1:spcs(m+1)-1);
                if strcmp(tempcontact,contactid{i})
                    %This experimenter owns at least one rat
                    ownsrats = 1;
                end
                if ownsrats == 1; break; end
            end
            if ownsrats == 1; break; end
        end
        
        if ownsrats == 1 || strcmp(Experimenters{i},'Carlos') ||...
                            strcmp(Experimenters{i},'Jovanna') ||...
                            strcmp(Experimenters{i},'Klaus')
            %Don't draft emails to people who don't train rats unless it's
            %someone included in the list above
            draftemail = 1;
        else
            disp(['Sending no email to ',Experimenters{i}]);
            continue;
        end
        
        %prepare the message
        message=cell(0);
        if isempty(rigs) && isempty(snugs)
            %Tere are no broken rigs or snugs
            message=cell(0);
            message{end+1} = ['BrokenRigs Report Generated: ',datestr(now,'yyyy-mm-dd')];
            message{end+1} = '';
            message{end+1} = 'There are no broken rigs or snugs!';

        else
            %Stuff is broken
            message{end+1} = ['BrokenRigs Report Generated: ',datestr(now,'yyyy-mm-dd')];
            message{end+1} = '';
        end 
    
        %loop through the broken rigs
        for j = 1:numel(rigs)
            rigrats = Srats(Srigs == rigs(j));
            rigrats(strcmp(rigrats,'')) = [];
            
            %loop through the rats in that rig
            myrats = [];
            for k = 1:numel(rigrats)
                ratcontact = Rcont{strcmp(Rrats,rigrats{k})};
                spcs = find(ratcontact == ' ' | ratcontact == ',');
                spcs = [0,spcs,numel(ratcontact)+1];
                for m = 1:numel(spcs)-1
                    tempcontact = ratcontact(spcs(m)+1:spcs(m+1)-1);
                    
                    if strcmp(tempcontact,contactid{i})
                        %This experimenter owns this rat
                        if isempty(myrats)
                            myrats = rigrats{k};
                        else
                            myrats = [myrats,', ',rigrats{k}];
                        end
                    end
                end
            end
            
            message{end+1} = ['Rig ',num2str(rigs(j))];
            message{end+1} = ['  -broken for ',num2str(rigbrokefor(j)),' days'];
            if ~isempty(myrats) 
                message{end+1} = ['  -trains ',myrats];
            end
            message{end+1} = ['  -',repair{rigs(j)},' is assigned to repair'];
            message{end+1} = ' ';
        end
        
        %loop through the broken snugs and let all experiments know
        for j = 1:numel(snugs)
            message{end+1} = ['Snug ',num2str(snugs(j))];
            message{end+1} = ['  -broken for ',num2str(snugbrokefor(j)),' days'];
            message{end+1} = ['  -',repair{snugs(j)},' is assigned to repair'];
            message{end+1} = ' ';
        end
                
        IP = get_network_info;
        if ischar(IP); message{end+1} = ['Email generated by ',IP];
        else           message{end+1} = 'Email generated by an unknown computer!!!';
        end
        message{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\announce_rigbroken.m';
        
        disp(Experimenters{i});
        disp(message');
        disp(' ');
        disp(' ');
        disp(' ');
    
        %prepare the Title of the email.
        subjectline = [num2str(numel(rigs)),' Rigs & ',num2str(numel(snugs)),' Snugs Broken'];

        %send the email
        set_email_sender
        sendmail(Emails{i},subjectline,message);   
    end
catch %#ok<CTCH>
   senderror_report;  
end

function output = checkratweights(find_missing,extreme_only,ratrig,varargin)

try 
    rng('shuffle','twister');

    if nargin < 1; find_missing = 0; end
    if nargin < 2; extreme_only = 0; end
    if nargin < 3; ratrig       = []; end
    
    if isempty(ratrig)
        ratrig = bSettings('get','RIGS','ratrig');
        if isnan(ratrig); ratrig = 1; end
    end
    
    istodaysunday = strcmp(datestr(now,'ddd'),'Sun');
    
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['MassMeister',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    [ratnames1, forcefrees, forcedeps, recoverings, cagemates, contacts] =...
        bdata(['select ratname, forcefreewater, forcedepwater, recovering, cagemate, contact from ratinfo.rats where extant=1 and israt=',num2str(ratrig)]); %#ok<ASGLU>
    [training, slots] = bdata('select ratname, timeslot from ratinfo.schedule where date="{S}"',datestr(now,29));
        
    RatWaterList = WM_rat_water_list([],[],'all');
    FreeWaterRats = unique(RatWaterList{10}(:));
    FreeWaterRats(strcmp(FreeWaterRats,'')) = [];
    
    norats = strcmp(training,'');
    training(norats) = [];
    slots(norats) = [];
    
    remrat = [];
    for i = 1:numel(training)
        if sum(strcmp(ratnames1,training{i})) == 0
            remrat(end+1) = i; %#ok<AGROW>
        end
    end
    training(remrat) = [];
    slots(   remrat) = [];
    
    recov = ratnames1(recoverings==1);
    
    colors = upper({'red','orange','yellow','green','blue','purple','magenta','cyan','black','white','brown','pink'});
    
    weighedrats = training;
    for r=1:length(training)
        temp = strcmp(ratnames1,training{r});
        if sum(temp) == 0; weighedrats{end+1} = ''; %#ok<AGROW>
        else               weighedrats{end+1} = cagemates{temp}; %#ok<AGROW>
        end
    end
    weighedrats(strcmp(weighedrats,'')) = [];
    weighedrats = unique(weighedrats);
    
    fd = ratnames1(forcedeps ~= 0);
    
    ratnames = [weighedrats; recov; fd]; ratnames(strcmp(ratnames,'')) = []; ratnames = unique(ratnames);
    
    max_days = 40;
    days = 0:-1:-max_days+1;
    for i = 1:numel(days)
        tempdays{i} = datestr(now+days(i),29); %#ok<AGROW>
    end
    
    [m,d,r] = bdata(['select mass, date, ratname from ratinfo.mass where date>"',datestr(now-(max_days+1),'yyyy-mm-dd'),'" order by date']); 
    remrat = [];
    for i = 1:numel(r)
        if sum(strcmp(ratnames1,r{i})) == 0
            remrat(end+1) = i; %#ok<AGROW>
        end
    end
    m(remrat) = []; %#ok<NASGU>
    d(remrat) = []; %#ok<NASGU>
    r(remrat) = [];
    
    for i = 1:length(ratnames)
        temp = strcmp(r,ratnames{i}); %#ok<NASGU>
        eval(['MASS.' ,ratnames{i},' = m(temp);']);
        eval(['DATES.',ratnames{i},' = d(temp);']);
    end
    
    
    
    pmain = bSettings('get','GENERAL','Main_Code_Directory');
    pname = [pmain,'\Utility\AutomatedEmails\'];
    
    LTR = 'abcdefghijklmnopqrstuvwxyz';
    foundfile = 0;
    dt = changedate(yearmonthday,1);
    cnt = 0;
    while foundfile == 0
        cnt = cnt+1;
        dt = changedate(dt,-1);
        for ltr = 26:-1:1
            file = ['C:\Automated Emails\Mass\',dt,LTR(ltr),'_DecliningRats.mat'];
            if exist(file,'file')==2; foundfile = 1; load(file); PreviousBad = AllBadRats; end     %#ok<NODEF>
        end
        if cnt >= 10; PreviousBad = cell(0); foundfile = 1; end
    end

    notrealrats = {'sen1';'sen2'};

    missingeveningmass = cell(0);
    missingmorningmass = cell(0);
    missingovernightmass = cell(0);

    output = [];

    [Exp, expnames, subscribe_alls, morningTs, afternoonTs, overnightTs, LMs] =...
        bdata(['select email, experimenter, subscribe_all, tech_morning, tech_afternoon, tech_overnight,',...
        ' lab_manager from ratinfo.contacts where is_alumni=0']);
    
    AllBadRats    = cell(0);
    AllRecovRats  = cell(0);
    RecovPosRats  = cell(0);
    FewEntRats    = cell(0);

    for e = 1:length(Exp)
        if extreme_only == 1 && ~strcmp(Exp{e},'ckopec@princeton.edu'); continue; end
        contains_superextreme_decline = 0;

        expname = expnames{e};
        tempemail = Exp{e}(1:find(Exp{e} == '@',1,'first')-1);
        rattemp = [];
        for r = 1:length(ratnames)
            temp = strcmp(ratnames1,ratnames{r});
            if sum(temp) == 0; continue; end
            contact = contacts{temp};
            expswap = parse_emails(contact);
            
            temp = Exp(subscribe_alls == 1);
            for i = 1:length(temp)
                temp{i}(find(temp{i}=='@',1,'first'):end) = [];
            end
            expswap(end+1:end+length(temp)) = temp;
            
            if sum(strcmp(expswap,tempemail)) > 0
                rattemp(end+1) = r; %#ok<AGROW>
            end
        end
        
        if extreme_only == 1 && strcmp(Exp{e},'ckopec@princeton.edu'); rattemp = 1:numel(ratnames); end

        message = cell(0);
        badrats = [];
        tempdata = cell(0);
        for r = 1:length(rattemp)

            ratname = ratnames{rattemp(r)};
            if sum(strcmp(notrealrats,ratname)) > 0; continue; end
            min_entries = 14;

            %get the mass and days for this rat
            mass = []; 
            eval(['M = MASS.',ratname,';']);
            eval(['D = DATES.',ratname,';']);
            
            %string the mass in date order, nan for missing entries
            for d = 1:numel(days)
                temp = strcmp(D,tempdays{d});
                if sum(temp) ~= 0; mass(end+1) = M(find(temp==1,1,'first')); %#ok<AGROW>
                else               mass(end+1) = nan; %#ok<AGROW>
                end
            end
            
            %determine the rats weighing session
            temp1 = strcmp(training,ratname);
            if sum(temp1) == 0
                %He doesn't train
                temp2 = strcmp(ratnames1,ratname);
                if sum(temp2) == 0; continue; end
                cm = cagemates{find(temp2 == 1,1,'first')};
                if strcmp(cm,'') == 1 || sum(strcmp(training,cm)) == 0
                    %He had no cagemate or his cagemate doesn't train
                    slot = forcedeps(strcmp(ratnames1,ratname));
                    if slot == 0
                        %He is not forced to get water at any particular time
                        if sum(strcmp(recov,ratname)) > 0
                            %He's a recovering rat, weight in C shift
                            slot = 10;
                        else
                            slot = nan;
                        end
                    end
                else
                    %His cagemate does train
                    slot = slots(strcmp(training,cm));
                end
            else
               slot = slots(temp1);     
            end        
                
            %if the most recent entry is nan, it's missing, add rat to
            %appropriate missing list based on weighing session
            if isnan(mass(1)) && ~istodaysunday
                if     any(slot <= 3);                   missingovernightmass{end+1} = ratname; %#ok<AGROW>
                elseif any(slot >= 4) && any(slot <= 6); missingmorningmass{end+1}   = ratname; %#ok<AGROW>    
                elseif any(slot >= 7);                   missingeveningmass{end+1}   = ratname; %#ok<AGROW>
                end
            end
            if find_missing == 1; continue; end

            isrecoveringrat = recoverings(strcmp(ratnames1,ratname));
            if isrecoveringrat == 1; AllRecovRats{end+1} = ratname; end %#ok<AGROW>
            
            %0g entries are placeholders so remove them
            mass(mass == 0) = nan; %#ok<AGROW>

            %let's flag anomalous weights as nan
            for m = 2:length(mass)-1
                if sum(isnan(mass(m-1:m+1))) == 0
                    temp = mean([mass(m-1) mass(m+1)]);
                    if abs(mass(m-1) - mass(m+1)) / temp < 0.02
                        if abs(mass(m) - temp) / temp > 0.04
                            mass(m) = nan; %#ok<AGROW>
                        end
                    end
                end
            end

            %nan weights are bad so take them out
            gooddata = ~isnan(mass);
            goodmass = mass(gooddata);
            gooddays = days(gooddata);
            n_done_trials=[]; %#ok<NASGU>
            
            fewentries = 0;
            weight_declining = 0;
            extreme_decline  = 0;
            superextreme_decline = 0;
            slow_steady_decline = 0;
            onedaychange = nan;
            %multidaychange = nan;
            twoweekchange = nan;
            rr = [nan nan];
            pp = [nan nan];
            slope = nan;
            extra_message = '';
            
            %see if weights pass any thresholds for email notification
            if sum(gooddata) < min_entries; 
                fewentries = 1;
            else
                onedaychange   = (goodmass(1) - goodmass(2)) / goodmass(1);
                %multidaychange = (mean(goodmass(1:3)) - mean(goodmass(8:10))) / mean(goodmass(1:10));
                [rr,pp]        = corrcoef(gooddays(1:14),goodmass(1:14));
                slope          = polyfit(gooddays(1:14),goodmass(1:14),1);
                
                twoweekmax = max(goodmass(gooddays<0 & gooddays>-15));
                twoweekchange = (goodmass(1) - twoweekmax) / twoweekmax;
                
                xtemp = [];
                if numel(goodmass) >= 30
                    for i = 1:17
                        [rtemp,ptemp] = corrcoef(gooddays(i:i+13),goodmass(i:i+13));
                        linefit = polyfit(gooddays(i:i+13),goodmass(i:i+13),1);
                        percent_week_change = ((linefit(1) * 7) / mean(goodmass(i:i+13))) * 100;
                        if rtemp(2) < 0 && ptemp(2) < 0.02 && percent_week_change <= -1.5
                            xtemp(i) = 1; %#ok<AGROW>
                        else
                            xtemp(i) = 0; %#ok<AGROW>
                        end
                    end
                    if all(xtemp == 1)
                        slow_steady_decline = 1;
                    end
                end

                if onedaychange < -0.05 || twoweekchange < -0.1 || (rr(2) < 0 && pp(2) < 0.01 && slope(1) < -2) || slow_steady_decline == 1;  
                    weight_declining = 1; 
                end
                
                if onedaychange < -0.06 || twoweekchange < -0.12 || (rr(2) < 0 && pp(2) < 0.01 && slope(1) < -3) || slow_steady_decline == 1;
                    weight_declining = 1; 
                    extreme_decline = 1;
                else
                    extreme_decline = 0;
                end
                
                if onedaychange < -0.1 || twoweekchange < -0.2 || slow_steady_decline == 1
                    weight_declining = 1; 
                    extreme_decline = 1;
                    superextreme_decline = 1;
                    contains_superextreme_decline = 1;
                    
                    if sum(strcmp(FreeWaterRats,ratname)) > 0
                        extra_message = 'This rat is already on the free water list.';
                    end
                        
                else
                    superextreme_decline = 0;
                end
            end
            
            if (extreme_only == 1 &&  (extreme_decline == 1 || superextreme_decline == 1)) ||...
                extreme_only == 0 && (weight_declining == 1 || sum(strcmp(PreviousBad,ratname)) > 0 || isrecoveringrat == 1 || fewentries == 1)
                
                    
                if extreme_only == 1 && extreme_decline == 1
                    if superextreme_decline == 1
                        message{end+1,1}  = [ratname,' EXTREME DECLINE'];                         %#ok<AGROW>
                    else
                        message{end+1,1}  = ratname;                                              %#ok<AGROW>
                    end
                elseif fewentries == 1
                    message{end+1,1}  = [ratname,'  Too Few Weight Entries'];                     %#ok<AGROW>
                    FewEntRats{end+1} = ratname;                                                  %#ok<AGROW>
                elseif weight_declining == 1
                    if superextreme_decline == 1
                        message{end+1,1} = [ratname,' EXTREME DECLINE'];                          %#ok<AGROW>
                    else
                        message{end+1,1} = ratname;                                               %#ok<AGROW>
                    end
                    badrats = [badrats,' ',ratname];                                              %#ok<AGROW>
                    AllBadRats{end+1} = ratname;                                                  %#ok<AGROW>
                elseif sum(strcmp(PreviousBad,ratname)) > 0
                    message{end+1,1} = [ratname,'  First Good Day Follow Up'];                    %#ok<AGROW>
                elseif isrecoveringrat == 1
                    message{end+1,1} = [ratname,'  Recovering'];                                  %#ok<AGROW>
                    RecovPosRats{end+1} = ratname;                                                %#ok<AGROW>
                end
                
                message{end+1,1} =  ' ';                                                          %#ok<AGROW>
                message{end+1,1} = ['One Day Change: ',num2str(round(onedaychange*1e3)/1e3)];     %#ok<AGROW>
                %message{end+1,1} = ['Multi Day Change: ',num2str(round(multidaychange*1e3)/1e3)]; %#ok<AGROW>
                message{end+1,1} = ['Two week Change: ',num2str(round(twoweekchange*1e3)/1e3)];   %#ok<AGROW>
                message{end+1,1} = ['Multi Day Slope: ',num2str(round(slope(1)*1e3)/1e3)];        %#ok<AGROW>
                if slow_steady_decline == 1
                    message{end+1,1} = 'Slope has been significantly negative for 30 days';       %#ok<AGROW>
                end
                if ~isempty(extra_message)
                    message{end+1,1} = extra_message;                                             %#ok<AGROW>
                end
                %message{end+1,1} = ['Multi Day r: ',num2str(round(rr(2)*1e3)/1e3)];              %#ok<AGROW>
                %message{end+1,1} = ['Multi Day p: ',num2str(round(pp(2)*1e3)/1e3)];              %#ok<AGROW>
                
                message{end+1,1} =  ' ';                                                          %#ok<AGROW>
                if length(goodmass) < 10
                    message{end+1,1} = ['Rat Mass Data: ',num2str(goodmass(end:-1:1))];           %#ok<AGROW>
                    %message{end+1,1}=  ['Rat Trials:    ',num2str(n_done_trials(end:-1:1))];
                else
                    message{end+1,1} = ['Rat Mass Data: ',num2str(goodmass(10:-1:1))];            %#ok<AGROW>
                    %message{end+1,1}=  ['Rat Trials:    ',num2str(n_done_trials(10:-1:1))];
                end
                message{end+1,1} =  ' ';                                                          %#ok<AGROW>
                message{end+1,1} =  ' ';                                                          %#ok<AGROW>
                message{end+1,1} =  ' ';                                                          %#ok<AGROW>
                
                tempdata{end+1}.ratname = ratname;                                                %#ok<AGROW>
                tempdata{end}.mass = mass;
            end
        end
        if find_missing == 1; continue; end
        
        if ~isempty(message)   
            if contains_superextreme_decline == 0 && extreme_only == 0 && rand(1) < 1/21
                %find a spot between weight alerts and place a test
                blankrows = [];
                for i = 1:numel(message)
                    if numel(message{i}) == 1 && message{i} == ' '
                        blankrows(i) = 1;
                    else
                        blankrows(i) = 0;
                    end
                end
                goodspot = [];
                for i = 1:numel(blankrows) - 2
                    if all(blankrows(i:i+2) == 1)
                        goodspot(end+1) = i+1; %#ok<AGROW>
                    end
                end
                if ~isempty(goodspot)
                    thespot = goodspot(randperm(numel(goodspot)));
                    
                    message{thespot(1),1} = ['This is a test. Please respond to this email with the word ',...
                                             colors{ceil(rand(1)*numel(colors))}];
                end
            end
            
            message{end+1,1} = ' ';                                                                  %#ok<AGROW>
            message{end+1,1} = 'Any rats flagged as EXTREME DECLINE must be flagged as "Sick" using';%#ok<AGROW>
            message{end+1,1} = 'TechNotes with the note "Significant weight loss" and return to ';   %#ok<AGROW>
            message{end+1,1} = 'training no sooner than 5 days. Someone should perform a health ';   %#ok<AGROW>
            message{end+1,1} = 'check as soon as possible. Animals are not to return to water ';     %#ok<AGROW>
            message{end+1,1} = 'restriction until their weight has increased and stabilized.';       %#ok<AGROW>
            message{end+1,1} = ' ';                                                                  %#ok<AGROW>
            message{end+1,1} = 'Thanks';                                                             %#ok<AGROW>
            message{end+1,1} = 'The Mass Meister';                                                   %#ok<AGROW>
            message{end+1,1} = '  ';                                                                 %#ok<AGROW>
            message{end+1,1} = '  ';                                                                 %#ok<AGROW>
            message{end+1,1} = 'This email was generated by the Brody Lab Automated Email System.';  %#ok<AGROW>
            
            IP = get_network_info;
            message{end+1} = ' ';                                                                    %#ok<AGROW>
            if ischar(IP); message{end+1} = ['Email generated by ',IP];                              %#ok<AGROW>
            else           message{end+1} =  'Email generated by unknown computer!!!';               %#ok<AGROW>
            end
            
            message{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\checkratweights.m'; %#ok<AGROW>
            
            if ~isempty(tempdata)
                f = figure('color','w'); set(gca,'fontsize',18); hold on;
                c = jet(length(tempdata));
                name = cell(0);
                for r = 1:length(tempdata)
                    plot(0:-1:-max_days+1,tempdata{r}.mass,'-o','markerfacecolor',c(r,:),...
                        'markeredgecolor',c(r,:),'markersize',8,'color',c(r,:),'linewidth',2);
                    if sum(strcmp(AllRecovRats,tempdata{r}.ratname)) > 0
                        name{r} = [tempdata{r}.ratname,'_R'];
                        if sum(strcmp(RecovPosRats,tempdata{r}.ratname)) > 0
                            name{r} = [tempdata{r}.ratname,'_R+'];
                        end
                    elseif sum(strcmp(FewEntRats,tempdata{r}.ratname)) > 0
                        name{r} = [tempdata{r}.ratname,'_F'];
                    elseif sum(strcmp(AllBadRats,tempdata{r}.ratname)) == 0
                        name{r} = [tempdata{r}.ratname,'*'];
                    else
                        name{r} = tempdata{r}.ratname; 
                    end
                end
                legend(gca,name,'Location','EastOutside');
                xlabel(['Days Prior to ',datestr(now,29)]);
                ylabel('Rat Mass, grams'); pause(0.1);

                saveas(f,[pname,'ratmassfig.pdf']); pause(0.1);
                close(f);
            end

            if extreme_only == 1
                if contains_superextreme_decline == 1
                    subject = 'Extreme Weight Drop Colony Analysis (contains EXTREME decline)';
                else
                    subject = 'Extreme Weight Drop Colony Analysis';
                end
            elseif contains_superextreme_decline == 1
                subject = [badrats,' Weight Declining (contains EXTREME decline)'];
            elseif isempty(badrats)
                subject = 'Rat Mass Follow-Up';
            else
                subject = [badrats,' Weight Declining'];
            end
            %message = remove_duplicate_lines(message);
            message %#ok<NOPRT>
            sendmail(Exp{e},subject,message,[pname,'ratmassfig.pdf']);
            eval(['output.',expname,' = message;']); 

        end
    end 

    clear output
    if find_missing == 1
        output.overnight = unique(missingovernightmass);
        output.morning   = unique(missingmorningmass);
        output.evening   = unique(missingeveningmass);
    else 
        output = [];
    end
    
    for i = 1:3
        if i == 1;     R = missingovernightmass; T = 'overnight'; 
                       E = Exp(subscribe_alls == 1 | overnightTs == 1 | LMs == 1);
        elseif i == 2; R = missingmorningmass; T = 'morning'; 
                       E = Exp(subscribe_alls == 1 | morningTs   == 1 | LMs == 1);
        else           R = missingeveningmass; T = 'evening'; 
                       E = Exp(subscribe_alls == 1 | afternoonTs == 1 | LMs == 1);
        end
        if ~isempty(R)
            message = cell(0);
            message{end+1} = ['The following rats are to be weighed in the ',T];                   %#ok<AGROW>
            message{end+1} = 'but were not weighed today.';                                        %#ok<AGROW>
            message{end+1} = '   ';                                                                %#ok<AGROW>
            for r = 1:length(R); message{end+1} = R{r}; end                                        %#ok<AGROW>
            message{end+1} = '   ';                                                                %#ok<AGROW>
            message{end+1} = 'Please remember to weigh all rats that run, every day.';             %#ok<AGROW>
            message{end+1} = '   ';                                                                %#ok<AGROW>
            message{end+1} = 'Thanks,';                                                            %#ok<AGROW>
            message{end+1} = 'The Mass Meister';                                                   %#ok<AGROW>
            
            IP = get_network_info;
            message{end+1} = ' '; %#ok<AGROW>
            if ischar(IP); message{end+1} = ['Email generated by ',IP]; %#ok<AGROW>
            else           message{end+1} = 'Email generated by an unknown computer!!!'; %#ok<AGROW>
            end

            for e = 1:length(E)
                %if alum(strcmp(Exp,E{e})) == 1; continue; end
                techname = expnames{strcmp(Exp,E{e})};
                message = remove_duplicate_lines(message);
                if find_missing == 0 && extreme_only == 0
                    message %#ok<NOPRT>
                    sendmail(E{e},'Missing Rat Weights Detected',message);
                end
                eval(['output.',techname,' = message;']);
            end
        end
    end

    if find_missing == 0
        try %#ok<TRYNC>
            for ltr = 1:26
                file = ['C:\Automated Emails\Mass\',yearmonthday,LTR(ltr),'_MassProblem_Email.mat'];
                if ~exist(file,'file'); save(file,'output'); break; end    
            end
        end

        try %#ok<TRYNC>
            for ltr = 1:26
                file = ['C:\Automated Emails\Mass\',yearmonthday,LTR(ltr),'_DecliningRats.mat'];
                if ~exist(file,'file'); save(file,'AllBadRats'); break; end    
            end
        end
    end
    
catch %#ok<CTCH>
    senderror_report;
end

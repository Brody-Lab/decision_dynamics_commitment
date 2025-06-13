function checkschedulechange2(shift,compareto,varargin)

try    
    do_sendmail = 1;
    
    if nargin < 1; shift = [1 2 3]; end
    if nargin < 2; compareto = 'yesterday'; end

    if strcmp(compareto,'yesterday')
        [slot_t rig_t rat_t instr_t] = bdata(['select timeslot, rig, ratname, instructions from ratinfo.schedule where date="',datestr(now,29),'"']);
        [slot_y rig_y rat_y instr_y] = bdata(['select timeslot, rig, ratname, instructions from ratinfo.schedule where date="',datestr(now-1,29),'"']);
    else
        [slot_t rig_t rat_t instr_t] = bdata(['select timeslot, rig, ratname, instructions from ratinfo.schedule where date="',datestr(now+1,29),'"']);
        [slot_y rig_y rat_y instr_y] = bdata(['select timeslot, rig, ratname, instructions from ratinfo.schedule where date="',datestr(now,29),'"']);
    end
    
    ratnames = unique([rat_t;rat_y]);
    ratnames(strcmp(ratnames,'')) = [];
    
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['ScheduleMeister',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    X.ratsremoved = cell(0);
    X.ratsadded   = cell(0);
    X.ratsmoved   = cell(0);
    X.notechanged = cell(0);

    output = []; %#ok<NASGU>

    for r = 1:length(ratnames)
        ratname = ratnames{r};
        pos_t = strcmp(rat_t,ratname);
        pos_y = strcmp(rat_y,ratname);

        if sum(pos_y) > 0; slot_yesterday  = slot_y(pos_y); slot_yesterday(slot_yesterday > 6) = []; else slot_yesterday = []; end
        if sum(pos_t) > 0; slot_today      = slot_t(pos_t); slot_today(    slot_today     > 6) = []; else slot_today     = []; end

        if sum(pos_y) > 0; rig_yesterday   = rig_y(pos_y); else rig_yesterday = []; end
        if sum(pos_t) > 0; rig_today       = rig_t(pos_t); else rig_today     = []; end
        
        instr_yesterday = cell(0);
        instr_today     = cell(0);
        if sum(pos_y) > 0; instr_yesterday = instr_y(pos_y); else instr_yesterday{1} = ''; end
        if sum(pos_t) > 0; instr_today     = instr_t(pos_t); else instr_today{1}     = ''; end

        if length(slot_yesterday) > 1 || length(slot_today) > 1 || length(rig_yesterday) > 1 || length(rig_today) > 1; 
            %Rat is on the schedule twice
            for i = 1:length(slot_yesterday)
                for j = 1:length(slot_today)
                    temp5 = find(slot_yesterday == slot_today(j));
                    temp6 = find(slot_today     == slot_yesterday(i));

                    if isempty(temp5)
                        %j is new for today
                        X.ratsadded{end+1} = [ratname,' added to rig ',num2str(rig_today(j)),' session ',num2str(slot_today(j))];

                    elseif rig_yesterday(temp5) ~= rig_today(j)
                        %j is new rig for today
                        X.ratsmoved{end+1} = [ratname,' moved from rig ',num2str(rig_yesterday(temp5)),' to rig ',num2str(rig_today(j)),' in session ',num2str(slot_today(j))];
                    end
                    if isempty(temp6)
                        %i removed for today
                        X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday(i))];

                    elseif rig_today(temp6) ~= rig_yesterday(i)
                        %i is new rig for today
                        X.ratsmoved{end+1} = [ratname,' moved from rig ',num2str(rig_yesterday(i)),' to rig ',num2str(rig_today(temp6)),' in session ',num2str(slot_today(temp6))];
                    end
                end
            end

            continue;
        end

        if (isempty(slot_yesterday) && isempty(slot_today)); continue; end

        if isempty(slot_today) && ~isempty(slot_yesterday)
            %Rat removed
            X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];

        elseif ~isempty(slot_today) && isempty(slot_yesterday)
            %Rat added
            X.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];

        elseif ~isempty(slot_today) && ~isempty(slot_yesterday)
            %if slot_today == slot_yesterday && rig_today == rig_yesterday; continue; end

            %Moved within session
            if slot_yesterday == slot_today && rig_today ~= rig_yesterday 
                X.ratsmoved{end+1}   = [ratname,' moved from rig ',num2str(rig_yesterday),' to rig ',num2str(rig_today),' in session ',num2str(slot_today)];
            end

            %Moved between sessions
            if slot_yesterday ~= slot_today
                X.ratsremoved{end+1} = [ratname,' removed from session ',num2str(slot_yesterday)];
                X.ratsadded{end+1}   = [ratname,' added to rig ',num2str(rig_today),' session ',num2str(slot_today)];
            end 
        end
        
        if strcmp(instr_yesterday{1}(instr_yesterday{1}~=' '),instr_today{1}(instr_today{1}~=' ')) == 0
            X.notechanged{end+1} = [ratname,' has a new instruction for today "',instr_today{1},'" rig ',num2str(rig_today),' session ',num2str(slot_today)];
        end
    end

    for i = shift;
        if i == 1;  
            [E Alum] = bdata('select email, is_alumni from ratinfo.contacts where tech_overnight="1"');
            S = [1 2 3 4]; 
        elseif i == 2;
            [E Alum] = bdata('select email, is_alumni from ratinfo.contacts where tech_morning="1"');
            S = [4 5 6 7];
        else
            [E Alum] = bdata('select email, is_alumni from ratinfo.contacts where tech_afternoon="1"');
            S = [7 8 9];
        end
        message = cell(0);
        RR = X.ratsremoved;
        RA = X.ratsadded;
        RM = X.ratsmoved;
        NC = X.notechanged;
        for r = 1:length(RR)-1; if r>length(RR); break; end; temp = []; temp(r+1:length(RR)) = strcmp(RR(r+1:end),RR{r}); RR(find(temp == 1)) = []; end %#ok<FNDSB>
        for r = 1:length(RA)-1; if r>length(RA); break; end; temp = []; temp(r+1:length(RA)) = strcmp(RA(r+1:end),RA{r}); RA(find(temp == 1)) = []; end %#ok<FNDSB>
        for r = 1:length(RM)-1; if r>length(RM); break; end; temp = []; temp(r+1:length(RM)) = strcmp(RM(r+1:end),RM{r}); RM(find(temp == 1)) = []; end %#ok<FNDSB>
        for r = 1:length(NC)-1; if r>length(NC); break; end; temp = []; temp(r+1:length(NC)) = strcmp(NC(r+1:end),NC{r}); NC(find(temp == 1)) = []; end %#ok<FNDSB>
        
        if ~isempty(RR) || ~isempty(RA) || ~isempty(RM) || ~isempty(NC)       
            foundaline = 0;
            for s = S
                message{end+1} = ['Session ',num2str(s),' changes:'];                                               %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RR); if RR{a}(end) == num2str(s); message{end+1} = RR{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RA); if RA{a}(end) == num2str(s); message{end+1} = RA{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(RM); if RM{a}(end) == num2str(s); message{end+1} = RM{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                for a = 1:length(NC); if NC{a}(end) == num2str(s); message{end+1} = NC{a}; foundaline = 1; end; end %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
                message{end+1} = '  ';                                                                              %#ok<AGROW>
            end
            message{end+1} = 'Thanks,';                                                                             %#ok<AGROW>
            message{end+1} = 'The Schedule Meister';                                                                %#ok<AGROW>
            message{end+1} = '  ';                                                                                  %#ok<AGROW>
            message{end+1} = '  ';                                                                                  %#ok<AGROW>
            message{end+1} = 'This email was generated by the Brody Lab Automated Email System.';                   %#ok<AGROW>
            
            IP = get_network_info;
            message{end+1} = ' '; %#ok<AGROW>
            if ischar(IP); message{end+1} = ['Email generated by ',IP]; %#ok<AGROW>
            else           message{end+1} = 'Email generated by an unknown computer!!!'; %#ok<AGROW>
            end
            
            message{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\checkschedulechange2.m';
            
            for m = 1:length(message); disp(message{m}); end
            
            if foundaline == 1
                for e = 1:length(E)
                    if Alum(e) == 1; continue; end
                    message = remove_duplicate_lines(message);
                    if do_sendmail==1; sendmail(E{e},'Training Schedule Changes',message); end
                    expname = bdata(['select experimenter from ratinfo.contacts where email="',E{e},'"']);
                    eval(['output.',expname{1},' = message;']);
                end
            end
        end
    end

    %if ~isempty(output)
        LTR = 'abcdefghijklmnopqrstuvwxyz';
        for ltr = 1:26
            file = ['C:\Automated Emails\Schedule\Changes\',yearmonthday,LTR(ltr),'.mat'];
            if ~exist(file,'file'); save(file,'output'); break; end    
        end
    %end
catch %#ok<CTCH>
    senderror_report;
end

    
    
    

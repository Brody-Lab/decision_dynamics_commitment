function check_shift_running_long

try
    set_email_sender

    [RT,DT,RG,ST,WE,SI] = bdata(['select ratname, sessiondate, rigid, starttime, was_ended, sessid',...
        ' from sess_started where sessiondate>="',datestr(now-1,'yyyy-mm-dd'),'" and sessiondate<"',...
        datestr(now+1,'yyyy-mm-dd'),'"']);

    [RM,DM,TM] = bdata(['select ratname, date, tech from ratinfo.mass where date>="',datestr(now-1,'yyyy-mm-dd'),...
        '" and date<"',datestr(now+1,'yyyy-mm-dd'),'"']);

    dur = zeros(37,1); dur(:) = nan;
    ses = zeros(37,1); ses(:) = nan;
    dat = cell(37,1);
    tec = cell(37,1); for i=1:37; tec{i} = ''; end
    running = zeros(37,1);
    endtime = cell(37,1);

    for rig = 1:37
        rigpos = find(RG == rig);
        if isempty(rigpos)
            running(rig) = 0;
            endtime{rig} = nan;
        else
            lastsess = find(SI == max(SI(rigpos)),1,'last');
            if WE(lastsess) == 1
                running(rig) = 0;
                [endtemp,datetemp] = bdata(['select endtime, sessiondate from sessions where sessid=',num2str(SI(lastsess))]);
                if ~isempty(endtime) && ~isempty(datetemp)
                    endtime{rig} = [datetemp{1},' ',endtemp{1}];
                else
                    endtime{rig} = nan;
                end
            else
                running(rig) = 1;

                rattemp  = RT{lastsess};
                datetemp = DT{lastsess};
                timetemp = ST{lastsess};

                dur(rig) = (now - datenum([datetemp,' ',timetemp],'yyyy-mm-dd HH:MM:SS'))*24;

                sesstemp = bdata(['select timeslot from ratinfo.schedule where ratname="',rattemp,'" and date="',datetemp,'"']);
                if numel(sesstemp) == 1; ses(rig) = sesstemp; 
                else                     ses(rig) = nan;
                end
                dat{rig} = datetemp;

                tech = find(strcmp(RM,rattemp) == 1 & strcmp(DM,datetemp) == 1);
                if numel(tech) == 1
                    tec{rig} = TM{tech};
                end
            end
        end
    end


    if nanmedian(dur) > 5.5 && sum(running) > 10

        %We have a long session detected.  Let's see if any rigs have been
        %ended in the last 10 minutes and note that in the alert

        for i = 1:numel(endtime)
            if ~isempty(endtime{i})
                try
                    ended(i) = (now - datenum(endtime{i},'yyyy-mm-dd HH:MM:SS')) * 24 * 60; %#ok<AGROW>
                catch
                    ended(i) = nan;
                end
            else
                ended(i) = nan; %#ok<AGROW>
            end
        end
        numendrecent = sum(ended < 10);
        if numendrecent == 0
            extramessage = 'No rigs have been ended in the past 10 minutes.';
        elseif numendrecent == 1
            extramessage = [num2str(numendrecent),' rig has been ended in',...
                ' the past 10 minutes so a tech may be on site.'];
        else
            extramessage = [num2str(numendrecent),' rigs have been ended in',...
                ' the past 10 minutes so a tech may be on site.'];
        end


        currsess = mode(ses);
        currdate = dat{find(ses == currsess,1,'first')};

        utec = unique(tec);
        utec(strcmp(utec,'')) = [];
        for i = 1:numel(utec);
            nt(i) = sum(strcmp(tec,utec{i})); %#ok<AGROW>
        end
        starttech_initials = utec{find(nt == max(nt),1,'first')};
        starttech = bdata(['select experimenter from ratinfo.contacts where initials="',starttech_initials,'" and is_alumni=0']);

        if     currsess == 9 
            endtech = bdata(['select overnight from ratinfo.tech_schedule where date="',datestr(datenum(currdate)+1,'yyyy-mm-dd'),'"']);        
        elseif currsess == 1 || currsess == 2
            endtech = bdata(['select overnight from ratinfo.tech_schedule where date="',currdate,'"']);
        elseif currsess == 3 || currsess == 4 || currsess == 5
            endtech = bdata(['select morning from ratinfo.tech_schedule where date="',currdate,'"']);
        elseif currsess == 6 || currsess == 7 || currsess == 8
            endtech = bdata(['select evening from ratinfo.tech_schedule where date="',currdate,'"']);
        else
            endtech = {'unknown'};
        end

        message = ['Session ',num2str(currsess),' started by ',starttech{1},' on ',currdate,...
            ' appears to be running for ',num2str(round(nanmedian(dur)*100)/100),' hours and should',...
            ' have been ended by ',endtech{1},'. ',extramessage,' Rats must be removed from training',...
            ' rigs promptly. Coordinate conversation on Slack #Rigs channel.'];

        [EXP,EMAIL] = bdata('select experimenter, email from ratinfo.contacts where is_alumni = 0'); 

        %EXP = {'Chuck'};
        %EMAIL = {'ckopec@princeton.edu'};

        for i = 1:numel(EXP);
            if nanmedian(dur) > 6.5
                try
                    send_text_message(message,'Long Training Alert',EXP{i});
                end
            else
                try
                    sendmail(EMAIL{i},'Long Training Alert',message)
                end
            end
        end

    end

catch
    senderror_report

end


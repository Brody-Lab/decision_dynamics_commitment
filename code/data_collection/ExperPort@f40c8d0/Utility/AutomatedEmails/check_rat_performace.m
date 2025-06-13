function check_rat_performace(day,varargin)

try
    if nargin == 0; day = now; end
    
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['PerformanceMeister',datestr(now,'yymm'),'@princeton.edu']);
    set_email_sender
    
    [Exp email IN]            = bdata('select experimenter, email, initials from ratinfo.contacts where is_alumni=0 order by experimenter');
    [ratR contact]            = bdata('select ratname, contact from ratinfo.rats');
    [CalRig CalIn CalDate]    = bdata(['select rig_id, initials, dateval from calibration_info_tbl where dateval>" ',datestr(day-100,'yyyy-mm-dd'),'" and dateval<=" ',datestr(day,'yyyy-mm-dd'),'" order by dateval']);
    [SchRig SchRat]           = bdata(['select rig, ratname from ratinfo.schedule where date="',datestr(day,'yyyy-mm-dd'),'"']);
    [MassRat Mass MassDate]   = bdata(['select ratname, mass, date from ratinfo.mass where date>"',datestr(day-7,'yyyy-mm-dd'),'" and date<="',datestr(day,'yyyy-mm-dd'),'"']);
    [N L R ratn rig st et DT] = bdata(['select n_done_trials, left_correct, right_correct, ratname,',...
        ' hostname, starttime, endtime, sessiondate from sessions where sessiondate>"',datestr(day-60,'yyyy-mm-dd'),'" and sessiondate<="',datestr(day,'yyyy-mm-dd'),'"']);
    
    L(L < 0) = 0;
    R(R < 0) = 0;
    N(N < 0) = 0;
    
    if sum(strcmpi(rig,'unknown')) > 0
        rig(find(strcmpi(rig,'unknown')==1)) = {'Rig00'}; %#ok<FNDSB>
    end
    
    ratT = unique(ratn(strcmp(DT,datestr(day,'yyyy-mm-dd'))));
    for i=1:length(email); econ{i} = email{i}(1:find(email{i}=='@',1,'first')-1); end
    for i=1:length(rig);   RIG(i)  = str2num(rig{i}(4:end)); end %#ok<ST2NM>
    for i=1:length(st);    ST(i)   = datenum(st{i},'HH:MM:SS'); end 
    for i=1:length(et);    ET(i)   = datenum(et{i},'HH:MM:SS'); end 
    DUR = round((ET - ST) * 24 * 60);

    for i=[0:38,201:205,210,401:404] 
        eval(['X.rig',num2str(i),'.data=[];']); 
        eval(['X.rig',num2str(i),'.rat={};']);
    end

    %Let's compile the data for each rat and rig
    for i = 1:length(ratT)
        x = strcmp(ratn,ratT{i});
        if sum(x) == 0; continue; end

        n = N(x);
        l = L(x);
        r = R(x);
        d = r-l;

        zn = (n-mean(n))/std(n);
        zd = (d-mean(d))/std(d);

        cn = n(zn > -4 & zn < 4);
        cd = d(zd > -4 & zd < 4);

        xt = strcmp(ratn,ratT{i}) & strcmp(DT,datestr(day,'yyyy-mm-dd'));
        if sum(xt) ~= 1; continue; end

        nt = N(xt);
        lt = L(xt);
        rt = R(xt);
        dt = rt-lt;

        ztn = (nt - mean(cn)) / std(cn);
        ztd = (dt - mean(cd)) / std(cd);

        clear data
        data.zn  = ztn;
        data.zd  = ztd;
        data.n   = nt;
        data.d   = dt;
        data.mn  = mean(cn);
        data.md  = mean(cd);
        data.dur = DUR(xt);
        data.rig = RIG(xt);
        
        data.mass = [];
        for j=-6:0
            temp = strcmp(MassDate,datestr(day+j,'yyyy-mm-dd')) & strcmp(MassRat,ratT{i});
            if sum(temp) == 1; data.mass(end+1) = Mass(temp);
            else               data.mass(end+1) = NaN;
            end
        end

        scht = strcmp(SchRat,ratT{i});
        if sum(scht) == 1; data.schrig = SchRig(scht);
        else               data.schrig = [];
        end

        problem = '';
        df = 0;
        if     ztd < -3; problem = 'Significant Left Bias';  df = 1;
        elseif ztd >  3; problem = 'Significant Right Bias'; df = 1;
        end

        if df == 1 && abs(ztn) > 3; problem = [problem,' AND ']; end

        if     ztn < -3; problem = [problem,'Too Few Trials'];
        elseif ztn >  3; problem = [problem,'Too Many Trials'];
        end
        data.problem = problem;

        if abs(ztn) > 3 || abs(ztd) > 3; 
            eval(['Z.rat.',ratT{i},'=data;']);
        end

        RG = RIG(xt);
        if any([0:38,201:205,210,401:404] == RG)
            eval(['X.rig',num2str(RG),'.data(end+1,:) = [ztn ztd nt dt];']);
            eval(['X.rig',num2str(RG),'.rat{ end+1}   = ratT{i};']);
        end
    end
    
    temp = randn(1e4,9);
    for i=1:9; ZMAT(:,i) = mean(temp(:,1:i),2); end 


    %Let's figure out which rigs are significantly off
    for i=[1:38,201:205,210,401:404]
        data = eval(['X.rig',num2str(i),'.data;']);
        if isempty(data) || size(data,1)==1; continue; end

        zn = data(:,1); zn(zn < -3) = -3; zn(zn > 3) = 3;
        zd = data(:,2); zd(zd < -3) = -3; zd(zd > 3) = 3;
        nt = data(:,3);
        dt = data(:,4);
        rigrats = eval(['X.rig',num2str(i),'.rat;']);

        c = numel(zn);

        clear ratst
        for r=1:c
            ratst(r)=ST(strcmp(ratn,rigrats{r}) & strcmp(DT,datestr(day,'yyyy-mm-dd'))); 
        end
        [ratst ord] = sortrows(ratst');
        zn = zn(ord);
        zd = zd(ord);
        nt = nt(ord);
        dt = dt(ord);
        rigrats = rigrats(ord);

        zzn = (mean(zn) - mean(ZMAT(:,c))) / std(ZMAT(:,c));
        zzd = (mean(zd) - mean(ZMAT(:,c))) / std(ZMAT(:,c));

        clear data
        data.zzn = zzn;
        data.zzd = zzd;
        data.zn  = zn';
        data.zd  = zd';
        data.nt  = nt';
        data.dt  = dt';
        data.rat = rigrats;

        problem = '';
        df = 0;
        if     zzd < -3; problem = ['Significant Left Bias Z=', sprintf('%+4.1f',data.zzd)];  df = 1;
        elseif zzd >  3; problem = ['Significant Right Bias Z=',sprintf('%+4.1f',data.zzd)]; df = 1;
        end

        if df == 1 && abs(zzn) > 3; problem = [problem,' AND ']; end

        if     zzn < -3; problem = [problem,'Too Few Trials Z=', sprintf('%+4.1f',data.zzn)];
        elseif zzn >  3; problem = [problem,'Too Many Trials Z=',sprintf('%+4.1f',data.zzn)];
        end
        data.problem = problem;
        
        %save the z-scores to the schedule for future trend analysis
        id = bdata(['select schedentryid from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),...
            '" and rig=',num2str(i),' and timeslot=9']);
        bdata('call ratinfo.update_rig_bias_n("{S}","{S}","{S}")',zzn,zzd,id);
        
        temp = strcmp(CalRig,num2str(i));
        if sum(temp) ~= 0
            lastcalib = unique(CalDate(temp));
            lastcalib = lastcalib{end}(1:10);
            techin = CalIn{find(temp == 1,1,'last')};
            temp = strcmp(IN,techin);
            if sum(temp) == 1; techname = Exp{temp};
            else               techname = techin;
            end
            lastcalib = [lastcalib,' by ',techname];
        else
            lastcalib = 'Older than 100 days';
        end
        data.lastcalib = lastcalib;

        if abs(zzd) > 3 || abs(zzn) > 3
            eval(['Z.rig.rig',num2str(i),'=data;']);
        end
    end

    if exist('Z','var')
        if isfield(Z,'rig'); badrigs = fields(Z.rig);
        else                 badrigs = [];
        end
        if isfield(Z,'rat'); badrats = fields(Z.rat);
        else                 badrats = [];
        end
    else
        badrigs = [];
        badrats = [];
    end

    %Now we send out the emails
    for i=1:length(Exp)
        message    = cell(0);
        message{1} = [Exp{i},','];
        message{2} = ' ';
        message{3} = 'Below is a summary of all anomalous performance';
        message{4} = 'by your rats or rigs in which your rats train.';
        message{5} = ' ';

        %Let's find all the rats that have a problem that belong to this
        %experimenter
        donefirst = 0;
        for j = 1:length(badrats)
            ratdata = eval(['Z.rat.',badrats{j}]);

            temp = strcmp(ratR,badrats{j});
            if sum(temp) ~= 1; continue; end
            con = contact{temp};
            if ~isempty(strfind(con,econ{i}))
                %This experimenter owns this rat

                if donefirst == 0
                    message{end+1} = 'Problem Rats:';
                    message{end+1} = ' ';
                    donefirst = 1;
                end
                message{end+1} = [badrats{j},'  ',ratdata.problem];
                message{end+1} = ' ';

                if abs(ratdata.zn) >= 3
                    message{end+1} = ['  Total Trials: ',num2str(ratdata.n),' (average ',num2str(round(ratdata.mn)),')'];
                    message{end+1} = ['       Trial Z: ',sprintf('%+4.1f',ratdata.zn)];
                    message{end+1} = ['    Run Length: ',num2str(ratdata.dur),' minutes'];
                end

                if abs(ratdata.zd) >= 3
                    message{end+1} = ['          Bias: ',sprintf('%+5.2f ',ratdata.d),' (average ',sprintf('%+4.2f',ratdata.md),')'];
                    message{end+1} = ['        Bias Z: ',sprintf('%+4.1f',ratdata.zd)];
                    message{end+1} = ['  Total Trials: ',num2str(ratdata.n),' (average ',num2str(round(ratdata.mn)),')'];
                end
                
                message{end+1} = '          Mass: ';
                for m=1:length(ratdata.mass); message{end} = [message{end},sprintf('%3.0f ',(ratdata.mass(m)))]; end
                
                if ratdata.rig == ratdata.schrig
                    message{end+1} = ['           Rig: ',num2str(ratdata.rig)];
                else
                    message{end+1} = ['           Rig: ',num2str(ratdata.rig),' (schedule ',num2str(ratdata.schrig),')'];
                end
                message{end+1} = ' ';
            end
        end
        if donefirst == 1; message{end+1} = ' '; message{end+1} = ' '; end


        %Let's find all the rigs that have a problem with one of this
        %experimenters rats in it
        donefirst = 0;
        for j = 1:length(badrigs)
            rigdata = eval(['Z.rig.',badrigs{j}]);
            rigrats = rigdata.rat;

            for k = 1:length(rigrats)
                temp = strcmp(ratR,rigrats{k});
                if sum(temp) ~= 1; continue; end
                con = contact{temp};
                if ~isempty(strfind(con,econ{i}))
                    %This experimenter owns a rat in this rig

                    if donefirst == 0
                        message{end+1} = 'Problem Rigs:'; %#ok<*AGROW>
                        message{end+1} = ' ';
                        donefirst = 1;
                    end
                    message{end+1} = ['Rig ',badrigs{j}(4:end),'  ',rigdata.problem];
                    message{end+1} = ' ';
                    message{end+1} = '          Rats: ';
                    for m = 1:length(rigrats); message{end} = [message{end},rigrats{m},'  ']; end

                    if abs(rigdata.zzn) >= 3;
                        message{end+1} = '  Total Trials: ';
                        for m = 1:length(rigdata.nt); message{end} = [message{end},sprintf('%4.0f  ',(rigdata.nt(m)))]; end
                        message{end+1} = '       Trial Z: '; 
                        for m = 1:length(rigdata.zn); message{end} = [message{end},sprintf('%+4.1f  ',(rigdata.zn(m)))]; end
                    end

                    if abs(rigdata.zzd) >= 3
                        message{end+1} = '          Bias: ';
                        for m = 1:length(rigdata.dt); message{end} = [message{end},sprintf('%+5.2f ',(rigdata.dt(m)))]; end
                        message{end+1} = '        Bias Z: ';
                        for m = 1:length(rigdata.zd); message{end} = [message{end},sprintf('%+4.1f  ',(rigdata.zd(m)))]; end
                    end
                    message{end+1} = ['  Last Calibration: ',rigdata.lastcalib];

                    message{end+1} = ' ';

                    %Now we break out of the loop through rigrats so we don't
                    %duplicate the message if the experimenter happens to own
                    %more than 1 rat in this rig
                    break;
                end
            end
        end

        if length(message) > 5
            IP = get_network_info;
            message{end+1} = ' ';
            if ischar(IP); message{end+1} = ['Email generated by ',IP];
            else           message{end+1} = 'Email generated by an unknown computer!!!';
            end
            
            message{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\check_rat_performance.m';
            
            disp(message');
            disp(' ');
            disp(' ');
            sendmail(email{i},'Performance Issues',message);
        end
    end

catch %#ok<CTCH>
    senderror_report;
end



function checkdir_uncommitted_files

try
    E = bSettings('get','GENERAL','Main_Code_Directory');

    cd(E);
    newstartup;
    dispatcher('init');

    D = bSettings('get','GENERAL','Main_Data_Directory');
    Ds = {[D,filesep,'Data'], [D,filesep,'Settings']};

    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['OldFileRecovery',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    RID = bSettings('get','RIGS','Rig_ID');
    if isnan(RID); pause((rand(1)*120)); 
    else           pause(RID*10);
    end

    if exist([D,filesep,'uncommitable_files.mat'],'file') == 0
        uncommitable = cell(1,2);
    else
        load([D,filesep,'uncommitable_files.mat']);
    end

    for d = 1:length(Ds)
        Exp = dir(Ds{d});

        for e = 1:length(Exp)
            if strcmp(Exp(e).name,'.')   || strcmp(Exp(e).name,'..') ||...
               strcmp(Exp(e).name,'CVS') || strcmp(Exp(e).name,'experimenter') ||...
               ~Exp(e).isdir
                continue; 
            end

            ratnames = dir([Ds{d},filesep,Exp(e).name]);

            for r = 1:length(ratnames)
                if strcmp(ratnames(r).name,'.')   || strcmp(ratnames(r).name,'..') ||...
                   strcmp(ratnames(r).name,'CVS') || strcmp(ratnames(r).name,'ratname') ||...
                   ~ratnames(r).isdir
                    continue; 
                end

                p = [Ds{d},filesep,Exp(e).name,filesep,ratnames(r).name];
                disp(['Checking: ',p]);

                z      = dir(p);
                cd(p); pause(0.01);

                %Find orphaned ASV files
                dt_asv = cell(0);
                dt_com = cell(0);
                floc   = [];
                for i = 1:length(z)
                    if length(z(i).name) < 4; continue; end
                    [pname fname ext vers] = fileparts(z(i).name); %#ok<NASGU>
                    if length(fname) > 9
                        if strcmpi(fname(end-2:end),'asv') 
                            dt_asv{end+1} = fname(end-9:end-4); %#ok<AGROW>
                            floc(end+1)   = i;
                        else
                            dt_com{end+1} = fname(end-6:end-1); %#ok<AGROW>
                        end
                    end
                end
                for i = 1:length(dt_asv)
                    if sum(strcmp(dt_asv{i},dt_com)) == 0
                        oldfile = [p,filesep,z(floc(i)).name];
                        if length(oldfile) > 8
                            newfile = [oldfile(1:end-8),'a.mat'];
                            disp(['Found unmatched ASV file: ',z(floc(i)).name]);
                            disp('Generating new file:');
                            disp(newfile);

                            %Load the new file in the protocol and run pre_saving_settings

                            copyfile(oldfile,newfile,'f');
                            curdir = pwd;
                            try
                                [pname,fname,ext,versn] = fileparts(newfile);
                                us = find(fname == '_');
                                if length(fname)>12 && strcmp(fname(1:4),'data') && length(us)>=4
                                    proto=fname(us(1)+2:us(2)-1);
                                    protoobj=(eval(proto));
                                    expn = fname(us(2)+1:us(3)-1);
                                    ratn = fname(us(3)+1:us(4)-1);

                                    cd(E);
                                    dispatcher('set_protocol',proto);
                                    load_soloparamvalues(protoobj,ratn,'data_file',newfile);

                                    evalstr=[proto '(' proto ',''pre_saving_settings'')'];
                                    eval(evalstr);

                                    sessid=getSessID(protoobj);
                                    bdata(['update_crashed(',num2str(sessid),',1)']); 
                                end
                            catch
                                message = cell(0);
                                message{end+1} = 'Found an orphaned ASV file:'; %#ok<AGROW>
                                message{end+1} = oldfile; %#ok<AGROW>
                                message{end+1} = ' '; %#ok<AGROW>
                                message{end+1} = 'and committed it to SoloData as:'; %#ok<AGROW>
                                message{end+1} = newfile; %#ok<AGROW>
                                message{end+1} = ' '; %#ok<AGROW>
                                message{end+1} = ['but was unable to run pre_saving_settings in ',proto]; %#ok<AGROW>
                                message{end+1} = 'so the data is NOT in the sessions table.'; %#ok<AGROW>

                                contacts = bdata(['select contact from ratinfo.rats where ratname="',ratn,'"']);
                                if ~isempty(contacts)
                                    contacts = contacts{1};
                                    if ~isempty(contacts)
                                        if sum(contacts == ' ') > 0 && sum(contacts == ',') > 0
                                            contacts(contacts == ' ') = [];
                                        elseif sum(contacts == ' ') > 0
                                            contacts(contacts == ' ') = ',';
                                        end
                                        contacts = [',',contacts,',']; %#ok<AGROW>
                                        bks = find(contacts == ',');
                                        for c = 2:length(bks)
                                            contact = contacts(bks(c-1)+1:bks(c)-1);
                                            try
                                                sendmail([contact,'@princeton.edu'],'Orphaned ASV File Problem',message);
                                            end
                                        end
                                    end
                                end
                            end
                            cd(curdir);
                        end
                    end
                end

                z      = dir(p);
                files  = cell(length(z),1);
                status = cell(length(z),1);
                fcnt = 0; scnt = 0;

                %Check for uncommitted files
                F = fopen([p,filesep,'CVS',filesep,'Entries']);
                if F == -1; continue; end
                y = textscan(F,'%s','Delimiter','\n');
                y = y{1};
                fclose(F);
                for i = 1:length(y)
                    if y{i} == 'D'; continue; end
                    breaks = find(y{i} == '/');
                    if isempty(breaks); continue; end
                    fcnt = fcnt + 1; scnt = scnt + 1;
                    files{fcnt}  = y{i}(breaks(1)+1:breaks(2)-1);
                    status{scnt} = y{i}(breaks(2)+1:breaks(3)-1);
                end

                files( fcnt+1:end) = [];
                status(scnt+1:end) = [];

                badfiles = cell(0);
                for i = 1:length(z)
                    if z(i).isdir == 1; continue; end
                    temp = strcmp(z(i).name,files);
                    if sum(temp) == 0; badfiles{end+1} = z(i).name;  %#ok<AGROW>
                    else
                        if status{temp}=='0'; badfiles{end+1} = z(i).name; end %#ok<AGROW>
                    end
                end

                skipfile = [];
                for i = 1:length(badfiles)
                    if badfiles{i}(1) ~= 's' && badfiles{i}(1) ~= 'd'
                        skipfile(end+1) = i; %#ok<AGROW>
                        continue;
                    end
                    if length(badfiles{i}) > 2 && ~strcmp(badfiles{i}(end-2:end),'mat')
                        skipfile(end+1) = i; %#ok<AGROW>
                        continue;
                    end
                    for j = 1:length(badfiles{i})-2
                        if badfiles{i}(j) == 'a' || badfiles{i}(j) == 'A'
                            if strcmp(badfiles{i}(j:j+2),'asv') || strcmp(badfiles{i}(j:j+2),'ASV');
                                skipfile(end+1) = i; %#ok<AGROW>
                                break;
                            end
                        end
                    end
                    temp = strcmp(badfiles{i},uncommitable(:,1));
                    if sum(temp) > 0 && uncommitable{temp,2} >= 10; skipfile(end+1) = i; end %#ok<AGROW>
                end
                badfiles(skipfile) = [];
                disp(badfiles');


                %Commit the files
                for i = 1:length(badfiles)
                    [errID errmsg] = add_and_commit(badfiles{i}); %#ok<NASGU>
                    if errID ~= 0
                        temp = strcmp(badfiles{i},uncommitable(:,1));
                        if sum(temp) == 0
                            uncommitable(end+1,1) = {badfiles{i}}; %#ok<AGROW>
                            uncommitable(end  ,2) = {1};
                        else
                            uncommitable(temp ,2) = {uncommitable{temp,2} + 1};
                        end
                    end
                end
            end
        end
    end

    save([D,filesep,'uncommitable_files.mat'],'uncommitable');

catch %#ok<CTCH>
    senderror_report;
end

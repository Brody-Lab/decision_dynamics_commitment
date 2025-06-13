function TN_removetraining(handles,state)

if get(handles.rat_button,'value') == 1
    
    names = get(handles.name_menu,'string');
    tech  = names{get(handles.name_menu,'value')};

    [Rr,C,Er,Recov,RID] = bdata('select ratname, contact, experimenter, recovering, internalID from ratinfo.rats where extant=1');
    [Exp,Eml,phone] = bdata('select experimenter, email, telephone from ratinfo.contacts where is_alumni=0');
    
    temp = strcmp(Exp,tech);
    if sum(temp) == 1
        techphone = phone(temp);
    end
    
    for i = 1:length(handles.active)
        ratname = handles.active{i};
        
        if strcmp(state,'missing')
            answer = questdlg(['Are you sure you want to flag ',ratname,' as missing?'],...
                '','Yes','No','No');
            
        elseif strcmp(state,'training')
            answer = questdlg(['Are you sure you want to return ',ratname,' to water restriction and training?'],...
                '','Yes','No','No');
            
        elseif strcmp(state,'hematuria')
            answer = questdlg(['Are you sure you want to flag ',ratname,' as hematuria?'],...
                '','Yes','No','No');
            
        else
            if strcmp(state,'sick') && isempty(get(handles.note_edit,'string'))
                msgbox('You must enter a description of the rat''s condition in the note window before submiiting a sick note.',...
                       'NOTE NOT SENT');
                return; 
            end
            
            answer = questdlg(['Are you sure you want to remove ',ratname,' from training and flag as ',state,'?'],...
                '','Yes','No','No');
        end
        
        if strcmp(answer,'Yes')
            
            contact=bdata(['select contact from ratinfo.rats where ratname="',ratname,'"']);
            realexp = find_realexp(contact,Exp,Eml);
            
            cm = bdata(['select cagemate from ratinfo.rats where ratname="',ratname,'"']);
            if iscell(cm) && ~isempty(cm); cm = cm{1}; end
        
            if strcmp(state,'hematuria'); separate = 1;
            else,                         separate = 0;
            end
            
            if ~isempty(cm) && ~strcmp(state,'missing') && ~strcmp(state,'hematuria')
                answer2 = questdlg([ratname,' has ',cm,' as a cagemate. Do you want to separate them?'],...
                    '','Yes','No','Yes');
                if strcmp(answer2,'Yes'); separate = 1; end
            end
            
            if strcmp(state,'recovery') || strcmp(state,'freewater') || strcmp(state,'sick')
                recovdays = inputdlg(['In how many days do you want ',ratname,' to return to training? (Leave blank if unknown or never)']);
                recovdays = str2num(recovdays{1}); %#ok<ST2NM>
            else
                recovdays = [];
            end
            
            if strcmp(state,'recovery')
                put_rat_on_recovery(ratname,0,separate,recovdays);
            
            elseif strcmp(state,'freewater')
                put_rat_on_recovery(ratname,1,separate,recovdays);
                
            elseif strcmp(state,'hematuria')
                %if ~isempty(cm)
                    
                    answer2 = questdlg(['Which hematuria check is this for ',ratname,'?'],'','First','Second','First');
                    if strcmp(answer2,'First')

                        ratID = bdata(['select internalID from ratinfo.rats where ratname="',ratname,'"']);
                        %mym(bdata,['update ratinfo.rats set cagemate="" where internalID="',num2str(ratID),'"']);
                        bdata('call ratinfo.update_cagemate("{S}","{Si}")','',ratID);
                        
                        if ~isempty(cm)
                            mateID = bdata(['select internalID from ratinfo.rats where ratname="',cm,'"']);
                            if numel(mateID) == 1
                                %mym(bdata,['update ratinfo.rats set cagemate="" where internalID="',num2str(mateID),'"']);
                                bdata('call ratinfo.update_cagemate("{S}","{Si}")','',mateID);
                            end
                        end
                        
                        [sID,TI] = bdata(['select schedentryid, instructions from ratinfo.schedule where ratname="',...
                            ratname,'" and date="',datestr(now+1,'yyyy-mm-dd'),'"']);
                        
                        for sid = 1:numel(sID)
                            %mym(bdata,['update ratinfo.schedule set instructions="',['Check Hematuria ',TI{sid}],...
                            %           '" where schedentryid=',num2str(sID(sid))]);
                            bdata('call ratinfo.update_schedule_instructions("{S}",{Si})',['Check Hematuria ',TI{sid}],sID(sid));       
                        end
                        
                        if isempty(sID)
                            nsID = bdata(['select schedentryid from ratinfo.schedule where ratname="',...
                                ratname,'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
                            
                            copy_schedule_tomorrow(nsID);
                            
                            [sID,TI] = bdata(['select schedentryid, instructions from ratinfo.schedule where ratname="',...
                                ratname,'" and date="',datestr(now+1,'yyyy-mm-dd'),'"']);

                            for sid = 1:numel(sID)
                                %mym(bdata,['update ratinfo.schedule set instructions="',['Check Hematuria ',TI{sid}],...
                                %           '" where schedentryid=',num2str(sID(sid))]);
                                bdata('call ratinfo.update_schedule_instructions("{S}",{Si})',['Check Hematuria ',TI{sid}],sID(sid));       
                            end
                        end
                        
                    elseif strcmp(answer2,'Second')
                        msgbox(['If this is ',ratname,'s 2nd positive sign of hematuria please flag him as sick with',...
                                ' the note indicating 2nd hematuria check.']);
                    end
                %end
            
            elseif strcmp(state,'sick')
                
                put_rat_on_recovery(ratname,0,separate,recovdays);
                
                note = get(handles.note_edit,'string');
                if isempty(strfind(note,'Flagged as Sick: ')) %#ok<STREMP>
                    note = ['Flagged as Sick: ',note];
                end
                TN_submit(handles);
                
                %Sick notes should go to the tech supervisor.  There's no
                %field for this in the contacts but they will likely be the
                %only person with lab manager and subscribe all both set to
                %1. So let's add them to the list.
                
                TS = bdata('select experimenter from ratinfo.contacts where lab_manager=1 and subscribe_all=1 and is_alumni=0');
                if ~isempty(TS); realexp(end+1:end+numel(TS)) = TS; end
                realexp = unique(realexp);
                
                for j = 1:numel(realexp)
                    note = get(handles.note_edit,'string');
                    message = [ratname,' was flagged as ',state,' by ',tech,' (',num2str(techphone),'). ',note];
                    send_text_message(message,[ratname,' SICK'],realexp{j});
                end
            
            elseif strcmp(state,'dead')
                
                answer3 = questdlg(['Are you absolutely certain you want to flag ',ratname,' as dead?'],'','Yes','No','No');
                if strcmp(answer3,'Yes')
                
                    [oldid, rig, slot, Scomments]=bdata(['select schedentryid, rig, timeslot, comments from ratinfo.schedule where date>="',...
                        datestr(now,'yyyy-mm-dd'),'" and ratname="',ratname,'" order by date desc']);
                    [ratID,contact]=bdata(['select internalID, contact from ratinfo.rats where ratname="',ratname,'"']);

                    if numel(ratID)==1   
                        
                        realexp = find_realexp(contact,Exp,Eml);
                        
                        if ~isempty(oldid)
                            %He is on the schedule
                            if ~isempty(realexp); rsvmsg = ['reserved for ',realexp{1},' [[',Scomments{end},']]'];
                            else                  rsvmsg = Scomments{end};
                            end
                            for x=1:numel(oldid)
                                %mym(bdata,'update ratinfo.schedule set ratname="", experimenter="", comments="{S}" where schedentryid="{S}"',...
                                %    rsvmsg,oldid(x));
                                bdata('call ratinfo.update_schedule_ratname("{S}",{Si})','',oldid(x));
                                bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})','',oldid(x));
                                bdata('call ratinfo.update_schedule_comments("{S}",{Si})',rsvmsg,oldid(x));
                                
                            end
                            disp(['Rat ',ratname,' removed from the schedule, marked as reserved: Rig ',num2str(rig(x)),', Slot ',num2str(slot(x))]);
                        end

                        %Mark as dead
                        %mym(bdata,['update ratinfo.rats set extant=0, dateSac="',datestr(now,'yyyy-mm-dd'),'" where internalID="{S}"'],ratID);
                        bdata('call ratinfo.flag_rat_dead("{S}","{Si}")',datestr(now,'yyyy-mm-dd'),ratID)
                        
                        for j = 1:numel(realexp)
                            message = [ratname,' was flagged as ',state,' by ',tech,' (',num2str(techphone)...
                                       ') and removed from training.'];
                            send_text_message(message,[ratname,' DEAD'],realexp{j});
                        end

                        if separate == 1
                            %set his cagemate to "" and same for his cagemate

                            cm = bdata(['select cagemate from ratinfo.rats where internalID=',num2str(ratID)]);
                            if iscell(cm) && ~isempty(cm); cm = cm{1}; end
                            if ~isempty(cm)
                                %mym(bdata,'update ratinfo.rats set cagemate="" where internalID="{S}"',ratID);
                                bdata('call ratinfo.update_cagemate("{S}","{Si}")','',ratID);
                                mateID = bdata(['select internalID from ratinfo.rats where ratname="',cm,'"']);
                                if numel(mateID) == 1
                                    %mym(bdata,'update ratinfo.rats set cagemate="" where internalID="{S}"',mateID);
                                    bdata('call ratinfo.update_cagemate("{S}","{Si}")','',mateID);
                                end
                            end
                        end

                    end
                end
            
            elseif strcmp(state,'missing')
                
                for j = 1:numel(realexp)
                    message = [ratname,' was flagged as ',state,' by ',tech,' (',num2str(techphone),').'];
                    send_text_message(message,[ratname,' MISSING'],realexp{j});
                end
                
            elseif strcmp(state,'training')
                [id,note,dt,Rs] = bdata(['select schedentryid, comments, date, ratname from ratinfo.schedule where date>="',...
                    datestr(now,'yyyy-mm-dd'),'"']);
                
                ID = [];
                DT = cell(0);
                RS = cell(0);
                NT = cell(0);
                phrase = lower(['reserved for ',ratname]);
                for j = 1:numel(note)
                    if ~isempty(strfind(lower(note{j}),phrase))
                        ID(end+1) = id(j); %#ok<AGROW>
                        DT{end+1} = dt{j}; %#ok<AGROW>
                        RS{end+1} = Rs{j}; %#ok<AGROW>
                        NT{end+1} = note{j}; %#ok<AGROW>
                    end
                end
                
                if isempty(ID)
                    msgbox(['No rigs found reserved for ',ratname]);
                    return;
                end

                foundtomorrow = 0;
                temp = strcmp(Rr,ratname);
                if sum(temp) == 1
                    fakeexp = Er{temp};
                    tomorrow = strcmp(DT,datestr(now+1,'yyyy-mm-dd'));

                    for j = 1:numel(tomorrow)
                        if tomorrow(j) == 1
                            if isempty(RS{j})
                                st = strfind(NT{j},'[[');
                                ed = strfind(NT{j},']]');
                                if numel(st) == 1 && numel(ed) == 1
                                    newnote = NT{j}(st+2:ed-1);
                                else
                                    newnote = NT{j};
                                end
                                b = strfind(lower(newnote),phrase);
                                bad = zeros(size(newnote));
                                for k = 1:numel(b)
                                    bad(b(k):b(k)+numel(phrase)-1) = 1;
                                end
                                newnote(bad == 1) = '';
                                
                                
                                %mym(bdata,'update ratinfo.schedule set ratname="{S}", experimenter="{S}", comments="{S}", instructions="{S}" where schedentryid={S}',...
                                %    ratname,fakeexp,newnote,'Remove from free water',ID(j));
                                bdata('call ratinfo.update_schedule_ratname("{S}",{Si})',ratname,ID(j));
                                bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})',fakeexp,ID(j));
                                bdata('call ratinfo.update_schedule_comments("{S}",{Si})',newnote,ID(j));
                                bdata('call ratinfo.update_schedule_instructions("{S}",{Si})','Remove from free water',ID(j));
                                
                                foundtomorrow = 1;
                            else
                                msgbox(['Rig reserved for ',ratname,' is already scheduled for ',RS{j}]);
                            end
                        end
                    end

                    
                    if sum(tomorrow == 0) > 0 && foundtomorrow == 1
                        answer3 = questdlg(['Do you want ',ratname,' to start training today or tomorrow?'],...
                            '','Today','Tomorrow','Tomorrow');
                        if strcmp(answer3,'Today')
                            emailextramsg = 'today and ';
                            for j = 1:numel(tomorrow)
                                if tomorrow(j) == 0
                                    st = strfind(NT{j},'[[');
                                    ed = strfind(NT{j},']]');
                                    if numel(st) == 1 && numel(ed) == 1
                                        newnote = NT{j}(st+2:ed-1);
                                    else
                                        newnote = NT{j};
                                    end
                                    b = strfind(lower(newnote),phrase);
                                    bad = zeros(size(newnote));
                                    for k = 1:numel(b)
                                        bad(b(k):b(k)+numel(phrase)-1) = 1;
                                    end
                                    newnote(bad == 1) = '';
                                    
                                    %mym(bdata,'update ratinfo.schedule set ratname="{S}", experimenter="{S}", comments="{S}", instructions="{S}" where schedentryid={S}',...
                                    %    ratname,fakeexp,newnote,'Remove from free water',ID(j));
                                    bdata('call ratinfo.update_schedule_ratname("{S}",{Si})',ratname,ID(j));
                                    bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})',fakeexp,ID(j));
                                    bdata('call ratinfo.update_schedule_comments("{S}",{Si})',newnote,ID(j));
                                    bdata('call ratinfo.update_schedule_instructions("{S}",{Si})','Remove from free water',ID(j));
                                end
                            end
                        else
                            emailextramsg = '';
                        end
                    end
                    
                    if foundtomorrow == 1 && Recov(temp) == 1
                        answer4 = questdlg([ratname,' is flagged as recovering. Do you want to unflag?'],'','Yes','No','Yes');
                        if strcmp(answer4,'Yes')
                            %mym(bdata,'update ratinfo.rats set recovering=0 where internalID="{S}"',RID(temp));
                            bdata('call ratinfo.update_rat_recovery("{Si}","{Si}")',RID(temp),0);
                        end
                    end
                end
                 
            end
            
            temp = find(strcmp(Rr,ratname)==1,1,'first');
            if ~isempty(temp)

                b = [0,find(C{temp}==' ' | C{temp}==','),numel(C{temp})+1];
                for k = 1:numel(b)-1
                    email=C{temp}(b(k)+1:b(k+1)-1);
                    if numel(email) > 1

                        clear message
                        if strcmp(state,'training')
                            if foundtomorrow == 1
                                message{1} = [ratname,' was returned to training by ',tech,...
                                    ' for ',emailextramsg,'tomorrow'];
                            else
                                message{1} = '';
                            end
                        elseif strcmp(state,'hematuria')
                            message{1} = [ratname,' was flagged as ',state,' by ',tech,...
                                ' and separated from cagemate but will train today.'];
                        else
                            message{1} = [ratname,' was flagged as ',state,' by ',tech,...
                                ' and removed from training.'];
                        end
                        
                        message{2} = get(handles.note_edit,'string');

                        disp(email);
                        disp(message);
                        disp(' ');

                        %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
                        %setpref('Internet','E_mail',['RegistryMeister',datestr(now,'yymm'),'@Princeton.EDU']);
                        set_email_sender
                        
                        if ~isempty(message)
                            sendmail([email,'@princeton.edu'],[ratname,' Flagged as ',state],message);
                        end
                    end
                end
            
            
            end
            
        end
        pause(0.1);
    end
end


function realexp = find_realexp(contact,Exp,Eml)

realexp = cell(0);

if iscell(contact) && ~isempty(contact{1}); contact = contact{1}; end

b = [0,find(contact==' ' | contact==','),numel(contact)+1];
for i = 1:numel(b)-1
    email=contact(b(i)+1:b(i+1)-1);
    
    temp = strcmp(Eml,[email,'@princeton.edu']);
    if sum(temp)==1
        realexp(end+1) = Exp(temp); %#ok<AGROW>
    end
end

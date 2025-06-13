function cleanup_longterm_reserved

%If a rig has been reserved for a rat for more than 2 months or if the rat
%is deceased or if the rig is running a rat, the reserved not is removed

try

    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['ScheduleMeister_',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender    
    
    [Rr,Xr,Cr] = bdata('select ratname, extant, contact from ratinfo.rats');
    [Ec,Ac,Mc] = bdata('select experimenter, is_alumni, email from ratinfo.contacts');
    [Rs,Cs,Ds,Is,Ss,Gs] = bdata(['select ratname, comments, date, schedentryid, timeslot, rig from ratinfo.schedule where date>="',datestr(now-61,'yyyy-mm-dd'),'"']);
    tomorrow = strcmp(Ds,datestr(now+1,'yyyy-mm-dd'));
    Rt = Rs(tomorrow);
    Ct = Cs(tomorrow);
    It = Is(tomorrow);
    St = Ss(tomorrow);
    Gt = Gs(tomorrow);
    
    for i = 1:numel(Ct)
        remove  = 0;
        comment = '';
        email   = {};
        if isempty(Ct{i}); continue; end

        if ~isempty(strfind(lower(Ct{i}),'reserved for'))
            %These comments are reserving something
            
            for j = 1:numel(Rr)
                if ~isempty(strfind(lower(Ct{i}),lower(Rr{j})))
                    %There is a rat name in the comments
                    if Xr(j) == 0
                        %Reserved rat is dead, let's remove
                        remove = 1;
                        comment = 'Training slots cannot be reserved for dead rats.';
                        break;
                    else
                        %Reserved rat is alive
                        if ~isempty(Rt{i}) && strcmp(Rr{j},Rt{i}) == 0
                            %rig is running a different rat
%                             remove = 1;
%                             comment = 'Rig is running a different rat.';
%                             break;
                        elseif isempty(Rt{i})
                            %rig is not running a rat, let's see how long
                            %it's been reserved
                            found_different = 0;
                            for k = 1:60
                                x = strcmp(Ds,datestr(now-k,'yyyy-mm-dd')) & Ss==St(i) & Gs==Gt(i);
                                if sum(x) == 1 && strcmp(Cs{x},Ct{i}) == 0
                                    found_different = 1;
                                    break;
                                end
                            end
                            if found_different == 0
                                remove = 1;
                                comment = 'Rig was reserved for 60 consecutive days without training the rat.';
                                break;
                            end
                            
                        end
                        
                    end
                end
            end
            if remove == 1
                reservedfor = Rr{j};
                contact = Cr{j};
                b = [0,find([contact==',' | contact==' ']==1),numel(contact)+1]; %#ok<NBRAK>
                for k = 1:numel(b)-1
                    if b(k+1)-b(k) <= 1; continue; end
                    email{end+1} = [contact(b(k)+1:b(k+1)-1),'@princeton.edu']; %#ok<*AGROW>
                end
            end
            
            if remove == 0
                for j = 1:numel(Ec)
                    if ~isempty(strfind(lower(Ct{i}),lower(Ec{j})))
                        %There is an experimenter name in the comments
                        if Ac(j) == 1
                            %Experimenter is alumni, remove
                            remove = 1;
                            break
                        else
                            %Experimenter is active lab member, let's see how
                            %long it's been reserved
                            found_different = 0;
                            for k = 1:60
                                x = strcmp(Ds,datestr(now-k,'yyyy-mm-dd')) & Ss==St(i) & Gs==Gt(i);
                                if sum(x) == 1 && strcmp(Cs{x},Ct{i}) == 0
                                    found_different = 1;
                                    break;
                                end
                            end
                            if found_different == 0
                                remove = 1;
                                comment = 'Rig was reserved for 60 consecutive days without training a rat.';
                                break
                            end

                        end
                    end
                end
                if remove == 1
                    reservedfor = Ec{j};
                    email{1} = Mc{j};
                end
            end
            
            if remove == 1
                
                session = St(i);
                rig     = Gt(i);
                message = {};
                
                message{1} = ['Reserved note for ',reservedfor,' removed from Rig: ',...
                    num2str(rig),' Session: ',num2str(session)];
                message{end+1} = comment;
               
                IP = get_network_info;
                message{end+1} = ' '; 
                if ischar(IP); message{end+1} = ['Email generated by ',IP];
                else           message{end+1} = 'Email generated by an unknown computer!!!';
                end
                %message{end+1} = 'cleanup longterm reserved.m'; 
                
                disp(message');
                disp(' ');
                
                if ~isempty(comment)
                    for k = 1:numel(email)
                        disp(email{k});
                        sendmail(email{k},'Removed Reserved Slot',message);
                    end
                end
                
                %remove the reserved note
                %mym(bdata,'update ratinfo.schedule set comments="" where schedentryid={S}',It(i));
                bdata('call ratinfo.update_schedule_comments("{S}",{Si})','',It(i));
                if isempty(Rt{i})
                    %the rig is not running a rat, also remove the
                    %experimenter
                    %mym(bdata,'update ratinfo.schedule set experimenter="" where schedentryid={S}',It(i));
                    bdata('call ratinfo.update_schedule_experimenter("{S}",{Si})','',It(i));
                end
            end
        end
    end
    
catch
    senderror_report;
end    
    
    

function remove_longterm_recovery

try
    L = 28;
    
    set_email_sender
    map_bucket_drive;
    
    file = ['X:\backups\RegistryBackup\',datestr(now-L,'yyyymmdd'),'.mat'];

    [Rr,C] = bdata('select ratname, contact from ratinfo.rats where extant=1 and recovering=1');

    if exist(file,'file') ~= 0
        load(file); X = x;

        for i = 1:numel(Rr)
            j = find(strcmp(X.ratname,Rr{i})==1);

            if numel(j) ~= 1; continue; end

            if X.recovery(j) == 1
                %This rat was on recovery 4 weeks ago and still is.
                
                %Now let's check that he's been on recovery every day since
                continuousrecovery = 1;
                for d = 1:L
                    file = ['X:\backups\RegistryBackup\',datestr(now-d,'yyyymmdd'),'.mat'];
                    try 
                        load(file); 
                        j = find(strcmp(x.ratname,Rr{i})==1);
                        if numel(j) ~= 1; continue; end
                        if x.recovery(j) ~= 1
                            %He wasn't on recovery on this day. Rather than
                            %looking for ==0 this was changed to ~=1 so we
                            %can use a 2 to indicate he was on recovery but
                            %we want to use this to reset the 4 week clock
                            %allowing experimenters to keep animals on
                            %longer
                            continuousrecovery = 0;
                            break
                        end
                    end
                end
                
                ratID = bdata(['select internalID from ratinfo.rats where ratname="',Rr{i},'"']);
                b = [0,find(C{i}==' ' | C{i}==','),numel(C{i})+1];
                        
                if continuousrecovery == 1 && numel(ratID) == 1
                    weight_is_good = 0;
                    %Let's do an added check to see if his weight is not decreasing
                    m = bdata(['select mass  from ratinfo.mass where ratname="',Rr{i},...
                        '" and date>="',datestr(now-(L+7),'yyyy-mm-dd'),'" order by date asc']);
                    m = rowvec(m);
                    
                    d = 1:numel(m);
                    d(m == 0) = [];
                    m(m == 0) = [];
                        
                    if numel(m) >= L
                        %Rat on recovery should be weighed every day so
                        %there should be 28 records especially if we asked
                        %for the past 35 day.
                        m = m(end-(L-1):end);
                        d = d(end-(L-1):end);
                        
                        p4 = polyfit(d,m,1);
                        p2 = polyfit(d(15:end),m(15:end),1);
                        p1 = polyfit(d(22:end),m(22:end),1);
                        
                        if p1(1) >= 0 && p2(1) >= 0 && p4(1) >= 0
                            %The rat's weight has been stable or increasing
                            %over the past 1, 2, and 4 week periods
                            weight_is_good = 1;
                        end
                    end
                        
                    if weight_is_good == 1
                        %Weight is good, remove from recovery
                        bdata('call ratinfo.update_rat_recovering("{S}","{S}")',ratID,0);
                        
                        for k = 1:numel(b)-1
                            email=C{i}(b(k)+1:b(k+1)-1);
                            if numel(email) > 1

                                message{1}     = [Rr{i},' was determined to be on the recovery list ',...
                                                  'for at least ',num2str(L/7),' weeks and has been removed via the ',...
                                                  'automated script remove_longterm_recovery.m'];
                                message{end+1} =  ' ';
                                message{end+1} = ['If you want to keep the animal on the recovery list ',...
                                                  'flag the animal as Recovery using TechNotes.'];

                                disp(email);
                                disp(message);
                                disp(' ');

                                sendmail([email,'@princeton.edu'],[Rr{i},' Removed from Recovery'],message);
                            end
                        end

                    else
                        %weight is not good, keep on recovery and notify experimenter
                        for k = 1:numel(b)-1
                            email=C{i}(b(k)+1:b(k+1)-1);
                            if numel(email) > 1
                            
                                message{1} = [Rr{i},' was determined to be on the recovery list ',...
                                              'for at least ',num2str(L/7),' weeks. However, his WEIGHT IS ',...
                                              'NOT STABLE OR INCREASING. Therefore he will be kept on the ',...
                                              'Recovery list.'];
                                          
                                disp(email);
                                disp(message);
                                disp(' ');

                                sendmail([email,'@princeton.edu'],[Rr{i},' Kept on Recovery'],message);          
                            end
                        end
                    end
                end
            end
        end
    end
catch %#ok<CTCH>
    senderror_report;
end

function handles = SC_running(handles)


%while get(handles.run_toggle,'value') == 1
    
    set(handles.title_text,'string',['Checking Shifts for: ',datestr(now,'mmmm dd, yyyy')]);
    set(handles.time_text,'string',datestr(now,'HH:MM PM'));
    set(handles.run_toggle,'string','Updating','BackgroundColor',[0.5 0.5 0.5]);
    pause(0.1);
   
    p = bSettings('get','GENERAL','Main_Code_Directory');
    file = [p,'\Utility\AutomatedEmails\shiftchecker_status.mat'];
    if exist(file,'file') ~= 0
        load(file);
    else
        lastupdatestring = cell(3,1);
    end
   
    lastupdate = now;
    x = checkshift; %#ok<NASGU>
   
    set(handles.run_toggle,'string','Pause','BackgroundColor',[1 0 0]);
    pause(0.1);
    
    lockedstate = [0 0 0];
    DONE        = [0 0 0];
   
    SHIFT = 'ABC';
    
    OLDSHIFT{1} = 'overnight';
    OLDSHIFT{2} = 'morning';
    OLDSHIFT{3} = 'evening';
    
    YEAR = datenum([datestr(now,'yyyy'),'-01-01 00:00:01'],'yyyy-mm-dd HH:MM:SS');
    
    
    for i = 1:3
        
        SC_check_next_tech(handles,i);
        
        problems = eval(['x.',SHIFT(i),'.problems;']);
        spacecount = eval(['x.',SHIFT(i),'.spacecount;']);
        c=0;
        str = cell(0);
        if isempty(problems); str{1} = ['No problems discovered for ',SHIFT(i),' shift.'];
        else                  str{1} = [num2str(length(problems)-spacecount),' problems discovered for ',SHIFT(i),' shift.'];
            for j = 1:numel(problems)
                if ~isempty(strfind(problems{j},'NO TECH NOTE')) || ~isempty(strfind(problems{j},'MUST BE FIXED')); c=c+1; end
            end
            str{2} = [num2str(c),' problems have NO TECH NOTE.'];
            str{3} = ' ';
        end
        
       
        for j = 1:length(problems)
            if ~strcmp(problems{j},' ')
                str{end+1} = problems{j};  %#ok<AGROW>
            end
        end

        if (i == 1 && (str2num(datestr(now,'HH')) >= 0  && str2num(datestr(now,'HH')) <= 11)) ||...
           (i == 2 && (str2num(datestr(now,'HH')) >= 4  && str2num(datestr(now,'HH')) <= 17)) ||...
           (i == 3 && (str2num(datestr(now,'HH')) >= 12 && str2num(datestr(now,'HH')) <= 23)) ||...
           numel(lastupdatestring{i})==0 %#ok<ST2NM>
            %Unlocked
            
            
%             numprobs_old = Inf;
%             if lockedstate(i) == 1
%                 %if the session just unlocked then let the problem count
%                 %rise, if not then the problem count shouldn't ever rise
%                 
%             end
            
            %Check how many problems existed on last run
            str_old = get(eval(['handles.',SHIFT(i),'_edit']),'string');
            if numel(str_old) > 1
                firstspace = find(str_old{2} == ' ',1,'first');
                numprobs_old = str2num(str_old{2}(1:firstspace-1)); %#ok<ST2NM>
            end
            
            %Check how many problems exist on this run
            if numel(str) > 1
                firstspace = find(str{2} == ' ',1,'first');
                numprobs = str2num(str{2}(1:firstspace-1)); %#ok<ST2NM>
            else
                numprobs = 0;
            end
            
            set(eval(['handles.',SHIFT(i),'lock_text']),'visible','off')
            set(eval(['handles.',SHIFT(i),'tech_menu']),'enable','on');
            
            %if numprobs <= numprobs_old
                %Problem count did not go up, so display new string str
                set(eval(['handles.',SHIFT(i),'_edit']),'string',str);
                %if c == 0
                %    set(eval(['handles.',SHIFT(i),'_edit']),'BackgroundColor',[0.8 1 0.8]);
                %else
                %    set(eval(['handles.',SHIFT(i),'_edit']),'BackgroundColor',[1 0.8 0.8]);
                %end
                lastupdatestring{i} = str;
                
                if numprobs == 0 && DONE(i) == 0
                    %We've hit no problems that haven't been addressed
                    
                    try %#ok<TRYNC>
                        [TS,ID] = bdata(['select ',OLDSHIFT{i},', scheduleid from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
                        TS = TS{1};
                        
                        if numel(TS) < 6 || (numel(TS) >= 6 && isempty(str2num(TS(end-5:end)))) %#ok<ST2NM>
                            %We haven't appended the schedule entry yet
                            id = sprintf('%06d\n',round((now-YEAR)*24*60));
                            TS = [TS,' ',id]; %#ok<AGROW>
                            
                            %mym(bdata,['update ratinfo.tech_schedule set ',OLDSHIFT{i},'="',TS,'" where scheduleid=',num2str(ID)]);
                            if i == 1
                                bdata('call ratinfo.append_tech_schedule_overnight("{S}","{Si}")',TS,ID);
                            elseif i == 2
                                bdata('call ratinfo.append_tech_schedule_morning("{S}","{Si}")',TS,ID);
                            else
                                bdata('call ratinfo.append_tech_schedule_evening("{S}","{Si}")',TS,ID);
                            end
                        end
                        DONE(i) = 1;
                    end
                    
                else
                    DONE(i) = 0;
                end
                
                shift_color = SC_determine_color(i);
                set(eval(['handles.',SHIFT(i),'_edit']),'BackgroundColor',shift_color);
                if shift_color(1) == 0.8
                    set(eval(['handles.',SHIFT(i),'tech_menu']),'enable','off');
                end
            %end
            lockedstate(i) = 0;
        
        else
            %Locked
            set(eval(['handles.',SHIFT(i),'_edit']),'string',lastupdatestring{i});
            set(eval(['handles.',SHIFT(i),'lock_text']),'visible','on');
            set(eval(['handles.',SHIFT(i),'tech_menu']),'enable','off');
            
            shift_color = SC_determine_color(i);
            set(eval(['handles.',SHIFT(i),'_edit']),'BackgroundColor',shift_color);
            
%             if str2num(lastupdatestring{i}{2}(1)) == 0 %#ok<ST2NM>
%                 
%             else
%                 set(eval(['handles.',SHIFT(i),'_edit']),'BackgroundColor',[1 0.8 0.8]);
%             end
            
            lockedstate(i) = 1;
        end
    end
    
    save(file,'lastupdatestring');

    if handles.runonecycle == 1
        %set(handles.run_toggle,'string','RUN','BackgroundColor',[0 1 0]);
        %handles.running = 0;
        handles.runonecycle = 0;
        %set(handles.Atech_menu,'enable','off');
        %set(handles.Btech_menu,'enable','off');
        %set(handles.Ctech_menu,'enable','off');
        %set(handles.run_toggle,'value',0);
        %break
    end
        
    %while rem(str2num(datestr(now,'MM')),5) ~= 0 || (now-lastupdate)*24*60<1  %#ok<ST2NM>
    %    if get(handles.run_toggle,'value') == 0
    %        break;
    %    end
    %    pause(5);
    %end
%end
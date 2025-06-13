function check_mouseroom_confirmed_empty(alert_type)

try
    if nargin == 0; alert_type = 'all'; end
    [notes,note_time] = bdata(['select note, timestr from ratinfo.technotes where datestr="',datestr(now,'yyyy-mm-dd'),'"']);

    room_confirmed_empty = 0;
    for i = 1:numel(notes)
        if ~isempty(strfind(char(notes{i}'),'Room 165: Mice, confirmed empty')) %#ok<STREMP>
            room_confirmed_empty = 1;
        end
    end

    [r,h] = bdata(['select ratname, hostname from sess_started where sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
    for i = 1:numel(h)
        if numel(h{i}) > 3
            rig(i) = str2num(h{i}(4:end)); %#ok<AGROW,ST2NM>
        else
            rig(i) = nan;  %#ok<AGROW>
        end
    end

    mice_did_train = 0;
    mice = r(rig > 400);
    mice = unique(mice);

    if ~isempty(mice)
        mice_did_train = 1;
    end
    
    last_pub_session_ended = 1;
    WM = WM_rat_water_list(1:10,[],'all',datestr(now,'yyyy-mm-dd'),0,0);
    pub_was_ended = zeros(numel(WM)-1,1);
    pub_was_ended(:) = nan;
    pub_complete_times = cell(0);
    for i = 1:numel(WM)-1
        wm = unique(WM{i});
        pub_was_ended_session = [];
        for j = 1:numel(wm)
            if isempty(wm{j}); continue; end
            
            [pbm,endtimes] = bdata(['select percent_bodymass, stoptime from ratinfo.water where rat="',...
                          wm{j},'" and date="',datestr(now,'yyyy-mm-dd'),'"']); 
            if ~isempty(pbm) && any(pbm ~= 0)
                %This animal was watered in the pub 
                for k = 1:numel(endtimes)
                    if pbm(k) ~= 0 && ~strcmp(endtimes{k},'23:59:00')
                        pub_complete_times{end+1} = endtimes{k};
                    end
                end
                
                pub_was_ended_session(j) = 0;
                for k = 1:numel(notes)
                    if ~isempty(strfind(char(notes{k}'),'Watering ended in Pub')) &&...
                       ~isempty(strfind(char(notes{k}'),wm{j}))%#ok<STREMP>
                        pub_was_ended_session(j) = 1;
                    end
                end
            end
            
        end
        if ~isempty(pub_was_ended_session) && any(pub_was_ended_session == 1)
            pub_was_ended(i) = 1;
        end
    end
    if sum(~isnan(pub_was_ended)) > 0
        last_pub_session = pub_was_ended(find(~isnan(pub_was_ended) == 1,1,'last'));
        if last_pub_session == 0
            last_pub_session_ended = 0;
        end
    end
    
    found_pubempty_note = 0;
    found_late_pub = 0;
    if last_pub_session_ended == 0
        %Now we check for a pub empty tech note
        for i = 1:numel(notes)
            if ~isempty(strfind(char(notes{i}'),'Pubs in 165: Mice, confirmed empty')) %#ok<STREMP>
                %Pub was confirmed empty. Did this happen AFTER the last animal
                %used the pub
                found_pubempy_note = 1;
                found_late_pub = 0;
                for j = 1:numel(pub_complete_times)
                    if datenum(pub_complete_times{j},'HH:MM:SS') > datenum(note_time{i},'HH:MM:SS')
                        %no a pub session ended after the note, note inavid
                        found_late_pub = 1;
                    end
                end
            end
            
        end
        if found_pubempty_note == 1 && found_late_pub == 0
            last_pub_session_ended = 1;
        end
    end
    
    
    alert_message = [];
    if room_confirmed_empty == 0 && mice_did_train == 1
        alert_message = 'Mouse room 165H has NOT been confirmed empty. ';
    end
    if last_pub_session_ended == 0
        alert_message = [alert_message,'Mice may still be in the pub.'];
    end
    

    if (room_confirmed_empty == 0 && mice_did_train == 1) || last_pub_session_ended == 0
        %The mouse room has not been confirmed empty. Alert mouse experimenters
        contact_list = cell(0);
        tech_list = cell(0);
        for i = 1:numel(mice)
            c = bdata(['select contact from ratinfo.rats where ratname="',mice{i},'"']);
            c = c{1};
            brks = find(c == ' ' | c == ',');
            brks = [0,brks,numel(c)+1]; %#ok<AGROW>
            for i = 1:numel(brks)-1
                if brks(i+1) - brks(i) > 1
                    contact_list{end+1} = c(brks(i)+1:brks(i+1)-1);  %#ok<AGROW>
                end
            end

            techm = bdata(['select tech from ratinfo.mass  where ratname="',mice{i},'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
            if ~isempty(techm); tech_list{end+1} = techm{1}; end %#ok<AGROW>
            techw = bdata(['select tech from ratinfo.water where rat="',    mice{i},'" and date="',datestr(now,'yyyy-mm-dd'),'"']);
            if ~isempty(techw); tech_list{end+1} = techw{1}; end  %#ok<AGROW>
        end
        contact_list = unique(contact_list);
        contact_list{end+1} = 'ckopec';
        contact_list{end+1} = 'jteran';

        tech_list = unique(tech_list);

        [Exp,email,initials] = bdata('select experimenter, email, initials from ratinfo.contacts where is_alumni = 0');
        for i = 1:numel(email)
            em{i} = email{i}(1:find(email{i}=='@',1,'first')-1);  %#ok<AGROW>
        end

        if strcmp(alert_type,'all')
            %alert the experimenters
            for i = 1:numel(contact_list)
                pos = strcmp(em,contact_list{i});
                if sum(pos) == 1
                    E = Exp(pos);
                    send_text_message(alert_message,'Mouse Room Alert',E);
                    pause(1)
                end
            end
        end

        %alert the technicians
        for i = 1:numel(tech_list)
            pos = strcmp(initials,tech_list{i});
            if sum(pos) == 1
                E = Exp(pos);
                send_text_message(alert_message,'Mouse Room Alert',E);
                pause(1)
            end
        end

        %alert the rat C shift tech
        rat_tech = bdata(['select evening from ratinfo.tech_schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
        if ~isempty(rat_tech)
            send_text_message(alert_message,'Mouse Room Alert',rat_tech{1});
        end
    end
catch
    senderror_report;
end
        
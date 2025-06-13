function check_rat_exceptions(check_type,varargin)

try
    if nargin < 1; check_type = 'normal'; end
    
    %setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
    %setpref('Internet','E_mail',['RatRegistry',datestr(now,'yymm'),'@Princeton.EDU']);
    set_email_sender
    
    [ratR,recov,forcedep,bringup,deliv,contact,comments,cagemate] = bdata(['select ratname, recovering, forceDepWater,',...
        ' bringUpAt, deliverydate, contact, comments, cagemate from ratinfo.rats where extant=1 order by ratname']);
    
    [ratM,mass] = bdata(['select ratname, mass from ratinfo.mass where date>"',datestr(now-7,'yyyy-mm-dd'),'"']);
    mass(mass == 0) = nan;
    
    ratS = bdata(['select ratname from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    ratS = unique(ratS);
    
    rat_WM_list = WM_rat_water_list(1:10,[],'all',datestr(now,'yyyy-mm-dd'),0,1);
    mouse_WM_list = WM_rat_water_list(1:10,[],'all',datestr(now,'yyyy-mm-dd'),0,0);
    free_water_list = unique([unique(mouse_WM_list{10});unique(rat_WM_list{10})]);

    [Exp,email] = bdata('select experimenter, email from ratinfo.contacts where is_alumni=0');
    for i = 1:length(email); econ{i} = email{i}(1:find(email{i} == '@',1,'first')-1); end %#ok<AGROW>

    X = struct('old',[],'bringup',[],'forcedep',[],'recov',[],'mass',[],'freewater',[]);
    
    for i = 1:length(ratR)

        %Let's check for old rats
        age = now - datenum(deliv{i},'yyyy-mm-dd');
        if  (strcmp(check_type,'normal') && age > 610) || (strcmp(check_type,'extreme') && age > 730)
            if strcmp(deliv{i},'0000-00-00')
                months = nan; %#ok<NASGU>
            else
                months = round((age/30.5) * 10) / 10; %#ok<NASGU>
            end
            eval(['X.old.',ratR{i},'=months;']);
        end

        %Let's check for recovering rats
        if recov(i) == 1 && strcmp(check_type,'normal')
            eval(['X.recov.',ratR{i},'=1;']); 
        end

        %Let's check for bring up rats
        if bringup(i) ~= 0 && strcmp(check_type,'normal')
            eval(['X.bringup.',ratR{i},'=bringup(i);']);
        end

        %Let's check for forcedep rats
        if forcedep(i) ~= 0 && strcmp(check_type,'normal')
            eval(['X.forcedep.',ratR{i},'=forcedep(i);']);
        end
        
        %Let's check for overweight pair housed cages
        if ~isempty(cagemate{i})
            rtmass = floor(nanmean(mass(strcmp(ratM,ratR{i}))));
            cmmass = floor(nanmean(mass(strcmp(ratM,cagemate{i}))));
            
            if rtmass + cmmass > 1100
                eval(['X.mass.',ratR{i},'=rtmass + cmmass;']);
            end
        end
        
        %Let's check for free water animals
        is_free_water = 0;
        if sum(strcmp(ratS,ratR{i})) == 0 && recov(i) == 0
            %This rat is not on the schedule and their recovery bit is 0
            
            if isempty(cagemate{i}) || sum(strcmp(ratS,cagemate{i})) == 0
                %Either there is no cagemate or the cagemate also doesn't train
                is_free_water = 1;
            end
        end
        if sum(strcmp(free_water_list,ratR{i})) == 1 && recov(i) == 0
            %animal is on the WaterMeister free water list and recovery bit is 0
            is_free_water = 1;
        end
        if is_free_water == 1
            eval(['X.freewater.',ratR{i},'=1;']);
        end
        
    end

    if isstruct(X.old);       oldrats = fields(X.old);       else, oldrats = []; end
    if isstruct(X.recov);     recrats = fields(X.recov);     else, recrats = []; end
    if isstruct(X.bringup);   buprats = fields(X.bringup);   else, buprats = []; end
    if isstruct(X.forcedep);  deprats = fields(X.forcedep);  else, deprats = []; end
    if isstruct(X.mass);      masrats = fields(X.mass);      else, masrats = []; end
    if isstruct(X.freewater); frerats = fields(X.freewater); else, frerats = []; end
    

    for i = 1:length(Exp)
        if strcmp(check_type,'extreme') && ~strcmp(Exp{i},'Chuck')
            continue;
        end
        
        found_animal = 0;
        for j = 1:numel(contact)
            if ~isempty(strfind(contact{j},econ{i}))
                found_animal = 1;
                break
            end
        end
        if found_animal == 0
            %This experimenter currently has no animals in the colony, skip
            continue;
        end
            
        message = cell(0);
        message{1} = [Exp{i},','];
        message{end+1} = ' '; %#ok<AGROW>
        
        donefirst = 0;
        skip = cell(0);
        for j = 1:numel(masrats)
            if strcmp(check_type,'extreme'); con = 'ckopec';
            else,                            con = contact{strcmp(ratR,masrats{j})};
            end
            if ~isempty(strfind(con,econ{i})) 
                if donefirst == 0
                    message{end+1} = 'The following rat pairs are over 1100g and must be separated:'; %#ok<AGROW>
                    message{end+1} = ' '; %#ok<AGROW>
                    donefirst = 1;
                end
                
                cm = cagemate{find(strcmp(ratR,masrats{j})==1,1,'first')};
                skip{end+1} = cm; %#ok<AGROW>
                if sum(strcmp(skip,masrats{j})) == 0
                    message{end+1} = [masrats{j},' ',cm,'  ',num2str(eval(['X.mass.',masrats{j}])),'g']; %#ok<AGROW>
                end
            end
        end
        if donefirst == 1; message{end+1} = ' '; message{end+1} = ' '; end %#ok<AGROW>

        donefirst = 0;
        for j = 1:length(oldrats)
            if strcmp(check_type,'extreme'); con = 'ckopec';
            else,                            con = contact{strcmp(ratR,oldrats{j})};
            end
            if ~isempty(strfind(con,econ{i})) 
                if donefirst == 0
                    message{end+1} = 'The following animals are more than 20 months old:'; %#ok<AGROW>
                    message{end+1} = ' '; %#ok<AGROW>
                    donefirst = 1;
                end
                
                regpos = find(strcmp(ratR,oldrats{j})==1,1,'first');
                comment = comments{regpos};
                extension = strfind(lower(comment),'lar extension until');
                
                pastext = 0;
                if ~isempty(extension) && numel(comment) >= extension + 25
                    extend = comment(extension+20:extension+25);
                    if str2num(extend) < 1e4 && numel(comment) >= extension + 29 %#ok<ST2NM>
                        %extension format likely in yyyy-mm-dd format
                        extend = comment(extension+20:extension+29);
                        extendlength = 29;
                        try
                            extnum = datenum(extend,'yyyy-mm-dd');
                        catch
                            extnum = 0;
                        end
                    else
                        extendlength = 25;
                        try
                            extnum = datenum(extend,'yymmdd');
                        catch
                            extnum = 0;
                        end
                    end
                    
                    if now > extnum; pastext = 1; end
                else
                    pastext = 1;
                end
                    
                age = eval(['X.old.',oldrats{j}]);
                
                if     age >= 23 && age < 24 && isempty(extension);                 exmsg = '. Get LAR Extension if necessary.';
                elseif age >= 23 &&            ~isempty(extension) && pastext == 0; exmsg = ['. ',comment(extension:extension+extendlength)];
                elseif age >= 24 &&             isempty(extension);                 exmsg = '. MUST EUTHANIZE.';
                elseif age >= 24 &&                                   pastext == 1; exmsg = '. MUST EUTHANIZE.';
                else,                                                               exmsg = '';
                end
                
                if  strcmp(check_type,'normal') || (strcmp(check_type,'extreme') && pastext == 1)
                    message{end+1} = [oldrats{j},' is now ',num2str(eval(['X.old.',oldrats{j}])),' months old',exmsg]; %#ok<AGROW>
                end
            end
        end
        if donefirst == 1; message{end+1} = ' '; message{end+1} = ' '; end %#ok<AGROW>

        if ~strcmp(check_type,'extreme')
            message{end+1} = 'The following animals are flagged as recovering (brought to lab for daily health checks & weighing):'; %#ok<AGROW>
            message{end+1} = ' '; %#ok<AGROW>
            for j = 1:length(recrats)
                con = contact{strcmp(ratR,recrats{j})};
                if ~isempty(strfind(con,econ{i})) 
                    message{end+1} = recrats{j}; %#ok<AGROW>
                end
            end
            message{end+1} = ' '; %#ok<AGROW>

            message{end+1} = 'The following animals are flagged as free water (stays in LAR, NO health checks, NO weighing):'; %#ok<AGROW>
            message{end+1} = ' '; %#ok<AGROW>
            for j = 1:length(frerats)
                con = contact{strcmp(ratR,frerats{j})};
                if ~isempty(strfind(con,econ{i})) 
                    message{end+1} = frerats{j}; %#ok<AGROW>
                end
            end
            message{end+1} = ' '; %#ok<AGROW>
        end

        donefirst = 0;
        for j = 1:length(buprats)
            con = contact{strcmp(ratR,buprats{j})};
            if ~isempty(strfind(con,econ{i})) 
                if donefirst == 0
                    message{end+1} = 'The following animals have specified bring up times:'; %#ok<AGROW>
                    message{end+1} = ' '; %#ok<AGROW>
                    donefirst = 1;
                end
                message{end+1} = [buprats{j},' is scheduled for bring up in session ',num2str(eval(['X.bringup.',buprats{j}]))]; %#ok<AGROW>
            end
        end
        if donefirst == 1; message{end+1} = ' '; message{end+1} = ' '; end %#ok<AGROW>

        donefirst = 0;
        for j = 1:length(deprats)
            con = contact{strcmp(ratR,deprats{j})};
            if ~isempty(strfind(con,econ{i})) 
                if donefirst == 0
                    message{end+1} = 'The following animals have specified watering times:'; %#ok<AGROW>
                    message{end+1} = ' '; %#ok<AGROW>
                    donefirst = 1;
                end
                message{end+1} = [deprats{j},' is scheduled for watering in session ',num2str(eval(['X.forcedep.',deprats{j}]))]; %#ok<AGROW>
            end
        end

        if ~isempty(message)
            IP = get_network_info;
            message{end+1} = ' '; %#ok<AGROW>
            if ischar(IP); message{end+1} = ['Email generated by ',IP]; %#ok<AGROW>
            else,          message{end+1} = 'Email generated by an unknown computer!!!'; %#ok<AGROW>
            end
            
            message{end+1} = 'ratter\ExperPort\Utility\AutomatedEmails\check_rat_exceptions.m'; %#ok<AGROW>
            disp(message')
            if strcmp(check_type,'normal'); subject = 'Weekly Animal Exception Reminder';
            else,                           subject = 'Extreme Colony Problem Analysis';
            end
            sendmail(email{i},subject,message);
        end

    end

catch %#ok<CTCH>
    senderror_report;
end
    
    
    
    
            

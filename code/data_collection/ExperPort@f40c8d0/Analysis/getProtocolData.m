function data = getProtocolData(rat,dates,protocolPattern,varargin)
    p=inputParser;
    p.KeepUnmatched=true;
    p.addParamValue('byRat',true,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('getPeh',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParamValue('rig',[],@(x)validateattributes(x,{'numeric'},{'vector','positive'}));
    p.parse(varargin{:});
    params=p.Results;
    %% figure out who the rat(s) is/are
    if isnumeric(dates) && dates(1)>0 % daterange is a sessid
        params.sessIdSupplied=true;
        if ischar(rat)
            ratList{1}=rat;
        else
            ratList = rat;
        end
    else
        params.sessIdSupplied=false;
        date_str = parse_daterange(dates);
        if ischar(rat)
            ratList=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "' rat '" and (' date_str ') order by ratname']);              
        else
            ratList=bdata(['select distinct(ratname) from bdata.sessions where ratname regexp "' strjoin(rat,'|') '" and (' date_str ') order by ratname']);  
        end
        if isempty(ratList)
            error('No rats in bdata.sessions match the pattern "%s" for the dates requested.',rat);
        end
    end
    %% extract protocol data from mySQL server
    if numel(ratList)>1 % multiple rats listed
        for ratIdx = 1:numel(ratList) 
            if ~params.byRat
                   if ratIdx==1
                        data=struct('sessiondate',[],'sessid',[],'protocol',[],'pd',[],'ratname',[],'nSessions',0);
                        if params.getPeh
                            data.peh=[];
                        end
                   end                
                if params.sessIdSupplied
                    d = get_sessdata(dates);
                    if any(~ismember(d.ratname,ratList{ratIdx}))
                        good = ismember(d.ratname,ratList{ratIdx});
                        d.sessiondate = d.sessiondate(good);
                        d.pd = d.pd(good);
                        d.protocol = d.protocol(good);
                        d.peh = d.peh(good);
                        d.ratname = d.ratname(good);      
                        d.sessid = d.sessid(good);             
                        d.hostname = d.hostname(good);                                                
                    end                       
                    if ~params.getPeh
                        d = rmfield(d,'peh');         
                    end
                    if any(~ismember(d.ratname,rat))
                        error('Rat name supplied does not match rat corresponding to the sessid(s) supplied.');
                    end
                   d.hostname = cellfun(@str2num,regexprep(d.hostname,'Rig(.*)','$1'));                                        
                   validSessions = ~cellfun(@isempty,regexp(d.protocol,protocolPattern)) & (isempty(params.rig) | ismember(d.hostname,params.rig));                    
                   data.sessiondate = cat(1,data.sessiondate,d.sessiondate(validSessions));
                   data.sessid = cat(1,data.sessid,d.sessid(validSessions));
                   data.protocol = cat(1,data.protocol,d.protocol(validSessions));
                   data.pd = cat(1,data.pd,d.pd(validSessions));
                   if params.getPeh
                        data.peh = cat(1,data.peh,d.peh(validSessions));
                   end
                   data.ratname = cat(1,data.ratname,d.ratname(validSessions));     
                   data.nSessions = sum(validSessions) + data.nSessions;                   
                else
                    if params.getPeh
                        [sessiondate, sessid, protocol, pd, peh, ratname, hostname] = ...
                           bdata(['select sessiondate,s.sessid,protocol,protocol_data,peh,ratname,hostname from sessions s,parsed_events p where ratname="' ratList{ratIdx} '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);        
                    else
                        [sessiondate, sessid, protocol, pd, ratname, hostname] = ...
                           bdata(['select sessiondate,s.sessid,protocol,protocol_data,ratname,hostname from sessions s,parsed_events p where ratname="' ratList{ratIdx} '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);                      
                    end
                   hostname = cellfun(@str2num,regexprep(hostname,'Rig(.*)','$1'));                    
                   validSessions = ~cellfun(@isempty,regexp(protocol,protocolPattern)) & (isempty(params.rig) | ismember(hostname,params.rig));
                   data.sessiondate = cat(1,data.sessiondate,sessiondate(validSessions));
                   data.sessid = cat(1,data.sessid,sessid(validSessions));
                   data.protocol = cat(1,data.protocol,protocol(validSessions));
                   data.pd = cat(1,data.pd,pd(validSessions));
                   if params.getPeh
                        data.peh = cat(1,data.peh,peh(validSessions));
                   end
                   data.ratname = cat(1,data.ratname,ratname(validSessions));     
                   data.nSessions = sum(validSessions) + data.nSessions;
                end
            else
                if params.sessIdSupplied
                    d = get_sessdata(dates);
                    if any(~ismember(d.ratname,ratList{ratIdx}))
                        good = ismember(d.ratname,ratList{ratIdx});
                        data(ratIdx).sessiondate = d.sessiondate(good);
                        data(ratIdx).pd = d.pd(good);
                        data(ratIdx).protocol = d.protocol(good);
                        data(ratIdx).peh = d.peh(good);
                        data(ratIdx).ratname = d.ratname(good);      
                        data(ratIdx).sessid = d.sessid(good);             
                        data(ratIdx).hostname = d.hostname(good);                                                
                    end          
                    if ~params.getPeh
                        data(ratIdx) = rmfield(data(ratIdx),'peh');         
                    end                    
                else
                    if params.getPeh
                        [data(ratIdx).sessiondate, data(ratIdx).sessid, data(ratIdx).protocol, data(ratIdx).pd, data(ratIdx).peh, data(ratIdx).hostname] = ...
                            bdata(['select sessiondate,s.sessid,protocol,protocol_data,peh,hostname from sessions s,parsed_events p where s.ratname="' ratList{ratIdx} '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);                        
                    else
                        [data(ratIdx).sessiondate, data(ratIdx).sessid, data(ratIdx).protocol, data(ratIdx).pd, data(ratIdx).hostname] = ...
                            bdata(['select sessiondate,s.sessid,protocol,protocol_data,hostname from sessions s,parsed_events p where s.ratname="' ratList{ratIdx} '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);                     
                    end
                end
               data(ratIdx).ratname = ratList{ratIdx};
               data(ratIdx).hostname = cellfun(@str2num,regexprep(data(ratIdx).hostname,'Rig(.*)','$1'));               
               validSessions = ~cellfun(@isempty,regexp(data(ratIdx).protocol,protocolPattern)) & (isempty(params.rig) | ismember(data(ratIdx).hostname,params.rig));                    
               data(ratIdx).nSessions=sum(validSessions); 
               fields=fieldnames(data);
               for f=1:length(fields)
                   if ~isscalar(data(ratIdx).(fields{f})) && ~ischar(data(ratIdx).(fields{f}))
                       data(ratIdx).(fields{f}) = data(ratIdx).(fields{f})(validSessions);
                   end
               end
            end
            if ~all(validSessions)
                fprintf('Removed %g sessions for rat %s that didn''t match desired protocol pattern or rig.\n',sum(~validSessions),ratList{ratIdx});            
            end
        end                  
    else
        if params.sessIdSupplied
            data = get_sessdata(dates);
            if ~params.getPeh
                data = rmfield(data,'peh');         
            end
            if any(~ismember(data.ratname,rat))
                error('Rat name supplied does not match rat corresponding to the sessid(s) supplied.');
            end
        else  
            if params.getPeh
                [data.sessiondate, data.sessid, data.protocol, data.pd, data.peh, data.hostname] = ...
                    bdata(['select sessiondate,s.sessid,protocol,protocol_data,peh,hostname from sessions s,parsed_events p where s.ratname regexp "' rat '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);        
            else
                [data.sessiondate, data.sessid, data.protocol, data.pd, data.hostname] = ...
                    bdata(['select sessiondate,s.sessid,protocol,protocol_data,hostname from sessions s,parsed_events p where s.ratname regexp "' rat '" and (' date_str ') and s.sessid=p.sessid order by sessiondate']);                  
            end
            data.ratname = ratList{1};
        end
        data.hostname = cellfun(@str2num,regexprep(data.hostname,'Rig(.*)','$1'));
        validSessions = ~cellfun(@isempty,regexp(data.protocol,protocolPattern)) & (isempty(params.rig) | ismember(data.hostname,params.rig));                 
        data.nSessions=sum(validSessions);
        fields=fieldnames(data);
        for f=1:length(fields)
            if ~isscalar(data.(fields{f})) && ~ischar(data.(fields{f}))
                data.(fields{f}) = data.(fields{f})(validSessions);
            end
        end
        if any(validSessions) 
            if ~all(validSessions)
                fprintf('Removed %g sessions for rat %s that didn''t match desired protocol pattern or rig.\n',sum(~validSessions),ratList{1});                        
            end
        else
            data=[];
            fprintf('No sessions among the sessid(s) supplied that match the desired protocol pattern.\n');
            return
        end
    end
    
    data = remove_empty_sessions(data);
    
end

function data = remove_empty_sessions(data)
    for i=1:length(data)
        vl_nonempty = ~cellfun(@isempty, data(i).pd);
        if sum(vl_nonempty) == data(i).nSessions
            return
        else
            for field = {'sessiondate', 'sessid', 'protocol', 'pd', 'peh'}; field = field{:};
                if isfield(data(i),field)
                    data(i).(field) = data(i).(field)(vl_nonempty);
                end
            end
            data(i).nSessions = sum(vl_nonempty);
        end
    end
end
function data = freeRigs(varargin)
    p=inputParser;
    p.addParameter('date','tomorrow',@(x)validateattributes(x,{'char'},{'nonempty'}));
    p.addParameter('showReserved',false,@(x)validateattributes(x,{'logical'},{'scalar'}));
    p.addParameter('showSixPoke',false,@(x)validateattributes(x,{'logical'},{'scalar'}));    
    p.addParameter('sessions',1:9,@(x)validateattributes(x,{'numeric'},{'>',0,'<',10}));
    p.parse(varargin{:});
    params=p.Results;
    if isempty(regexp(params.date,'\d{4}-\d{2}-\d{2}','once'))
        switch params.date
            case 'today'
                params.date=datestr(now,29);
            case 'yesterday'
                params.date=datestr(now-1,29);            
            case 'tomorrow'
                params.date=datestr(now+1,29);            
            otherwise
                error('First argument must be a date expressed as YYYY-MM-DD or one of the following special strings: "yesterday","today" or "tomorrow"');
        end
    end
    params.sessions = sprintf('%d,',params.sessions);
    params.sessions = ['(',params.sessions(1:end-1),')'];
    if params.showReserved      
        if params.showSixPoke
            [rig,session,comments] = bdata(['select rig,timeslot,comments from ratinfo.schedule where timeslot in ',params.sessions,' and ratname="" and experimenter="" and date="',...
                params.date,'" and comments not like "%DO NOT SCHEDULE RAT HERE%"',' and comments not like "MOUSE RIG"'  ]);              
        else
            [rig,session,comments] = bdata(['select rig,timeslot,comments from ratinfo.schedule where timeslot in ',params.sessions,' and ratname="" and experimenter="" and date="',...
                params.date,'" and comments not like "%six%"',' and comments not like "%DO NOT SCHEDULE RAT HERE%"',' and comments not like "MOUSE RIG"'  ]);              
        end
    elseif params.showSixPoke
        [rig,session,comments] = bdata(['select rig,timeslot,comments from ratinfo.schedule where timeslot in ',params.sessions,' and ratname="" and experimenter="" and date="',...
            params.date,'" and comments not like "%eserve%"',' and comments not like "%DO NOT SCHEDULE RAT HERE%"',' and comments not like "MOUSE RIG"'  ]);        
    else
        [rig,session,comments] = bdata(['select rig,timeslot,comments from ratinfo.schedule where timeslot in ',params.sessions,' and ratname="" and experimenter="" and date="',...
            params.date,'" and comments not like "%six%" and comments not like "%eserve%"',' and comments not like "%DO NOT SCHEDULE RAT HERE%"' ,' and comments not like "MOUSE RIG"' ]);
    end
    data = table(rig,session,comments);
end
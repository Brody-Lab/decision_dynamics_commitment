function copy_schedule_tomorrow(sID,varargin)

if nargin == 0

    [R,S,I,C,G,E] = bdata(['select ratname, timeslot, instructions, comments, rig, experimenter from ratinfo.schedule where date="',...
        datestr(now,'yyyy-mm-dd'),'"']);
    
else
    if numel(sID) == 1
        [R,S,I,C,G,E] = bdata(['select ratname, timeslot, instructions, comments, rig, experimenter from ratinfo.schedule where date="',...
            datestr(now,'yyyy-mm-dd'),'" and schedentryid=',num2str(sID)]);
    else
        for i =1:numel(sID)
            copy_schedule_tomorrow(sID(i));
        end
        return;
    end
end

for i = 1:numel(R)
    
    rtemp = bdata(['select ratname from ratinfo.schedule where rig=',     num2str(G(i)),...
                                                         ' and timeslot=',num2str(S(i)),...
                                                         ' and date="',   datestr(now+1,'yyyy-mm-dd'),'"']);
    
    if isempty(rtemp) 
        bdata(['insert into ratinfo.schedule set ratname="',     R{i},...
                                             '", timeslot=',     num2str(S(i)),...
                                             ',  instructions="',I{i},...
                                             '", comments="',    C{i},...
                                             '", rig=',          num2str(G(i)),...
                                             ',  experimenter="',E{i},...
                                             '", date="',        datestr(now+1,'yyyy-mm-dd'),'"']);
        pause(0.01);
    end
end
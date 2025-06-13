function output = WM_carryover(displayonly,varargin)

try
    if nargin == 0; displayonly = 0; end
    
    output = cell(0);
    [R,S,E,I,W] = bdata(['select rat, starttime, stoptime, tech, watering from ratinfo.water where date="',...
        datestr(now,'yyyy-mm-dd'),'" order by watering']);
    
    Rm = bdata(['select ratname from ratinfo.mass where date="',datestr(now,'yyyy-mm-dd'),'"']);
    
    Rr = bdata('select ratname from ratinfo.rats where extant=1');
    
    st = now;
    uR = unique(R);
    uR(strcmp(uR,'')) = [];

    for i=1:numel(uR)
        temp = find(strcmp(R,uR{i})==1,1,'last');
        
        if strcmp(S{temp},E{temp}) == 1 && sum(strcmp(Rr,uR{i})) == 1
            %This rat has the same start and end time, meaning he wasn't ended
            %yet.  This entry should be carried over to tomorrow. 
            disp(uR{i});
            
            output{end+1} = uR{i}; %#ok<AGROW>
    
            if displayonly == 1; continue; end
            
            %First we set his end time for today to be 1 minute before midnight
            bdata('call ratinfo.update_water_tbl2 ("{Si}","{S}")',W(temp),'23:59:00');

            %Second we add a new entry to the water table with a start and stop
            %time of one minute after midnight
            bdata('INSERT INTO ratinfo.water (date, rat, tech, starttime, stoptime) values ("{S}","{S}","{S}","{S}","{S}")',...
                    datestr(st+1,'yyyy-mm-dd'),R{temp},I{temp},'00:01:00','00:01:00');
                
            %Finally we check if he has a weight entry for today, if not it's
            %because he's on free water and should have 0g with FW initials        
            if sum(strcmp(Rm,uR{i})) == 0
                bdata(['insert into ratinfo.mass set mass=0, date="',datestr(st,'yyyy-mm-dd'),...
                    '", ratname="',uR{i},'", tech="FW", timeval="',datestr(st,'HH:MM:SS'),'"']); 
            end
            
            %Commenting out this section 2021-07-29 CK
            %This way a free water animal can easily be weighed if someone
            %wants to do it without having to delete the 0g. The 0g FW will
            %still be added at the end of the day
            %
            %Since the free water is continuing to tomorrow let's also give
            %him a 0g FW weight entry for tomorrow
            %bdata(['insert into ratinfo.mass set mass=0, date="',datestr(st+1,'yyyy-mm-dd'),...
            %    '", ratname="',uR{i},'", tech="FW", timeval="00:01:00"']);
            
            
        end
    end
catch
    senderror_report
end

return

%I use this code to muck with things. Leave it alone. -Chuck
% 
% [R,S,E,I] = bdata(['select rat, starttime, stoptime, tech from ratinfo.water where date="',...
%         datestr(now,'yyyy-mm-dd'),'" and stoptime="23:59:00"']);
% 
% for i=1:numel(R)
%     
%     disp(R{i});
% 
%     bdata('call ratinfo.update_water_tbl ("{S}","{S}","{S}")',R{i},datestr(now,'yyyy-mm-dd'),S{i});
% 
%     %bdata('INSERT INTO ratinfo.water (date, rat, tech, starttime, stoptime) values ("{S}","{S}","{S}","{S}","{S}")',...
%     %        datestr(st+1,'yyyy-mm-dd'),R{i},I{i},'00:01:00','00:01:00');
% 
% end


% for i = 1:numel(R)
%     W = bdata(['select watering from ratinfo.water where rat="',R{i},'" and stoptime="00:17:21"']);
%     bdata('call ratinfo.update_water_tbl2 ("{Si}","{S}")',W,'01:32:15');
% end


x = WM_rat_water_list(1:10,[],'all');
allrats = cell(0);
for i=1:10
    temp = unique(x{i});
    allrats(end+1:end+numel(temp)) = temp;
end
allrats(strcmp(allrats,'')) = [];
allrats = unique(allrats);

for i = 1:numel(allrats)
    m = bdata(['select mass from ratinfo.mass where date="',datestr(now,'yyyy-mm-dd'),...
        '" and ratname="',allrats{i},'"']);
    if isempty(m)
        bdata(['insert into ratinfo.mass set mass=0, date="',datestr(now,'yyyy-mm-dd'),...
            '", ratname="',allrats{i},'", tech="FW", timeval="00:01:00"']);
    end
end

            
            
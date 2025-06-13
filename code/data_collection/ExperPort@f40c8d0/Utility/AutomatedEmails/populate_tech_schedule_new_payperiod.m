function populate_tech_schedule_new_payperiod

%Populates the tech schedule every friday ensuring there are 4 weeks
%existing into the future.
% Written by Chuck

try
    dt1 = '';
    dt2 = '';

%     dn = str2num(datestr(now,'dd')); %#ok<ST2NM>
%     mn = str2num(datestr(now,'mm')); %#ok<ST2NM>
%     yn = str2num(datestr(now,'yy')); %#ok<ST2NM>

    if strcmp(datestr(now,'ddd'),'Fri')
        %Every friday we ensure there are 4 weeks in the tech schedule
        %d = bdata(['select date from ratinfo.tech_schedule where date>"',datestr(now,'yyyy-mm-dd'),'"']);
        %if isempty(d)
            dt1 = datestr(now+1,'yyyy-mm-dd');
        %else
        %    dt1 = datestr(datenum(d{end},'yyyy-mm-dd')+1,'yyyy-mm-dd'); 
        %end
        dt2 = datestr(now+28,'yyyy-mm-dd');
    end
        
%     if dn == 1
%         if     mn == 1; ed = 31;
%         elseif mn == 2; if rem(yn,4)==0; ed = 29; else ed = 28; end
%         elseif mn == 3; ed = 31;
%         elseif mn == 4; ed = 30;
%         elseif mn == 5; ed = 31;
%         elseif mn == 6; ed = 30;
%         elseif mn == 7; ed = 31;
%         elseif mn == 8; ed = 31;
%         elseif mn == 9; ed = 30;
%         elseif mn == 10; ed = 31;
%         elseif mn == 11; ed = 30;
%         elseif mn == 12; ed = 31;
%         end   
% 
%         if mn < 10; dt1 = [num2str(yn),'0',num2str(mn),'16']; dt2 = [num2str(yn),'0',num2str(mn),num2str(ed)];
%         else        dt1 = [num2str(yn),    num2str(mn),'16']; dt2 = [num2str(yn),    num2str(mn),num2str(ed)];
%         end
% 
%     elseif dn == 15    
%         if mn == 12; ny = yn + 1; nm = 1;
%         else         ny = yn;     nm = mn + 1;
%         end
% 
%         if nm < 10; dt1 = [num2str(ny),'0',num2str(nm),'01']; dt2 = [num2str(ny),'0',num2str(nm),'15'];
%         else        dt1 = [num2str(ny),    num2str(nm),'01']; dt2 = [num2str(ny),    num2str(nm),'15'];
%         end
% 
%     end

    if ~isempty(dt1) && ~isempty(dt2)
        populate_tech_schedule({dt1,dt2});
        email_tech_schedule({dt1,dt2});
    end
    
catch
    senderror_report
end
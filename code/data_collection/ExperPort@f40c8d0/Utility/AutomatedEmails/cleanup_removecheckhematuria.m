function cleanup_removecheckhematuria

try
    [Rs,Is,sID] = bdata(['select ratname, instructions, schedentryid from ratinfo.schedule where date="',datestr(now+1,'yyyy-mm-dd'),'"']);
    for i = 1:numel(Rs)
        if isempty(Rs{i}) || isempty(Is{i}); continue; end

        if ~isempty(strfind(lower(Is{i}),'check hematuria'))
            Ist = bdata(['select instructions from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),...
                '" and ratname="',Rs{i},'"']);

            found_today = 0;
            for j = 1:numel(Ist)
                if ~isempty(strfind(lower(Ist{j}),'check hematuria'))
                    found_today = 1;
                end
            end

            if found_today == 1
                newinstr = Is{i};
                x = strfind(lower(newinstr),'check hematuria');
                newinstr(x:x+14) = [];

                %mym(bdata,['update ratinfo.schedule set instructions="',newinstr,'" where schedentryid=',num2str(sID(i))]);
                bdata('call ratinfo.update_schedule_instructions("{S}",{Si})',newinstr,sID(i));
            end
        end
    end
catch
    senderror_report;
end
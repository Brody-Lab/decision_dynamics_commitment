function cleanup_removefromfreewater


try
    [Rs,Is] = bdata(['select ratname, instructions from ratinfo.schedule where date="',datestr(now,'yyyy-mm-dd'),'"']);
    for i = 1:numel(Rs)
        if isempty(Rs{i}) || isempty(Is{i}); continue; end

        if ~isempty(strfind(lower(Is{i}),'remove')) &&...
           ~isempty(strfind(lower(Is{i}),'free'))   &&...
           ~isempty(strfind(lower(Is{i}),'water'))

            x = bdata(['select starttime from sess_started where ratname="',Rs{i},'" and sessiondate="',datestr(now,'yyyy-mm-dd'),'"']);
            if ~isempty(x)
                id = bdata(['select schedentryid from ratinfo.schedule where ratname="',Rs{i},'" and date="',datestr(now+1,'yyyy-mm-dd'),'"']);
                if ~isempty(id)
                    RIs = bdata(['select instructions from ratinfo.schedule where ratname="',Rs{i},'" order by date desc']);
                    newinstruct = '';
                    for j = 1:numel(RIs)
                        if isempty(strfind(lower(RIs{j}),'remove')) ||...
                           isempty(strfind(lower(RIs{j}),'free'))   ||...
                           isempty(strfind(lower(RIs{j}),'water'))
                            newinstruct = RIs{j};
                            break
                        end
                    end
                    for j = 1:numel(id)
                        %We should find the last set of instructions for
                        %this rat that were not 'remove from free water'
                        %and set them back to those
                        
                        %mym(bdata,'update ratinfo.schedule set instructions="{S}" where schedentryid={S}',newinstruct,id(j));
                        bdata('call ratinfo.update_schedule_instructions("{S}",{Si})',newinstruct,id(j));
                    end
                end
            end
        end

    end
catch
    senderror_report;
end
    

function GCS_live_update

% c = findall(0);
% for i=1:numel(c)
%     try
%         if ~isempty(strfind(c(i).Name,'GlobalControlSystem'))
%             pos = c(i).Position;
%             break;
%         end
%     end
% end
% 
handles = GlobalControlSystem;
% 
% set(c(i),'Position',pos)


x = get(handles.figure1,'Children');
for id=1:numel(x)
    if strcmp(get(x(id),'Tag'),'live_toggle')
        break
    end
end

set(x(id),'String','Updating...','BackgroundColor',[0.5 0.5 0.5]);
pause(0.01);

GlobalControlSystem('update',x(id),[],handles);

set(x(id),'String','Pause','BackgroundColor',[1 0 0]);
pause(0.01);






return
try %#ok<TRYNC>
    if get(handles.live_toggle,'value') == 1
        %Let's update the system in real time

        set(handles.live_toggle,'string','Pause','backgroundcolor',[1 0 0]);

        while get(handles.live_toggle,'value') == 1
            %We will continue to loop while the button is on
            tempstart = now;

            set(handles.live_toggle,'string','Updating...','backgroundcolor',[1 0 0]); pause(0.1)
            handles = check_running(handles);
            
            set(handles.live_toggle,'string','Pause','backgroundcolor',[1 0 0]);
            
            %Puase such that we do 1 update every 30 seconds
            endpause = tempstart + (30/(3600*24));
            while now < endpause
                timerem = ceil((endpause - now)*3600*24);
                set(handles.live_toggle,'string',['Pause ',num2str(timerem)],'backgroundcolor',[1 0 0]);
                pause(1);
            end
        end
        set(handles.live_toggle,'string','Go Live','backgroundcolor',[0 1 0]);

    else
        set(handles.live_toggle,'string','Go Live','backgroundcolor',[0 1 0]);
    end
      
end
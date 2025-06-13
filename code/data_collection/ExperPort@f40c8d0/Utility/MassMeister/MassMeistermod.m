function varargout = MassMeister(varargin)
% MASSMEISTER M-file for MassMeister.fig
%      MASSMEISTER, by itself, creates a new MASSMEISTER or raises the existing
%      singleton*.
%
%      H = MASSMEISTER returns the handle to a new MASSMEISTER or the handle to
%      the existing singleton*.
%
%      MASSMEISTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASSMEISTER.M with the given input arguments.
%
%      MASSMEISTER('Property','Value',...) creates a new MASSMEISTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MassMeister_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MassMeister_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MassMeister

% Last Modified by GUIDE v2.5 09-Jan-2019 13:45:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MassMeister_OpeningFcn, ...
                   'gui_OutputFcn',  @MassMeister_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MassMeister is made visible.
function MassMeister_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>

        scalemodel         = bSettings('get','RIGS','scalemodel');
		scalecom           = bSettings('get', 'RIGS', 'scalecom');
		RFIDcom           = bSettings('get', 'RIGS', 'RFIDcom');
        
handles.output = hObject;

set(gcf,'name','MassMesiter V3.1');
set(handles.date_text,'string',datestr(now,'yyyy-mm-dd'));
handles.groups = get(handles.session_list,'string');
handles = get_newrats(  handles);
handles = get_movedrats(handles);
handles = get_colors(   handles);
handles = update_names( handles);

handles = update_lists(handles);
handles = update_ratname(handles);
%Let's try to establish connection to the RFID scanner
    try

    handles.RFID = serial(RFIDcom);
         set(handles.RFID,'Terminator','CR','baudrate',115200);
    fopen(handles.RFID);
    set(handles.status_text,'string','Please select your name.',...
        'backgroundcolor',[1 1 1]);

    catch
    handles.RFID = [];
    set(handles.status_text,'string','ERROR: Can''t connect to RFID',...
        'backgroundcolor',[1 0 0]);
    end


%Let's try to establish a connection to the balance
try

    handles.balance = serial(scalecom);
if strcmp(scalemodel,'STX421');
    set(handles.balance,'Terminator','LF');
    %else CHUCK
end
    fopen(handles.balance);
    set(handles.status_text,'string','Please select your name.',...
        'backgroundcolor',[1 1 1]);
catch %#ok<CTCH>
    handles.balance = [];
    set(handles.status_text,'string','ERROR: Can''t connect to balance',...
        'backgroundcolor',[1 0 0]);
    pause(2);
    
end



handles = load_settings(handles);

figsize = get(gcf,'position');
handles.figsize = figsize(3:4);
handles.ratname_text_font = get(handles.ratname_text,'fontsize');
handles.status_text_font = get(handles.status_text,'fontsize');


% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = MassMeister_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
varargout{1} = handles.output;


% --- Executes on selection change in session_list.
function session_list_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

handles = update_lists(handles);
handles = update_ratname(handles);
guidata(hObject, handles);


% --- Executes on selection change in ratname_list.
function ratname_list_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

handles = update_ratname(handles);
guidata(hObject,handles);



% --- Executes on button press in start_toggle.
function start_toggle_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

if get(handles.start_toggle,'value') == 0
    set(handles.start_toggle,'backgroundcolor',[0 1 0],'string','Start');    
    set(handles.mass_text,'string','0');
else
    set(handles.start_toggle,'backgroundcolor',[1 0 0],'string','Stop');
    uicontrol(handles.ratname_list);
    
    %Let's load the settings file
    handles = load_settings(handles);
    
    %Let's jump to the first empty rat in the list.
    handles = jump_to_empty(handles);
    
    timeout       = 2;
    fulltimeout   = 1800;
    foundstable   = 0;
    doing_reweigh = 0;
    M = [];
    fullstart = now;
    while get(handles.start_toggle,'value') == 1
        cyclestart = now;
        
        %Let's see if there's anything to read from the RFID scanner
        RFID_ratname = '';
        if ~isempty(handles.RFID)
            ba = get(handles.RFID,'BytesAvailable');
            if ba > 0
                %There are bytes so let's read them off
                RFID_ratname = fscanf(handles.RFID);
                if numel(RFID_ratname) > 4
                    RFID_ratname = RFID_ratname(1:4);
                end

                ba = get(handles.RFID,'BytesAvailable');
                while ba > 0
                    %There are extra bytes, possible multiple reads, let's just
                    %drain them away be reading them off
                    fscanf(handles.RFID);
                    ba = get(handles.RFID,'BytesAvailable');
                    pause(0.01);
                end

                curr_ratlist = get(handles.ratname_list,'string');
                curr_ratpos  = get(handles.ratname_list,'value');
                
                for i=1:numel(curr_ratlist)
                    if numel(curr_ratlist{i})>4
                        curr_ratlist{i} = curr_ratlist{i}(1:4);
                    end
                end
                if sum(strcmp(curr_ratlist,RFID_ratname)) == 1
                    %The scanned rat is on the current list
                    rat_pos = find(strcmp(curr_ratlist,RFID_ratname)==1,1,'first');
                    if rat_pos ~= curr_ratpos
                        %The scanned rat is not the active rat on the list
                        set(handles.ratname_list,'value',rat_pos);
                        handles = update_ratname(handles);
                    end
                end
            end
        end
        %Let's get the mass off the balance
%         
        ba=get(handles.balance,'BytesAvailable'); 
        while ba > 0; 
            fscanf(handles.balance); 
            ba=get(handles.balance,'BytesAvailable'); 
            pause(0.01); 
        end
        fprintf(handles.balance,'P'); 
        m = fscanf(handles.balance);
        if (now-cyclestart)*24*3600 > timeout
            set(handles.start_toggle,'backgroundcolor',[0 1 0],'string','Start','value',0); 
            set(handles.status_text,'string','ERROR: Can''t connect to balance',...
                'backgroundcolor',[0 1 0]);
            set(handles.mass_text,'string','0');
            return
        end
        
        if (now-fullstart)*24*3600 > fulltimeout
            set(handles.start_toggle,'backgroundcolor',[0 1 0],'string','Start','value',0); 
            set(handles.status_text,'string','Timed Out',...
                'backgroundcolor',[0 1 0]);
            set(handles.mass_text,'string','0');
            return
        end
        
         m(m=='?') = '';

        
%        m = str2num(m(2:12)); %#ok<ST2NM>
         m=str2num(m);
        
        set(handles.mass_text,'string',num2str(m));
        
        if m > handles.minmass
            %There is a rodent on the scale
            if foundstable == 0
                %we do not yet have a stable reading
                if length(M) < handles.numreads
                    M(end+1) = m; %#ok<AGROW>
                else
                    %We have a full list of readings
                    M(1:end-1)=M(2:end);
                    M(end) = m;
                    p = polyfit(1:handles.numreads,M,1);
                    score = abs(p(1) * handles.rate)/mean(M);

                    if score < handles.threshold / 100
                        %We have a stable reading
                        foundstable = 1;
                        
                        ratname = get(handles.ratname_text,'string');
                        weight = round(mean(M));
                        
                        %If we have an entry for this rat today, delete it
                        try
                            id = bdata(['select weighing from ratinfo.mass where date="',...
                                datestr(now,29),'" and ratname="',ratname,'"']);
                            if ~isempty(id); bdata('call bdata.delete_weighing("{Si}")',id); end
                        catch %#ok<CTCH>
                            set(handles.status_text,'string','ERROR: Unable to connect to network.',...
                                'backgroundcolor',[1 0 0]);
                            set(handles.start_toggle,'value',0);
                            return
                        end
                        
                        %Insert the new weight into the MySQL table
                        try
                            bdata(['insert into ratinfo.mass set mass=',num2str(weight),...
                                ', date="',datestr(now,29),'", ratname="',ratname,...
                                '", tech="',handles.active_user,'", timeval="',datestr(now,'HH:MM:SS'),'"']); 
                        catch %#ok<CTCH>
                            set(handles.status_text,'string','ERROR: Unable to connect to network.',...
                                'backgroundcolor',[1 0 0]);
                            set(handles.start_toggle,'value',0);
                            return
                        end
                        
                        %Let's update the lists, but we don't want change
                        %the active rat just yet
                        handles = update_lists(handles,get(handles.ratname_list,'value'));
                        
                        %Tell the user to remove the rat
                        rignum=0;
                        try %#ok<TRYNC>
                            rignum = bdata(['select rig from ratinfo.schedule where ratname="',...
                            ratname,'" and date="',datestr(now,'yyyy-mm-dd'),'" and timeslot="',...
                            num2str(get(handles.session_list,'value')),'"']); 
                        end
                        if isempty(rignum) || rignum == 0
                            set(handles.status_text,'string','Weighing Complete. Return rat to cage.',...
                                'backgroundcolor',[0 1 0]);
                        elseif weight < handles.smallrat
                            set(handles.status_text,'string',['Weighing Complete. Rat is too small to train.',...
                                ' Return rat to cage. Log a TechNote and flag as RECOVERY.'],...
                                'backgroundcolor',[0 1 0]);
                        else
                            try
                                Instructions = MM_get_tech_instructions(ratname,get(handles.session_list,'value'));
                            catch
                                Instructions = '';
                            end
                            set(handles.status_text,'string',['Weighing Complete. Load in ',...
                                num2str(rignum),'. ',Instructions],'backgroundcolor',[0 1 0]);
                        end
                    end
                end
            end
        else         
            if foundstable == 1
                %The rat is off the scale, jump to the next
                
                %We're only going to check if the weight is similar for
                %rats not scanned with RFID chips.
                
                
                %if the weight is similar to the last weight entry, let's
                %move on to the next unweighed rat, if not we should prompt
                %the user to reweight this rat

                %oldmass = bdata(['select mass from ratinfo.mass where ratname="',...
                %    ratname,'" and date<"',datestr(now,29),'"order by weighing desc']);

                oldmass = bdata(['select mass from ratinfo.mass where ratname="',...
                    ratname,'" order by weighing desc']);

                %Free water rats have 0g entered in the mass log. Let's
                %eliminate these so we only look at real masses.
                oldmass(oldmass == 0) = [];
                
                if ~strcmp(ratname,RFID_ratname)
                    if numel(oldmass) < 2 ||...
                       abs((weight - oldmass(2)) / oldmass(2)) < handles.error / 100 ||...
                       doing_reweigh == 1
                        %Weight is within range, there was no previous entry, 
                        %or this is our second attempt at weighing this rat, 
                        %either way, let's move on 

                        if numel(oldmass) > 1 && doing_reweigh == 1 && ((oldmass(2)-weight) / oldmass(2)) > handles.error / 100
                            %This is our second weighing and the rats has gone
                            %down by a significant amount 5%.  Instruct the tech
                            %to place the rat on free water and contact the
                            %experimenter.

                            %Run this code to alert the tech to put the rat on
                            %free water and stop mass meister from running

                            %set(handles.status_text,'string','Put rat on free water. Call experimenter.',...
                            %    'backgroundcolor',[1 0 0]);
                            %set(handles.start_toggle,'value',0,'String','Start','backgroundcolor',[0 1 0]);
                            %return

                            %Run this code to send a text alert to the
                            %experimenter that the rat has shown a >5% weight
                            %drop. But let the tech continue as normal
                            try  %#ok<TRYNC>
                                %let's confirm that this is a real drop and not
                                %just that the previous weight entry was 
                                %mistakenly high

                                if numel(oldmass) < 3
                                    %there are only two weight entries, have to
                                    %trust that this is a real drop
                                    send_massdrop_text(handles,oldmass);
                                else
                                    %check against previous entries to ensure
                                    %this is a real drop
                                    if (oldmass(3) - weight) / oldmass(3) > 0.02
                                        send_massdrop_text(handles,oldmass);
                                    end
                                end        
                            end

                        end

                        handles = jump_to_empty(handles);
                        doing_reweigh = 0;


                    else
                        %Weight is out of range, let's reweigh this rat once
                        %more, that requires us to delete the weight entry from
                        %MySQL and update the lists
                        handles = update_ratname(handles);
                        id = bdata(['select weighing from ratinfo.mass where date="',...
                            datestr(now,29),'" and ratname="',ratname,'"']);
                        if ~isempty(id); bdata('call bdata.delete_weighing("{Si}")',id); end
                        handles = update_lists(handles,get(handles.ratname_list,'value'));
                        doing_reweigh = 1;
                    end
                    
                else
                    %This was a RFID scanned rat, if weight dropped a lot
                    %send text then clean things up
                    
                    if numel(oldmass) > 1 && ((oldmass(2)-weight) / oldmass(2)) > handles.error / 100
                        try  %#ok<TRYNC>
                            %let's confirm that this is a real drop and not
                            %just that the previous weight entry was 
                            %mistakenly high

                            if numel(oldmass) < 3
                                %there are only two weight entries, have to
                                %trust that this is a real drop
                                send_massdrop_text(handles,oldmass);
                            else
                                %check against previous entries to ensure
                                %this is a real drop
                                if (oldmass(3) - weight) / oldmass(3) > 0.02
                                    send_massdrop_text(handles,oldmass);
                                end
                            end        
                        end
                    end
                    handles = jump_to_empty(handles);
                    
                end
                foundstable = 0;
                
            end         
            M = []; 
        end
        
        if all(get(handles.start_toggle,'backgroundcolor') == [1 0 0])
            set(handles.start_toggle,'backgroundcolor',[1 0 1]);
        else
            set(handles.start_toggle,'backgroundcolor',[1 0 0]);
        end
        %Let's pause for a bit so we take a reading at the desired rate
        pausetime = (1/handles.rate) - ((now-cyclestart)*24*3600);
        if pausetime > 0; pause(pausetime); end
    end
    
    set(handles.start_toggle,'backgroundcolor',[0 1 0],'string','Start');  
    set(handles.mass_text,'string','0');
end
guidata(hObject,handles);



% --- Executes on button press in edit_button.
function edit_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.start_toggle,'value',0);
set(handles.mass_text,'style','edit');
set(handles.status_text,'string','Please enter the rat''s mass then click Enter',...
    'backgroundcolor',[1 1 1]);

%Pass the focus to the mass_text object so the user doesn't need to mouse
%click on it
uicontrol(handles.mass_text);
doing_reweigh = 0;

%Now we wait for user to enter a good weight
good_weight = 0;
while good_weight == 0

    %Now we wait for the user to enter the weight.
    while get(handles.mass_text,'value') == 0
        pause(0.2);
    end
    weight_entered = get(handles.mass_text,'value');
    ratname = get(handles.ratname_text,'string');

    oldmass = bdata(['select mass from ratinfo.mass where ratname="',...
                        ratname,'" order by weighing desc']);

    %Free water rats have 0g entered in the mass log. Let's
    %eliminate these so we only look at real masses.
    oldmass(oldmass == 0) = [];

    if numel(oldmass) < 2 || doing_reweigh == 1 || ...
       abs((weight_entered - oldmass(2)) / oldmass(2)) < handles.error / 100
             
        good_weight = 1;
    else
        doing_reweigh = 1;
        set(handles.status_text,'string','Check weight is correct and re-enter',...
            'backgroundcolor',[1 0.5 0.5]);
        set(handles.mass_text,'string',0,'value',0);
        pause(0.1);
    end
end

try
    %If this rat has an entry for this day we need to delete it
    id = bdata(['select weighing from ratinfo.mass where date="',datestr(now,29),'" and ratname="',ratname,'"']);
    if ~isempty(id); bdata('call bdata.delete_weighing("{Si}")',id); end
    
    %Now we insert the new weight into the table
    bdata(['insert into ratinfo.mass set mass=',num2str(weight_entered),...
        ', date="',datestr(now,29),'", ratname="',ratname,'", tech="',...
        handles.active_user,'", timeval="',datestr(now,'HH:MM:SS'),'"']); 
    
    %If the mass is down, we need to alert experimenter just like we do in the
    %non-manual entry weighing
    if numel(oldmass) > 1 && doing_reweigh == 1 && ((oldmass(2)-weight_entered) / oldmass(2)) > handles.error / 100
        try  %#ok<TRYNC>
            if numel(oldmass) < 3
                %there are only two weight entries, have to
                %trust that this is a real drop
                set(handles.status_text,'string','Notifying experimenter. Please wait.',...
                    'backgroundcolor',[1 0 0]);
                pause(0.1);
                send_massdrop_text(handles,oldmass);
            else
                %check against previous entries to ensure
                %this is a real drop
                if (oldmass(3) - weight_entered) / oldmass(3) > 0.02
                    set(handles.status_text,'string','Notifying experimenter. Please wait.',...
                        'backgroundcolor',[1 0 0]);
                    pause(0.1);
                    send_massdrop_text(handles,[weight_entered;oldmass]);
                end
            end        
        end
    end

catch %#ok<CTCH>
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
end

    
%Revert the mass_text object back to a text style
set(handles.mass_text,'style','text','value',0,'string','0');
handles = update_lists(handles);
handles = jump_to_empty(handles);

guidata(hObject,handles);


% --- Executes on button press in mass_text
function mass_text_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%Executes when the user is done entering the weight for the rat manually.
%It is used by the edit button callback to know when to break out of the
%loop
set(handles.mass_text,'value',str2num(get(handles.mass_text,'string'))); %#ok<ST2NM>
guidata(hObject,handles);


% --- Executes on button press in delete_button.
function delete_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

ratname = get(handles.ratname_text,'string');
try
    id = bdata(['select weighing from ratinfo.mass where date="',datestr(now,29),'" and ratname="',ratname,'"']);
    %Make a call to MySQL to remove the line
    bdata('call bdata.delete_weighing("{Si}")',id);
    
catch %#ok<CTCH>
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
end
handles = update_lists(handles,get(handles.ratname_list,'value'));
handles = update_ratname(handles);
guidata(hObject,handles);


% --- Executes on button press in zero_button.
function zero_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

if ~isempty(handles.balance)
    try
        fprintf(handles.balance,'T');
        set(handles.mass_text,'string','0');
    catch %#ok<CTCH>
        set(handles.status_text,'string','ERROR: Can''t connect to balance',...
            'backgroundcolor',[1 0 0]);
    end
else
    set(handles.status_text,'string','ERROR: Can''t connect to balance',...
        'backgroundcolor',[1 0 0]);
end
guidata(hObject,handles);
    


% --- Executes on selection change in user_menu.
function user_menu_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

handles.active_user = handles.initials{get(handles.user_menu,'value')};

if get(handles.user_menu,'value') == 1
    set(handles.start_toggle,'enable','off');
    set(handles.edit_button, 'enable','off');
else
    if ~isempty(handles.balance); set(handles.start_toggle,'enable','on'); end
    set(handles.edit_button,'enable','on');
end
guidata(hObject,handles);


% --- Executes on button press in plotmass_button.
function plotmass_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

set(handles.start_toggle,'value',0);

str = get(handles.ratname_list,'string');
rtn = get(handles.ratname_list,'value');
ratname = str{rtn}(1:4);

try
    plot_rat_mass(ratname);
catch %#ok<CTCH>
    set(handles.status_text,'string','ERROR: Unable to connect to network.',...
        'backgroundcolor',[1 0 0]);
    return;
end



% --- Executes on button press in settings_button.
function settings_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

MassMeister_Properties;



% --- Executes during object creation, after setting all properties.
function session_list_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ratname_list_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function user_menu_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

try %#ok<TRYNC>
    fclose(handles.balance);
    fclose(handles.RFID);
end
delete(hObject);


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)

if isfield(handles,'figsize')
   newpos = get(handles.figure1,'position');
   newpos = newpos(3:4);

       newratio = min(newpos ./ handles.figsize);
       newfontsize = floor(newratio * handles.ratname_text_font);
       set(handles.ratname_text,'fontsize',newfontsize);
    
       newfontsize = floor(newratio * handles.status_text_font);
       set(handles.status_text,'fontsize',newfontsize);
       
   guidata(hObject,handles);
end



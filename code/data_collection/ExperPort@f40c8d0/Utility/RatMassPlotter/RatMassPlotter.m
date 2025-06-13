function varargout = RatMassPlotter(varargin)
% RATMASSPLOTTER M-file for RatMassPlotter.fig
%      RATMASSPLOTTER, by itself, creates a new RATMASSPLOTTER or raises the existing
%      singleton*.
%
%      H = RATMASSPLOTTER returns the handle to a new RATMASSPLOTTER or the handle to
%      the existing singleton*.
%
%      RATMASSPLOTTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RATMASSPLOTTER.M with the given input arguments.
%
%      RATMASSPLOTTER('Property','Value',...) creates a new RATMASSPLOTTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RatMassPlotter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RatMassPlotter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RatMassPlotter

% Last Modified by GUIDE v2.5 04-Aug-2011 10:40:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RatMassPlotter_OpeningFcn, ...
                   'gui_OutputFcn',  @RatMassPlotter_OutputFcn, ...
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


% --- Executes just before RatMassPlotter is made visible.
function RatMassPlotter_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for RatMassPlotter
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

D = [];
L = cell(0);
for y = 2008:str2num(datestr(now,'yyyy')) %#ok<ST2NM>
    for m = 1:12
        if m < 10; dtemp = [num2str(y),'-0',num2str(m),'-01'];
        else       dtemp = [num2str(y),'-', num2str(m),'-01'];
        end
        D(end+1) = datenum(dtemp,'yyyy-mm-dd');
        L{end+1} = datestr(D(end),'mmm-yy');
    end
end
handles.datebounds = D;
handles.datecenter = D+15;
handles.datelabels = L;

guidata(hObject,handles);
    


% --- Outputs from this function are returned to the command line.
function varargout = RatMassPlotter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ratlist.
function ratlist_Callback(hObject, eventdata, handles)




% --- Executes during object creation, after setting all properties.
function ratlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
ratnames = bdata('select ratname from ratinfo.rats where extant=1');
ratnames = sortrows(ratnames);
set(hObject,'string',ratnames);


% --- Executes on button press in zoom_toggle.
function zoom_toggle_Callback(hObject, eventdata, handles)

set(handles.pan_toggle,'value',0);
pan off
if get(hObject,'value') == 1; zoom on;
else                          zoom off;
end


% --- Executes on button press in pan_toggle.
function pan_toggle_Callback(hObject, eventdata, handles)

set(handles.zoom_toggle,'value',0);
zoom off
if get(hObject,'value') == 1; pan on;
else                          pan off;
end


% --- Executes on button press in cagemate_button.
function cagemate_button_Callback(hObject, eventdata, handles)



% --- Executes on selection change in time_menu.
function time_menu_Callback(hObject, eventdata, handles)

handles = update_xlim(handles);


% --- Executes during object creation, after setting all properties.
function time_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)

allrats = get(handles.ratlist,'string');
ratnums = get(handles.ratlist,'value');

ratnames = allrats(ratnums);
axes(handles.axes1);
handles = update_plot(handles);
set(gca,'xtick',handles.datecenter,'xticklabel',handles.datelabels);

if length(ratnames) == 1
    cnorm = [0 0 0];
    canom = [0 0 1];
else
    cnorm = jet(length(ratnames)) .* 0.8;
    canom = cnorm;
end

for i = 1:12
    for j = 1:3
        set(eval(['handles.stats_text_',num2str(i),num2str(j)]),'string','');
    end
end   

change = zeros(1,2); 
M = [nan nan];
for i = 1:length(ratnames);
    x = plot_rat_mass(ratnames{i},'max_days',Inf,'do_plot',0);
    dnum = zeros(size(x.days));
    for j=1:length(x.days); dnum(j) = datenum(x.days{j},29); end
    plot(dnum,x.mass,     '-o','color',cnorm(i,:),'linewidth',2,'markersize',6,'markerfacecolor',cnorm(i,:));
    if i == 1; hold on; end
    plot(dnum,x.anomalous,'-o','color',canom(i,:),'linewidth',2,'markersize',6,'markerfacecolor',canom(i,:));
    
    change(:) = nan;
    if length(x.mass)>1; change(1) = (x.mass(end)-x.mass(end-1)) / x.mass(end-1); end
    if length(x.mass)>7; change(2) = (mean(x.mass(end-1:end))-mean(x.mass(end-7:end-6))) / mean(x.mass(end-1:end)); end
    change = round(change * 1000) / 10;
    
    if i <= 12
        set(eval(['handles.stats_text_',num2str(i),'1']),'foregroundcolor',cnorm(i,:),'string',ratnames{i})
        for j = 1:2
            if     change(j)<0;  set(eval(['handles.stats_text_',num2str(i),num2str(j+1)]),'foregroundcolor','r','string',[num2str(change(j)),'%']);
            elseif change(j)>0;  set(eval(['handles.stats_text_',num2str(i),num2str(j+1)]),'foregroundcolor','g','string',[num2str(change(j)),'%']);
            elseif change(j)==0; set(eval(['handles.stats_text_',num2str(i),num2str(j+1)]),'foregroundcolor','k','string',[num2str(change(j)),'%']);    
            end
        end
    end
    if i == length(ratnames); hold off; end
    
    M(1) = min([M(1),min(x.mass),min(x.anomalous)]);
    M(2) = max([M(2),max(x.mass),max(x.anomalous)]);
    set(gca,'ylim',[M(1)-5,M(2)+5]);
    handles = update_xlim(handles);
    pause(0.1);
end

%for i = 1:length(ratnames)
%    ratnames{i} = [ratnames{i},'  ',num2str(change(i,1)),'% ',num2str(change(i,2)),'%'];
%end

ylabel('Mass, grams')

%set(gca,'fontsize',10); 
%legend(ratnames,'Location','EastOutside');
%set(gca,'fontsize',16);
%handles = update_stats(handles);



    
    
    
    
    
    
    

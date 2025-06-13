function openSettingsInDispatcher(protocol, experimenter, rat, sessid,get_latest)

%% Make sure you have the data file
curdir=pwd;
if nargin<5
    get_latest=false;
end
[data_file]=bdata('select data_file from sessions where sessid="{S}"',sessid);
data_file=data_file{1};
datadir=bSettings('get','GENERAL', 'Main_Data_Directory');
if isempty(datadir) || any(isnan(datadir))
    datadir=[filesep 'ratter'];
end

datapath=[datadir filesep 'Settings' filesep experimenter filesep rat filesep];
verifyPathCVS(datapath)

cd(datapath);
if get_latest
    last_date=010101;
    [a,lsout]=system('cvs ls');
    sind=regexp(lsout, 'settings','start');
    eind=regexp(lsout, '.mat','start');
    
    for dx=1:numel(eind)
        this_date=str2double(lsout(eind(dx)-7:eind(dx)-2));
        if this_date==last_date
            if lsout(eind(dx)-1)>lsout(eind(last_idx)-1)
                 last_date=this_date;
                 last_idx = dx;
            end
        elseif this_date>last_date
            last_date=this_date;
            last_idx = dx;
        end
        
    end
    
    settings_file=lsout(sind(last_idx):eind(last_idx)+3);
        
else
settings_file=['settings' data_file(5:end)];

if ~strcmp('.mat',data_file(end-3:end))
    settings_file=[settings_file '.mat'];
end

end

    
df=dir(settings_file);
if isempty(df)
    % does our data file have the .mat extension?
    [sysout]=system(['cvs up ' settings_file]);
end

%% Get dispatcher and the Protocol Ready
% is dispatcher already running?  We need to be in the code directory now

codedir=bSettings('get','GENERAL', 'Main_Code_Directory');
cd(codedir)

try
    dispatcher('getstatemachine');
catch
    % if it is not running start it.
    newstartup; dispatcher('init');
end

% is there a protocol open?
curprot=dispatcher('get_protocol_object');

if isempty(curprot) || ~isequal(curprot, eval(protocol))
    dispatcher('set_protocol',protocol)
end

%% Load the file 
outflag = load_solouiparamvalues(rat, 'owner',protocol,'settings_file',[datapath settings_file]);



cd(curdir)
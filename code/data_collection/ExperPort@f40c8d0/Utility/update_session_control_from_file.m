function update_session_control_from_file(pathname, filename,do_rats)
% update_session_control_from_file(pathname, filename,do_rats)
% Pathname and filename should point to a .m style Session Control file.
% do_rats is a cell array of ratnames. 
%


if isempty(filename)
     [filename, pathname] = uigetfile('*.m', 'Pick an Session Control M-file');
end

if ischar(do_rats)
    do_rats{1}=do_rats;
end

for rx=1:numel(do_rats)
    sessid=bdata('select max(sessid) from sessions where ratname="{S}"',do_rats{rx});
    [protocol, exptr]=bdata('select protocol, experimenter from sessions where sessid="{S}"',sessid);
    protocol=protocol{1};
    exptr=exptr{1};
    openSettingsInDispatcher(protocol, exptr, do_rats{rx}, sessid);
    SessionDefinition(eval(protocol),'insert_from_file',pathname, filename);
    SavingSection(eval(protocol),'savesets','interactive',0);
end

function openSettingsInDispatcher(protocol, experimenter, rat, sessid)

%% Make sure you have the data file
curdir=pwd;
[data_file]=bdata('select data_file from sessions where sessid="{S}"',sessid);
data_file=data_file{1};
settings_file=['settings' data_file(5:end)];
datadir=bSettings('get','GENERAL', 'Main_Data_Directory');
if isempty(datadir) || any(isnan(datadir))
    datadir=[filesep 'ratter'];
end

datapath=[datadir filesep 'Settings' filesep experimenter filesep rat filesep];

verifyPathCVS(datapath)

cd(datapath);
if ~strcmp('.mat',data_file(end-3:end))
    settings_file=[settings_file '.mat'];
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
function openInDispatcher(protocol, experimenter, rat, sessid)

%% Make sure you have the data file
curdir=pwd;
[data_file]=bdata('select data_file from sessions where sessid="{S}"',sessid);
data_file=data_file{1};
datadir=bSettings('get','GENERAL', 'Main_Data_Directory');
if isempty(datadir) || any(isnan(datadir))
    datadir=[filesep 'ratter'];
end

datapath=[datadir filesep 'Data' filesep experimenter filesep rat filesep];

verifyPathCVS(datapath)

cd(datapath);
if ~strcmp('.mat',data_file(end-3:end))
    data_file=[data_file '.mat'];
end
    
df=dir(data_file);
if isempty(df)
    % does our data file have the .mat extension?
    [sysout]=system(['cvs up ' data_file]);
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
outflag = load_soloparamvalues(rat, 'owner',protocol,'data_file',[datapath data_file]);



cd(curdir)
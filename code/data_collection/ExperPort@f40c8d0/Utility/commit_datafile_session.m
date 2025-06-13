function commit_datafile_session(datafile,settingsfile)

%Takes a SoloData data file and attempts to commit it to the sessions and
%parsed_events MySQL tables.
%
%newstartup;
%commit_datafile_session(datafile);
%
%datafile is the full path and file name to the SoloData file you want to
%commit. This function will attempt to open dispatcher and load the data
%file into the relevant protocol.  Make sure dispatcher is not already open
%and run newstartup before running this function. This function will then
%call the "pre_saving_settings" case in the relevant protocol which should
%include the code to parse the protocol data structure pd and pass that
%into the function sendsummary.  If the data file was recovered from an ASV
%folder it's possible the length of some variables are different from what
%is normally encountered when End Session is clicked on RunRats.  If an
%error is encountered it will be displayed in the command window.
%
%Written by Chuck 8/2017


[pname, fname, ext] = fileparts(datafile);
u = find(fname=='_');
u = [0,u,numel(fname)+1];
if numel(u)~= 6 || ~strcmp(fname(1:u(2)-1),'data') 
    disp('Improper File Name');
    return;
end

protocol = fname(u(2)+1:u(3)-1);
expname  = fname(u(3)+1:u(4)-1);
ratname  = fname(u(4)+1:u(5)-1);

if protocol(1) ~= '@'
    disp('Improper Protocol');
    return;
end
protocol = protocol(2:end);

id = bdata(['select sessid from sessions where data_file="',fname,'"']);
if ~isempty(id)
    disp('An entry already exists in the sessions table for this data file');
    return; 
end

dispatcher init
dispatcher('set_protocol',protocol);

rath = get_sphandle('name','ratname','owner',protocol);
exph = get_sphandle('name','experimenter','owner',protocol);

rath{1}.value = ratname;
exph{1}.value = expname;

protobj=eval(protocol);

load_soloparamvalues(ratname,'experimenter',expname ,...
    'owner', class(protobj), 'interactive', 0,'data_file',datafile);

SavingSection(protobj,'set','data_file',datafile);

try
    feval(protocol, protobj, 'pre_saving_settings');
    disp('Commit COMPLETED');
catch
    disp(['ERROR evaluating ',protocol,' pre_saving_settings case']);
    disp(' ');
    x = lasterror;
    disp(x.message);
    disp(x.stack);
end
SavingSection(eval(protocol),'savesets','interactive',0,'fullfilename',settingsfile);

dispatcher('set_protocol','');
dispatcher('close');

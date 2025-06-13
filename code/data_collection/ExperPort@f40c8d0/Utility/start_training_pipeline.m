function start_training_pipeline(ratname,Experimenter,task,varargin)

%Currently this function only works for PBups training pipeline but should
%be expanded by others to work for theirs. Training Pipeline starter files
%are stored in the git repository: 
%   https://github.com/Brody-Lab/TrainingPipelines
%
%which should be cloned to your local computer at:
%   \ratter\TrainingPipelines
%
%Inputs:
%   ratname: The rat's name, i.e. 'K001'
%
%   experimenter: The experimenter's first name, i.e. 'Chuck'
%
%   task: The task the rat is to be trained on, i.e. 'PoissonClicks'
%
%Optional Inputs: (task specific)
%   PoissonClicks
%       frequency: The total frequency of the two click trains, 20 or 40
%
%       clicktype: 'Classic'   (for left right clicks)
%                  'Frequency' (for high low clicks)
%
%       protcol: the protocol to start the training from, 'ProAnti3' or 'PBups'
%       
%       pipeline_name: If you have your own start files for PoissonClicks, 
%                      this will direct the function to use those, located 
%                      in a subdirectory with this name  
%
%The function finds the appropriate starter file, loads it, changes the
%experimenter and ratname fields to have the appropriate values then
%saves it to the rat's settings folder in RATTER on bucket. If the rat
%starts from ProAnti3 protocol then the appropriate secondary starter file
%is copied into the settings directory and any existing starter files
%are deactivated.
%
%Example:
%   start_training_pipeline('K345','Chuck','PoissonClicks',...
%                           'frequency', 20,...
%                           'clicktype','Frequency',...
%                           'protocol', 'ProAnti3');
%
% or to load settings in your own subdirectory at
% \ratter\TrainingPipelines\PoissonClicks\experimenter_name
%
%   start_training_pipeline('K345','Chuck','PoissonClicks',...
%                           'experimenter',experimenter_name);
%
%Starter File:
%   A starter file is a settings file for the protocol the rat is to train
%   on with all the appropriate values saved. Experimenter and Ratname
%   fields are irrelevant as these are changed before the files is copied
%   to the appropriate folder. 
%
%   Starter files have the format Protocol_Starter_Descriptor.mat
%   For example, C:\ratter\TrainingPipelines\PoissonClicks\Frequency_20Hz\
%   ProAnti3_Starter_Frequency_20Hz.mat
%
%  or for your own starters:
%  \ratter\TrainingPipelines\PoissonClicks\Chuck\ProAnti3_Starter_Chuck.mat
%
%   Since the ProAnti3 protocol is now used in place of Classical a second
%   jump needs to be made.  That jump is coded in the Session Definition
%   end of day logic using the function jump_to_new_protocol. 
%
%   Example: jump_to_new_protocol('ProAnti3','PBups','PBups_starter');
%   This will jump the rat from ProAnti3 to PBups using a starter file with
%   "PBups_starter" in the file name located in the rat's settings folder
%   on bucket.
%
%   start_training_pipeline will copy the secondary starter file to the rat's
%   settings folder. This function assumes the secondary starter file is
%   any .mat file in the appropriate starter folder that does NOT have the
%   input protocol in its file name.  As good practice files should have 
%   the same name structure as the original starter file. So 
%   PBups_Starter_Frequency_20Hz.mat is paired with 
%   ProAnti3_Starter_Frequency_20Hz.mat
%
%Written by Chuck 2020. (Option for experimenter-specific start files added
%by Adrian 9/2020)

%make sure we're connected to bucket
if ~exist('X:\RATTER\SoloData\Settings','dir')
    map_bucket_drive
end

%Check inputs

tempdir = bSettings('get','GENERAL','Main_Code_Directory');
startdir = [tempdir(1:strfind(tempdir,'ExperPort')-1),'TrainingPipelines'];
pairs = {'frequency', 20;...
         'clicktype', 'Frequency';...
         'protocol',  'ProAnti3';...
         'pipeline_name', '' ;...
         'startdir',startdir};
parseargs(varargin, pairs);  

if ~exist(startdir,'dir')
    disp('ERROR: Unable to find Starter Files');
    return;
end

if numel(ratname) ~= 4 || isempty(str2num(ratname(2:4))) %#ok<ST2NM>
    disp('ERROR: ratname must be 1 letter followed by 3 digits')
    return;
end   


%Use inputs to determine which starter file to use
if strcmp(task,'PoissonClicks')
    if ~isempty(pipeline_name)
        startdir = fullfile(startdir,task,'Experimenters',pipeline_name);
        startfile = [protocol,'_Starter_',pipeline_name,'.mat'];
    else
        startdir = [startdir,'\',task,'\',clicktype,'_',num2str(frequency),'Hz\']; 
        startfile = [protocol,'_Starter_',clicktype,'_',num2str(frequency),'Hz.mat'];
    end
    
    %Other Tasks place code here to determine which starter file to use
end


%Load starter file and alter experimenter and ratname
if ~exist(fullfile(startdir,startfile),'file')
    disp(['ERROR: ',startdir,startfile,' does NOT EXIST']);
    return;
end
load(fullfile(startdir,startfile));

saved.SavingSection_experimenter = Experimenter;
saved.SavingSection_ratname      = ratname; %#ok<STRNU>

%Make directories if they don't yet exist
expdir = ['X:\RATTER\SoloData\Settings\',Experimenter,'\'];
if ~exist(expdir,'dir')
    disp(['Creating experimenter directory ',expdir]);
    mkdir(expdir);
end

ratdir = [expdir,ratname,'\'];
if ~exist(ratdir,'dir')
    disp(['Creating rat directory ',ratdir]);
    mkdir(ratdir);
end

%Determine which letter should be appended at the end of the settings file
%This will determine the highest letter appended to a file with today's
%date then go 2 higher (this is in case the rat is currently running which
%when ended and saved a settings file will be made with 1 letter higher)
x = dir(ratdir);
ltr = 'a';
for i = 1:numel(x)
    if numel(x(i).name) > 10 && strcmp(x(i).name(end-10:end-5),datestr(now,'yymmdd'))
        ltr(end+1) = x(i).name(end-4); %#ok<AGROW>
    end
end

LTR = max(ltr)+2;
if LTR > 122; LTR = 122; end

%Construct the settings file name and save it in the appropriate folder
fname = ['settings_@',protocol,'_',Experimenter,'_',ratname,'_',datestr(now,'yymmdd'),char(LTR),'.mat'];

disp(['Saving new settings file: ',ratdir,fname]);
save([ratdir,fname],'saved','saved_autoset','fig_position')


if strcmp(protocol,'ProAnti3')
    %If this is ProAnti3 we need to copy a secondary starter file
    %into the settings folder, this should be the other file in the
    %startdir folder
    
    %Determine which secondary starter file to use
    jumpfile = '';
    x = dir(startdir);
    for i = 1:numel(x)
        if numel(x(i).name) > 4 &&...
           strcmp(x(i).name(end-3:end),'.mat') &&...
           isempty(strfind(x(i).name,protocol))
       
            jumpfile = x(i).name;
        end
    end
    if isempty(jumpfile)
        disp('ERROR: no secondary starter file found')
        return;
    end
    
    %Look for existing starter files and change the string "Starter" to
    %"Deactive" in the file name. This will prevent them from being used
    %but preserve them in the rat's settings folder
    x = dir(ratdir);
    for i = 1:numel(x)
        spacers = find(x(i).name == '_');
        if numel(spacers) > 1
            for j = 1:numel(spacers)-1
                if strcmp(x(i).name(spacers(j)+1:spacers(j+1)-1),'Starter')
                    disp(['Renaming existing starter file: ',ratdir,x(i).name]);
                    newname = [x(i).name(1:spacers(j)),'Deactive',x(i).name(spacers(j+1):end)];
                    movefile([ratdir,filesep,x(i).name],[ratdir,filesep,newname]);
                    break    
                end
            end
        end
    end
    
    %Copy the secondary starter file to the rat's settings folder
    disp(['Copying new secondary starter file: ',ratdir,jumpfile]);
    copyfile([startdir,filesep,jumpfile],[ratdir,jumpfile]); 
end

disp('COMPLETE');


     

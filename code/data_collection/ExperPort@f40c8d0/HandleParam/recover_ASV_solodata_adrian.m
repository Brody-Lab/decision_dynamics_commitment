function datafile = recover_ASV_solodata(varargin)

%This function will reconstitute a SoloData Data file from the saved parts
%files located in an ASV subdirectory. The user will be prompted if they
%want to add and commit the newly saved file to CVS and if they want to
%delete the ASV folder.
%
% Optional Inputs:
%
%   'file_path'     default ''. If empty a file browser will open prompting 
%                   the user to select the ASV folder to recover the data 
%                   from. Supply the full ASV folder path to skip the file 
%                   browser.
%
%   'cvs_commit'    default []. User will be prompted with a question box
%                   if they want to commit the data file to cvs. Set to 1
%                   to skip the question box and is equivalent to 
%                   answering Yes. Set to 0 equivalent to answering No. If
%                   the rig is set to use bucket, setting this to 1 will
%                   upload the file to bucket.
%
%   'delete_ASV'    default []. User will be prompted with a question box 
%                   if they want to delete the ASV folder the data was
%                   recovered from. Set to 1 skips the question box and is
%                   equivalent to answering Yes. Set to 0 equivalent to
%                   answering No.
%
%   'session_commit'default []. User will be prompted with a question box
%                   if they want to commit the data to the sessions table.
%                   Set to 1 to skip the question box, equivalent to
%                   answering Yes. Set to 0 equivalent to answering No.
%               
% UPDATE: add_and_commit has been updated to use bucket if the use_bucket
% flag is set to 1 in settings_custom.conf file.  The question dialogue
% will be updated to reflect that setting.
%
%This file does NOT commit data to the sessions or any other MySQL tables.
%For that pass the output of this function datafile as the input to
%commit_datafile_session.
%
%datafile = recover_ASV_solodata('cvs_commit',1,'delete_ASV',0);
%commit_datafile_session(datafile);
%
% UPDATE: function will now call commit_datafile_session us the user sets
% the session_commit input flag to 1.
%
%datafile = recover_ASV_solodata('cvs_commit',1,'delete_ASV',0,'session_commit',1);
%
%written by Chuck  5/2017
%updated by Chuck  8/2017
%updated by Chuck 10/2018

pairs = { ...
    'file_path'      ,'' ; ...
    'cvs_commit'    ,[] ; ...
    'delete_ASV'    ,[] ; ...
    'session_commit',[];...
    }; 
parseargs(varargin, pairs);

if isempty(file_path)
    file_path = uigetdir('','Select the ASV folder you want to recover data from:');
end
if ~strcmp(file_path(end-3:end),'_ASV')
    disp('This is not an ASV folder');
    disp('NO DATA RECOVERED');
    return; 
end

cd(file_path)

u1 = dir(file_path);
saved_history_temp = [];
saved_history = [];

for i = 1:numel(u1)
    if u1(i).isdir == 1; continue; end
    disp(['Recovering file: ',u1(i).name,'...']);
    load(u1(i).name);
    if isempty(saved_history)
        disp('Folder does not contain files with saved_history variable');
        disp('NO DATA RECOVERED');
        return;
    end
    if isempty(saved_history_temp)
        saved_history_temp = saved_history; 
        f = fields(saved_history);
    
    else
        for j = 1:numel(f)
            n = numel(eval(['saved_history.',f{j},';']));
            if n > 1
                eval(['saved_history_temp.',f{j},'(end+1:end+n) = saved_history.',f{j},';']);
            end
        end
    end
end
saved_history = saved_history_temp;

disp('Data recovered');

lastfilesep = find(file_path == filesep,1,'last');    
ratdir = file_path(1:lastfilesep);  

cd(ratdir);

u2 = dir([file_path(1:end-4),'*.mat']);

ltr = 'abcdefghijklmnopqrstuvwxyz';
l = 0;
for i = 1:numel(u2)
    l(i) = strfind(ltr,u2(i).name(end-4));
end
nextltr = max(l)+1;
if nextltr > 26
    disp('Unable to save recovered data since a Z file already exists.');
    return;
end
newfile = [file_path(1:end-4),ltr(nextltr),'.mat'];

save(newfile,'saved','saved_history','saved_autoset','fig_position');
disp(['Data saved to file: ',newfile]);

usebucket = bSettings('get','RIGS','use_bucket');
if usebucket == 1
    queststring = 'Do you want to upload the file to Bucket?';
    questtitle  = 'Bucket Upload';
    errorstring = 'File FAILED to upload to Bucket';
    successstr  = 'File successfully uploaded to Bucket';
else
    queststring = 'Do you want to add and commit file to CVS?';
    questtitle  = 'CVS Commit';
    errorstring = 'File FAILED to commit to CVS';
    successstr  = 'File successfully committed to CVS';
end

answer1 = '';
if isempty(cvs_commit)
    answer1 = questdlg(queststring,questtitle,'Yes','No','No');
elseif cvs_commit == 0
    answer1 = 'No';
elseif cvs_commit == 1
    answer1 = 'Yes';
end

if strcmp(answer1,'Yes')
    try
        add_and_commit(newfile);
        disp(successstr);
    catch
        disp(errorstring);
        return;
    end
end

answer2 = '';
if isempty(delete_ASV)
    answer2 = questdlg('Do you want to DELETE the ASV folder?','Delete ASV','Yes','No','No');
elseif delete_ASV == 0
    answer2 = 'No';
elseif delete_ASV == 1
    answer2 = 'Yes';
end

if strcmp(answer2,'Yes')
    for i = 1:numel(u1);
        if u1(i).isdir == 0
            delete([file_path,filesep,u1(i).name]);
        end
    end
    rmdir(file_path);
    disp('ASV folder successfully deleted');
end

datafile = newfile;

answer3 = '';
if isempty(session_commit)
    answer3 = questdlg('Do you want to commit the data to the sessions table?','Commit Session','Yes','No','No');
elseif session_commit == 0
    answer3 = 'No';
elseif session_commit == 1
    answer3 = 'Yes';
end

if strcmp(answer3,'Yes')
    try
        commit_datafile_session(datafile);
    catch
        disp('Error commiting data file to sessions table');
    end
end


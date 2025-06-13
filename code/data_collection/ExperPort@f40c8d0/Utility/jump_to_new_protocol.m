function jump_to_new_protocol(curr_protocol,new_protocol,file)

%This function will rename an existing file in the rat's settings folder
%which contains the string input as "file" to be a settings file with
%tomorrows date for the protocol defined by "new_protocol".
%
%   curr_protocol -The protocol the rat is currently running on
%
%   new_protocol  -The protocol the rat is to switch to
%
%   file -A string to identify which file in the rat's settings folder
%         contains the settings for the new protocol. The new file's name
%         must contain the string input via the file variable.  Only one
%         file can exist in the settings folder containing that string. 
%
%   Example: A rat is currently running on the ProAnti3 protocol and the
%   experimenter wants them to transition to the PBups protocol.  This line
%   would appear in their "End of Day Logic" section in a training string
%   in Session Control
%
%   jump_to_new_protocol('ProAnti3','PBups','PBups_Starter');
%
%   If the file PBups_Starter_Classic_40Hz.mat exists in the folder it will
%   be loaded and resaved as
%   settings_@PBups_Experimenter_Ratname_YYMMDDb.mat where Experimenter and
%   Ratname are taken from the current protocol and the date YYMMDD is set
%   for tomorrow.
%
%   Another rat could have the file PBups_Starter_Classic_20Hz.mat in their
%   settings folder and the same call to jump_to_new_protocol will load the
%   20Hz file.
%
%   Written by Chuck 2019

obj = eval(curr_protocol);
[expmtr, rname]=SavingSection(obj, 'get_info');

try
    map_bucket_drive;
    pname = ['X:\RATTER\SoloData\Settings\',expmtr,'\',rname];
    x = dir([pname,'\*',file,'*.mat']);
    
    if numel(x) == 1
        load([pname,'\',x(1).name]);
        if exist('saved','var') && exist('saved_autoset','var') && exist('fig_position','var')
            saved.SavingSection_experimenter = expmtr;
            saved.SavingSection_ratname      = rname;
            
            newfile = ['settings_@',new_protocol,'_',expmtr,'_',rname,'_',datestr(now+1,'yymmdd'),'b.mat'];
            save([pname,'\',newfile],'saved','saved_autoset','fig_position');
            
        else
            disp('File does not contain the correct variables.');
            disp('Taking No Action');
        end
        
    elseif numel(x) == 0
        disp(['No starter file named: ',file]);
        disp('Taking No Action');
    elseif numel(x) > 1
        disp(['Multiple starter files named: ',file]);
        disp('Taking No Action');
    end
catch
    disp('Taking No Action');
end
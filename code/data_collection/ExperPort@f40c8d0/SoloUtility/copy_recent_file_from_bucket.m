function [err,msg] = copy_recent_file_from_bucket(pname,filetype,expname,ratname,varargin)

%This function takes a path as input and finds the most recent file within
%the corresponding path on bucket and copies it over.  The path must be in 
%the ratter folder on the local computer.  The corresponding path on bucket
%will be in the RATTER folder.  A valid file must be of the following format
%
% type_@protocol_experimenter_ratname_DateStringLetter.mat
%
%with a date that is not in the future.  The most recent file is the file
%with the closest date to now with the highest letter. All files that have
%the same date and letter that is considered most recent will be copied.
%
%Update 01-18-2021 you can now input an empty string for the path and
%simply state the 
%   filetype:   either Data or Settings
%   expname:    experimenter name
%   ratname:    rat name
%
%Chuck 2018

err = 0;
msg = '';

try
    map_bucket_drive;
    
    if nargin == 4
        bpath = ['X:\RATTER\SoloData\',filetype,'\',expname,'\',ratname,'\'];
        
        p = bSettings('get','GENERAL','Main_Data_Directory');
        pname = [p,'\',filetype,'\',expname,'\',ratname,'\'];
    else
        ratterpos = strfind(pname,'ratter');
        bpath = ['X:\RATTER\',pname(ratterpos+7:end),'\'];
    end
    
    if ~exist(bpath,'dir')
        %no such folder exists on bucket to copy a file from
        disp(bpath)
        disp('Directory does not exist...')
        disp('No file copied')
        return;
    end

    x = dir(bpath);
    dt = zeros(numel(x),1); dt(:) = nan;
    for i = 1:numel(x)
        if x(i).isdir == 1; continue; end

        [p,fname,ext] = fileparts(x(i).name); %#ok<ASGLU>
        if strcmp(ext,'.mat') == 0; continue; end

        uscorepos = find(fname=='_');
        if numel(uscorepos) ~= 4; continue; end
        if numel(fname) ~= uscorepos(4)+7; continue; end

        dtnum = datenum(fname(uscorepos(4)+1:end-1),'yymmdd');
        if dtnum > now; continue; end

        dt(i) = dtnum + ((lower(fname(end))+0)/200);
    end

    recent = find(dt == nanmax(dt));
    
    if nargin == 4
        p = bSettings('get','GENERAL','Main_Data_Directory');
        pexp = [p,'\',filetype,'\',expname];
        if ~exist(pexp,'dir')
            mkdir(p,expname);
        end
        if ~exist(pname,'dir')
            mkdir(pexp,ratname);
        end
    end
    
    for i = 1:numel(recent)
        if ~exist([pname,filesep,x(recent(i)).name],'file')
            copyfile([bpath,x(recent(i)).name],[pname,filesep,x(recent(i)).name],'f');
            disp(['copied file ',x(recent(i)).name]);
        end
    end
catch
    err = 1;
    msg = lasterr;
end
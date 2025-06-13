function filename = find_recent_file_local(filetype,expname,ratname)

%This function finds the most recent file in a folder, i.e. the file that
%is loaded by runrats. Valid files must be of the format
%
% type_@protocol_experimenter_ratname_DateStringLetter.mat
%
%with a date that is not in the future.  The most recent file is the file
%with the closest date to now with the highest letter. 
%
%   filetype:   either Data or Settings
%   expname:    experimenter name
%   ratname:    rat name
%
%Chuck 2022

filename = '';

solodata = bSettings('get','GENERAL','Main_Data_Directory');
if solodata(end) == filesep; solodata = solodata(1:end-1); end

p = [solodata,filesep,filetype,filesep,expname,filesep,ratname,filesep];

if exist(p,'dir')

    x = dir(p);
    dt = zeros(numel(x),1); dt(:) = nan;
    for i = 1:numel(x)
        if x(i).isdir == 1; continue; end

        [pname,fname,ext] = fileparts(x(i).name); %#ok<ASGLU>
        if strcmp(ext,'.mat') == 0; continue; end

        uscorepos = find(fname=='_');
        if numel(uscorepos) ~= 4; continue; end
        if numel(fname) ~= uscorepos(4)+7; continue; end

        dtnum = datenum(fname(uscorepos(4)+1:end-1),'yymmdd');
        if dtnum > now; continue; end

        dt(i) = dtnum + ((lower(fname(end))+0)/200);
    end

    recent = find(dt == nanmax(dt),1,'first');

    filename = [p,x(recent).name];
end

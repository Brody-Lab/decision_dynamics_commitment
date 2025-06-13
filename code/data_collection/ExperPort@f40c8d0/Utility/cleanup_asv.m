% cleanup_asv(ratname)
%
% Deletes local ASV (autosave) data files that have committed versions in
% the repository. The purpose of this code is to free up space on the local
% training rigs. Specifically, it seems that ASV files are not being
% properly deleted by save_soloparamvalues. This is likely due to an issue
% with Windows file locking.
%
%
% PARAMETERS:
% ----------
%
% experimenter     This will determine which directory gets cleaned up
% ratname          This will determine which directory gets cleaned up
%
% OPTIONAL PARAMETERS:
% --------------------
%
%
% EXAMPLE CALL:
% -------------
%
%   >> cleanup_asv('T011');
%



function cleanup_asv(experimenter, ratname)


Solo_datadir=bSettings('get','GENERAL','Main_Data_Directory');
if isnan(Solo_datadir)
    Solo_datadir=[pwd filesep '..' filesep 'SoloData'];
end
if Solo_datadir(end)~=filesep, Solo_datadir=[Solo_datadir filesep]; end;
data_dir = [Solo_datadir 'Data' filesep experimenter filesep ratname];
old_dir = pwd;
cd(data_dir);
asv_files = dir('*ASV.mat');
for i=1:numel(asv_files)
    data_file = [asv_files(i).name(1:end-8)];
    [s, w] = system(['cvs -q -n update ' data_file 'a.mat']);
    if ~strncmp(w,'cvs update: nothing known about',30)
        delete(asv_files(i).name);
    end
end

cd(old_dir);
return
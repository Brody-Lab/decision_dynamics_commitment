
found_orphan_file = 0;

if bSettings('get','RIGS','bpod') == 1
    bpodcom = bSettings('get','RIGS','bpodcom');
    Bpod(bpodcom);
end

newstartup;

datadir = bSettings('get','GENERAL','Main_Data_Directory');
datadir = [datadir,filesep,'Data'];
cd(datadir);

E = dir(pwd);
for i = 1:numel(E)
    if strcmp(E(i).name,'.') || strcmp(E(i).name,'..') || E(i).isdir==0 || strcmp(E(i).name,'CVS')
        continue; 
    end
    
    R = dir([datadir,filesep,E(i).name]);
    for j = 1:numel(R)
        if strcmp(R(j).name,'.') || strcmp(R(j).name,'..') || R(j).isdir==0 || strcmp(R(j).name,'CVS')
            continue; 
        end
        
        F = dir([datadir,filesep,E(i).name,filesep,R(j).name]);
        for k = 1:numel(F)
            if strcmp(F(k).name,'.') || strcmp(F(k).name,'..') || F(k).isdir==0 || strcmp(F(k).name,'CVS')
                continue; 
            end
        
            disp([datadir,filesep,E(i).name,filesep,R(j).name,filesep,F(k).name]);
            
            if ~isempty(strfind(F(k).name,'ASV'))
                %We found an ASV temp data directory.
                datafile_name = '';
                settingsfile_name = '';
                foundfile = 0;
                for m = 1:numel(F)
                    if F(m).isdir == 0 && ~isempty(strfind(F(m).name,F(k).name(1:end-4)))
                        %We found a file, but now let's see if it's a real
                        %data file or just a place holder made by
                        %check_rig_frozen.m
                        if F(m).bytes < 1e3
                            load([datadir,filesep,E(i).name,filesep,R(j).name,filesep,F(m).name])
                            if exist('x','var') && strcmp(x,'This is a place holder data file.')
                                foundfile = 0;
                                delete([datadir,filesep,E(i).name,filesep,R(j).name,filesep,F(m).name]);
                                datafile_name = [datadir,filesep,E(i).name,filesep,R(j).name,filesep,F(m).name];
                                settingsfile_name = convert_data_to_settings_file(datafile_name);
                                if exist(settingsfile_name,'file')
                                    %This was a placeholder made by check_rig_frozen and will be
                                    %overwritten by recover_ASV_solodata
                                    delete(settingsfile_name)
                                end
                            else
                                %doesn't contain a place holder variable
                                foundfile = 1;
                            end
                        else
                            %Too big to be a place holder file
                            foundfile = 1;
                        end
                    end
                end
                
                if foundfile == 0
                    datafile = recover_ASV_solodata('file_path',[datadir,filesep,E(i).name,filesep,R(j).name,filesep,F(k).name],...
                        'cvs_commit',1,'delete_ASV',1,'session_commit',1,'datafile_name',datafile_name,...
                        'settingsfile_name',settingsfile_name);
                    found_orphan_file = 1;
                    %commit_datafile_session(datafile);
                    return;
                end
            end
        end
    end
end
disp('COMPLETE');

return;

datafile = recover_ASV_solodata('cvs_commit',1,'delete_ASV',0);
newstartup;
commit_datafile_session(datafile);

function output = compare_local2cup_hash(Fname,Ename,Rname,local_hash,do_delete)

cupfile = ['X:\RATTER\Video\',Ename,'\',Rname,'\',Fname];
cuphash_file = ['X:\RATTER\Video\',Ename,'\',Rname,'\File_DataHash.mat'];

load(cuphash_file) %#ok<LOAD>

filepos = find(strcmp(local_datahash(:,1),Fname) == 1,1,'first'); %#ok<NODEF>
if isempty(filepos)
    output = nan;
else
    cup_hash = local_datahash{filepos,2};
    
    if strcmp(cup_hash,local_hash) == 1
        output = 1;
    else
        output = 0;
    end
end

if output == 0 && do_delete == 1
    %The has on cup didn't match and the instructions are to delete
    %keyboard
    %delete the video file on cup
    disp(['Cup File Hash Does Not Match Local File. Deleting: ',cupfile]);
    delete(cupfile)
    
    %store this info in a corrupted file list
    cupcorrupted_file = ['X:\RATTER\Video\',Ename,'\',Rname,'\Corrupted_Files_List.mat'];
    if ~exist(cupcorrupted_file,'file')
        corrupted_files_list = cell(0);
    else
        load(cupcorrupted_file); %#ok<LOAD>
    end
    corrupted_files_list{end+1} = cupfile;
    save(cupcorrupted_file,'corrupted_files_list')
    
    %remove the hash entry from the cup hash file
    local_datahash(filepos,:) = [];
    
    %save the cup hash file
    save(cuphash_file,'local_datahash');
    
    %We don't need to worry about recopying the file up, runrats will see
    %it's missing tomorrow and copy it up, then the cup hash scrip will see
    %a file with a missing hash and recompute it. Finally this check will
    %be run again to confirm all is okay.
    
end

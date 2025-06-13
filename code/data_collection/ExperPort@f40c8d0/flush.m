if bSettings('get','RIGS','bpod') == 1  
    EndBpod;
end
delete(get(0,'Children'));
hndls_to_delete = findobj(findall(0));
for ctr = 1:length(hndls_to_delete)
    try
        delete(hndls_to_delete(ctr));
    catch %#ok<CTCH>
    end
end
try
    % appears not to work with new MATLAB
    delete(timerfindall); 
catch
    disp('unable to delete timers');
end
    
close all;
clear all;
clear classes;
clear functions;
dbclear all;

%% Close all existing open serial objects
objlist = instrfind;
for ctr = 1:length(objlist)
    try
        fclose(objlist(ctr));
    catch %#ok<CTCH>
    end
    try
        delete(objlist(ctr));
    catch %#ok<CTCH>
    end
end

clear all;


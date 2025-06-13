function GCS_automation

%This function runs on the tech computer on the half of every hour via
%windows scheduled tasks.  Users can drop code into the hour slot when they
%want the code executed.  This function serves as a central hub to run
%scheduled tasks on each individual computer.  

H = str2num(datestr(now,'HH')); %#ok<ST2NM>

if     H == 0
%     try %#ok<TRYNC>
%         %Delete old video each night
%         code = ['system(''start matlab -r "cd(''''\ratter\RigScripts'''');',...
%             ' addpath(genpath(pwd)); delete_old_video; exit;"'');'];
%         GCS_send_automated_script(code);
%     end
    
elseif H == 1
    
elseif H == 2
    try %#ok<TRYNC>
        %Check for uncommitted files and orphaned ASV files
        code = ['system(''start matlab -r "cd(''''\ratter\ExperPort'''');',...
            'addpath(genpath(pwd)); checkdir_uncommitted_files; exit;"'');'];
        GCS_send_automated_script(code);
    end
    
elseif H == 3
    
elseif H == 4    
    
elseif H == 5    
    
elseif H == 6   
%     try %#ok<TRYNC>
%         %Morning switch to RunRats            
%         code = ['system(''taskkill /F /IM matlab.exe''); ',...
%                 'system(''start matlab -r "cd(''''\ratter\ExperPort''''); addpath(genpath(pwd)); remove_svn_from_path;',...
%                 'cd(bSettings(''''get'''',''''GENERAL'''',''''Protocols_Directory'''')); ',...
%                 'system(''''svn cleanup''''); system(''''svn update''''); ',...
%                 'cd(bSettings(''''get'''',''''GENERAL'''',''''Main_Code_Directory'''')); flush; ',...
%                 'system(''''svn cleanup''''); system(''''svn update''''); newstartup; runrats(''''init'''');"'');'];
%         GCS_send_automated_script(code);
%     end
    
elseif H == 7
    
elseif H == 8   
    
elseif H == 9    
 
elseif H == 10    
    
elseif H == 11   
    
elseif H == 12    
   
elseif H == 13  
    
elseif H == 14    
    
elseif H == 15    
    
elseif H == 16    
    
elseif H == 17    
    
elseif H == 18    
    
elseif H == 19    
    
elseif H == 20
 
elseif H == 21
    
elseif H == 22
    
elseif H == 23
    
end    

pause(10);
exit
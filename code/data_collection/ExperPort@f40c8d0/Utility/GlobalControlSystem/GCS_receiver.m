function GCS_receiver

%This function should run all the time on all rigs. A shortcut should be
%placed in the startup folder.  It's job is to detect commands from the
%Global Control System and execute them locally.  This includes starting
%RunRats, BCG, and rebooting the machine.
%
%Created by Chuck 2011

try
    %d = bSettings('get','GENERAL','Main_Code_Directory');
    cd('C:\ratter\ExperPort');
    newstartup;
    
    %Let's get the computers name
    hostname=get_network_info; % Actually the ip_address

    %Time to start an infinite loop
    while 1
        start = now;

        %Let's get any uncompleted jobs for this computer
        try
            [DT,JB,IN,MS,ID,CD] = bdata(['select dateval, job, initials, message, id, code from',...
            ' bdata.gcs where computer_name = "',hostname,'" and completed=0 order by id']);
        catch %#ok<CTCH>
            pause((30 - ((now-start)*3600*24)) + (rand(1) * 30));
            continue; 
        end

        %If we have a job let's deal with it, but we will only do the first one
        %on this pass if we have more than one
        if ~isempty(DT)
            disp('Found job');
            DT = DT{1};
            JB = JB{1};
            ID = ID(1);
            IN = IN{1};
            MS = MS{1};
            CD = CD{1};

            %only do the job if it's less than 3 minutes old
            if (now - datenum(DT,'yyyy-mm-dd HH:MM:SS')) * 24 * 60 < 3
                try %#ok<TRYNC>

                    if GCS_checkcode(CD,DT,JB,ID) == 1
                        %The code is good, this means the user entered the
                        %correct password when adding the global command

                        if strcmp(JB,'runrats')
                            %To restart RunRats let's kill all matlabs and start a new
                            %one that loads RunRats
                            system('taskkill /F /IM matlab.exe')
                            system(['start matlab -r "cd(''\ratter\Protocols'');',...
                                'system(''svn cleanup''); system(''svn update'');',...
                                'cd(''\ratter\ExperPort''); flush; system(''svn cleanup'');',...
                                'system(''svn update''); newstartup; runrats(''init'');"']);
                        
                        elseif strcmp(JB,'monitoroff')
                            try
                                system('nircmd monitor off');
                            end
                            
                        elseif strcmp(JB,'monitoron')
                            try
                                system('nircmd monitor on');
                            end
                            
                        elseif strcmp(JB,'time')
                            if numel(MS >= 22);
                                system(['date ',MS(1:10)]);
                                system(['time ',MS(12:22)]);
                            end
                            
                        elseif strcmp(JB,'bcg')
                            %To start BCG let's kill all matlabs and start a new one
                            %that runs BCG
                            system('taskkill /F /IM matlab.exe')
                            system(['start matlab -r "cd(''\ratter\ExperPort'');',...
                                'flush; cd(''\ratter\bcg''); system(''cvs update -d -P -A'');',...
                                'addpath(genpath(''\ratter\bcg'')); start_multi_bcg;"']);

                        elseif strcmp(JB,'reboot')
                            %Force system reboot, kill all functions, and have a 1
                            %second timer
                            system('shutdown -r -f -t 1');

                        elseif strcmp(JB,'message')
                            %Let's start an instance of MatLab and have it display
                            %the message contained in jobid ID

                            name = bdata(['select experimenter, initials from ratinfo.contacts where initials="',IN,'"']);
                            if isempty(name); name{1} = ''; end
                            system(['start matlab -nosplash -minimize -nodesktop -r "cd(''\ratter\ExperPort'');'...
                                ' addpath(genpath(pwd)); GCS_Message({''',name{1},''',[',MS','],',num2str(ID),'});"'])

                        elseif strcmp(JB,'update')
                            %We need to start an instance of matlab, kill the
                            %GCS_receiver, clean and update the folders, then
                            %restart GCS_receiver

                            system(['start matlab -r "system(''taskkill /F /IM GCS_Receiver.exe'');',...
                                ' cd(''\ratter\ExperPort'');  system(''svn cleanup''); system(''svn update'');',...
                                ' cd(''\ratter\Protocols'');  system(''svn cleanup''); system(''svn update'');',...
                                ' cd(''\ratter\bcg'');        system(''cvs update -d -P -A'');',...
                                ' cd(''\ratter\RigScripts''); system(''cvs update -d -P -A'');',...
                                ' cd(''\ratter\ExperPort\Utility\GlobalControlSystem\GCS_receiver_compiled\distrib'');',...
                                ' winopen(''GCS_receiver_woCMD.exe'');',...
                                ' exit;"']);   

                        elseif strcmp(JB,'run')
                            %Here we are going to evaluate whatever string of code
                            %the user entered.  

                            try %#ok<TRYNC>
                                eval(char(str2num(char(MS')))); %#ok<ST2NM>
                            end

                        end
                    end
                end
            end

            %Now that the job is done, let's mark it as complete
            bdata('call bdata.mark_gcs_complete("{Si}")',ID);
        else
            disp('No jobs found...');
        end

        %Let's add a pause that ensures we run 1 cycle between 30 and 60
        %seconds, we add the rand to ensure computers don't sync up
        pause((30 - ((now-start)*3600*24)) + (rand(1) * 30));
    end

catch %#ok<CTCH>
    %Email me any errors
    senderror_report
end
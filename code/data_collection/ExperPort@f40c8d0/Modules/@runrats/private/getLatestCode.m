function getLatestCode

olddir=cd;
try

    dd=bSettings('get','GENERAL','Main_Code_Directory');

    if isnan(dd)
        dd=cd;
    end
    
    if dd(end)~=filesep
        dd(end+1)=filesep;
    end
    

    cd(dd);

	system('svn cleanup');% Added by Praveen 01/21/2011 to remove svn locks
    system('svn up');% Added by Praveen 01/21/2011 to update ExperPort
    cvsup('.');
    
    % <~> New code, 2008.Sep.04; svn updates the external Protocols
    %       directory if that exists.
    %     SUCH a hack right now. I don't care. I'm tired.%
    if exist([dd '..' filesep 'Protocols'],'dir'),
        try
            cd([dd '..' filesep 'Protocols']);
            if ispc
            system('\ratter\svn\bin\svn up');
            system('svn cleanup');% Added by Praveen 01/21/2011 to remove svn locks
            system('svn up'); % Sundeep Tuteja, 12th October, 2009:
                              % Since the new installer sets up svn as a
                              % program which is present in the path
                              % directory, svn up should work for windows
                              % machines too. SVN need not be set up in the
                              % ratter/svn folder
            else
                system('svn cleanup');% Added by Praveen 01/21/2011 to remove svn locks
                system('svn up');
            end
        catch
        end;
        cd(dd);
        
    end;
    
catch
end
cd(olddir)
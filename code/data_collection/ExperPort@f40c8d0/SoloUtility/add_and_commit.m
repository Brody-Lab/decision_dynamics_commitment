%     SoloUtility/add_and_commit.m
%     adds data files to cvs repository; BControl system;
%
%
%     [errID errmsg] = add_and_commit(fname)
%
%     Given a file,
%       tries to cvs add and then cvs commit that file
%
%       after adding the file's parent directory to CVS if necessary.
%
%
%     The repository to connect to is determined by a setting called
%       CVSROOT_STRING. If this setting is blank, cvs calls are not
%       performed.
%
%     To employ this feature, set CVSROOT_STRING in the settings file
%       Settings/Settings_Custom.conf. Instructions are provided there.
%
%     NOTES:
%       - fname may include a path, or a relative path.
%       - .mat files are always added as BINARY files (i.e. with -kb flag)
%       - Other files are handled as ASCII/BINARY based on cvs local and
%           repository settings.
%       - CVS messages are printed to the command window.
%
%     RETURN VALUES:
%       errID       
%                   0  if either:
%                        - CVS add&commit commands used (?successfully?)
%                        - CVSROOT_STRING setting empty; returned early.
%                   2  if the file does not exist (locally)
%                   8  if the file's parent directory doesn't seem to be
%                           in CVS, and adding the parent directory's
%                           parent directory failed....
%                   16 if seemingly impossible CVS failures occur
%                           (Contact developer.)
%                   32 if the CVSROOT_STRING setting exists but is not a
%                           string (e.g. is numeric)
%       errmsg      '' if cvs command is executed, else diagnostic message
%
%     SAMPLE CALLS:
%       add_and_commit('/ratter/SoloData/ASmith/MrRat.mat');
%       [err] = add_and_commit('somefile.txt');
%       [errID errmsg] = add_and_commit([filesep .. filesep 'SoloData' ...
%           filesep 'watering_notes.txt']);
%
%
% 2018-10-09 plan is to move CVS data and settings file to PNI bucket. This
% function can be called the same but if the CVSROOT_STRING is empty and
% REPOSITORY USE_BUCKET is set to 1 that is where the data will go.

function [errID,errmsg] = add_and_commit(fname,overwrite,varargin)
errID = -1; errmsg = '';
errorlocation = 'WARNING in SoloUtility/add_and_commit.m';

nl = sprintf('\n'); %     more convenient form for newline character

usebucket = bSettings('get','RIGS','use_bucket');
if usebucket == 1
    %New add and commit code to send to bucket
    
    if nargin < 1
        errID = 0;
        errmsg = 'no file specified'; 
        warning(errmsg);
        return;
    end
    
    if nargin < 2
        overwrite = 0;
    end
        
    map_bucket_drive;
    
    [pname,fname,ext] = fileparts(fname);
    fname = [fname,ext];
    
    if isempty(pname)
        pname = pwd;
    end
    
    if ~exist([pname,filesep,fname],'file')
        errID = 0;
        errmsg = ['file ',pname,filesep,fname,' does not exist']; 
        warning(errmsg);
        return;
    end
        
    ratterpos = strfind(pname,'ratter');
    if isempty(ratterpos)
        errID = 1;
        errmsg = 'file paths must be in the ratter folder'; 
        warning(errmsg);
        return;
    end
    
    bpath = ['X:\RATTER\',pname(ratterpos+7:end),'\'];
    if ~exist(bpath,'dir')
        try
            mkdir(bpath);
        catch
            errID = 2;
            errmsg = 'unable to make file path on bucket';
            warning(errmsg);
            return;
        end
    end
    
    if ~exist([bpath,fname],'file') || overwrite == 1
        try
            copyfile([pname,filesep,fname],[bpath,fname],'f');
            disp('file successfully copied to bucket');
        catch
            errID = 3;
            errmsg = 'unable to copy the file to bucket';
            warning(errmsg);
            return;
        end
    else
        errID = 4;
        errmsg = 'file exists on bucket and overwrite was set to 0';
        warning(errmsg);
        return;
    end
    
else
    %old add and commit code sending files to cvs. 
    %why are you using this. boooooo
    
    %     Generate an error if we have n args where n~=1.
    error(nargchk(1, 1, nargin, 'struct'));

    %     -------------------------------------------------------------
    %     -------  FETCH CVSROOT_STRING SETTING
    %     -------------------------------------------------------------
    %     ... so that we know where to send the file.
    [croot errID_i errmsg_i] = bSettings('get','CVS','CVSROOT_STRING');

    %     If the setting does not exist, is blank, is NaN, or is "NULL", we try
    %       for the cvsroot_string global instead.
    if errID_i,
        errID = 0;
        errmsg = [errorlocation ':' nl 'Attempt to' ...
            ' retrieve the setting CVS;CVSROOT_STRING failed. Behavioral' nl...
            'data/settings files will not be sent to a central' nl...
            'repository.' nl...
            'bSettings(''get'',''CVS'',''CVSROOT_STRING'') call returned' ...
            ' errID ' int2str(errID_i) nl ' and message: "' errmsg_i '".'];
        warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
        return;
    elseif isempty(croot) || strcmpi(croot,'NULL'),
        errID = 0;
        errmsg = [errorlocation ':' nl ...
            'The CVSROOT_STRING setting is empty.' nl ...
            'Saved behavioral data and settings files will not be sent' nl ...
            'to any data repository.' nl nl...
            'IF YOU WISH TO EMPLOY THIS FEATURE,' nl ...
            'please set CVSROOT_STRING in the custom settings file' nl ...
            'Settings/Settings_Custom.conf. Instructions are available' nl ...
            'there. If you are running the old RPbox-based system and' nl ...
            'Settings_Custom.conf does not exist, copy' nl ...
            'Settings_Template.conf to Settings_Custom.conf and then' nl ...
            'try again.'];
        warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
        return;
    elseif ~ischar(croot),
        errID = 32;
        errmsg = [errorlocation ': The CVSROOT_STRING setting was not a' ...
            ' string! It was: ' num2str(croot) '. CVS calls will not be' ...
            ' made.'];
        warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
        return;
    end;

    %     Otherwise, we at least have a string.


    %     -------------------------------------------------------------
    %     -------  ADD PARENT DIRECTORY, THEN FILE
    %     -------------------------------------------------------------

    if ~exist(fname, 'file'),
        errID = 2;
        errmsg = [errorlocation ': ADD&COMMIT CANCELLED. Filename "' fname ...
            '" not found.'];
        error(errmsg);
        return;
    end;

    %     Break filename up.
    [path, fname, ext]  = fileparts(fname); fname = [fname ext];

    %     Save dir we're in so we can return afterwards.
    currdir = pwd;


    try
        %     Move to file's parent directory if it is specified.
        if ~isempty(path), cd(path); end;

        %     Try adding the file's parent directory to cvs
        %       (harmless if it's already there).
        [pathtoparent, myparent] = fileparts(pwd);
        if ~isempty(pathtoparent) && ~isempty(myparent),

            cd(pathtoparent); % to gp (absolute) from p

            [s,w] = system(['cvs -d ' croot ' add -- ' myparent]);
            fprintf(1, w);

            %     If add failed, then either:
            %       1.The directory already exists in CVS or
            %       2.The directory does not exist in CVS and neither does its
            %           parent directory (i.e. there is no CVS information in
            %           the containing directory).
            %     In Case 1, cvs log will return 0 and we're fine.
            %     In Case 2, cvs log will return 1 (the directory is not in
            %          CVS), and we should try adding that directory's parent
            %          directory first.
            if s==1,
                [s,w] = system(['cvs -d ' croot ' log -- ' myparent]);
                if s==1,
                    %     Try adding parent's parent.
                    [pathtomygrandparent, mygrandparent] = fileparts(pwd);
                    if ~strcmp(pwd,pathtoparent),
                        cd(currdir); %     Go back first.
                        error('Programming error: code has been changed and assumption is false. Contact a developer.');
                        %return;
                    end;
                    if ~isempty(pathtomygrandparent) && ~isempty(mygrandparent),
                        cd(pathtomygrandparent); % to ggp (absolute) from gp
                        [s,w] = system(['cvs -d ' croot ' add -- ' mygrandparent]);
                        fprintf(1, w);
                        if s==1,
                            cd(currdir); %     Go back first.
                            errID = 8;
                            errmsg = [errorlocation ':' nl 'ADD&COMMIT' ...
                                ' CANCELLED. Sorry.' nl 'The dir' ...
                                ' containing the file specified does not' nl...
                                'seem to be in CVS but attempts to add' nl...
                                'it to CVS failed. An attempt to add the' nl...
                                'directory housing that directory also' nl...
                                'failed. Please make sure that your' nl...
                                'CVSROOT_STRING setting is correct, and' nl...
                                'that *some* directory 2-3 levels up' nl...
                                'from the file you are trying to add is' nl...
                                'in CVS....'];
                            warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
                            return;
                        else
                            %     Otherwise, grandparent directory add worked,
                            %       and now we need to try adding parent again.
                            cd(mygrandparent); % to gp from ggp

                            [s,w] = system(['cvs -d ' croot ' add -- ' myparent]);
                            fprintf(1, w);
                            if s==1,
                                cd(currdir); %     Go back first.
                                errID = 16;
                                errmsg = [errorlocation ':' nl 'ADD&COMMIT' ...
                                    ' CANCELLED. Sorry.' nl 'Something'...
                                    ' is wrong with this code, unless' nl...
                                    'your directory structure is' nl...
                                    'changing as we try to commit it to' nl...
                                    'CVS. Try again, and if this happens' nl...
                                    'again, contact a developer.'];
                                warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
                                return;
                            end; %end if parent add failed after grandparent add succeeded
                            %     Otherwise, we're good to continue.
                        end;    %end if-else grandparent add succeeded
                    end;        %end if      great grandparent string is not empty
                end;            %end if      parent is not in cvs (cvs log failed)
            end;                %end if      parent add failed the first time

            %     At this point, either:
            %       - Parent dir added (and grandparent added if necessary)
            %       - Parent dir already in CVS (add failed but log succeeded)
            %       - Parent dir add failed and grandparent is empty string
            %           (i.e. DNE, i.e. parent dir is root?).

            %     We now move back to file's parent directory and add the file.
            cd(myparent); % to p from gp
        end;                    %end if     grandparent string is not empty

        % Finally, add the file itself to CVS:
        if strcmp(ext, '.mat'), [s_add, w] = system(['cvs -d ' croot ' add -kb -- ' fname]);
        else                    [s_add, w] = system(['cvs -d ' croot ' add     -- ' fname]);
        end;
        fprintf(1, w);

        % Now commit:
        [s_commit, w] = system(['cvs -d ' croot ' commit -m "auto_commit by SoloUtility/add_and_commit" -- ' fname]);
        fprintf(1, w);
    catch
        cd(currdir); %     paranoid addition
    end;

    cd(currdir);

    if s_add~=0 || s_commit~=0,
        errID = 1;
        errmsg = [errorlocation ': Sorry. Either add or commit of file failed.'];
        warning(errmsg); %#ok<WNTAG> (Ignore meaningless Matlab warning about this line.)
    else
        errID = 0;  % both add and commit returned 0, so we should be okay
    end;
end

return;

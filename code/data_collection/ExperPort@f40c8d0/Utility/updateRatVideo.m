%     Download video files for a particular rat between the given dates.
%
%     Arguments:
%
%       strVideoDir      e.g. /ratter/ExperPort    (/ or \ as appropriate)
%       strExp           e.g. Carlos
%       strRat           e.g. C015           
%       strDateFrom      e.g. 20080301             (yyyymmdd)
%       strDateTo        e.g. 20080309
%
%       The arguments are strings that should exactly match the format used
%         in the saving of the video files.
%
function [errID errmsg] = updateRatVideo(strVideoDir, strExp, strRat, strDateFrom, strDateTo)

errID = 0;
errmsg = '';

%     CONSTANTS
strCVSUP            = 'cvs up -d -P -A';
strCVSADD           = 'cvs add';
strFileExtension    = '.mp4';
%strVideoDir         = [filesep 'ratter' filesep 'Video'];
%strCVSSTAT          = 'cvs status';


%     (sample full filename: Carlos_C015_20080301.mp4
strFilenameBase     = [strExp '_' strRat '_'];


% % % %     This is the regular expression we'll use to pick filenames out of
% % % %       what is displayed by the cvs status call. We require a newline,
% % % %       space, linebreak, or tab character after 'mp4' or 'avi' so as to
% % % %       exclude the listings of the ',v' repository versions of the files.
% % % %       (e.g. include Carlos_C015_20080301.mp4   and
% % % %             exclude Carlos_C015_20080301.mp4,v )
% % % %       We later use strtrim to remove this whitespace character included.
% % % strRegExpr          = [strExp '_' strRat '_[0123456789]*\.(mp4|avi)[ \n\b\t]'];

strCurDir           = pwd; %     Note current directory so that we can go back to it after script is done.

if ~exist(strVideoDir,'dir'),
    warning(['Video directory (' strVideoDir ') does not exist. Please check it out before running this script. Aborting.']); %#ok<WNTAG>
    cd(strCurDir);
end;

cd(strVideoDir);

if ~exist([pwd filesep strExp],'dir'),
    mkdir(strExp);
end;
[status output]     = system([strCVSADD ' ' strExp]); display(output);
cd(strExp);

if ~exist([pwd filesep strRat],'dir'),
    mkdir(strRat);
end;
[status output]     = system([strCVSADD ' ' strRat]); display(output);
cd(strRat);

dFrom       = str2double(strDateFrom);
dTo         = str2double(strDateTo);

dFrom_D     =        dFrom                    ; %     e.g. 20071225
dFrom_M     = floor( dFrom  /   100 ) *   100 ; %     e.g. 20071200
dFrom_Y     = floor( dFrom  / 10000 ) * 10000 ; %     e.g. 20070000

dTo_D       =        dTo                      ; %     e.g. 20080201
dTo_M       = floor( dTo    /   100 ) *   100 ; %     e.g. 20080200
dTo_Y       = floor( dTo    / 10000 ) * 10000 ; %     e.g. 20080000

for     y   = dFrom_Y:10000:dTo_Y,

    mStart  =  100 + y;
    mEnd    = 1200 + y;
    if y == dFrom_Y, mStart = dFrom_M; end; %     if it's the first month to be included, start at the from date
    if y == dTo_Y  , mEnd   = dTo_M  ; end; %     if it's the last  month to be included, stop  at the to   date
    
    for     m  = mStart:100:mEnd,

        dStart  =  1 + m;
        dEnd    = 31 + m;
        if m == dFrom_M, dStart = dFrom_D; end; %     if it's the first month to be included, start at the from date
        if m == dTo_M  , dEnd   = dTo_D  ; end; %     if it's the last  month to be included, stop  at the to   date

        for d   = dStart:dEnd,
            
            [status output] = system([strCVSUP ' ' strFilenameBase int2str(d) strFileExtension]);
            if status,
                warning(['updateRatVideo warning: cvs update call (file: ' strFilenameBase int2str(d) strFileExtension ') failed. Status: ' int2str(status) '. Result: ' output]); %#ok<WNTAG>
            else
                display(output);
            end; %     end if else error in cvs up call

        end;     %     end for all included days in the month
    end; %     end for all included months in the year
end; %     end for all included years

% % % %     Grab the cvs statuses for this rat (this directory) so that we can
% % % %       determine what files are available.
% % % [status output]     = system(strCVSSTAT);
% % % if status,
% % %     warning(['updateRatVideo warning: cvs status call failed. Returning. Status: ' int2str(status) '. Result: ' output]); %#ok<WNTAG>
% % %     cd(strCurDir);
% % %     return;
% % % end;
% % % 
% % % 
% % % %     Fetch all filenames from the cvs status output using regular
% % % %       expression matching.
% % % [trash trash trash strFilenames] = regexp(output,strRegExpr); %#ok<NASGU>
% % % strFilenames = strtrim(strFilenames); %     Remove the extra whitespace character included in each.
% % % 
% % % 
% % % %     For each filename returned (available on cvs), determine whether or
% % % %       not its date falls between the from and two dates, and download
% % % %       that file if so.
% % % for i=1:length(strFilenames),
% % %     strTemp                         = strFilenames{i};
% % %     [trash trash trash dateTemp]    = regexp(strTemp,'[0123456789]{8}'); %     exactly 8 digits
% % %     if      str2double(dateTemp{1}) >= str2double(strDateFrom) && ...
% % %             str2double(dateTemp{1}) <= str2double(strDateTo)   ,
% % %         
% % %         [status output] = system([strCVSUP ' ' strTemp]);
% % %         
% % %         if status,
% % %             warning(['updateRatVideo warning: cvs update call (file: ' strTemp ') failed. Status: ' int2str(s) '. Result: ' output]); %#ok<WNTAG>
% % %         else
% % %             display(output);
% % %         end; %     end if else error in cvs up call
% % %         
% % %     end;     %     end if date matches
% % %     
% % % end; %     end for each video filename in cvs status


cd(strCurDir); %     Return to the directory we were in before updating.

end %     End of function updateRatVideo





% 
% %     Download video file for a particular rat and a particular date.
% %
% %     Arguments:
% %
% %       strExp      e.g. Carlos
% %       strRat      e.g. C015           
% %       strDate     e.g. 20080301       yyyymmdd
% %
% %       The arguments are strings that should exactly match the format used
% %         in the saving of the video files.
% %
% function [errID errmsg] = updateRatVideo1(strExp, strRat, strDate);
% 
% errID = 0;
% errmsg = '';
% 
% %     CONSTANTS
% strVideoDir        = [filesep 'ratter' filesep 'Video'];
% 
% 
% strFilename         = [strExp '_' strRat '_' strDate '.mp4'];
% 
% cd(strVideoDir);
% 
% cd(strExp);
% cd(strRat);
% 
% [s m] = system(['cvs up -d -P -A ' strFilename]);
% 
% if s,
%     warning(['updateRatVideo warning: cvs update call failed. Status: ' int2str(s) '. Result: ' m]); %#ok<WNTAG>
% end;
% 
% display(m);
% 
% cd(strCurDir);
% 
% end %     End of function updateRatVideo

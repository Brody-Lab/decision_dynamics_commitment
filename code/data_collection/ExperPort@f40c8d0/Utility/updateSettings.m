% <~> Sebastien Awwad
%     Update settings files for a given rat.
%
%     example calls:
%       updateSettings('Lucy','L013');      %     Lucy's rat L013
%       updateSettings('Lucy','_all');      %     all of Lucy's rats
function [errID errmsg] = updateSettings(experimenter,ratname) %#ok<INUSL>

errID = -1; errmsg = ''; %#ok<NASGU>

if nargin~=2 || ~ischar(experimenter) || ~ischar(ratname) || isempty(experimenter) || isempty(ratname),
    errID = 1; errmsg = 'updateSettings expects two arguments: experimenter name, and rat name.'; %#ok<NASGU>
    warning(errmsg); %#ok<WNTAG>
    return;
end;
    
dirCurrent  = cd;
[dirData errtmp] = bSettings('get','GENERAL','Main_Data_Directory');
if errtmp || ~ischar(dirData) || isempty(dirData), dirData = [dirCurrent filesep '..' filesep 'SoloData']; end;
dirSettings = [dirData      filesep     'Settings'];
dirExp      = [dirSettings  filesep     experimenter];
dirRat      = [dirExp       filesep     ratname];

if      ~exist(dirData,'dir'), error('Please check out the SoloData project before trying to update rat settings.'); end;
cd(dirData);
if ~exist(dirSettings,'dir'),
    mkdir('Settings');
    system('cvs add Settings');
end;
cd(dirSettings);
if ~exist(dirExp,'dir');
    mkdir(experimenter);
    system(['cvs add ' experimenter]);
end;
cd(dirExp);

%     If ratname is '_all', we stay in the experimenter's main directory
%       and update all rats, else we step into the specific rat's dir.
if ~strcmpi(ratname,'_all'),
    if ~exist(dirRat,'dir');
        mkdir(ratname);
        system(['cvs add ' ratname]);
    end;
    cd(dirRat);
end; %     end if 

system('cvs up -d -P -A');

cd(dirCurrent);

errID = 0;

end %     end function

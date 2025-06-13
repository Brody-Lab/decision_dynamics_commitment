% Startup file for hybrid Exper/Solo system.
%
% A typical opening command sequence would be
%
%    >> mystartup; ModuleInit('control'); ModuleInit('rpbox');
%
% after which one would select a protocol from the 'protocols' menu in
% the rpbox window.
%
%
%     

% Exper's repository of all variables:
global exper;           

% Variable that determines what kind of Real-Time State Machine, and
% what kind of sound machine, are to be run:
%
%  fake_rp_box = 0    -->   Use the TDT RM1 boxes   
%  fake_rp_box = 1    -->   Use FakeRP/@lunghao1 and FakeRP/@lunghao2
%                           objects as virtual machines
%  fake_rp_box = 2    -->   Use the RT Linux state machine
%  fake_rp_box = 3    -->   Use the Modules/@SoftSMMarkII and
%                           Modules/@softsound objects as virtual
%                           machines. These are recommended over the
%                           old @lunghao1 and @lunghao2
%  fake_rp_box = 4    -->   Use the Modules/@softsm and
%                           Modules/@softsound objects as virtual
%                           machines. @softsm has no scheduled waves.

global fake_rp_box;     


%     The following variable is overridden by the CVSROOT_SETTING in the
%       Settings/Settings_Custom.conf file if that is nonempty.
%     PLEASE SET IT THERE INSTEAD OF MODIFYING THIS STARTUP FILE.
%
%     cvsroot_string is used to tell cvs how to connect to the data
%       repository when submitting files (e.g. behavioral data or settings)
%       via SoloUtility/add_and_commit.m, which is generally called when
%       data/settings are saved. It is automatically set below based on
%       hostname FOR CERTAIN HOSTNAMES.
%
%     If both this and the setting are blank, cvs calls are skipped.
%
global cvsroot_string;
       cvsroot_string = '';

% Now variables that say which are the digital outs for 
% left water and right water; these are slightly different
% in the new rigs as compared to the old RM1-based rigs
global center1water;
global center1led;
global left1water;
global left1led;
global right1water;
global right1led;

global center2water;
global center2led;
global left2water;
global left2led;
global right2water;
global right2led;

%     moved up
global state_machine_server;
global sound_machine_server;
%     end moved

% The following global is ONLY relevant when NOT using the RT Linux sound
% server. 
% When using the virtual sound machine this variable determines whether
% sounds are played or not. Sometimes sounds are not played with the
% precise timing of the RT Linux server; turning them off permits
% examining the timing of states in better detail.  
global softsound_play_sounds;
% To NOT play sounds:
% softsound_play_sounds = 0; %     changed from typo
% To play sounds as normal:
softsound_play_sounds = 1; %     changed from softsound_playsounds (typo)

% The time needed by the pump to inject a unit of water (ontime) and for
% the piston to recover (offtime). These values have been determined by 
% trial and error, to minimise total delivery time without damaging the 
% pump.
global pump_ontime;
global pump_offtime;
pump_ontime = 0.150;
pump_offtime = 0.10;

% Need some proper auto-config method...
global sound_sample_rate;  sound_sample_rate = 50e6/1024;
%     note that this is redefined below for rtlinux rigs

% Put get_hostname.m in the path, and use that to try to get the hostname.
% That file has a few tricks to avoid errors on different systems.
addpath([pwd filesep 'SoloUtility']);
hostname = get_hostname;



if ismember(hostname, {'krasko' 'kostra'}),
   fake_rp_box = 0;

elseif strmatch('brodyrigxp',hostname)
    %     The call just above to strmatch returns a 1 iff* the hostname
    %     BEGINS WITH the given strings. In such cases, we are running on
    %     an experimental rig communicating with a real-time rig that
    %     controls a real experimental rat box of the latest make, and we
    %     should note that and set the servers (e.g. brodyrigrt01), taking
    %     the number directly from the hostname of this machine.
    fake_rp_box = 2;
    state_machine_server = ['brodyrigrt' hostname(11:end)];
    sound_machine_server = state_machine_server;
    %     Assign rig group (username for cvs, etc.)
    cvsroot_string = ':ext:brodylab@brodylab.princeton.edu/cvs';
    
elseif strmatch('cnmc',hostname)
    fake_rp_box = 2;
    state_machine_server = ['rtlinuxrig' hostname(5:end)];
    sound_machine_server = state_machine_server;
%     cvsroot_string = ''; %What value shall we put here, CSHL people?
    
elseif strcmp('saturn',hostname)
    fake_rp_box = 2;
    
else
    fake_rp_box = 3; % force SoftSMMarkII to be the fake rp box
end;



% If we are using the RTLinux servers:
if fake_rp_box == 2,

    %     No longer needed:
    %    % Where are our RT Linux State Machine and our RT Linux Sound Machine?
    % %   global state_machine_server;
    % %   global sound_machine_server;
    %
    %    switch hostname
    %        case 'cnmc1'
    %            sound_machine_server = 'rtlinuxrig1';
    %            state_machine_server = 'rtlinuxrig1';
    %        case 'cnmc2'
    %            sound_machine_server = 'rtlinuxrig2';
    %            state_machine_server = 'rtlinuxrig2';
    %        case 'cnmc3'
    %            sound_machine_server = 'rtlinuxrig3';
    %            state_machine_server = 'rtlinuxrig3';
    %        case 'cnmc4'
    %            sound_machine_server = 'rtlinuxrig4';
    %            state_machine_server = 'rtlinuxrig4';
    %        case 'cnmc5'
    %            sound_machine_server = 'rtlinuxrig5';
    %            state_machine_server = 'rtlinuxrig5';
    %        case 'cnmc6'
    %            sound_machine_server = 'rtlinuxrig6';
    %            state_machine_server = 'rtlinuxrig6';
    %        case 'cnmc7'
    %            sound_machine_server = 'rtlinuxrig7';
    %            state_machine_server = 'rtlinuxrig7';
    % %            sound_machine_server = '143.48.30.39';
    % %            state_machine_server = '143.48.30.39';
    %        case 'cnmc8'
    %           sound_machine_server = 'rtlinuxrig8';
    %           state_machine_server = 'rtlinuxrig8';
    %        otherwise,
    %            sound_machine_server = 'arany';
    %            state_machine_server = 'arany';
    %    end;
    %     end no longer needed

   % Where's the water?
   center1water = 2^0;
   center1led   = 2^1;
   left1water   = 2^2;
   left1led     = 2^3; 
   right1water  = 2^4;
   right1led    = 2^5;
   
   center2water = 2^6;
   center2led   = 2^7;
   left2water   = 2^8;
   left2led     = 2^9; 
   right2water  = 2^10;
   right2led    = 2^11;
   

   % for now, rtlinux machines use 200kHz always
   sound_sample_rate = 200000;
   	
else  % --- Not using RT Linux servers
%<<<<<<< mystartup.m
%   left1water = 1; right1water = 2;left2water = 3;right2water = 4;
%=======
   left1water   = 1; 
   right1water  = 2;
   % The following are fake:
   left1led     = 4;
   center1led   = 8;
   right1led    = 16;
%>>>>>>> 1.32
end;



% Variable used to determine whether chunks of code should be run
% within try/catch structures. For example, a piece of code that does
% only analysis, and therefore reads variables but sets absolutely no
% variables relevant to further behavior, could be run in this way, so
% that if by any chance it crashes, it doesn't crash the rest of the
% protocol. Typical use might be:
%   if Solo_Try_Catch_flag, 
%      try, analysis; catch, warning('analysis failed!'); lasterr; end;
%   else analysis;
%   end;
%
% During deployment, this flag should be set to "1". For debugging, you
% can set it to "0."
%   
global Solo_Try_Catch_Flag;
Solo_Try_Catch_Flag = 1;

% Indicate root directory for the code distribution:
global Solo_rootdir;
Solo_rootdir = pwd;


% Indicate root directory for the data:
global Solo_datadir;
Solo_datadir = [pwd filesep '..' filesep 'SoloData'];
if ~exist(Solo_datadir, 'dir'),
   success = mkdir(Solo_datadir);
   if ~success, error(['Couldn''t make directory ' Solo_datadir]); end;
end;



addpath(pwd);
addpath(['.' filesep 'Plugins']);
addpath([pwd filesep 'Utility']);
addpath([pwd filesep 'Modules']);
addpath([pwd filesep 'Modules' filesep 'NetClient']);
addpath([pwd filesep 'Modules' filesep 'SoundTrigClient']);
addpath([pwd filesep 'Modules' filesep 'TCPClient']);
addpath([pwd filesep 'Protocols']);
addpath([pwd filesep 'soundtools']);
addpath([pwd filesep 'FakeRP']);
addpath([pwd filesep 'Analysis']);
%addpath([pwd filesep 'Analysis' filesep 'Event_Analysis']);
addpath([pwd filesep 'Analysis' filesep 'duration_disc']);
%addpath([pwd filesep 'Analysis' filesep 'duration_disc' filesep 'Event_Analysis']);
addpath([pwd filesep 'Analysis' filesep 'duration_disc' filesep 'dual_disc']);
addpath([pwd filesep 'HandleParam']);
addpath([pwd filesep 'UiClasses']);
addpath([pwd filesep 'bin']);
addpath([pwd filesep 'Protocols' filesep 'NewParamTester'])
addpath([pwd filesep 'Protocols' filesep 'SigmoidSamp7'])

% Old Exper-related hack
setpref('carlos', 'control_datapath', [pwd filesep 'data'])

dbstop if error

% Exper ran mixing lower and upper case function names, something that
% causes a warning in Matlab 7. In addition, exper often assigned
% structure elements to something not yet defined as a structure, which
% also causes a warning (and will cause an error in future Matlab
% releases).
warning('off','MATLAB:dispatcher:InexactMatch');
warning('off','MATLAB:warn_r14_stucture_assignment');

% To start the system off, run these commands after mystartup.m:
%    >> ModuleInit('control'); ModuleInit('rpbox');
%

% Names of protocols built using protocolobj
global Super_Protocols;
Super_Protocols = {'duration_discobj','dual_discobj'};

% 


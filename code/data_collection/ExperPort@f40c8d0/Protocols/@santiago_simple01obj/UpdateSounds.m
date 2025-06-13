% This function updates the sounds and sends them to the sound
% server.
%
% Santiago Jaramillo - 2007.05.18

function UpdateSounds(obj)

GetSoloFunctionArgs; % See PROTOCOLNAMEobj.m for the list of
                     % variables passed to this function.
    

% --- Send sounds to sound server ---
SoundServer = rpbox('getsoundmachine');
fprintf('Loading sounds to sound server...\n');
LoadSound(SoundServer, 1, value(GoSignalWave), 'left', 3, 0);
LoadSound(SoundServer, 2, value(GoSignalWave), 'right', 3, 0);

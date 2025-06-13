function sync_video(sessid, fldr, force)
% function sync_video(sessid, fldr, force)
% 
% this function is intended to process and send video tracker info to the
% sql db for sessions where the phys data has already been synced using
% sync_nlx_fsm


olddir = pwd;
if ~exist('fldr','var')
	fldr=uigetdir('Please select a folder to process.');
end

if nargin<3
    force=0;
end
nofldr=1;
while nofldr
    try
        if fldr==0 % then they cancelled
            return
        end

    cd(fldr)
    nofldr=0;
    catch
        fldr=uigetfolder('Please select a folder to process.');
    end
end

%% get sync fit
[m b] = bdata('select sync_fit_m,sync_fit_b from phys_sess where sessid="{Si}"',sessid);

%% sync video tracker
if isempty(m) || isempty(b),
    error('SYNCVIDEO:unsyncedsession', 'session %d does not to have phys session synced', sessid);
    cd(olddir);
    return;
else
    try
        err = process_video(sessid, fldr, [m b], force);
    catch
		showerror(lasterror);
    end;
end;


cd(olddir);
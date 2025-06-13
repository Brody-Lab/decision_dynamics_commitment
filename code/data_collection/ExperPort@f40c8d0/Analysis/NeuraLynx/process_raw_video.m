function err = process_raw_video(sessid, fldr, r1, force)
% This function will save the raw thresholded points info to the DB.
%
% written March 2011, Jeff Erlich

if nargin<3
    force=0;
end

%% check if the video has already have been processed
already_done=bdata('select count(sessid) from raw_tracking where sessid="{Si}"',sessid);

if already_done>0
    fprintf(2,'Session %i video tracking already processed\n', sessid);
    if force
        fprintf(2,'Reprocessing video tracking for session %i. Replacing old entries\n', sessid);
    else
        fprintf(2,'No changes are made to video tracking for session %i.\n', sessid);
        err=3;
        return;
    end
    
end


%% extract and process tracked data
olddir = pwd;
cd(fldr);

aa = VT2Mat('ExtractMode', 'all', 'in_this_dir', 1,'FieldSelection',[1 0 0 0 0 0]);
Targets=zeros(numel(aa),50,numel(aa(1).TimeStamps),'uint32');

if numel(aa(1).TimeStamps)<500000
    tmp = VT2Mat('ExtractMode', 'all', 'in_this_dir', 1,'FieldSelection',[0 0 0 0 1 0]);
    for xx=1:numel(aa)
        Targets(xx,:,:)=tmp(xx).Targets;
    end
    clear tmp;
else
    
    num_steps=ceil(numel(aa(1).TimeStamps)/500000);
    for nx=1:num_steps
        tstart=(1+(nx-1)*500000);
        tend=nx*500000;
        tend=min(numel(aa(1).TimeStamps),tend);
        tmp = VT2Mat('ExtractMode', 'index range', 'in_this_dir', 1,'FieldSelection',[0 0 0 0 1 0],'ModeArray',[tstart-1 tend-1]);
        for xx=1:numel(aa)
            Targets(xx,:,tstart:tend)=tmp(xx).Targets;
        end
        clear tmp;
        
    end
end

% cc = VT2Mat('ExtractMode', 'all', 'in_this_dir', 1,'FieldSelection',[0 0 0 0 0 1]);

for x=1:numel(aa)
    
    aa(x).TimeStamps = aa(x).TimeStamps*r1(1)+r1(2);
    aa(x).Targets=squeeze(Targets(x,:,:));
    
    
    
end
clear Targets;

%% insert into DB
try
    if ~already_done,
        bdata('insert into raw_tracking (sessid,data) values ("{Si}","{M}")', sessid, aa);
    elseif force,
        mym(bdata, 'update raw_tracking set data="{M}" where sessid="{Si}"',  aa, sessid);
    end;
    err = 0;
catch
    showerror(lasterror);
    err = 2;
end;

cd(olddir);
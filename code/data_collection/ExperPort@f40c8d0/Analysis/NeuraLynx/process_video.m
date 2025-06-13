function err = process_video(sessid, fldr, r1, force)
% This function will save the relevant head info to the DB.
%
% written May 2009, BWB

if nargin<3
	force=0;
end

%% check if the video has already have been processed
already_done=bdata('select count(sessid) from tracking where sessid="{Si}"',sessid);

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
err=0;
aa = VT2Mat('ExtractMode', 'all', 'in_this_dir', 1);
if numel(aa)==1
% I think there are problems with smooth_trajectory, so we are going to
% skip it for now.  we'll re-write this code soon -Jeff 2011-03-31
    % [aa.X aa.Y aa.Theta error] = smooth_trajectory(aa.X, aa.Y, aa.Theta); 
else
      
    [aa err] = combine_trackers(aa); 

    %    [aa.X aa.Y aa.Theta error] = smooth_trajectory(aa.X, aa.Y, aa.Theta); 

end


% error = 1 indicates that we have only one led visible for most of the
% session, so that no smoothing was possible
% if ~error,
% 	aa.Theta = stitch_theta(aa.Theta); % is this sensible?  We need to check
%     end;

aa.TimeStamps = aa.TimeStamps*r1(1)+r1(2);
fr=round(1/median(diff(aa.TimeStamps)));
    filt_length=round(fr/10)*2+1;
    new_theta=medfilt1(aa.Theta,filt_length);

%% insert into DB
try
    if ~already_done,
    	bdata('insert into tracking (sessid, ts, x, y, theta,proc_theta, header, error_code) values ("{Si}","{M}","{M}","{M}","{M}","{M}","{M}","{Si}")', sessid, aa.TimeStamps, aa.X, aa.Y, aa.Theta,new_theta, aa.Header, err);
    elseif force,
        mym(bdata, 'update tracking set ts="{M}", x="{M}", y="{M}", theta="{M}",proc_theta="{M}", header="{M}", error_code="{S}" where sessid="{Si}"', aa.TimeStamps, aa.X, aa.Y, aa.Theta,new_theta, aa.Header, err);
    end;
 %   fix_bad_ts_in_tracking(sessid, 1);
    err = 0;
catch me
	showerror(me);
	err = 2;
end;

cd(olddir);
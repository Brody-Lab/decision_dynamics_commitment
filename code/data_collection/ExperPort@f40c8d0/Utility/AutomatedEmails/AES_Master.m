function AES_Master

%Update repos before running code
try update_folder(bSettings('get','GENERAL','Main_Code_Directory'));  end %#ok<TRYNC>
try update_folder(bSettings('get','GENERAL','Protocols_Directory'));  end %#ok<TRYNC>
try update_folder(bSettings('get','GENERAL','Bpod_Code_Directory'));  end %#ok<TRYNC>
try update_folder(bSettings('get','GENERAL','Rigscripts_Directory')); end %#ok<TRYNC>

rng('shuffle','twister');

HR = str2num(datestr(now,'HH')); %#ok<ST2NM>
if     HR == 0 %functions to run between 12AM  and 1AM
    try %#ok<TRYNC>
        registry_backup;
    end
    try %#ok<TRYNC>
        schedule_backup;
    end
    try %#ok<TRYNC>
        copy_schedule_tomorrow;
    end
    try %#ok<TRYNC>
        cleanup_removecheckhematuria;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        archive_old_video(1);
    end
    
elseif HR == 1  %functions to run between 1AM  and 2AM
    try %#ok<TRYNC>
        BDay;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    try %#ok<TRYNC>
        bdata('call update_bdata_sess_agg')
    end
    
elseif HR == 2  %functions to run between 2AM  and 3AM 
    try %#ok<TRYNC>
        populate_tech_schedule_new_payperiod
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 3  %functions to run between 3AM  and 4AM 
    try  %#ok<TRYNC>
        checktrainproblems3(now-1);
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 4  %functions to run between 4AM  and 5AM     
    try %#ok<TRYNC>
        cleanup_longterm_reserved;
    end
    try %#ok<TRYNC>
        auto_place_rats_back_on_training;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 5  %functions to run between 5AM  and 6AM     
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %system('shutdown -r -f -t 1');
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 6  %functions to run between 6AM  and 7AM
    try  %#ok<TRYNC>
        check_sched_reg_problems;       
    end 
    try %#ok<TRYNC>
        copy_schedule_tomorrow;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 7  %functions to run between 7AM  and 8AM 
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 8  %functions to run between 8AM  and 9AM
    try  %#ok<TRYNC>
        checknoratsrun(1:3,1:2);
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
		notify_rig_repair;
    end
    
elseif HR == 9  %functions to run between 9AM  and 10AM
    try %#ok<TRYNC>
        check_tomorrow_schedule_exists;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 10 %functions to run between 10AM and 11AM
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 11 %functions to run between 11AM and 12PM
    try  %#ok<TRYNC>
        checknoratsrun(1:3,1:2);
    end
    try  %#ok<TRYNC>
        checknoratsrun(1:3,1:3,0); %Mice 
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 12 %functions to run between 12PM and 1PM 
    try %#ok<TRYNC>
        text_tech_schedule_change(datestr(now+1,'yyyy-mm-dd'));
    end
    try %#ok<TRYNC>
        copy_schedule_tomorrow;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        archive_old_video(1);
    end
    
elseif HR == 13 %functions to run between 1PM  and 2PM    
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 14 %functions to run between 2PM  and 3PM  
    try  %#ok<TRYNC>
        checknoratsrun(4:6,3:4);      
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 15 %functions to run between 3PM  and 4PM 
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try  %#ok<TRYNC>
        checknoratsrun(4:6,4:6,0); %Mice 
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 16 %functions to run between 4PM  and 5PM 
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 17 %functions to run between 5PM  and 6PM
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        check_mouseroom_confirmed_empty('techs');
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 18 %functions to run between 6PM  and 7PM
    try %#ok<TRYNC>
        copy_schedule_tomorrow;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        check_mouseroom_confirmed_empty('all');
    end
    
elseif HR == 19 %functions to run between 7PM  and 8PM    
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 20 %functions to run between 8PM  and 9PM
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 21 %functions to run between 9PM   and 10PM
    try  %#ok<TRYNC>
        checknoratsrun(7:9,5:8); 
    end 
    try  %#ok<TRYNC>
        checknoratsrun(7:9,7:9,0); %Mice 
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    try %#ok<TRYNC>
        %archive_old_video(1); %auto delete yes
        check_video_hash
    end
    
elseif HR == 22 %functions to run between 10PM  and 11PM    
    try %#ok<TRYNC>
        generate_test_technotes;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
elseif HR == 23 %functions to run between 11PM and MIDNIGHT
    try  %#ok<TRYNC>
        checkratweights(0,0,1); %rats    
    end 
    try  %#ok<TRYNC>
        checkratweights(0,0,0); %mice    
    end 
    try  %#ok<TRYNC>
        checkratweights(0,1,1); %extreme weight drop email to Chuck, rats   
    end 
    try  %#ok<TRYNC>
        checkratweights(0,1,0); %extreme weight drop email to Chuck, mice   
    end 
    try  %#ok<TRYNC>
        if strcmp(datestr(now,'ddd'),'Sun')
            check_rat_exceptions;
            check_rat_exceptions('extreme');
        end
    end
	try %#ok<ALIGN,TRYNC>
		check_rat_performace;
    end
    try %#ok<TRYNC>
		announce_rigbroken;
    end
    try %#ok<TRYNC>
        remove_longterm_recovery;
    end
    try %#ok<TRYNC>
        WM_carryover;
    end
    try %#ok<TRYNC>
        cleanup_removefromfreewater;
    end
    try %#ok<TRYNC>
        check_shift_running_long;
    end
    
end

pause(10);
exit;
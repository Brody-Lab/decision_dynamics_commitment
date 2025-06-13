% Performance Meister Script | Run by AES on Tech Computer
% Copyright Praveen | Programmer | HHMI | Feb. 2011
function checkPerformance

try
	min_session_duration_threshold=60; %in minutes
	rat_history_max=60; % in days
	rat_history_min=15; % in days
	rig_trials_deviation_threshold=2; % zscore
	rat_trials_deviation_threshold=3;
	rig_bias_deviation_threshold=2;
	rat_bias_deviation_threshold=3;	
	date_shift=0;
	weights_history=7;
	pres_stat=sprintf('Running for date shift=%d',date_shift);
	disp(pres_stat);

	%setpref('Internet','SMTP_Server','brodyfs2.princeton.edu');
	%setpref('Internet','E_mail',['PerformanceMeister',datestr(now,'yymm'),'@princeton.edu']);
    set_email_sender
    
	sqlstr=sprintf('select distinct hostname,sessiondate from bdata.sessions where datediff(curdate(),sessiondate)=%d and ratname<>"" and ratname is not null and floor(time_to_sec(timediff(endtime,starttime)))/60>%d and hostname<>"Rig05" and hostname<>"Rig06" order by hostname',date_shift,min_session_duration_threshold); % select all rigs each having at least one valid session
	[hostname,sessiondate]=bdata(sqlstr);
	sessiondate=cell2mat(unique(sessiondate));
	all_contacts=bdata('select email from ratinfo.contacts where is_alumni=0');
	subscribers=bdata('select distinct email from ratinfo.contacts where subscribe_all=1 and is_alumni=0');
	comp_techs=bdata('select distinct email from ratinfo.contacts where tech_computer=1 and is_alumni=0');
	problem_rats=struct('hostname',{},'message',{},'owners',{},'tech',{});
	problem_rigs=struct('hostname',{},'message',{},'owners',{},'tech',{});
	problem_rat_counter=0;
	problem_rig_counter=0;
	for i=1:length(hostname) % Recurse through all rigs of the present day
		k=0;l=0;
		sqlstr=sprintf('select distinct ratname from bdata.sessions where hostname="%s" and char_length(ratname)<5 and ratname<>"" and ratname is not null and length(ratname)=4 and datediff(curdate(),sessiondate)=%d order by starttime',hostname{i},date_shift); % select rats with a valid name from each rig
		ratname=bdata(sqlstr);
		ar=cell2mat(ratname);
		total_rats_in_rig=size(ar,1);
		all_rats_in_rig='';
		for hh=1:total_rats_in_rig
			if ~isempty(all_rats_in_rig)
				all_rats_in_rig=sprintf('%s,%s',all_rats_in_rig,ar(hh,:));
			else
				all_rats_in_rig=sprintf('%s',ar(hh,:));
			end
		end
		%min_problem_rats_in_rig=ceil(total_rats_in_rig/2);
		min_problem_rats_in_rig=2;
		all_rats_in_rig=strtrim(all_rats_in_rig);
		rig_id=str2num(hostname{i}(end-1:end));
		sqlstr=sprintf('select max(dateval) from calibration_info_tbl where rig_id=%d and datediff(curdate(),dateval)>=%d',rig_id,date_shift);
		last_calibration=bdata(sqlstr);
		trial_deviation_rats={};
		bias_deviation_rats={};
		rig_mailing_list=struct('owners',[],'tech',[]);
		all_owners_rig=[];
		problem_rat_owners_rig=[];
		problem_rig_flag=0;
		for j=1:length(ratname) % Recurse through rats of each rig
			% Grab all contacts for the current rat: START
			rat_owners=bdata(['select contact from ratinfo.rats where ratname="',ratname{j},'"']);
			rat_owners_raw=rat_owners;
			sqlstr=sprintf('select tech from ratinfo.mass where ratname="%s" and datediff(curdate(),date)=%d',ratname{j},date_shift);
			rat_tech_initials=bdata(sqlstr);
			temp=regexp(rat_owners,'\,','split');
			sqlstr='select email from ratinfo.contacts where email like ';
			for ij=1:size(temp{1},2)
				if ij<size(temp{1},2)
					sqlstr=[sqlstr, '"%',strtrim(char(temp{1}(ij))),'%" or email like '];
				else
					sqlstr=[sqlstr, '"%',strtrim(char(temp{1}(ij))),'%"']; %Nook<*AGROW>
				end
			end		
			sqlstr=[sqlstr ' and is_alumni=0'];
			rat_owners=bdata(sqlstr); %Nook<*NBRAK>
			rat_tech=bdata(['select email from ratinfo.contacts where initials="',char(rat_tech_initials),'"']);
			% Grab all contacts for the current rat: STOP
			all_owners_rig=[all_owners_rig;rat_owners];
			rig_mailing_list.owners=unique([rig_mailing_list.owners;rat_owners]);
			rig_mailing_list.tech=unique([rig_mailing_list.tech;rat_tech]);
			
			sqlstr=sprintf('select n_done_trials,protocol,floor(time_to_sec(timediff(endtime,starttime))/60) as session_length from bdata.sessions where ratname="%s" and datediff(curdate(),sessiondate)=%d and floor(time_to_sec(timediff(endtime,starttime)))/60>%d and hostname<>"Rig05" and hostname<>"Rig06"',ratname{j},date_shift,min_session_duration_threshold);
			%select trials of current rat for a valid session on the chosen date		
			[n_done_trials current_protocol current_session_length]= bdata(sqlstr);
			problem_rat_flag=0;
			problem_rat_in_rig_flag=0;
			if(~isempty(n_done_trials) && ~isempty(current_protocol)) % Start performance check only if the session is valid
				sqlstr=sprintf('select n_done_trials,left_correct,right_correct,(left_correct-right_correct) as bias from bdata.sessions where ratname="%s" and datediff(curdate(),sessiondate)>=%d and datediff(curdate(),sessiondate)<=%d and  floor(time_to_sec(timediff(endtime,starttime)))/60>%d and protocol="%s" order by sessiondate desc',ratname{j},date_shift,date_shift+rat_history_max,min_session_duration_threshold,char(current_protocol));
				[n_done_trials,left_correct,right_correct,bias] = bdata(sqlstr);
				
				rat_header_email_msg='';
				rat_trials_email_mssg='';
				rat_bias_email_mssg='';			
				
				% Grab the session ID of the current rat
				sqlstr=sprintf('select timeslot from ratinfo.schedule where ratname="%s" and datediff(curdate(),date)=%d',ratname{j},date_shift);
				rat_session_id=bdata(sqlstr);
				rat_trials_issue_string='';
				rat_bias_issue_string='';
				% Performance check for number of trials: START
				if ((length(n_done_trials)>rat_history_min))
					trials_to_check=n_done_trials(2:end);
					rat_trial_deviations=abs(zscore(trials_to_check));
					trials_to_compare=trials_to_check(rat_trial_deviations<rat_trials_deviation_threshold); %filter out anomalies to create preferred data set
					
					if length(trials_to_compare)>rat_history_min %check if length of data set comprising the number of trials is still big enough to compare
						trials_to_compare(end+1)=n_done_trials(1); %insert the current session's trials at the end of the preferred data set
						rat_trials_past_avg=floor(mean(trials_to_compare));
						rat_final_score=zscore(trials_to_compare); %calculate zscores on preferred data set
						if rat_final_score(end)<0; trial_string='Few Trials'; else trial_string='Too many trials'; end
						
						%Rat Performance check: START
						if(abs(rat_final_score(end))>rat_trials_deviation_threshold) %compare with threshold and send rat performance email
							problem_rat_flag=1;
							rat_trials_email_mssg=sprintf('\t[%s] => Avg Trials: %d | zscore: %.2f\n',trial_string,rat_trials_past_avg,rat_final_score(end));						
							if strcmpi(trial_string,'Few Trials')
								rat_trials_issue_string='FT';
							elseif strcmpi(trial_string,'Too many Trials')
								rat_trials_issue_string='TT';
							end						
						end
						%Rat Performance check: STOP
						%Rig Performance check: START
						if(abs(rat_final_score(end))>rig_trials_deviation_threshold && rat_final_score(end)<0) %compare with threshold
							k=k+1;
							problem_rat_in_rig_flag=1;
							trial_deviation_rats(k,:)={ratname{j},rat_session_id,current_session_length,trial_string,n_done_trials(1),rat_trials_past_avg,rat_final_score(end)};						
						end
						%Rig Performance check: STOP
					end
				end			
				% Performance check for number of trials: STOP
				
				% Performance check for biases: START
				if ((length(bias)>rat_history_min)) % Check only if sufficient history and bias is available
					bias_to_check=bias(2:end);
					rat_bias_deviations=zscore(bias_to_check);
					bias_to_compare=bias_to_check(rat_bias_deviations<rat_bias_deviation_threshold); %filter out anomalies to create preferred data set
					
					if length(bias_to_compare)>rat_history_min %check if length of data set comprising the number of bias is still big enough to compare
						bias_to_compare(end+1)=bias(1); %insert the current session's bias at the end of the preferred data set
						rat_bias_past_avg=mean(bias_to_compare);
						rat_final_score=zscore(bias_to_compare); %calculate zscores on absolute values of preferred data set
						bias_flag=0;bias_type='Left Bias';
						if rat_final_score(end)<0
							bias_flag=1; bias_type='Right Bias';
						end
						
						%Rat Performance check: START
						if abs(rat_final_score(end))>rat_bias_deviation_threshold %compare with threshold and send out a rat performance email
							problem_rat_flag=1;
							rat_bias_email_mssg=[sprintf('\t[%s] => L/R: %.2f/%.2f | Bias: %.2f | Avg: %.2f | zscore: %.2f\n',bias_type,left_correct(1),right_correct(1),bias(1),rat_bias_past_avg,rat_final_score(end))];						
							if bias_flag==0
								rat_bias_issue_string='LB';
							elseif bias_flag==1
								rat_bias_issue_string='RB';
							end						
						end
						%Rat Performance check: STOP
						%Rig Performance check: START
						if abs(rat_final_score(end))>rig_bias_deviation_threshold %compare with threshold
							l=l+1;
							problem_rat_in_rig_flag=1;
							bias_deviation_rats(l,:)={ratname{j},rat_session_id,current_session_length,left_correct(1),right_correct(1),bias(1),bias_flag,rat_bias_past_avg,rat_final_score(end),n_done_trials(1)};						
						end
						%Rig Performance check: STOP
					end
				end
				% Performance check for biases: STOP
			end
			if problem_rat_flag==1			
				sqlstr=sprintf('select mass from ratinfo.mass where ratname="%s" and datediff(curdate(),date)>=%d and datediff(curdate(),date)<=%d order by date asc',ratname{j},date_shift,date_shift+weights_history);
				rat_weights=strtrim(sprintf('%d  ', bdata(sqlstr)));
				rat_weights=sprintf('\tWeights in last %d days:  %s\n',weights_history,rat_weights);
				problem_rat_counter=problem_rat_counter+1;
				problem_rats(problem_rat_counter).hostname=hostname{i};			
				rat_header_email_msg=sprintf('Rat: %s  %s   Slot: %d   Dur: %d mins.   #Trials: %d\n',ratname{j},hostname{i},rat_session_id,current_session_length,n_done_trials(1));
				problem_rats(problem_rat_counter).message=[rat_header_email_msg,rat_trials_email_mssg,rat_bias_email_mssg,rat_weights];
				problem_rats(problem_rat_counter).owners=rat_owners;
				problem_rats(problem_rat_counter).tech=rat_tech;
				%Post the individual rat issues to ratinfo.schedule and performance_issues.rat_issues tables: START
				sqlstr=sprintf('call ratinfo.update_rat_perf("%s","%s","%s",%d)',ratname{j},rat_trials_issue_string,rat_bias_issue_string,date_shift);				
				bdata(sqlstr);
				sqlstr=sprintf('insert into performance_issues.rat_issues (ratname,rigID,slot,date,trials_issue,bias_issue,rat_owner) values ("%s","%s",%d,"%s","%s","%s","%s")',ratname{j},hostname{i},rat_session_id,sessiondate,rat_trials_issue_string,rat_bias_issue_string,cell2mat(rat_owners_raw));
				bdata(sqlstr);
				%Post the individual rat issues to ratinfo.schedule and performance_issues.rat_issues tables: STOP
			end
			if problem_rat_in_rig_flag==1			
				problem_rat_owners_rig=[problem_rat_owners_rig;rat_owners];
			end
		end
		% pror=unique(problem_rat_owners_rig);
		% problem_rat_owners_rig_filtered='';
		% tot_problem_rat_owners_rig=size(pror,1);
		% for hh=1:tot_problem_rat_owners_rig
			% if ~isempty(problem_rat_owners_rig_filtered)
				% problem_rat_owners_rig_filtered=sprintf('%s,%s',problem_rat_owners_rig_filtered,cell2mat(pror(hh,:)));
			% else
				% problem_rat_owners_rig_filtered=sprintf('%s',cell2mat(pror(hh,:)));
			% end
		% end
		
		rig_trials_email_mssg=[];
		rig_bias_email_mssg=[];
		ft_rats='';
		tt_rats='';
		lb_rats='';
		rb_rats='';
		if(k>=min_problem_rats_in_rig)
			problem_rig_flag=1;
			rig_trials_email_mssg=sprintf('\t{ No of trials Issues }\n');
			for jj=1:k			
				rig_trials_email_mssg=[rig_trials_email_mssg,sprintf('\tRat: %s   Slot: %d   Dur: %d mins.   # Trials: %d\n\t\t[%s] => Avg trials: %d | zscore: %.2f\n',char(trial_deviation_rats(jj,1)),cell2num(trial_deviation_rats(jj,2)),cell2num(trial_deviation_rats(jj,3)),cell2num(trial_deviation_rats(jj,5)),char(trial_deviation_rats(jj,4)),cell2num(trial_deviation_rats(jj,6)),cell2num(trial_deviation_rats(jj,7)))];
				%Post the rig trials issue of this rat to ratinfo.schedule table: START
				rig_trials_issue_string='';
				if strcmpi(char(trial_deviation_rats(jj,4)),'Few Trials')
					rig_trials_issue_string='FT';
					if ~isempty(ft_rats)
						ft_rats=sprintf('%s,%s',ft_rats,char(trial_deviation_rats(jj,1)));
					else
						ft_rats=sprintf('%s',char(trial_deviation_rats(jj,1)));
					end
				elseif strcmpi(char(trial_deviation_rats(jj,4)),'Too many Trials')
					rig_trials_issue_string='TT';
					if ~isempty(tt_rats)
						tt_rats=sprintf('%s,%s',tt_rats,char(trial_deviation_rats(jj,1)));
					else
						tt_rats=sprintf('%s',char(trial_deviation_rats(jj,1)));
					end
				end
				sqlstr=sprintf('call ratinfo.update_rat_perf("%s","%s","",%d)',char(trial_deviation_rats(jj,1)),rig_trials_issue_string,date_shift);
				bdata(sqlstr);
				%Post the rig trials issue of this rat to ratinfo.schedule table: STOP
			end			
			rig_trials_email_mssg=[rig_trials_email_mssg sprintf('\n')];
		end
		
		if(l>=min_problem_rats_in_rig)
			problem_rig_flag=1;
			rig_bias_email_mssg=sprintf('\t{ Bias Issues }\n');			
			for jj=1:l
				bias_type='Left Bias';
				rig_bias_issue_string='LB';
				if cell2num(bias_deviation_rats(jj,9))<0; bias_type='Right Bias'; rig_bias_issue_string='RB'; end
				if strcmpi(rig_bias_issue_string,'LB')
					if ~isempty(lb_rats)
						lb_rats=sprintf('%s,%s',lb_rats,char(bias_deviation_rats(jj,1)));
					else
						lb_rats=sprintf('%s',char(bias_deviation_rats(jj,1)));
					end
				elseif strcmpi(rig_bias_issue_string,'RB')
					if ~isempty(rb_rats)
						rb_rats=sprintf('%s,%s',rb_rats,char(bias_deviation_rats(jj,1)));
					else
						rb_rats=sprintf('%s',char(bias_deviation_rats(jj,1)));
					end
				end
				rig_bias_email_mssg=[rig_bias_email_mssg,sprintf('\tRat: %s   Slot: %d   Dur: %d mins.   L/R: %.2f/%.2f   #Trials: %d\n\t\t[%s] => Bias: %.2f | Avg Bias: %.2f |  zscore: %.2f\n',char(bias_deviation_rats(jj,1)),cell2num(bias_deviation_rats(jj,2)),cell2num(bias_deviation_rats(jj,3)),cell2num(bias_deviation_rats(jj,4)),cell2num(bias_deviation_rats(jj,5)),cell2num(bias_deviation_rats(jj,10)),bias_type,cell2num(bias_deviation_rats(jj,6)),cell2num(bias_deviation_rats(jj,8)),cell2num(bias_deviation_rats(jj,9)))];
				%Post the rig bias issue of this rat to ratinfo.schedule table: START
				sqlstr=sprintf('call ratinfo.update_rat_perf("%s","","%s",%d)',char(bias_deviation_rats(jj,1)),rig_bias_issue_string,date_shift);
				bdata(sqlstr);
				%Post the rig bias issue of this rat to ratinfo.schedule table: STOP
			end			
			rig_bias_email_mssg=[rig_bias_email_mssg sprintf('\n')];
		end
		
		if problem_rig_flag==1			
			% Determine Primary Contact for this rig: START
	% 		max_rat_owners_rig=[];
	% 		[temp1 temp2 temp3]=unique(all_owners_rig);
	% 		frequencies_of_multiple_rat_owners_rig=histc(temp3,1:length(temp2));
	% 		
	% 		if max(frequencies_of_multiple_rat_owners_rig)>1
	% 			max_frequency_indices=strfind(frequencies_of_multiple_rat_owners_rig',max(frequencies_of_multiple_rat_owners_rig));
	% 			for pp=1:length(max_frequency_indices)
	% 				max_rat_owners_rig=[max_rat_owners_rig;temp1(max_frequency_indices(pp))];
	% 			end
	% 			if length(max_frequency_indices)>1
					max_problem_rat_owners_rig=[];
					[temp4 temp5 temp6]=unique(problem_rat_owners_rig);
					frequencies_of_multiple_problem_rat_owners_rig=histc(temp6,1:length(temp5));
					max_frequency_indices=strfind(frequencies_of_multiple_problem_rat_owners_rig',max(frequencies_of_multiple_problem_rat_owners_rig));
					for pp=1:length(max_frequency_indices)
						max_problem_rat_owners_rig=[max_problem_rat_owners_rig;temp4(max_frequency_indices(pp))];
					end
					primary_contact=max_problem_rat_owners_rig(randi([1,length(max_problem_rat_owners_rig)]));
	% 				common_owners=intersect(max_rat_owners_rig,max_problem_rat_owners_rig);
	% 				if ~isempty(common_owners)
	% 					primary_contact=common_owners(randi([1,length(common_owners)]));
	% 				else
	% 					primary_contact=max_rat_owners_rig(randi([1,length(max_rat_owners_rig)]));
	% 				end
	% 			else
	% 				primary_contact=unique(max_rat_owners_rig);
	% 			end
	% 		else
	% 			primary_contact=problem_rat_owners_rig(randi([1,length(problem_rat_owners_rig)]));
	% 		end
			% Determine Primary Contact for this rig: STOP
			
			sqlstr=sprintf('select experimenter from ratinfo.contacts where email="%s"',char(primary_contact));
			primary_contact_name=bdata(sqlstr);primary_contact_name=upper(primary_contact_name);
			rig_header_email_msg=sprintf('%s  (%s)\n',hostname{i},all_rats_in_rig);		
			rig_footer_email_msg=[];
			for pp=1:length(rig_mailing_list.owners)
				rig_footer_email_msg=[rig_footer_email_msg sprintf('%s,',rig_mailing_list.owners{pp})];
			end
			if rig_footer_email_msg(end)==','
				rig_footer_email_msg(end)='';
				rig_footer_email_msg=strtrim(rig_footer_email_msg);
			end
			all_rig_owners_emails=rig_footer_email_msg;
			rig_footer_email_msg=sprintf('Last Rig Calibration: %s\n[Primary Rig Contact: %s]\nmailto:%s\n',char(last_calibration),char(primary_contact_name),rig_footer_email_msg);
			rig_footer_email_msg=strtrim(rig_footer_email_msg);
			problem_rig_counter=problem_rig_counter+1;
			problem_rigs(problem_rig_counter).hostname=hostname{i};
			problem_rigs(problem_rig_counter).message=[rig_header_email_msg,rig_trials_email_mssg,rig_bias_email_mssg,rig_footer_email_msg,sprintf('\n\n\n')];
			problem_rigs(problem_rig_counter).owners=rig_mailing_list.owners;
			problem_rigs(problem_rig_counter).tech=rig_mailing_list.tech;
			%Post the rig issues to performance_issues.rig_issues table: START
			sqlstr=sprintf('insert into performance_issues.rig_issues (rigID,date,all_rats,ft_rats,tt_rats,lb_rats,rb_rats,rig_owners) values("%s","%s","%s","%s","%s","%s","%s","%s")',hostname{i},sessiondate,all_rats_in_rig,ft_rats,tt_rats,lb_rats,rb_rats,all_rig_owners_emails);
			bdata(sqlstr);
			%Post the rig issues to performance_issues.rig_issues table: STOP
		end
	end

	contact_email_subject='Performance Issues';
	contact_email_header=sprintf('Date: %s\nAverages are taken over last %d days from this date\n\n',sessiondate,rat_history_max);
	contact_rig_mssg_header=sprintf('\nRIG ISSUES\n\n');
	contact_rat_mssg_header=sprintf('INDIVIDUAL RAT ISSUES\n\n');

	for i=1:length(all_contacts)
		contact_rig_mssg=[];
		contact_rat_mssg=[];
		rat_alert_counter=0;
		rig_alert_counter=0;
		is_subscriber=sum(cell2mat(strfind(subscribers,char(all_contacts(i)))));
		is_computer_tech=sum(cell2mat(strfind(comp_techs,char(all_contacts(i)))));
		
		for j=1:problem_rig_counter
			is_owner=sum(cell2mat(strfind(problem_rigs(j).owners,char(all_contacts(i)))));
			is_tech=sum(cell2mat(strfind(problem_rigs(j).tech,char(all_contacts(i)))));
			%if(is_tech>0 || is_owner>0 || is_subscriber>0 || is_computer_tech>0)
			if(is_computer_tech>0 || is_subscriber>0 || is_owner>0)
				rig_alert_counter=rig_alert_counter+1;
				if(is_owner>0 && length(problem_rigs(j).owners)==1)
					contact_rig_mssg=[contact_rig_mssg regexprep(problem_rigs(j).message,['mailto:',char(all_contacts(i))],'')];
				else
					contact_rig_mssg=[contact_rig_mssg problem_rigs(j).message];
				end
			end
		end
		if ~isempty(contact_rig_mssg)
			contact_rig_mssg=[contact_rig_mssg sprintf('\n')];		
			contact_rig_mssg=regexprep(contact_rig_mssg,[':',char(all_contacts(i)),','],':');
			contact_rig_mssg=regexprep(contact_rig_mssg,[',',char(all_contacts(i))],'');		
		end
		
		for j=1:problem_rat_counter
			is_owner=sum(cell2mat(strfind(problem_rats(j).owners,char(all_contacts(i)))));
			is_tech=sum(cell2mat(strfind(problem_rats(j).tech,char(all_contacts(i)))));
			%if(is_tech>0 || is_owner>0 || is_subscriber>0 || is_computer_tech>0)
			if(is_computer_tech>0 || is_subscriber>0 || is_owner>0)
				rat_alert_counter=rat_alert_counter+1;
				contact_rat_mssg=[contact_rat_mssg problem_rats(j).message];
				if sum(cell2mat(strfind({problem_rigs.hostname},problem_rats(j).hostname)))>0
					contact_rat_mssg=[contact_rat_mssg sprintf('\t[Note: This rig had issues on this date]\n\n')];
				else
					contact_rat_mssg=[contact_rat_mssg sprintf('\n')];
				end
			end
		end
		
		if rig_alert_counter>0
			contact_rig_mssg=[contact_rig_mssg_header contact_rig_mssg];
		end
		if rat_alert_counter>0
			contact_rat_mssg=[contact_rat_mssg_header contact_rat_mssg];
		end
		if rig_alert_counter>0 || rat_alert_counter>0
			contact_email_mssg=[contact_email_header contact_rig_mssg contact_rat_mssg];
			sendmail(all_contacts(i),contact_email_subject,contact_email_mssg);
			% disp(all_contacts(i));
			% disp(contact_email_mssg);
		end
	end
catch %#ok<CTCH>
    senderror_report;
end

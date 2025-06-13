function err=add_PA2data_to_db(fname)

load(fname);

err=1;

startT=saved_history.ProtocolsSection_parsed_events{1}.states.state_0(2);
endT=saved_history.ProtocolsSection_parsed_events{end}.states.state_0(2);
sess_length=endT-startT;


pd.hit=saved.PerformanceSection_hit_history;
pd.gotit=saved.PerformanceSection_gotit_history;
pd.context=saved.PerformanceSection_previous_cntxt;
pd.sides=saved.PerformanceSection_previous_sides;
pd.RT=saved.PerformanceSection_RT;

try
    pd.blocks=saved.PerformanceSection_block_history;
catch
    pd.blocks=zeros(size(pd.sides));
end

stime=saved.SavingSection_SaveTime;
endtime=datestr(datenum(stime),13);
sessiondate=datestr(datenum(stime),29);

lets={'l' 'c' 'r'};
sides=cell2mat(lets(pd.sides+2));
sendsummary(  ...
    'sides',sides,...
    'hits'		, pd.hit, ...
    'sides'		, sides, ...
    'endtime'			, endtime,...
    'sessiondate'		, sessiondate, ...
    'hostname'			, saved.SavingSection_hostname, ...
    'experimenter'      , saved.SavingSection_experimenter, ...
    'ratname'           , saved.SavingSection_ratname, ...
    'n_done_trials'		, saved.ProtocolsSection_n_done_trials ,...
    'protocol'			, 'ProAnti2' ,...
    'protocol_data'     , pd,...
     'sess_length'      , sess_length);


err=0;


function [err]=sendsummary(varargin)


try
	% since this code is not essential never break anything

    pairs = { ...
            'hits'				get_val('hit_history');...
            'sides'				get_val('previous_sides');...
			'endtime'			datestr(now,13);...
			'sessiondate'		datestr(now,29);...
			'hostname'			get_val('SavingSection_hostname');...	
			'experimenter'      get_val('SavingSection_experimenter');...
			'ratname'           get_val('SavingSection_ratname');...
			'n_done_trials'		get_val('n_done_trials');...
			'protocol'			'';...
			'protocol_data'     'NULL';...
            'sess_length'       '';...
            }; parseargs(varargin, pairs);
		

		
%% Get the relevant SPH

total_correct=nanmean(hits);
right_correct=nanmean(hits(sides=='r'));
left_correct=nanmean(hits(sides=='l'));
percent_violations=mean(isnan(hits));

%


 %id  starttime                 hit_mean   brokenbits
 
 %Deal with these later.
 %%settings_file   settings_path   data_file   data_path   video_file   video_path
 
 
 colstr='ratname, hostname, experimenter,  endtime, starttime ,sessiondate , protocol, n_done_trials ,total_correct, right_correct, left_correct, percent_violations ,protocol_data, brokenbits';    
 valstr=['"{S}","{S}","{S}","{S}", time(date_sub("2007-01-01 ' endtime '", interval ' num2str(sess_length) ' second)) ,"{S}","{S}", "{S}","{S}","{S}", "{S}","{S}","{M}",1']; 
 sqlstr=['insert into bdata.sessions (' colstr ') values (' valstr ')'];
 bdata(sqlstr, ratname, hostname, experimenter, endtime ,sessiondate , protocol, n_done_trials ,total_correct, right_correct, left_correct, percent_violations,protocol_data);
 
 
 err=0;
catch
	fprintf(2, 'Failed to send summary to sql');
	err=1;
end
 
 
 function y=get_val(x)
	% y=get_sphandle('fullname',x);
	% y=y{1};
	 y='';
	 return;
	 
	

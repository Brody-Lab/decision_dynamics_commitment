function [err]=sendsummary(obj, varargin)
% [err]=sendsummary(obj, varargin)
% This function sends session data to the bdata.sessions table
% By default it tries to get data from standard plugins:
% 	pairs = { ...
% 		'hits'				get_val('hit_history');...
% 		'sides'				get_val('previous_sides');...
% 		'endtime'			get_endtime;...
% 		'sessiondate'		datestr(now,29);...
% 		'hostname'			get_val('SavingSection_hostname');...
% 		'experimenter'      get_val('SavingSection_experimenter');...
% 		'ratname'           get_val('SavingSection_ratname');...
% 		'n_done_trials'		get_val('n_done_trials');...
% 		'protocol'			class(obj);...
% 		'protocol_data'     'NULL'; ...
% 		'last_comment'          cleanup(CommentsSection(obj,'get_latest'));...
% 		'data_file'         SavingSection(obj,'get_data_file')...
%     'force_send'      0 ; ...     % If 0, sends only if running on a real rig; if 1, sends even if not running on a real rig
% 		}; parseargs(varargin, pairs);
% As well it gets the # of pokes from parsed_events
% Note that sessiondate and endtime are defined as the time when this code
% runs.  If this code is run on old data, this will break.
% Perhaps it should first check if savetime exists and use that.



try
	% since this code is not essential never break anything
	pairs = { ...
      'force_send'      0 ; ...
		'hits'				get_val('hit_history');...
		'sides'				get_val('previous_sides');...
		'savetime'          get_savetime(obj)
		'endtime'			get_endtime(obj);...
		'sessiondate'		get_sessiondate(obj);...
		'hostname'			get_rigid;...
        'IP_addr'           get_network_info;...
		'experimenter'      get_val('SavingSection_experimenter');...
		'ratname'           get_val('SavingSection_ratname');...
		'n_done_trials'		get_val('n_completed_trials');...
		'protocol'			class(obj);...
		'protocol_data'     'NULL'; ...
		'peh'				get_parsed_events;
		'last_comment'          cleanup(CommentsSection(obj,'get_latest'));...
		'data_file'         SavingSection(obj,'get_data_file');...
        'video_file'        runrats('get_videofile');...
        'foodpuck'          get_foodpuck;
        'technotes'         get_val('TechComment')... % <~> added line locally 2008.Aug.27. new runrats technician comments field.
    }; parseargs(varargin, pairs);

    [rigID e m] = bSettings('get','RIGS','Rig_ID');
    if ~force_send && isnan(rigID)
       % if we're not forcing a send then check: only send if running on a real rig
       err=42;
       return
    end

 
    if ~ischar(technotes) || isempty(technotes), technotes = ' '; end; % <~> Temporary hack, 2008.Aug.29
    if ischar(video_file) && ~isempty(video_file)
        [v_path,v_file,v_ext] = fileparts(video_file);
        v_file = [v_file,v_ext];
    else
        v_path = '';
        v_file = '';
    end
    
    [pth fl]=extract_path(data_file);
	%% Get the relevant SPH

    hits=hits(1:n_done_trials);
    sides=sides(1:n_done_trials);
	total_correct=nanmean(hits);
    
	
    try
    right_correct=nanmean(hits(sides=='r'));
	left_correct=nanmean(hits(sides=='l'));
    catch
       right_correct=-1;
       left_correct=-1;
    end
    
    if strncmpi('pbups', protocol, 5) && isfield(protocol_data, 'violations'), % added 2011-02-03
        percent_violations = mean(protocol_data.violations);
    elseif strncmpi('proanti3', protocol, 8) && isfield(protocol_data, 'violations'), % added 2023-10-18
        percent_violations = mean(protocol_data.violations);
    else
        percent_violations=mean(isnan(hits));
    end;

%%  calculate pokes

	left_pokes=0;
	center_pokes=0;
	right_pokes=0;
	for px=1:numel(peh)
	left_pokes=left_pokes+numel(peh(px).pokes.L);
	center_pokes=center_pokes+numel(peh(px).pokes.C);
	right_pokes=right_pokes+numel(peh(px).pokes.R);
	end	
	
	%Deal with these later.
	%%settings_file   settings_path   data_file   data_path   video_file   video_path
    
%%
	sessid=getSessID(obj);

	starttime = get_starttime(sessid);  % added 20091214
	if isempty(starttime),
		% if the starttime cannot be located in the sess_started table,
		% compute using the old method
		starttime = datestr(datenum(savetime)-sess_length(obj)/60/60/24, 13);
	else
		% update sess_started table indicating that the session has ended
		% properly
		bdata('call set_sess_ended("{Si}", "{Si}")', sessid, 1);
	end;

    %added entry for foodpuck 2018-02-02 -Chuck
    %added entry for video file and path 2018-10-03 -Chuck
	colstr='sessid, ratname, hostname, experimenter,  endtime, starttime ,sessiondate , protocol, n_done_trials ,total_correct, right_correct, left_correct, percent_violations ,protocol_data,comments,  data_file,   data_path, left_pokes,center_pokes,right_pokes,technotes,IP_addr, foodpuck, video_file, video_path'; % <~> added technotes, 2008.Aug.27, locally
	valstr=['"{Si}","{S}","{S}","{S}","{S}","{S}","{S}","{S}", "{S}","{S}","{S}", "{S}","{S}","{M}","{S}","{S}","{S}","{S}","{S}","{S}","{S}","{S}","{Si}","{S}","{S}"']; % <~> added one more "{S}" for technotes, 2008.Aug.27, locally
	sqlstr=['insert into bdata.sessions (' colstr ') values (' valstr ')'];
	bdata(sqlstr, sessid,ratname, hostname, experimenter, endtime, starttime, sessiondate, protocol, n_done_trials, total_correct, right_correct, left_correct, percent_violations,protocol_data,last_comment, fl, pth, left_pokes,center_pokes,right_pokes,technotes,IP_addr,foodpuck, v_file, v_path);  % <~> added technotes, 2008.Aug.27, locally

    bdata('insert into parsed_events values ("{S}", "{M}")',sessid, peh);
	
	err=0;
catch
	fprintf(2, 'Failed to send summary to sql\n');
    showerror
	err=1;
end


function y=get_foodpuck
if runrats('is_running')
    try
        y=runrats('get_foodpuck_state');
    catch
        y=0;
    end
else
    y=0;
end

function y=get_val(x)
y=get_sphandle('fullname',x);
if isempty(y)
	y='';
else
	y=y{1};
	y=value(y);
end
return;

function y=get_parsed_events
y=get_sphandle('fullname','ProtocolsSection_parsed_events');
y=cell2mat(get_history(y{1}));

function y=sess_length(obj)
% This is an estimate of the start time.
% The actual starttime could be easily saved as an SPH by the
% protocols.
GetSoloFunctionArgs(obj);

try
    %This is a hacky work around to get a more accurate start and stop time
    %for the session.  It takes the times from the protocol title.  SInce
    %the start time is taken after the first trial, the duration of the
    %first trial must be added to this difference to get the total run
    %time. I put it in a try catch loop just incase someone writes a
    %protocol that doesn't put the times in the title. -Chuck 09-12-10
    st = parsed_events_history{1}.states; %#ok<USENS>
    ss = st.starting_state;
    es = st.starting_state;
    eval(['ST = min(min(st.',ss,'));']);
    eval(['ET = max(max(st.',es,'));']);
    
    D1 = round(ET - ST);
    
    pt = get_sphandle('name','prot_title');
    [Ts,Te] = get_times_from_prottitle(value(pt{1}));
    Ts = [Ts,':00'];
    Te = [Te,':00'];
    
    Dt = timediff(Ts,Te,2);
    y = Dt + D1;
catch
    showerror
    % get the timestamp of the last trial
    endtime=parsed_events.states.state_0(2);

    % get the timestamp of the first trial
    starttime=parsed_events_history{1}.states.state_0(2);

    y=endtime-starttime;
end


function y=cleanup(M)
try
	y=strtrim(sprintf('%s',M'));
catch
	y='';
end


function [p f]=extract_path(s)

last_fs=find(s==filesep, 1, 'last' );
p=s(1:last_fs);
f=s(last_fs+1:end);


function y=get_savetime(obj)
[x,x,y]=SavingSection(obj,'get_info');
if y=='_'
	y=datestr(now);
end

function y=get_endtime(obj)
[x,x,savetime]=SavingSection(obj,'get_info');
if savetime=='_'
	y=datestr(now,13);
else
	y=datestr(savetime,13);
end

function y = get_starttime(sessid)
y = bdata('select starttime from bdata.sess_started where sessid="{Si}"', sessid);
if ~isempty(y),
	y = y{1};
end


function y=get_sessiondate(obj)
[x,x,savetime]=SavingSection(obj,'get_info');
if savetime=='_'
	y=datestr(now,29);
else
	y=datestr(savetime,29);
end

function y=get_rigid
y=getRigID;
if isnan(y)
    y='Unknown';
elseif isnumeric(y)
    y=sprintf('Rig%02d',y);
end
    


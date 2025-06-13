function fh=dtheta_plot(sessid, varargin)

pairs={'align_on'       '';...
	'correct_only'   0;...
	'noviol_only'    1; ...
	'main_sort'      'sides';...
	'plot_hv'        1;...  % plot head velocity
	'bin_size'       0.01;...
	'krn'            [];...
	'pre'            +3;...
	'post'           +3;...
	'print_flag'     0;...
	'save_flag'      0;...
	}; parseargs(varargin, pairs);

fh=figure;
set(fh,'Position',[100 100 650*.7 500*.7])
if print_flag==1
	set(fh,'Renderer','painters');
else
	set(fh,'Renderer','opengl');
end

if numel(sessid)>1
	for cx=1:numel(sessid)
		try
			if nargin>1
				fh=dtheta_plots(sessid(cx));
				pause(1);
				close(fh);
				pause(0.1);
				fh=0;
			else
				fh(cx)=dtheta_plot(sessid(cx));
				%                 pause(0.1);
				%                 close(fh(cx));
			end
		catch
			showerror
			sprintf('Failed to plot cell %d\n',cellid(cx))
		end
	end
else
	
	
	[ratname]=bdata('select ratname from sessions where sessid="{S}"',sessid);
	
	ia=axes('Position',[0.05 0.97 1 1]);
	set(ia,'Visible','off');
	make_title(sessid);
	
	
	
	%% set up the reference time and conditions
	
	peh=get_peh(sessid);		% get the parsed_events
	
	[ref,align_string]=get_ref_event(sessid,peh,align_on);
	
	%% head velocity plot
	
		try
			[timestamps theta] = bdata('select proc_ts, proc_theta from tracking where sessid="{S}"',sessid);
			timestamps=timestamps{1}; timestamps = timestamps(1:end-1);
			hv_height = 0.14;
		catch
			fprintf(2, 'Head tracking info not available for session %d\n', sessid);
			plot_hv = 0;
			hv_height = 0;
		end;
	

	% By default we are sorting on sides and hit/miss
	% We assume that there is a sides field in the protocol data and a hits
	% field.
	
	[ref, condition, legend_str]=get_conditions(sessid, ref, peh, correct_only, noviol_only);
	
	
	
	
	
	
	%% call rasterHV to plot the head velocity info
	
		theta_dot = headvelocity(timestamps, theta{1});
		rh=rasterHV(ref, timestamps, theta_dot, 'cnd', condition, ...
			'ref_label',align_string, ...
			'pre', pre, 'post', post, ...
			'legend_on', 0, ...
			'renderer', get(fh, 'Renderer'), ...
			'ax_height', 0.8);
	

		%% Print
	fh=gcf;
	if print_flag
		set(gcf,'PaperPosition',[0.25 0.25 8 9])
		print -dpsc2 -painters
	end
	
	%% Save
	if save_flag
		set(gcf,'PaperPosition',[0.25 0.25 8 9]);
		saveas(gcf,[ratname{1} '_' num2str(cellid) '.pdf']);
	end
	
	
	end



function th=make_title(sessid)
[rat, day, protocol]=bdata('select ratname, sessiondate,protocol from sessions where sessid="{S}"',sessid);
title_str=sprintf('%s,  %s, %s', rat{1},  day{1}, protocol{1});
th=text(0,0,title_str);
set(th,'FontSize',18);

function [ref,align_string]=get_ref_event(sessid,peh,align_on)
if isempty(align_on)      % get the reference event
	align_string=align_str(sessid);
	ref=extract_alignment(sessid,align_string,peh);
elseif strcmp(align_on,'DO')
	%     s_time=extract_event(peh,'cpoke1(end,end)');
	%     e_time=extract_event(peh,'wait_for_spoke(end,end)');
	%     cout=extract_event(peh,'C',2);
	ref=zeros(numel(peh),1);
	for rx=1:numel(ref)
		couts=peh(rx).pokes.C(:,2);
		if ~isempty(peh(rx).states.wait_for_spoke) && ~isempty(couts) && ~isempty(peh(rx).states.cpoke1)
			e_time=peh(rx).states.wait_for_spoke(end,end);
			ref(rx)=max(couts(couts<e_time));
		else
			ref(rx)=nan;
		end
	end
	
	
	align_string='RT';
else
	align_string=align_on;
	ref=extract_alignment(sessid,align_on,peh);
end

%ref=ref(~isnan(ref));


function a_str=align_str(sessid)
if iscell(sessid)
	sessid=sessid{1};
end
protocol=bdata('select protocol from sessions where sessid="{S}"',sessid);
switch protocol{1}
	case 'SameDifferent'
		a_str='ps.cpoke1(end,end)';
	case 'ProAnti2'
		a_str='ps.poke2sound(1,1)';
	case 'ExtendedStimulus'
		a_str='ps.wait_for_spoke(1,2)';
	otherwise
		warning('summary_plot:unknown_protocol','No default alignment for protocol %s.  Add to private align_on function in summary_plot',protocol);
end




%% Call rasterC to makes the raster and PSTH plot

function [ref,condition,legend_str]=get_conditions(sessid,ref,peh,correct_only,noviol_only)

[protocol,pd]=bdata('select protocol,protocol_data from sessions where sessid="{S}"',sessid);
pd=pd{1};
[pd,peh]=fix_sizes_in_pd(pd,peh);
if strcmpi(protocol,'samedifferent')
	legend_str={'SndL:PokeR' 'SndL:PokeL','SndR:PokeL' 'SndR:PokeR'};
	rights=pd.sides=='r';
	hits=pd.hits==1;
	inc_trs=~isnan(pd.hits);
	condition = ((hits==1)+10*(rights==1));
	if correct_only
		inc_trs=hits==1;
	end
	if noviol_only
		if isfield(pd, 'cpoke_violations'),
			noviol = pd.cpoke_violations==1;
		else
			noviol = zeros(size(hits));
			for i = 1:length(noviol),
				noviol(i) = rows(peh(i).states.cpoke1)==1;
			end;
		end;
		inc_trs = inc_trs & (noviol==1);
	end;
elseif strcmpi(protocol,'proanti2')
	legend_str={'Anti SoundR:PokeL' 'Pro SoundL:PokeL' 'Pro SoundR:PokeR','Anti SoundL:PokeR' };
	rights=pd.sides==1;
	pro=pd.context==1;
	inc_trs=~isnan(pd.hit) & pd.gotit==1;
	condition = (pro+(10*rights)); % anti-l 0, pro-l 1, anti-r 10, pro-r 11
	condition(condition==10)=20;  % this puts it in the order of the sides plot of the protocol

else
	if isempty(pd)
		%% if we don't have any trial info , just plot all trials.
		condition = 1;
		legend_str='all trials';
	else
		%% Try to seperate on hit/miss left/right for DO and pro/anti
		%% left/right for ProAnti2
		
		
		pd=pd{1};
		fn=fieldnames(pd);
		legend_str={'SndL:PokeR' 'SndL:PokeL','SndR:PokeL' 'SndR:PokeR'};
		if ismember('sides',fn)
			if ischar(pd.sides(1))
				rights=pd.sides=='r';
			else
				rights=pd.sides==1;
			end
		else
			warning('summary_plot:sides','No sides information in protocol data');
			rights=0;
			legend_str={'Miss' 'Hit'};
		end
		
		if ismember('hits',fn)
			hits=pd.hits==1;
		elseif ismember('gotit',fn)  %like in ProAnti2
			inc_trs=~isnan(pd.hit);
			hits=pd.gotit==1;
			
		else
			
			warning('summary_plot:hits','No hits information in protocol data');
			hits=0;
			
			if numel(legend_str)==4
				legend_str={'Left' 'Right'};
			else
				legend_str='';
			end
		end
		
	end
	
	if correct_only
		inc_trs=hits==1;
	end
	
	
	
	hits=hits(inc_trs);
	rights=rights(inc_trs);
	condition = ((hits==1)+10*(rights==1));
	
end

inc_trs = inc_trs(1:length(ref));
ref=ref(inc_trs);
condition=condition(inc_trs);


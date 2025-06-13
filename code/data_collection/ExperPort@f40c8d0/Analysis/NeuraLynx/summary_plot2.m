function [fh,R]=summary_plot2(cellid, varargin)
% summary_plot2(cellid, varargin)
% pairs={'align_on'       '';...
% 	'correct_only'   0;...
% 	'noviol_only'    1; ...
%     'mem_only'       0; ...
%     'by_sounds'      0;
% 	'main_sort'      'sides';...
% 	'plot_isi'       1;...
% 	'plot_raster'    1;...
% 	'plot_wave'      1;...
% 	'plot_hv'        1;...  % plot head velocity
% 	'bin_size'       0.01;...
% 	'krn'            [];...
% 	'pre'            +3;...
% 	'post'           +3;...
% 	'print_flag'     0;...
% 	'save_flag'      0;...
% 	}; parseargs(varargin, pairs);

% needs to be merged with summary_plot, but temporarily adding to repository so Carlos
% can use this

pairs={'align_on'       '';...    
    'correct_only'   0;...
    'noviol_only'    1; ...
    'mem_only'       0; ...
    'by_sounds'      0; ...
    'by_bup_diff'    0; ...
    'by_choice'    0; ...
    'mask_post_cpoke1' 0; ...
    'main_sort'      'sides';...
    'plot_isi'       1;...
    'plot_raster'    1;...
    'plot_wave'      1;...
    'plot_hv'        1;...  % plot head velocity
    'bin_size'       0.01;...
    'krn'            [];...
    'pre'            +3;...
    'post'           +3;...
    'print_flag'     0;...
    'save_flag'      0;...
    'fh'             [];...
    'num_plots'       1;...  % the total number of raster/PSTH/HV plots, each is a column
    'this_plot_num'   1;...  % index for this particular plot
    
    }; parseargs(varargin, pairs);


if isempty(fh)
    fh=figure;
else
    figure(fh);
end
% offset of raster/PSTH/HV plot in normalized units
x_offset = ((this_plot_num-1)/num_plots)*0.8+0.05;
plot_width = (1/num_plots)*0.7;
fig_width = 600*num_plots;

if this_plot_num==1
    set(fh,'Position',[100 100 fig_width 1000]);
end
if print_flag==1
    set(fh,'Renderer','painters');
else
    set(fh,'Renderer','opengl');
end

if numel(cellid)>1
    for cx=1:numel(cellid)
        try
            if nargin>1
                fh=summary_plot(cellid(cx));
                pause(1);
                close(fh);
                pause(0.1);
                fh=0;
            else
                fh(cx)=summary_plot(cellid(cx));
                %                 pause(0.1);
                %                 close(fh(cx));
            end
        catch
            showerror
            sprintf('Failed to plot cell %d\n',cellid(cx))
        end
    end
    % don't return data if there are multiple cells
    R = nan;
else
    
    [sessid,ts,waves]=bdata('select sessid, ts, wave from spktimes where cellid="{S}"',cellid);
    if isempty(sessid)
        fprintf(2,'Cell %d was not found',cellid);
        close(fh);
        fh=[];
        return;
    end
    ts=ts{1};
    [ratname]=bdata('select ratname from sessions where sessid="{S}"',sessid);
    
    ia=axes('Position',[0.05 0.97 1 1]);
    set(ia,'Visible','off');
    make_title(cellid,sessid);
    
    %% Create the ISI plot
    if plot_isi
        isi=diff(ts);
        bins=-4:0.1:1.5;
        axisi=axes('Position',[0.85 0.8 0.15 0.13]);
        hist(axisi,log10(isi),bins);
        xlabel('ISI (log_{10} secs)')
        ylabel('Frequency');
        xlim([min(bins) max(bins)]);
        set(axisi, 'XTick', [-3 -2 -1 0]);
        set(axisi, 'TickDir','out');
        set(axisi, 'TickLength',[0.025 0.2]);
        set(axisi, 'Box','off');
        
    end
    
    %% Create the waveplot
    
    if plot_wave
        axwave=axes('Position',[0.85 0.57 0.15 0.12]);
        waveplot(waves{1}, {'k', axwave,0.8});
        xlim([1 150]);
    end
    
    %% show cell info
    axinfo=axes('Position',[0.85 0.4 0.15 0.3]);
    th=text(0,0,getCellInfo(cellid));
    set(axinfo,'Visible','off');
    set(th,'Interpreter','none');
    
    
    %% get parsed events
    peh=get_peh(sessid);		% get the parsed_events
    
    
   
    
    %% set up the reference time and conditions
    
    [ref,align_string]=get_ref_event(sessid,peh,align_on);
    
    
    %% head velocity plot
    if plot_hv,
        try
            [timestamps theta] = bdata('select ts, theta from tracking where sessid="{S}"',sessid);
            timestamps=timestamps{1}; timestamps = timestamps(1:end-1);
            hv_height = 0.14;
        catch
            fprintf(2, 'Head tracking info not available for session %d\n', sessid);
            plot_hv = 0;
            hv_height = 0;
        end;
    else
        hv_height = 0;
    end;
    raster_height = 0.85 - hv_height;
    raster_corner = [x_offset 0.05+hv_height+0.08*hv_height];
    
    % calculate post_mask as time until end of last cpoke1 state
    if mask_post_cpoke1
        post_mask = extract_alignment(sessid,'ps.cpoke1(end,2)',peh);
        post_mask = post_mask - ref;    % post_mask is coded as relative to ref
    else
        post_mask = repmat(Inf,size(ref));
    end
    
    
    % By default we are sorting on sides and hit/miss
    % We assume that there is a sides field in the protocol data and a hits
    % field.
    [ref, condition, post_mask, legend_str]=get_conditions(sessid, ref, post_mask, peh, correct_only, noviol_only, by_sounds,mem_only,by_bup_diff,by_choice);
    
    
    %% make the call to rasterC
    %
    set(fh,'Renderer','painters'); % FIX: hacky temp solution by TDH
    gd_trials=ref>ts(1);
    ref=ref(gd_trials);  % This ignores trials before recording started. in a hacky way
    condition=condition(gd_trials);					 % jce
    post_mask=post_mask(gd_trials);
    
    % This used to be a call to exampleraster2, but I think this works now
    [rh,R]=exampleraster(ref,ts,'ref_label',align_string, ...
        'cnd', condition, ...
        'legend_str',legend_str, ...
        'legend_pos',[raster_corner(1) raster_corner(2)+0.25-0.1 0.1 0.1], ...
        'renderer',get(fh,'Renderer'), ...
        'pre', pre, 'post', post, ...
        'total_height', raster_height, ...
        'ax_width', plot_width, ...
        'corner', raster_corner, ...
        'errorbars', 1, ...
        'post_mask', post_mask, ...
        'krn', 0.1, ...
        'binsz', 0.05);
    
    
    
    %% call rasterHV to plot the head velocity info
    % FIX: make this work with trial-by-trial post masking!
    if plot_hv,
        set(rh(end),'XTickLabel',{});
        theta_dot = headvelocity(timestamps, theta{1});
        rh(end+1)=rasterHV(ref, timestamps, theta_dot, 'cnd', condition, ...
            'ref_label',align_string, ...
            'pre', pre, 'post', post, ...
            'legend_on', 0, ...
            'renderer', get(fh, 'Renderer'), ...
            'ax_height', hv_height, ...
            'ax_width', plot_width, ...
            'post_mask', post_mask, ...
            'corner', [x_offset 0.05]);
    end;
    
    linkaxes(rh,'x');
    
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



function th=make_title(cellid,sessid)
[rat, day, protocol]=bdata('select ratname, sessiondate,protocol from sessions where sessid="{S}"',sessid);
title_str=sprintf('%s, Cell %d, %s, %s', rat{1}, cellid, day{1}, protocol{1});
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
elseif strcmp(align_on,'PBUPS')
    % align to start of last cpoke1 state
    ref=extract_alignment(sessid,'ps.cpoke1(end,1)',peh);
    
    % compensate for stim_start_delay
    stim_start_delay = fetch_sph('StimulusSection_stim_start_delay', sessid);
    stim_start_delay = stim_start_delay(1:size(ref,1));
    ref = ref + stim_start_delay;
    
    % compensate for time of first bup
    % FIX: account correctly for non-stereo first bups
    [pd]=bdata('select protocol_data from sessions where sessid="{S}"',sessid);
    pd = pd{1};
    for j = 1:length(peh),
        if ~isempty(pd.bupsdata{j}.left),
            first_bup = pd.bupsdata{j}.left(1);
        else
            first_bup = pd.bupsdata{j}.right(1);
        end;
        ref(j) = ref(j) + first_bup;
    end;
    
    align_string='Stimulus Onset ';
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
    case 'PBups'
        a_str='ps.cpoke1(end,end)';
    case 'ProAnti2'
        a_str='ps.poke2sound(1,1)';
    case 'ExtendedStimulus'
        a_str='ps.wait_for_spoke(1,2)';
    otherwise
        warning('summary_plot:unknown_protocol','No default alignment for protocol %s.  Add to private align_on function in summary_plot',protocol);
end




%% Call rasterC to makes the raster and PSTH plot

function [ref,condition,post_mask,legend_str]=get_conditions(sessid,ref,post_mask,peh,correct_only,noviol_only,by_sounds,mem_only,by_bup_diff,by_choice)

[protocol,pd]=bdata('select protocol,protocol_data from sessions where sessid="{S}"',sessid);
pd=pd{1};
[pd,peh]=fix_sizes_in_pd(pd,peh);
hits=pd.hits==1;
inc_trs=ones(size(pd.hits));
if by_sounds
    condition=pd.sounds;
    sound_ids=unique(pd.sounds);
    for ls=1:numel(sound_ids)
        %         legend_str{ls}=sprintf('Snd%d',ls);
        this_sound_id = sound_ids(ls);
        legend_str{ls}=sprintf('Snd %d',this_sound_id);
    end
    
elseif by_bup_diff>0
    
    if strcmpi(protocol,'pbups')
        T = pd.samples;
    elseif strcmpi(protocol,'samedifferent')
        stim_start_delay = fetch_sph('StimulusSection_stim_start_delay', sessid);
    else
        error('Cannot sort by bup diff because this is not a pbups protocol!');
    end
    
    % calculate the bup differences
    for j=1:length(peh)
        % calculate sample duration if SameDifferent Protocol
        if strcmpi(protocol,'samedifferent')
            if isfield(peh(j).states, 'cpoke1') && ~isempty(peh(j).states.cpoke1),
                T(j) = diff(peh(j).states.cpoke1(end,:)) - stim_start_delay(j);
            else
                T(j) = nan;
            end
        end
        
        nleftbups = sum(pd.bupsdata{j}.left<=T(j));
        nrightbups = sum(pd.bupsdata{j}.right<=T(j));
        
        %         bup_diff(j) = nrightbups - nleftbups;   % bup diff
        %         bup_diff(j) = (nrightbups - nleftbups) / T(j); % bup diff rate
        bup_diff(j) = log(nrightbups / nleftbups);  % log bups ratio
    end
    
    % index to positive bup diff trials
    pos_bup_diffs = bup_diff>0;
    
    if by_bup_diff==2
        % Separate into two bins for each direction
        
        % bin the bup differences into high and low conditions in each
        % direction
        median_abs_bup_diff = nanmedian(abs(bup_diff));
        median_pos_bup_diff = nanmedian(bup_diff(pos_bup_diffs));
        median_neg_bup_diff = nanmedian(bup_diff(~pos_bup_diffs));
        
        % assign trials to the appropriate condition/bin
        condition = ((abs(bup_diff)>median_abs_bup_diff & ~pos_bup_diffs) + 2*(abs(bup_diff)<median_abs_bup_diff & ~pos_bup_diffs) + 3*(bup_diff>median_abs_bup_diff & pos_bup_diffs));

        % split by median separately for positive and negative differences
        condition = ((bup_diff<median_neg_bup_diff & ~pos_bup_diffs) + 2*(bup_diff>median_neg_bup_diff & ~pos_bup_diffs) + 3*(bup_diff>median_pos_bup_diff & pos_bup_diffs));
        
        % make legend
        %         legend_str={'Large Neg Bup Diff', 'Small Neg Bup Diff', 'Large Pos Bup Diff', 'Small Pos Bup Diff'};
        legend_str={'Small Pos LogBR', 'Large Neg LogBR', 'Small Neg LogBR', 'Large Pos LogBR'};
    elseif by_bup_diff==1
        % Just separate by bups diff
        condition = ~pos_bup_diffs;
        %         legend_str = {'Pos Bup Diff', 'Neg Bup Diff'};
        legend_str = {'Pos LogBR','Neg LogBR'};
    else
        error('by_bup_diff must be integer from the set {0, 1, 2}')
    end
    
elseif by_choice
    legend_str={'PokeL', 'PokeR'};
    right_sounds=pd.sides=='r';
    inc_trs=~isnan(pd.hits);
    condition = (right_sounds & hits) + (~right_sounds & ~hits);
    
    
elseif strcmpi(protocol,'samedifferent')
    legend_str={'SndL:PokeR' 'SndL:PokeL','SndR:PokeL' 'SndR:PokeR'};
    rights=pd.sides=='r';
    inc_trs=~isnan(pd.hits);
    condition = ((hits==1)+10*(rights==1));
elseif strcmpi(protocol,'pbups')
    if correct_only    
        legend_str={'SndL:PokeL', 'SndR:PokeR'};
    else
        legend_str={'SndL:PokeR', 'SndL:PokeL', 'SndR:PokeL', 'SndR:PokeR'};
    end
    rights=pd.sides=='r';
    inc_trs=~isnan(pd.hits);
    condition = ((hits==1)+10*(rights==1));
    
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
    
    
    hits=hits(inc_trs);
    rights=rights(inc_trs);
    condition = ((hits==1)+10*(rights==1));
    
end

if correct_only
    inc_trs=inc_trs & hits==1;
end

if mem_only
    inc_trs = inc_trs & pd.ssd<0.2;
end

if noviol_only
    if isfield(pd, 'cpoke_violations'),
        noviol = pd.cpoke_violations==1;
    else
        noviol = zeros(size(peh));
        for i = 1:length(noviol),
            noviol(i) = rows(peh(i).states.cpoke1)==1;
        end;
    end;
    inc_trs = inc_trs & (noviol==1);
end;

inc_trs = inc_trs(1:length(ref));
ref=ref(inc_trs);
post_mask=post_mask(inc_trs);
condition=condition(inc_trs);


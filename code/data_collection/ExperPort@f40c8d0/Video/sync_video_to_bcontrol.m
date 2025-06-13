function sync = sync_video_to_bcontrol(experimenter,rat,date,video_folder,varargin)
    % given rat and date, finds all videos and tries to match them up with
    % a behavioral session. optionally saves a .sync.mat file.
    % to do: future improvements could compare results from multiple videos
    % to refine the alignment (for instance, identify spurious flashes from
    % one video). also noise in estimating the flash times could be better estimated by
    % using infered times from neighboring flashes.

    %% parse and validate arguments
    validateattributes(experimenter,{'string','char'},{'vector','row'});
    validateattributes(rat,{'string','char'},{'vector','row'});
    validateattributes(video_folder,{'string','char'},{'vector','row'});    
    validateattributes(date,{'string','char','datetime','numeric'},{'vector','row'});
    p=inputParser;
    p.addParameter('flash_type','sync',@(x)validateattributes(x,{'string','char'},{'vector','row'}));
    p.addParameter('save',false,@(x)validateattributes(x,{'logical'},{'scalar'}));    
    p.addParameter('overwrite',false,@(x)validateattributes(x,{'logical'},{'scalar'}));      
    p.addParameter('interp_ratio',10,@(x)validateattributes(x,{'numeric'},{'positive','scalar','>=',1}));
    p.addParameter('hp_filt_length_s',4,@(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    p.parse(varargin{:});
    params=p.Results;  
    validatestring(params.flash_type,{'sync','l','r','lr','rl'},mfilename,'flash_type');
    try
        date = datetime(date);
    catch
        error('Argument 2 ("date") is in an unrecognized format. Must be a datetime or convertible to one.');
    end
    if ~isfolder(video_folder)
        error('Video folder (%s) does not exist.',video_folder);
    end
    
    %% load luminance data for videos
    luminance = load_luminance_data_for_session(experimenter,rat,date,video_folder);
    if isempty(luminance)
        return
    end
    orig_luminance=luminance;
    
    %% high-pass filter luminance data
    luminance = high_pass_luminance(luminance,'filt_length_s',params.hp_filt_length_s);
    
    %% interpolate luminance data
    if params.interp_ratio>1
        luminance = interp_luminance(luminance,params.interp_ratio);    
    end

    %% get video flash times
    [video_flash_times,full_flash,full_flash_diff] = get_video_flash_times(luminance);
    if isnumeric(video_flash_times)
        video_flash_times={video_flash_times};
        full_flash = {full_flash};
    end
    
    %% get sessid for session
    sessid = resolve_mult_sess_per_day(rat, date, 'multi_sess_rule', 'ask'); % this function is in the labwide_pbups_analysis repo

    %% get bcontrol flash times
    bcontrol_flash_times = get_bcontrol_flash_times(sessid,params.flash_type);        
    
    %% do syncing    
    for i=1:numel(luminance)
        fprintf('------------\nSyncing video file %s to sessid %d.\n',luminance(i).vfile,sessid);
        try
            sync(i) = do_sync_video_bcontrol(luminance(i),video_flash_times{i},bcontrol_flash_times,params.interp_ratio);        
            success(i)=true;
        catch
            success(i)=false;
        end
    end
    
    %% add metadata and optionally save results
    for i=1:numel(luminance)
        sync(i).sessid = sessid;
        sync(i).rat = rat;
        sync(i).video_date = date;  
        sync(i).luminance = orig_luminance(i);
        sync(i).processed = datetime(datestr(now));
        sync(i).params = params;
        if params.save && success(i)
            filename = strrep(luminance(i).vfile,'.mp4','.sync.mat');
            if isfile(filename)
                if params.overwrite
                    tmp=sync(i);                    
                    save(filename,'-struct','tmp');
                    fprintf('Saved alignment data to %s.\n',filename);
                else
                    warning('%s exists already. Use "sync_video_to_bcontrol(...,''overwrite'',true)" to overwrite.');
                end
            else
                tmp=sync(i);
                save(filename,'-struct','tmp');
                fprintf('Saved alignment data to %s.\n',filename);                
            end
        end
    end
    
end

function sync = do_sync_video_bcontrol(luminance,video_flash_times,bcontrol_flash_times,interp_ratio)
           
    %% make video timestamps struct
    sync.timestamps_video.samp_rate = luminance.framerate;        
    sync.timestamps_video.start_samples = video_flash_times(1:end-1);
    sync.timestamps_video.timestamps = 1:(numel(video_flash_times)-1);
    
    %% make bcontrol timestamps struct
    sync.timestamps_bcontrol.samp_rate = 1;
    sync.timestamps_bcontrol.start_samples = bcontrol_flash_times;
    sync.timestamps_bcontrol.timestamps = 1:numel(bcontrol_flash_times);
    
    if numel(sync.timestamps_video.start_samples)~=numel(sync.timestamps_bcontrol.start_samples)
        warning('Video and behavior have different numbers of putative flashes. Ignoring trailing flashes.'); 
    end
    
    %% do syncing
    [sync.frame_times_bcontrol,mins,maxs] = translate_clock_using_timestamps(1:interp_ratio:numel(luminance.alltimes),sync.timestamps_video,sync.timestamps_bcontrol,0.1,'max_uncertainty_s',1,'forbid_out_of_range',false,'max_chunk_size',Inf,'quiet',true);    
 
    %% evaluate syncing
    sync.frame_times_bcontrol_uncertainty_ms = 1000*(maxs-mins);
    sync.median_alignment_uncertainty_ms = median(sync.frame_times_bcontrol_uncertainty_ms);
    sync.alignment_uncertainty_ms_95_CI = prctile(sync.frame_times_bcontrol_uncertainty_ms,95);    
    fprintf('   Median alignment uncertainty is %.3g ms.\n',sync.median_alignment_uncertainty_ms);
    fprintf('   95%% of samples have alignment uncertainty less than %.3g ms.\n',sync.alignment_uncertainty_ms_95_CI);    
    figure;plot(sync.frame_times_bcontrol_uncertainty_ms);
    frac_bad_alignment=mean((maxs-mins)>0.1);
    if frac_bad_alignment>0
        fprintf('   Approximately %2g%% of the video cannot be aligned to the behavior with less than %g s of uncertainty.\n',round(frac_bad_alignment*1000)/10,0.1);            
    end
    if any(isnan(sync.frame_times_bcontrol))
        error('   Approximately %2g%% of the video cannot be aligned to the behavior with less than %g s of uncertainty.\n',round(mean(isnan(sync.frame_times_bcontrol))*1000)/10,1);        
    end  
end

function luminance = high_pass_luminance(luminance,varargin)
    % luminance is the struct loaded for one or more mat files
    % we high pass by subtracting a gaussian-filtered version of the
    % luminances. this removes irrelevant baseline noise.
    if ~isscalar(luminance)
        for i=1:numel(luminance)
            luminance(i) = high_pass_luminance(luminance(i),varargin{:});
        end
        return        
    end
    
    p=inputParser;
    p.addParameter('filt_length_s',4,@(x)validateattributes(x,{'numeric'},{'positive','scalar'}));
    p.parse(varargin{:});
    params=p.Results;
    
    filt = gausswin(params.filt_length_s*luminance.framerate)';
    n_samp = size(luminance.R_luminance);    
    correction = conv(ones(n_samp,'like',luminance.R_luminance),filt,'same');
    high_pass_fun = @(x)x-conv(x,filt,'same')./correction;
    fields = fieldnames(luminance);
    
    for f=1:numel(fields)
        if numel(luminance.(fields{f}))==max(n_samp)
            luminance.(fields{f}) = high_pass_fun(luminance.(fields{f}));
        end
    end
    
end

function luminance = interp_luminance(luminance,ratio,varargin)
    % luminance is the struct loaded for one or more mat files
    % interpolation allows for subsample estimation of flash times
    if ~isscalar(luminance)
        for i=1:numel(luminance)
            luminance(i) = interp_luminance(luminance(i),ratio,varargin{:});
        end
        return        
    end
    
    p=inputParser;
    p.addParameter('type','pchip',@(x)validateattributes(x,{'string','char'},{'vector','row'}));    
    p.parse(varargin{:});
    params=p.Results;

    n_samp = size(luminance.R_luminance);        
    interp_fun = @(x)interp1(1:max(n_samp),x,1:1/ratio:max(n_samp),params.type);    
    fields = fieldnames(luminance);
    
    for f=1:numel(fields)
        if numel(luminance.(fields{f}))==max(n_samp)
            luminance.(fields{f}) = interp_fun(luminance.(fields{f}));
        end
    end    

    luminance.framerate = luminance.framerate*ratio;
    
end

function flash_times = get_bcontrol_flash_times(sessid,flash_type)

    peh = bdata(['select peh from parsed_events where sessid=',num2str(sessid)]);
    pd  = bdata(['select protocol_data from sessions where sessid=',num2str(sessid)]);
    peh = peh{1};
    pd = pd{1};

    state_names = fields(peh(1).states);
    if strcmp(flash_type,'sync')
        if sum(strcmp(state_names,'sync_flash')) == 0
            error('Cannot use sync_flash state to find flash times since this state does not exist for this session.');
        end
        flash_times = [];
        for i = 1:numel(peh)
            state_times = peh(i).states.sync_flash;
            has_nan = sum(isnan(state_times),2);
            real_times = find(has_nan == 0,1,'first');
            flash_times(end+1) = mean(peh(i).states.sync_flash(real_times,:));
        end 
    else
        if strcmp(flash_type,'lr') || strcmp(flash_type,'rl')
            flash_times = [pd.leftwatertime;pd.rightwatertime];
            fprintf('Assuming flashes occurred with both left and right reward.\n');
        elseif strcmp(flash_type,'l')
            flash_times = pd.leftwatertime;
            fprintf('Assuming flashes occurred with left reward.\n');        
        elseif strcmp(flash_type,'r')
            fprintf('Assuming flashes occurred with right reward.\n');        
            flash_times = pd.rightwatertime;
        else
            flash_times = [pd.leftwatertime;pd.rightwatertime];
        end
        flash_times = sortrows(flash_times);
        flash_times(isnan(flash_times)) = [];

    end
end

function [flash_times,full_flash,full_flash_diff] = get_video_flash_times(luminance)
    % luminance is the struct loaded for one or more mat files
    if ~isscalar(luminance)
        for i=1:numel(luminance)
            fprintf('------------\nGetting flash times for %s.\n',luminance(i).vfile);
            [flash_times{i},full_flash{i},full_flash_diff{i}] = get_video_flash_times(luminance(i));
        end
        return        
    end
    
    [flash_times_assuming_red,full_flash_assuming_red,full_flash_diff_assuming_red] = get_video_flash_times_internal(luminance.RED_flash,luminance.framerate); 
    if isempty(flash_times_assuming_red)
        error('No flash times found.');
    end
    r_peaks=luminance.RED_flash(round(flash_times_assuming_red)) - median(luminance.RED_flash) ;
    b_peaks=luminance.IR_flash(round(flash_times_assuming_red)) - median(luminance.IR_flash);
    peak_ratio=median(r_peaks)/median(b_peaks);
    fprintf('   RED to IR flash height ratio is %.4g.\n',peak_ratio);
    if peak_ratio > 2 || (median(r_peaks)>0 && median(b_peaks)<0)
        flash_times = flash_times_assuming_red;
        full_flash = full_flash_assuming_red;
        full_flash_diff = full_flash_diff_assuming_red;        
        fprintf('   Flashes seem likely to be generated from a red LED. Using R - (B+G)/2 to find flashes.\n');
    else
        [flash_times,full_flash,full_flash_diff] = get_video_flash_times_internal(luminance.IR_flash,luminance.framerate);
        fprintf('   Flashes seem likely to be generated from an IR LED. Using mean luminance across R,G and B channels to find flashes.\n');        
    end

    
end

function [flash_times,full_flash,full_flash_diff] = get_video_flash_times_internal(luminance_values,framerate)
    % luminance values is a vector of values
    luminance_values=zscore(luminance_values);
    Cdiff =zscore(diff(luminance_values));
    flash_threshold=3.5;
    
    flash_window_s = [-0.02 0.15]; % time relative to first derivative exceeding threshold (tight window around the putative flash)
    full_flash_window_s = [-0.3 0.3]; % time relative to first derivative exceeding threshold (broad window around the putative flash)   
    min_gap_s = 0.5;
    count=0;
    lastevent = -framerate;
    putative_ons = find(Cdiff>flash_threshold);
    for i = putative_ons(:)'
        if i>(lastevent+min_gap_s*framerate)
            flash_idx = (round(flash_window_s(1)*framerate):round(flash_window_s(2)*framerate)) + i;
            flash = luminance_values(flash_idx);            
            flash_diff = Cdiff(flash_idx);    
            %surround = luminance_values([i-50:i-20,i+off+70:i+off+100]);                        
            if any(flash_diff < -flash_threshold)  && any(flash>flash_threshold)  %sum(diff(sign(diff(flash)))~=0)>1 && all(abs(surround)<6) 
                count=count+1;
                flash(flash<0)=0;
                flash_times(count) = i-1 + round(flash_window_s(1)*framerate) + round(wmean(1:numel(flash),flash));
                full_flash(count,:) = luminance_values((round(full_flash_window_s(1)*framerate):round(full_flash_window_s(2)*framerate)) + flash_times(count));                                
                full_flash_diff(count,:) = Cdiff((round(full_flash_window_s(1)*framerate):round(full_flash_window_s(2)*framerate)) + flash_times(count));                                                
                lastevent=i;        
            else
                bleep=1;
            end
        end
    end
    for i=1:numel(flash_times)
        x(i)=corr(full_flash(i,:)',nanmedian(full_flash)');
    end
    y=zscore(max(full_flash'));          
    
    % use zscore of peak flash and correlation with average flash as
    % final detection criteria
    flash_times = flash_times(x>0.8&y>-4);
    full_flash = full_flash(x>0.8&y>-4,:);
    full_flash_diff = full_flash_diff(x>0.8&y>-4,:);    
end

function y = wmean(x,w,dim)
    % weighted mean
    % by default, operates along the first non-scalar dimension.
    % NaN weights are treated like zeros
    % no singleton expansion. should add that.
    sz=size(x);
    if any(size(w)~=sz)
        error('wMean:sizeMismatch','x and w must be the same size');
    end      
    if any(isinf(w))
        error('Weights cannot be Inf.');
    end
    w(isnan(x))=NaN;
    w(w==0)=NaN;
    if nargin<3
        if max(sz)==1
            dim=1;
        else
            ndims=length(sz);
            for j=1:ndims
                if sz(j)>1
                    dim=j;
                    break
                end
            end
        end
    end           
    xw = x.*w;
    wsum = nansum(xw,dim);
    y = wsum ./ nansum(w,dim);
end

function [t2,t2_min,t2_max,params] = translate_clock_using_timestamps(t1,timestamps1,timestamps2,timestamp_duration_s,varargin)
    % t1 and t2 are sample indices in the respective streams
    % translates sample indices in one stream to another by anchoring to known
    % temporal landmarks and then extrapolating based on respective clock
    % rates (if landmarks are frequent enough this incurs extremely low
    % error). If you select the "infer_clock_ratio" option (true by
    % default) the relative clock rates are estimated based on the
    % distances between landmarks in the two data streams. If this differs
    % from the nominal relative rates by more than 1%, it will throw an
    % error to let you know your assumed sample rates are off.
    %
    % We assume it is possible that data was dropped from the streams. If a
    % time to translate falls within one of these time periods, and the data drop was sufficiently large (1ms by default) a NaN is
    % returned and the 2nd and 3rd outputs give a range of potentially
    % corresponding samples in the other stream. (Dropped data introduced
    % ambiguity in how the samples match up between the two streams, during
    % the period of dropped data before the next timestamp occurs).
    %
    % timestamps1 and timestamps2 are structures with fields:
    %   "samp_rate"     : sampling rate in Hz
    %   "timestamps"    : number encoded by each syncing timestamps
    %   "start_samples" : the sample index at which each timestamp started
    %
    % AGB, 9/2020
    %
    % 
    p=inputParser;
    p.addParameter('max_uncertainty_s',1e-3,@(x)validateattributes(x,{'numeric'},{'finite','nonnegative','scalar'}));
    p.addParameter('max_chunk_size',1e4,@(x)validateattributes(x,{'numeric'},{'positive','scalar'}));    
    p.addParameter('forbid_out_of_range',true,@(x)validateattributes(x,{'logical'},{'scalar'})); % by default, assume data may have been lost outside of the range of the timestamps
    p.addParameter('infer_clock_ratio',true,@(x)validateattributes(x,{'logical'},{'scalar'}));  % for the sake of determining if data was dropped between timestamps, we need to be pretty sure about the ratio of the clock sample rates. we can use the timestamps themselves to infer this.
    p.addParameter('inferred_clock_ratio_factor',NaN);
    p.addParameter('skip_corr',false,@(x)validateattributes(x,{'logical'},{'scalar'}));  
    p.addParameter('quiet',false,@(x)validateattributes(x,{'logical'},{'scalar'}));      
    p.parse(varargin{:});
    params=p.Results;
    if isempty(t1)
        [t2,t2_min,t2_max]=deal([]);
        return
    end
    if any(abs(t1-round(t1))>1e-6)
        %error('t1 must be integer-valued since it indexes samples.');
    end
    nt = numel(t1);
    t1=t1(:);
    nans = isnan(t1);
    t1(nans)=1;    
    [t2,t2_min,t2_max] = deal(NaN(size(t1)));
    timestamps1.timestamps = timestamps1.timestamps(:);
    timestamps1.start_samples = timestamps1.start_samples(:);
    timestamps2.timestamps = timestamps2.timestamps(:);
    timestamps2.start_samples = timestamps2.start_samples(:);        
    
    
    %% remove timestamps not shared between the streams
    [~,t1_keep_idx,t2_keep_idx] = intersect(timestamps1.timestamps,timestamps2.timestamps);
    timestamps1.timestamps = timestamps1.timestamps(t1_keep_idx);
    timestamps1.start_samples = timestamps1.start_samples(t1_keep_idx);
    timestamps2.timestamps = timestamps2.timestamps(t2_keep_idx);
    timestamps2.start_samples = timestamps2.start_samples(t2_keep_idx);    
    
    %% check timestamp correlation is sufficiently high to suggest these really are matching timestamps
    if ~params.skip_corr
        params.timestamp_corr = corr(timestamps1.start_samples,timestamps2.start_samples);
        if ~params.quiet
            fprintf('\ntranslate_clock_using_timestamps: Timestamp correlation is %0.10g.\n',params.timestamp_corr);            
        end
        if params.timestamp_corr<0.999
            warning('Low correlation (%0.10g) between timestamps. Check for unalignable data.',params.timestamp_corr);
        end
    end
    
    %% infer clock ratio correction factor
    if params.infer_clock_ratio && isnan(params.inferred_clock_ratio_factor)
        params.inferred_clock_ratio_factor = median(diff(timestamps1.start_samples./timestamps1.samp_rate) ./ diff(timestamps2.start_samples./timestamps2.samp_rate));
        if ~params.quiet
            fprintf('\ntranslate_clock_using_timestamps: Inferred clock ratio correction factor is %0.10g.\n',params.inferred_clock_ratio_factor);
        end
        if params.inferred_clock_ratio_factor>1.01 || params.inferred_clock_ratio_factor<0.99
           warning('Inferred clock ratio correction factor was suspiciously far from 1. You are likely assuming the wrong sample rates.'); 
        end
    elseif isnan(params.inferred_clock_ratio_factor)
        params.inferred_clock_ratio_factor = 1;
    end
        
    %% optionally loop over chunks and return
    if nt>params.max_chunk_size
        % chunk it up
        i=0;
        while 1
            i=i+1;
            this_chunk = (1:params.max_chunk_size) + params.max_chunk_size*(i-1);
            this_chunk = this_chunk(this_chunk<=nt);
            if isempty(this_chunk)
                return
            end
            [t2(this_chunk),t2_min(this_chunk),t2_max(this_chunk)] = translate_clock_using_timestamps(t1(this_chunk),timestamps1,timestamps2,timestamp_duration_s,varargin{:},'inferred_clock_ratio_factor',params.inferred_clock_ratio_factor);
        end
    end
    
    %% remove timestamps that are not needed based on timepoints queried
    lowerBound = max(timestamps1.start_samples(timestamps1.start_samples<=min(t1)));
    upperBound = min(timestamps1.start_samples(timestamps1.start_samples>=max(t1)));
    if isempty(lowerBound)
        lowerBound=0;
    end
    if isempty(upperBound)
        upperBound=Inf;
    end
    keep_idx = timestamps1.start_samples<=upperBound & timestamps1.start_samples>=lowerBound;
    timestamps1.timestamps = timestamps1.timestamps(keep_idx);
    starts1 = timestamps1.start_samples(keep_idx);
    timestamps2.timestamps = timestamps2.timestamps(keep_idx);
    starts2 = timestamps2.start_samples(keep_idx);     
    %% now anchor to landmarks to map between the streams. anchor to left and right landmarks and compare the results. when these differ, they provide useful bounds on uncertainty.
    clock_ratio = (timestamps2.samp_rate./timestamps1.samp_rate)./ params.inferred_clock_ratio_factor;
    samples_from_landmark=t1-starts1';
    for i=1:2    
        tmp=samples_from_landmark;
        if i==1
            tmp(tmp<0)=NaN;
        else
            tmp(tmp>0)=NaN;
        end
        [n,nearest_neighbor_idx] = min(abs(tmp),[],2);
        nearest_neighbor_idx = nearest_neighbor_idx;
        samples_from_nn{i} = t1-starts1(nearest_neighbor_idx);
        t2s{i} = starts2(nearest_neighbor_idx) + (samples_from_nn{i}*clock_ratio);
        t2s{i}(isnan(n)) = NaN;
        samples_from_nn{i}(isnan(n))=NaN;        
    end
    if params.forbid_out_of_range % set to NaN any sample indices out of the range of the temporal landmarks (i.e. assume there may be missing data out there)
        nans = nans | isnan(samples_from_nn{1}) | isnan(samples_from_nn{2});
    end
    %% set t2 to weighted average of estimate from the two nearest landmarks
    t2=wmean([t2s{:}],1./(eps+abs([samples_from_nn{:}])),2);
    %% determine if the the two estimates disagree significantly and set those to NaN
    disagree=abs(t2s{1}-t2s{2})>params.max_uncertainty_s*timestamps2.samp_rate & (min(abs(samples_from_nn{1}),abs(samples_from_nn{2}))./timestamps1.samp_rate)>timestamp_duration_s ; % flag for uncertainty if the two alignments disagree by more than max_uncertainty_s and if the timestamp didn't occur during a timestamp barcode, in which case we know no data was lost
    t2(disagree)=NaN;
    %% set upper and low bounds on t2 based on the disagreement between the right and left alignments
    t2_min = min(t2s{:});
    t2_max = max(t2s{:});
    %% set NaN inputs or out of bounds to NaNs in the output
    t2_min(nans)=NaN;
    t2_max(nans)=NaN;
    t2(nans)=NaN;   
    t2=reshape(t2,size(t1));
    t2_min = reshape(t2_min,size(t1));
    t2_max = reshape(t2_max,size(t1));
end


% resolve_mult_sess_per_day
%
%   Takes as input a number of rat names and dates. The function then checks whether are are
%   multiple sessions per day, and if so, what to do with it. The third input is then used to
%   specify the rule for dealing with multiple sessions in the same day:
%       "ask"           Asks the user to select a sessid
%       "take first"    Takes the first session
%       "take all"      Takes all the sessions from the same day
function [selected_sessid] = resolve_mult_sess_per_day(rats, dates, varargin)
input_parser = inputParser;
addParameter(input_parser, 'multi_sess_rule', 'ask', @(x) ischar(x))
parse(input_parser, varargin{:});
for param = fields(input_parser.Results)'; param = param{:}; eval([param ' = input_parser.Results.' param ';']); end

rats = string(rats);
try
    dates = datetime(dates);
catch
    dates = datetime(dates, 'Format', 'yyyy_MM_dd');
end
rats = rats(:);
dates = dates(:);

selected_sessid = [];
for r = 1:numel(rats)
for d = 1:numel(dates)
    date_str = datetime(dates(d), 'Format', 'yyyy-MM-dd');
    
    command = sprintf(['select sessid, starttime ' ...
                       'from sessions ' ...
                       'where ratname="%s" and sessiondate = "%s"'], rats{r}, date_str);
    [sessid, starttime] = bdata(command);
    
    if numel(sessid) == 1
        selected_sessid = [selected_sessid; sessid];
    elseif numel(sessid) > 1
        % first try the log
        % commented out the bit about the log because adrian doesn't use
        % it.
%         Log = PB_import_opto_ephys_log(rats{r});
%         selected_sessid = Log.(rats{r}).sessid(Log.(rats{r}).Date == dates(d));
%         if numel(selected_sessid) == 1; return; end
%         % if that doesn't work, ask the user
        switch multi_sess_rule
            case 'ask'
                need_user_input = true;
                while need_user_input
                    clc
                    disp(' ')
                    disp('There are multiple sessids!')
                    disp(' ')
                    command = sprintf(['select sessid, ratname, hostname, n_done_trials, sessiondate, starttime, endtime ' ...
                                       'from sessions where ratname="%s" and sessiondate = "%s"'], rats{r}, date_str);
                    bdata(command);
                    disp(' ')
                    questdlg('There are multiple sessids! Please examine the command window.', ' ', 'OK', 'OK');
                    input_sessid = input('Please type the sessid that you want to process: ', 's');
                    input_sessid = str2double(input_sessid);
                    if any(input_sessid == sessid)
                        selected_sessid = [selected_sessid; input_sessid];
                        need_user_input = false;
                        disp(' ')
                        disp(['Thanks, got it. The sessid is ' num2str(input_sessid) '.'])
                    else
                        disp(' ')
                        disp('You made a typo. Please try again.')
                        pause(1)
                    end            
                end
            case 'take first'
                starttime = datetime(starttime, 'InputFormat', 'HH:mm:ss');
                [~, idx] = min(starttime);
                selected_sessid = [selected_sessid; sessid(idx)];
            case 'take all'
                selected_sessid = [selected_sessid; sessid];
        end
    end
end
end
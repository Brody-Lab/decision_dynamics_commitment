function output = sync_video_to_trials4(sessid,lfile,do_side,flash_channel,output,find_missing_frames,varargin)

if nargin < 3; do_side = 'lr'; end
if nargin < 4; flash_channel = []; end
if nargin < 5; output = []; end
if nargin < 6; find_missing_frames = 1; end

if isempty(output)
    if exist(lfile,'file')
        load(lfile)
    else
        disp([lfile,' does not exist']);
        return
    end
end

peh = bdata(['select peh from parsed_events where sessid=',num2str(sessid)]);
pd  = bdata(['select protocol_data from sessions where sessid=',num2str(sessid)]);
peh = peh{1};
pd = pd{1};

state_names = fields(peh(1).states);
if sum(strcmp(state_names,'sync_flash')) > 0
    allvalve = [];
    for i = 1:numel(peh)
        state_times = peh(i).states.sync_flash;
        has_nan = sum(isnan(state_times),2);
        real_times = find(has_nan == 0,1,'first');
        
        allvalve(end+1) = mean(peh(i).states.sync_flash(real_times,:));
    end 
else
    if strcmp(do_side,'lr') || strcmp(do_side,'rl')
        allvalve = [pd.leftwatertime;pd.rightwatertime];
    elseif strcmp(do_side,'l')
        allvalve = pd.leftwatertime;
    elseif strcmp(do_side,'r')
        allvalve = pd.rightwatertime;
    else
        allvalve = [pd.leftwatertime;pd.rightwatertime];
    end
    allvalve = sortrows(allvalve);
    allvalve(isnan(allvalve)) = [];
    
end
framerate = output.framerate;

if isempty(flash_channel)
    %Figure out if it's IR LEDs or Red LEDs flashing
    C = output.RED_flash;
    Cdiff = C(2:end) - C(1:end-1);
    Ct = 4 * std(Cdiff);
    Cevent = [];
    lastevent = -99;
    for i = 1:numel(Cdiff)-3
        if Cdiff(i) > Ct && any(Cdiff(i+1:i+3) < -Ct) && i>lastevent+19
            temp = C(i-1:i+2);
            flash = find(temp == max(temp),1,'first');
            Cevent(end+1) = (i-2)+flash;  %#ok<AGROW>
            lastevent     = i; 
        end
    end
    if ~isempty(Cevent)
        ratio_red = mean(output.R_luminance(Cevent) ./ output.B_luminance(Cevent));
    end

    C = output.IR_flash;
    Cdiff = C(2:end) - C(1:end-1);
    Ct = 4 * std(Cdiff);
    Cevent = [];
    lastevent = -99;
    for i = 1:numel(Cdiff)-3
        if Cdiff(i) > Ct && any(Cdiff(i+1:i+3) < -Ct) && i>lastevent+19
            temp = C(i-1:i+2);
            flash = find(temp == max(temp),1,'first');
            Cevent(end+1) = (i-2)+flash;  %#ok<AGROW>
            lastevent     = i; 
        end
    end
    if ~isempty(Cevent)
        ratio_ir = mean(output.R_luminance(Cevent) ./ output.B_luminance(Cevent));
    end

    if ratio_red > 1.1
        C = output.RED_flash;
        flash_channel = 'RED';
    else
        C = output.IR_flash;
        flash_channel = 'IR';
    end
elseif strcmpi(flash_channel,'RED')
    C = output.RED_flash;
else
    C = output.IR_flash;
end
    
BEST_PARAMS = [];
SCORE       = [];
MUST_MATCH  = [];
CEVENT      = cell(0);
CT          = [];
VIDEO_TIMES = cell(0);

global valve_times
global video_times

Cdiff = C(2:end) - C(1:end-1);
        
threshold_range = 4;%:8;
for flash_threshold = threshold_range
    Ct = flash_threshold * nanstd(Cdiff);
    
    Cevent = [];
    fullflash = [];
    lastevent = -99;
    for i = 1:numel(Cdiff)-5
        if Cdiff(i) > Ct && any(Cdiff(i+1:i+5) < -Ct) && i>lastevent+framerate            
            off = find(Cdiff(i:i+5) < -Ct);
            flash = C(i+1:i+off-1);
            Cevent(end+1) = i + sum(flash .* (1:numel(flash))) / sum(flash);
            fullflash(end+1,:) = C(round(Cevent(end))-5:round(Cevent(end))+5);
            
        end
    end
    if isempty(Cevent); break; end

    video_times = Cevent / framerate;
    valve_times = allvalve;
    
    VIDEO_TIMES{end+1} = video_times;
    
    lb = [0.99,-1e4]; 
    ub = [1.01, 1e4];

    options = optimoptions('fmincon','Display','off','MaxFunEvals',1e4,...
        'TolCon',1e-12,'MaxIter',1e3,'OptimalityTolerance',1e-12,'StepTolerance',1e-20);
    
    for i = 1:100
        %disp(['Running Offset Fit Test ',num2str(i)]);
        seed = (rand(size(lb)) .* (ub - lb)) + lb;
        [best_params(i,:),score(i)] = fmincon(@test_alignment_ordered_pairs,seed,[],[],[],[],lb,ub,[],options);
        %disp(score(i))
    end
    best_score = find(score == min(score),1,'first');
    best_params = best_params(best_score,:);    
    
    %lb = [0.99,-1e4]; 
    %ub = [1.01, 1e4];
    %best_params = fmincon(@test_alignment_ordered_pairs,best_params,[],[],[],[],lb,ub,[],options);

    video_predict = ((valve_times * best_params(1)) + best_params(2));
    
    d = [];
    for i = 1:numel(video_predict)
        for j = 1:numel(video_times)
            d(i,j) = abs(video_predict(i) - video_times(j));
        end
    end
    must_match = round(min([numel(valve_times),numel(video_times)]) * 0.9);
    
    if must_match > (numel(allvalve) * 0.75)
        pairs = [];
        for k = 1:must_match
            [i,j] = ind2sub(size(d),find(d == min(d(:)),1,'first'));
            pairs(k,:) = [i,j];
            d(i,:) = Inf;
            d(:,j) = Inf;
        end
        
        valve_times = valve_times(pairs(:,1));
        video_times = video_times(pairs(:,2));

        [best_params,score] = fmincon(@test_alignment_ordered_pairs,best_params,[],[],[],[],lb,ub,[],options);
        disp(['Threshold ',num2str(flash_threshold),' Score:',num2str(score)]);

        BEST_PARAMS(end+1,:) = best_params;
        SCORE(end+1)         = score;
        
    else
        BEST_PARAMS(end+1,:) = nan;
        SCORE(end+1)         = Inf;
    end
    
    MUST_MATCH(end+1)    = must_match;
    CEVENT{end+1}        = Cevent;
    CT(end+1)            = Ct;
end

if isempty(SCORE)
    disp('No events detected for any threshold. Alignment is not possible.')
    return;
end

newscore = SCORE ./ MUST_MATCH;
BestT = find(newscore == min(newscore),1,'first');

best_params = BEST_PARAMS(BestT,:);
score       = SCORE(BestT);
cevent      = CEVENT{BestT};  
ct          = CT(BestT);

output.equation1 = ['F = output.real_frame_number(round(((T * ',sprintf('%10.10f',best_params(1)),') + ',sprintf('%10.10f',best_params(2)),') * ',num2str(framerate),'));'];
output.equation2 = [                              'F = (((T * ',sprintf('%10.10f',best_params(1)),') + ',sprintf('%10.10f',best_params(2)),') * ',num2str(framerate),');'];

output.timeshift = best_params(2);
output.timescale = best_params(1);
output.alignment_error = score;
output.all_scores = SCORE;

output.video_derivative = Cdiff;
output.video_threshold  = ct;
output.flash_channel    = flash_channel;

output.video_events     = cevent;
output.valve_time       = allvalve;

video_times = VIDEO_TIMES{BestT};
valve_times = allvalve;

pairs = test_alignment_ordered_pairs([best_params,0,2]);
framediff = (pairs(:,2) - pairs(:,1)) * framerate;
framediff2 = (framediff(2:end) - framediff(1:end-1));

for i=2:numel(framediff2)-2; zz(i)=mean(framediff2(i-1:i+1)); end
t = mean(zz) - (3*std(zz));

if isfield(output,'real_frame_number'); rfnu = output.real_frame_number;
else,                                   rfnu = 1:numel(output.RED_flash);
end
    
temp = find(zz < t);
if ~isempty(temp) && find_missing_frames == 1
    for i = 1:numel(temp)
        temp1 = framediff2(temp(i)-1:temp(i)+1);
        temp2 = find(temp1 == min(temp1),1,'first');
        temp3(i) = temp(i) + temp2 - 2;
    end
    droppedframes = unique(temp3);

    %droppedframes = find(framediff2 < -0.7);
    droppedframenum = -round(framediff2(droppedframes));
    droppedframepos = round((pairs(droppedframes,2).*framerate)) + framerate;

    %bad = find(droppedframenum > 5);
    %droppedframenum(bad) = [];
    %droppedframepos(bad) = [];
    
    newC = output.RED_flash;
    for i = 1:numel(droppedframepos)
        newC = [newC(1:droppedframepos(i)),ones(1,droppedframenum(i))*nan,newC(droppedframepos(i)+1:end)];
        rfnu = [rfnu(1:droppedframepos(i)),ones(1,droppedframenum(i))*nan,rfnu(droppedframepos(i)+1:end)];
        
        if i < numel(droppedframepos)
            droppedframepos(i+1:end) = droppedframepos(i+1:end) + droppedframenum(i);
        end
    end
else
    droppedframepos = [];
    droppedframenum = [];
    newC = [];
end

output.eventpairs       = pairs;
output.droppedframes    = droppedframepos;
output.droppedframesnum = droppedframenum;
output.RED_flash_insframes = newC;
output.real_frame_number   = rfnu;

disp('Alignment COMPLETE');
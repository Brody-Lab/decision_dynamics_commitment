function output = sync_video_to_trials2(sessid,data,varargin)

if nargin == 1; data = []; end

[v_pname,v_fname,pd] = bdata(['select video_path, video_file, protocol_data from sessions where sessid=',num2str(sessid)]);
pd = pd{1};
    
if isempty(data)
    map_bucket_drive;
    vfile = [v_pname{1},filesep,v_fname{1}];

    done = 0;
    cnt  = 0;
    C = [];
    framerate = [];
    while done == 0
        cnt = cnt + 1;
        disp(['Analyzing Frames ',num2str(((cnt-1)*1000)+1),' to ',num2str(cnt*1000),'...']);
        x = mmread(vfile,((cnt-1)*1000)+1:cnt*1000);
        if isempty(x.frames); done = 1; break; end %#ok<NASGU>
        for f = 1:numel(x.frames)
            R = x.frames(f).cdata(:,:,1);
            G = x.frames(f).cdata(:,:,2);
            B = x.frames(f).cdata(:,:,3);
            
            Ri = sum(R(:));
            Gi = sum(G(:));
            Bi = sum(B(:));
            
            C(end+1) = Ri - ((Gi + Bi)/2); %#ok<AGROW>
        end
        if isempty(framerate)
            framerate = round(1 / mean((x.times(2:end) - x.times(1:end-1))));
        end
    end
else
    C = data.video_luminance;
    framerate = data.framerate;
    vfile = data.vfile;
end

Cdiff = C(2:end) - C(1:end-1);

allvalve = [pd.leftwatertime;pd.rightwatertime];
allvalve = sortrows(allvalve);
allvalve(isnan(allvalve)) = [];

SCALE1 = [];
BESTSHIFT2 = [];
SCORE2 = [];
CT = [];
CEVENT = cell(0);

threshold_range = 4:15;
for flash_threshold = threshold_range
    Ct = flash_threshold * std(Cdiff);

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

    Ctime = Cevent / framerate;

    input.all_video = Ctime;
    input.all_valve = allvalve;

    [bestshift1,scale1,score1] = align_video_valve(input); %#ok<ASGLU>

    input.all_video = input.all_video * scale1;

    [bestshift2,scale2,score2] = align_video_valve(input); %#ok<ASGLU>
    disp(['Threshold ',num2str(flash_threshold),' Score:',num2str(score2(1))]);
    
    SCALE1(end+1)       = scale1;
    BESTSHIFT2(end+1) = bestshift2;
    SCORE2(end+1,:)     = score2;
    CT(end+1)           = Ct;
    CEVENT{end+1}       = Cevent;
    
end

%if any(SCORE2(:,3) == 1)
%    bestscore = min(SCORE2(SCORE2(:,3)==1));
%    BestT = find(SCORE2(:,1) == bestscore,1,'first');
%else
    %BestT = find(SCORE2(:,1) == min(SCORE2(:,1)),1,'first');
    newscore = SCORE2(:,1) ./ (SCORE2(:,2) .* SCORE2(:,3));
    BestT = find(newscore == min(newscore),1,'first');
%end

bestshift2 = BESTSHIFT2(BestT);
scale1 = SCALE1(BestT);
score2 = SCORE2(BestT,:);
Ct     = CT(BestT);
Cevent = CEVENT{BestT};
    
output.equation1 = ['F = round(((T + ',sprintf('%10.10f',bestshift2),') ./ ',sprintf('%10.10f',scale1),') .* ',sprintf('%10.10f',framerate),');'];
output.equation2 = ['F = ((T + ',sprintf('%10.10f',bestshift2),') ./ ',sprintf('%10.10f',scale1),') .* ',sprintf('%10.10f',framerate),';'];
output.timeshift = bestshift2;
output.timescale = scale1;
output.framerate = framerate;
output.alignment_error = score2(1);
output.all_scores = SCORE2;
output.fraction_video_events_aligned = score2(2);
output.fraction_valve_events_aligned = score2(3);
output.video_luminance  = C;
output.video_derivative = Cdiff;
output.video_threshold  = Ct;fi
output.video_events     = Cevent;
output.valve_time       = allvalve;
output.vfile            = vfile;

disp('Alignment COMPLETE');
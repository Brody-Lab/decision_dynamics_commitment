function score = test_alignment_ordered_pairs(p)

global valve_times
global video_times

if numel(p) < 3; dsp = 0;         else, dsp = p(3); end
if numel(p) < 4; output_type = 1; else, output_type = p(4); end

video_predict = (valve_times.*p(1)) + p(2);

if dsp == 1
    figure; hold on; 
    plot(video_predict,ones(size(video_predict)),'*k'); 
    plot(video_times,ones(size(video_times))*2,'*r');
    set(gca,'ylim',[0,3]);
end

vlvt = video_predict;
vidt = video_times;

vlvc = 1;
vidc = 1;

pairs = [];

while vlvc <= numel(vlvt) && vidc <= numel(vidt)

    vidd = abs(vidt(vidc) - vlvt);
    vlvd = abs(vlvt(vlvc) - vidt);

    if min(vlvd) < min(vidd)
        vidp = find(vlvd == min(vlvd),1,'first'); 
        pairs(end+1,:) = [vlvt(vlvc),vidt(vidp)];
        vlvc = vlvc + 1;
        vidc = vidp + 1;
    else    
        vlvp = find(vidd == min(vidd),1,'first');
        pairs(end+1,:) = [vlvt(vlvp),vidt(vidc)];
        vlvc = vlvp + 1;
        vidc = vidc + 1;
    end

    vlvt(1:vlvc-1) = nan;
    vidt(1:vidc-1) = nan;
    
    if dsp == 1; plot([pairs(end,1),pairs(end,2)],[1,2],'b'); end
end

missed_vlv = numel(vlvt) - size(pairs,1);

vlvt = video_predict;
for i = 1:size(pairs,1)
    vlvt(find(vlvt == pairs(i,1),1,'first')) = nan;
end

misd = [];
for i = 1:numel(vlvt)
    if ~isnan(vlvt(i))
        vlvd = abs(vlvt(i) - video_times);
        
        misd(end+1) = min(vlvd);
    end
end
if dsp == 1; plot(vlvt,ones(size(vlvt)),'*g'); end

score = sum((pairs(:,2) - pairs(:,1)).^2) + sum(misd.^2);
if dsp == 1; title(score); end

if output_type == 2
    score = pairs;
end




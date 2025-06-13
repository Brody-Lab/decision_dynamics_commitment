%function output = align_video_valve_events(valve_times,video_times)

%must_match = round(min([numel(valve_times),numel(video_times)]) * 0.9)
%global valve_times
%global video_times


function score = test_alignment_offset(p)

global valve_times
global video_times


video_predict = valve_times + p(1);
    
d = [];
for i = 1:numel(video_predict)
    for j = 1:numel(video_times)
        d(i,j) = abs(video_predict(i) - video_times(j));
    end
end
must_match = round(min([numel(valve_times),numel(video_times)]) * 0.9);

pairs = [];
for k = 1:must_match
    [i,j] = ind2sub(size(d),find(d == min(d(:)),1,'first'));
    pairs(k,:) = [i,j];
    d(i,:) = Inf;
    d(:,j) = Inf;
end

score = sum((video_predict(pairs(:,1)) - video_times(pairs(:,2))).^2);





return
video_predict = ((valve_times * p(1)) + p(2));

score = 0;
for i = 1:numel(video_predict)
    score = score + (min(abs(video_predict(i) - video_times)) ^2);
end

valve_predict = (video_times - p(2)) / p(1);
for i = 1:numel(valve_predict)
    score = score + (min(abs(valve_predict(i) - valve_times)) ^2);
end

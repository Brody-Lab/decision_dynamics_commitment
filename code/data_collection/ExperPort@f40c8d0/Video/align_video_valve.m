function [bestshift,scale,score] = align_video_valve(input) %video_event,valve_time)

%input.left_video;
%input.left_valve;
%input.right_video;
%input.right_valve;

% if numel(video_event) < numel(valve_time)
%     a = video_event; b = valve_time;
% else
%     b = video_event; a = valve_time;
% end

for iter = 1:4
    if iter == 1
        %shift = min([input.left_video(1),input.right_video(1)]) -...
        %        max([input.left_valve(end),input.right_valve(end)]) :10: ...
        %        max([input.left_video(end),input.right_video(end)]) +...
        %        min([input.left_valve(1),input.right_valve(1)]);
        shift = input.all_video(1)-input.all_valve(end) :10: ...
                input.all_video(end)+input.all_valve(1);    
    elseif iter == 2
        shift = bestshift-100:bestshift+100;
    elseif iter == 3
        shift = bestshift-10:0.1:bestshift+10;
    else
        shift = bestshift-1:0.01:bestshift+1;
    end
    
    %for side = 1:2
    %    if side == 1
    %        a = input.left_video;
    %        b = input.left_valve;
            a = input.all_video;
            b = input.all_valve;
    %    else
    %        a = input.right_video;
    %        b = input.right_valve;
    %    end
        
        offset = [];
        d = zeros(numel(a),numel(b)); 
        for i = 1:numel(shift)
            bnew = b+shift(i);
            for j = 1:numel(b)
                d(:,j) = abs(a - bnew(j)); 
            end
            [r,c] = ind2sub(size(d),find(d == min(d(:)),1,'first'));

            pairs = [r,c,d(r,c)];
            d(r,:) = nan;
            d(:,c) = nan;

            while pairs(end,1) < numel(a) && pairs(end,2) < numel(b)
                besta = nanmin(d(pairs(end,1)+1,:));
                bestb = nanmin(d(:,pairs(end,2)+1));

                if isnan(besta) && isnan(bestb); break; end
                
                if besta < bestb || isnan(bestb)
                    r = pairs(end,1)+1;
                    c = find(d(r,:) == besta,1,'first');
                else
                    c = pairs(end,2)+1;
                    r = find(d(:,c) == bestb,1,'first');
                end
                pairs(end+1,:) = [r,c,d(r,c)];
                d(r,:) = nan;
                d(:,c) = nan;
            end
            pairs(end+1,:) = pairs(1,:);
            pairs(1,:) = [];

            while pairs(end,1) > 1 && pairs(end,2) > 1
                besta = nanmin(d(pairs(end,1)-1,:));
                bestb = nanmin(d(:,pairs(end,2)-1));

                if isnan(besta) && isnan(bestb); break; end
                
                if besta < bestb || isnan(bestb)
                    r = pairs(end,1)-1;
                    c = find(d(r,:) == besta,1,'first');
                else
                    c = pairs(end,2)-1;
                    r = find(d(:,c) == bestb,1,'first');
                end
                pairs(end+1,:) = [r,c,d(r,c)];
                d(r,:) = nan;
                d(:,c) = nan;
            end

            if size(pairs,1) > min([numel(a),numel(b)]) / 2
                offset(i) = sum(pairs(:,3).^2);
            else
                offset(i) = nan;
            end
        end
        
        %if side == 1; offset_L = offset; pairs_L = pairs;
        %else          offset_R = offset; pairs_R = pairs;
        %end
              
    %end

    %offset = offset_L + offset_R;
    bestshift = shift(offset == nanmin(offset));
end
score(1) = nanmin(offset);
score(2) = size(pairs,1) / numel(a);
score(3) = size(pairs,1) / numel(b);


%minL = pairs_L(find(pairs_L(:,1) == min(pairs_L(:,1))),1:2);
%maxL = pairs_L(find(pairs_L(:,1) == max(pairs_L(:,1))),1:2);
%
%minR = pairs_R(find(pairs_R(:,1) == min(pairs_R(:,1))),1:2);
%maxR = pairs_R(find(pairs_R(:,1) == max(pairs_R(:,1))),1:2);
%
%Lscale = ((input.left_video(minL(1)) - (input.left_valve(minL(2)) + bestshift)) - ...
%          (input.left_video(maxL(1)) - (input.left_valve(maxL(2)) + bestshift))) / ...
%          (input.left_video(maxL(1)) -  input.left_video(minL(1)));
%
%Rscale = ((input.right_video(minR(1)) - (input.right_valve(minR(2)) + bestshift)) - ...
%          (input.right_video(maxR(1)) - (input.right_valve(maxR(2)) + bestshift))) / ...
%          (input.right_video(maxR(1)) -  input.right_video(minR(1)));
%
%scale = 1 + mean([Lscale,Rscale]);

minA = pairs(find(pairs(:,1) == min(pairs(:,1))),1:2);
maxA = pairs(find(pairs(:,1) == max(pairs(:,1))),1:2);

scale = ((input.all_video(minA(1)) - (input.all_valve(minA(2)) + bestshift)) - ...
         (input.all_video(maxA(1)) - (input.all_valve(maxA(2)) + bestshift))) / ...
         (input.all_video(maxA(1)) -  input.all_video(minA(1)));
scale = 1 + scale;     


%
% return
% shift = -1e5:100:1e5;
% for i = 1:numel(shift)
%     bnew = b+shift(i);
%     for j = 1:numel(a)
%         diff(j) = min(abs(bnew - a(j)));
%     end
%     offset(i) = sum(diff);
% end
% bestshift = shift(offset == min(offset))
% 
% shift = bestshift-1000:bestshift+1000;
% for i = 1:numel(shift)
%     bnew = b+shift(i);
%     for j = 1:numel(a)
%         diff(j) = min(abs(bnew - a(j)));
%     end
%     offset(i) = sum(diff);
% end
% bestshift = shift(offset == min(offset))
% 
% shift = bestshift-10:0.01:bestshift+10;
% for i = 1:numel(shift)
%     bnew = b+shift(i);
%     for j = 1:numel(a)
%         diff(j) = min(abs(bnew - a(j)));
%     end
%     offset(i) = sum(diff);
% end
% bestshift = shift(offset == min(offset))
% 
% bnew = b + bestshift;
% for j = 1:numel(a)
%     diff(j) = min(abs(bnew - a(j)));
% end
% badpoints = find(abs(diff) > 5);
% 
% anew = a;
% anew(badpoints) = [];
% 
% diff = [];
% shift = bestshift-10:0.01:bestshift+10;
% for i = 1:numel(shift)
%     bnew = b+shift(i);
%     for j = 1:numel(anew)
%         diff(j) = min(abs(bnew - anew(j)));
%     end
%     offset(i) = sum(diff);
% end
% bestshift = shift(offset == min(offset))
% 
% bnew = b + bestshift;
% for j = 1:numel(anew)
%     diff(j) = min(abs(bnew - anew(j)));
% end
% 
% 99
% 

function output = averageshape(s1,s2, wt_s1, wt_s2)
% s1,s2 - the two shapes to average, given either in vertex coordinates or
% in pixelated form.
% da,db - distance of interpolated shape to s1, distance to s2

if (wt_s1 + wt_s2) ~= 1
    error('wt_s1 and wt_s2 must add to 1');
end;


if size(s1,1) == 2 %Shape defined by coordinates
    m1 = poly2mask(s1(2,:),s1(1,:),max(max(s1))+10,max(max(s1))+10);
else
    m1 = s1;
end
c1 = regionprops(double(m1),'Centroid');

p1 = bwperim(m1);
p1 = smoothperim(p1);
tp1 = traceboundary(p1);

d1 = abs(tp1(:,1) - c1.Centroid(2));
d1(d1<=1) = 1;
d1(d1> 1) = 0;
h1 = tp1(d1==1,2);
h1 = h1(h1 == max(h1));
h1 = h1(1);
start1 = find((d1 == 1) & (tp1(:,2) == h1));
start1 = start1(1);
tp1new = tp1(start1:end,:);
tp1new = [tp1new; tp1(1:start1-1,:)];

tp1new = perimdirection(tp1new,c1.Centroid,'ccw');
tp1new(:,3) = (1:size(tp1new,1)) / size(tp1new,1);

if size(s2,1) == 2 %Shape defined by coordinates
    m2 = poly2mask(s2(2,:),s2(1,:),max(max(s2))+10,max(max(s2))+10);
else
    m2 = s2;
end
c2 = regionprops(double(m2),'Centroid');

p2 = bwperim(m2);
p2 = smoothperim(p2);
tp2 = traceboundary(p2);

d2 = abs(tp2(:,1) - c2.Centroid(2));
d2(d2<=1) = 1;
d2(d2> 1) = 0;
h2 = tp2(d2==1,2);
h2 = h2(h2 == max(h2));
h2 = h2(1);
start2 = find((d2 == 1) & (tp2(:,2) == h2));
start2 = start2(1);
tp2new = tp2(start2:end,:);
tp2new = [tp2new; tp2(1:start2-1,:)];

tp2new = perimdirection(tp2new,c2.Centroid,'ccw');
tp2new(:,3) = (1:size(tp2new,1)) / size(tp2new,1);

output = zeros(100,2);
c = 0;
for i = 0.01:0.01:1
    c=c+1;
    v1 = find(abs(tp1new(:,3) - i) == min(abs(tp1new(:,3) - i))); v1 = v1(1);
    v2 = find(abs(tp2new(:,3) - i) == min(abs(tp2new(:,3) - i))); v2 = v2(1);
    
     output(c,:) = [ ...
         mean([(wt_s1 * 2* tp1new(v1,1)) (wt_s2 * 2* tp2new(v2,1))]) ...
         mean([(wt_s1 * 2* tp1new(v1,2)) (wt_s2 * 2* tp2new(v2,2))])];
end


%output{1} = tp1;
%output{2} = tp2;
% resizes a polygon by a factor of fac
function p = resize_polygon(p, fac)
oldp = p;
p=round(p);

m1 = poly2mask(p(:,1),p(:,2),max(max(p))+10,max(max(p))+10);

c1 = regionprops(double(m1),'Centroid');

p(:,1) = p(:,1) - c1.Centroid(1); 
p(:,2) = p(:,2) - c1.Centroid(2);

p = p * fac;
p(:,1) = p(:,1) + c1.Centroid(1);
p(:,2) = p(:,2) + c1.Centroid(2);

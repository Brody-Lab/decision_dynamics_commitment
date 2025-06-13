
function dp=ndprime(x,y);

allX=[x;y];
[e,f]=sortedeig(cov(allX));
m=mean(allX);
c=e(:,1);
d=dot(c,m);

h=(sum((y*c)<d));
FA=(sum((x*c)<d));
ph=h/(length(y)+length(x));
pFA=FA/(length(y)+length(x));

%there is an assumtion here  that the distribution is guassian
dp=norminv(ph)-norminv(pFA);
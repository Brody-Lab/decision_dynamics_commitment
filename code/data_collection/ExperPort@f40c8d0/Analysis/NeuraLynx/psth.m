function [y,x,h]=psth(ev,ts,pre,post,bin, krn,cnf)
% [y,x,h]=psth(ev,ts,pre,post,bin, krn,cnf)
% ev and ts in seconds
% pre , post, bin in milliseconds

if nargin<6
	krn=1;
end

if nargin<7
	cnf={'k',figure,0.5};
end



[y,x]=tsraster(ev*1000,ts*1000,pre,post,bin);
y=y*1000/bin;
x=x/1000;

ymn=mean(jconv(krn, y));
yse=stderr(jconv(krn, y));

shadeplot(x,ymn-yse, ymn+yse,cnf);
hold on
h=plot(x,ymn,cnf{1});


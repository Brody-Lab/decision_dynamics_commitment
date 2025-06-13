function cscPeth(csc, ref, pre, post)


t=diff(csc.ts);
time_per_sample=t(1)/512;
roi=ceil((post+pre)/time_per_sample);
dV=zeros(numel(ref), roi);
for refX=1:numel(ref)
    
si=ref(refX)-pre;
ei=ref(refX)+post;
cscIdx=qfind(csc.ts, [si ei]); % returns the indexes closest to the reference event

dVc=reshape(csc.data(cscIdx(1):cscIdx(2),:)', numel(csc.data(cscIdx(1):cscIdx(2),:)), 1);
% return a vector that contains the relevant data.  and then trim the bits
% that are outside the temporal ROI

skips=si-csc.ts(cscIdx(1));
skips=round(skips/time_per_sample);

dV(refX,:)=dVc(skips:(skips+roi-1));

end
xax=-pre:time_per_sample:post;
xax=xax/1E6;
y=mean(dV);
y=jconv([1 1 1 1 1]/5, y);
%se=stderr(dV);
%h=gcf;
%shadeplot(xax, y-se,y+se,{ [.8 .8 .8 ] h 1})
%hold on
plot(xax,y,'k');





function [xax,y]=cscPeth(csc, ref, pre, post)


t=diff(csc.ts);
time_per_sample=t(1)/512;
roi=ceil((post+pre)/time_per_sample);
dV=zeros(numel(ref), roi)+nan;
for refX=1:numel(ref)

    si=ref(refX)-pre;
    ei=ref(refX)+post;
    
    % have to check for condition where the pre or post puts the index into
    % the next trial.
    
    cscIdx=qfind(csc.ts, [si ei]); % returns the indexes closest to the reference event
tss=diff(csc.ts(cscIdx(1):(cscIdx(2)+1)));
if numel(unique(tss))>1 
    %this overlaps trials.
    %skip this one for now.... maybe we'll come up with a better fix...  
    continue;
    
end
    dVc=reshape(csc.data(cscIdx(1):cscIdx(2),:)', numel(csc.data(cscIdx(1):cscIdx(2),:)), 1);
    % return a vector that contains the relevant data.  and then trim the bits
    % that are outside the temporal ROI

    skips=si-csc.ts(cscIdx(1));
    skips=round(skips/time_per_sample);
    if skips==0
        skips=1;
    end

    dV(refX,:)=dVc(skips:(skips+roi-1));

end
y=dV;
xax=-pre:time_per_sample:post;
xax=xax/1E6;


mn=nanmean(reshape(y, numel(y),1));
se=nanstd(reshape(y,numel(y),1));
z=(y-mn)/se;
%z(abs(z)>2.5)=nan;

%krn=normpdf(-100:99, 0 , 50);
%y=conv2(krn, z);
%y=y(:,(numel(krn)/2):end-(numel(krn)/2));

y=z;
imagesc(y);
%se=stderr(dV);
%h=gcf;
%shadeplot(xax, y-se,y+se,{ [.8 .8 .8 ] h 1})
%hold on
%surf(xax,1:numel(ref),y);





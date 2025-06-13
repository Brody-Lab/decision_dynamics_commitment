function [bon,boff]=getBursts(TS, thres)

if iscell(TS) && (numel(TS)==1)
    TS=TS{1};
end

isi=TS(2:end)-TS(1:end-1);
bind=find(isi<=thres);
bts=zeros(1,max(bind));
bts(bind)=1;

krn=[1 -1];

onoff=conv(bts, krn);
bon=TS(onoff==1);
boff=TS(onoff==-1);




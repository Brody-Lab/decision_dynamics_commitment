function median_filter_and_save_theta(sessid)

if nargin==0
    sessid=bdata('select sessid from tracking where proc_theta is null');
end

for sx=1:numel(sessid)
    try
        [ts a]=get_tracking(sessid(sx),'isdec',true);
        fr=round(1/median(diff(ts)));
        filt_length=round(fr/10)*2+1;
        new_theta=medfilt1(a.theta,filt_length);
        mym(bdata,'update tracking set proc_ts="{M}", proc_theta="{M}" where sessid="{S}"',ts,new_theta, sessid(sx))
    catch end
    
end
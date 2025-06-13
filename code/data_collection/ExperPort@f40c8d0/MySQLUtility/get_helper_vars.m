function hv=get_helper_vars(sessid)
% hv=get_helper_vars(sessid)
[tn,names,val]=bdata('select trial_n,sph_fullname,sph_value from protocol.helper_vars where sessid="{S}" order by trial_n',sessid);
if isempty(tn)
    hv=[];
    return;
end
u_names=unique(names);

for ux=1:numel(u_names)
    uidx=strmatch(u_names(ux),names);
    this_name=u_names{ux}(14:end);
    
    if isscalar(val{uidx(1)})
        try
            hv.(this_name)=cell2mat(val(uidx));
        catch me
            hv.(this_name)=val(uidx);
        end
    else
        hv.(this_name)=val(uidx);
    end
end

hv.trial_n=tn(uidx);

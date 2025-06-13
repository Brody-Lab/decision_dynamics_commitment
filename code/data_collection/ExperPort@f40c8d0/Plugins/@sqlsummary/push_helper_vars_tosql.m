function push_helper_vars_tosql(obj,trialn,varargin)

try
[rigID e m] = bSettings('get','RIGS','Rig_ID');
if isnan(rigID)
	return
end
	pairs = { ...
		'sessid'            getSessID(obj);...
		}; parseargs(varargin, pairs);
	
	if trialn > 0,
		hvs=SessionDefinition(obj,'get_helper_vars');
		for hvx=1:numel(hvs)
			if has_userprop_field(hvs{hvx},'save_to_helper_vars_table') && get_userprop(hvs{hvx},'save_to_helper_vars_table')
				sqlstr=['insert into protocol.helper_vars2 (sessid, trial_n,sph_fullname,sph_value) '...
						' values ("{S}","{S}","{S}","{M}")'];			
				bdata(sqlstr,sessid, trialn,get_fullname(hvs{hvx}), value(hvs{hvx}));
			end
		end
	end
catch
	fprintf(2,'Failed to send helper vars to sql in push_helper_vars_tosql\n')
	showerror
end
    
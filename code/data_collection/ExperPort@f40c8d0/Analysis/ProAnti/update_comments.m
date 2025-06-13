function update_comments

[id, pd] = bdata('select sessid, protocol_data from sessions where ratname regexp "{S}"', '^J01[0-6]$|J009');

for ux=1:numel(id)
	
	tts=unique(pd{ux}.context);
	if numel(tts)>1
		comments='mixed';
	elseif tts==1
		comments='pro';
	elseif tts==-1
		comments='anti';
	else
		'fucked'
		 continue;
	end
	
		 mym(2,'update sessions set comments="{S}", brokenbits=brokenbits+2 where sessid="{Si}"', comments, id(ux));
	
end
		
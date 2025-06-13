function err=post_process_spikes(sessid,force)

if nargin<2
	force=0;
end

already_done=bdata('select count(overlap) from cells where sessid="{S}"',sessid);
if already_done
	if ~force
		err=0;
		return;
	end
end

[cellid,ts,wave]=bdata('select cellid,ts,wave from spktimes where sessid="{S}"',sessid);

for cx=1:numel(cellid)
	
	isi=diff(ts{cx})*1e3;  % get isi in ms
	num_low_isi=sum(isi<1);
	frac_bad=num_low_isi/numel(isi);
    
    [i,c]=implanted_side(cellid(cx));
    if i=='r'
        rr=1;
    elseif i=='l'
        rr=0;
    else
        rr=nan;
    end
        
	
	% if we could get some info from the protocol about what to align on
	% then we could calculate background and trial activity, etc.  but
	% without some info... very hard.  We could ask all protocols to
	% have a function that returns this info..... hrm.
	overlap=0;
	for icx=1:numel(cellid)
		if icx==cx
			%skip this
        else
            %this rounds the timestamps to 100 us 
            ts_1=round(ts{cx}*10000);
            ts_2=round(ts{icx}*10000);
            
			c_overlap=numel(intersect(ts_1,ts_2));
			overlap=max(overlap,c_overlap);
		end
	end
	overlap=overlap/numel(ts{cx});
	
 rate=numel(ts{cx})/(ts{cx}(end)-ts{cx}(1));
 
 [spkH,hhW,pvW]=wave_stats(wave{cx});
 
	bdata('call update_celldata("{S}","{S}","{S}","{S}","{S}","{S}","{S}","{S}")', cellid(cx),rr,overlap,frac_bad,rate,hhW,pvW,spkH);
	
	% update_celldata`(cid  , recorded_on_right, overlap, frac_bad_isi, rate, half-height_width , peak-valley width , peak-valley height )

	
end

function [spkH,hhW,pvW]=wave_stats(wave)

% find which of the channels has the biggest waveform
mn=wave.mn;
for rx=1:size(mn,1)
 V(rx)=range(mn(rx,:));
end
[Rmax,ind]=max(V); 

spike=mn(ind,:);

[vMax,iMax]=max(spike);
[vMin,iMin]=min(spike);

if iMax>iMin
 spike=-spike;
 [vMax,iMax]=max(spike);
 [vMin,iMin]=min(spike);
end

pvW=(iMin-iMax);
spkH=Rmax;
spkF=spike(1:iMax);
spkL=spike((iMax+1):end);
hhW=(iMax+find(spkL<=(vMax/2),1,'first'))-find(spkF>=(vMax/2),1,'first');

	
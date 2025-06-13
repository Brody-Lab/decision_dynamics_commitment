function [ttimes, tnums]=trialnumtimes(ts, ttls)
% [ttimes, tnums]=trialnumtimes(ts, ttls)
% This is code to extract the TTL signalled trial number sent using the
% 'trialnum_indicator'.  
% http://brodylab/bcontrol/index.php/Dispatcher#Synchronizing_behavior_and_
% electrophysiological_recording
%


% Since adding the long cable we have some noise events on the digital
% input. However these events are always less than one clock cycle of the
% neuralynx box (<32 us). So let's just throw those away

tsthres=32;

dts=diff(ts);

badts=find(dts<tsthres);
badts=sort([badts badts+1]);
goodidx=1:numel(ts);
goodidx=setdiff(goodidx,badts(:));
ts=ts(goodidx);
ttls=ttls(goodidx);

dts=sort(diff(ts));



SIZE_FIELD=16;

% This setting needs to be the bitfield on the TTL inputs of the NeuraLynx
% machine.  
tnMask=2^0;
% for some reason the TTLS are not the usual.  
% changed by JCE 080815

% After changing the cable to use line 2, the TTLs were no longer coming in
% on the same bits. The following statement detects and fixes that
% situation ~kjm, 4/23/2018
if all(unique(ttls) == [0;12])
    tnMask = 2^2;
end

tnState=bitand(ttls(1),tnMask)&1;
tnts=ts(1);

%First, go through the TTL events and ignore events on other input lines.

for xi=2:numel(ts)
    tnBit=bitand(ttls(xi),tnMask)&1;
    if tnBit~=tnState
        tnts(end+1)=ts(xi);
        tnState=tnBit;
    end
end
    
tnts=tnts(:);
dtt=sort(diff(tnts));
% depending on the % of inconsistent transitions this line may not be
% totally robust.
if length(dtt)<300
    
    TIME_SLICE=ceil(median(dtt(1:length(dtt)))/100)*100; %maybe this should be the mode not the median.  
                                             %why the first 300? will this
                                             %break for short sessions?
else
    TIME_SLICE=ceil(median(dtt(1:300))/100)*100;    
end





% Now we have just the times when the state changed on the trialnum input
% line. 

 %This assumes that your time between trials is 100 times longer than your TIME_SLICE
 %This is a pretty conservative assumption, since with a 333us time_slice
 %your trial length has to be 33ms or longer in order for this code to
 %work.
 
rtimes=round(diff(tnts)/TIME_SLICE);
trial_bounds=find(rtimes>100);
tnums=zeros(size(trial_bounds));
ttimes=tnums;



% The following algorithm ignores the times of the transitions, and just
% uses the knowledge that each signal will be 16 bits starting with a 1.

for xi=1:numel(trial_bounds)-1
    try
        
   ttimes(xi)= tnts(trial_bounds(xi)+1);
   temp_ts=rtimes(trial_bounds(xi)+1:trial_bounds(xi+1)-1);
   last_bit=1;
   bitfield=zeros(1,SIZE_FIELD);
   bit_idx=1;
   for xj=1:numel(temp_ts)
       bitfield(bit_idx:bit_idx+temp_ts(xj)-1)=last_bit;
       last_bit=1-last_bit;
       bit_idx=bit_idx+temp_ts(xj); % really +1-1       
   end
   tnums(xi)=bin2dec(num2str(bitfield(2:end)));
    catch
        warning('you are fucked in trialnumtimes')
    end
end

if tnums(end)==0
	tnums=tnums(1:end-1);
	ttimes=ttimes(1:end-1);
end


   
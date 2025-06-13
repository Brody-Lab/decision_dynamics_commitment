%sync_pmt_fsmV2()
%synchronizes the fsm times recorded by bcontrol with the tiffs recorded by scanimage
%uses the LED times as the sync signal

%Inputs
%   fname
%        File path of scanimage tif stack.  Assumes as four channel tif
%        where channels 3 and 4 are the voltage signal from the LEDs.
%   sessid
%       The session id number obtained from bdata

%Example Inputs
% sessid=261877;
% fname='/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif';

%Outpus
%  I have no idea what this function outputs, except that they are called b
%  and D.

%Version 1 JE Nov 2013
%Version 2 BBS Nov 2013 increased tif reading speed, and added
%documentation


function [b,D]=sync_pmt_fsmV3(sessid, fname)

[L]=get_lights(fname);

[fsmL,fsmR]=get_fsm_light(sessid);


[lagL,bL,RL]=find_lag(fsmL,L);
[lagL2,bL2,RL2]=find_lag(fsmR,L);

%[lagR,bR,RR]=find_lag(fsmR,R);

b=bL;
%b=(bL+bR)/2;

D.lagL=lagL;
D.betaL=bL; %betaL is the scale factor and offset between fsmL and scimL
D.fsmL=fsmL;
D.residL=RL;
D.scimL=L;
% D.lagR=lagR;
% D.betaR=bR;
% D.fsmR=fsmR;
% D.residR=RR;

function [lag,b,R]=find_lag(f,t)

fprintf('Calculating Lag...\n');
tic 
X=xcorr(zscore(diff(f)),zscore(diff(t)));   %diff(t) gets us inter flash interval 

[mx,mxi]=max(zscore(X));
if mx>4
    lag=abs((numel(X)+1)/2-mxi); %this assumes that the fsm is started before scim and lag units are in flash number
else
    lag=nan;
    fprintf('Could not find good lag');
end

samp=round(0.7*numel(t));

[b,BINT,R]=regress(f(1+lag:lag+samp),[t(1:samp) ones(samp,1)]); %this regression finds the correct scale factor and offset
toc

function [fsmL,fsmR]=get_fsm_light(sessid)

peh=get_peh(sessid);

fsmL=[];

for px=1:numel(peh)
     fn=fieldnames(peh(px).states); % gets names of the states
     led_states=find(strncmp('led',fn,3)); %strncmp finds indx of states that begin with 'led' 
    for lx=1:numel(led_states) %loops through states to find which led states have value l, and b
        lind=led_states(lx);
        this_state=peh(px).states.(fn{lind});
        if rows(this_state)>0
            % if we actually went into this stat
            flash_time=this_state(1);
            if fn{lind}(end)=='l'
                fsmL=[fsmL; flash_time];
             elseif fn{lind}(end)=='r'
                 fsmR=[fsmR; flash_time];
                
            elseif fn{lind}(end)=='b'
                fsmL=[fsmL; flash_time];
                fsmR=[fsmR; flash_time];
            end 
        end 
    end
end


function [L]=get_lights(FileTif)
% Read the tif into vector format
fprintf('Reading Image Info...\n');
tic
InfoImage=imfinfo(FileTif); %reading image info, takes about 20 seconds
toc
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberofImages=length(InfoImage);
ppf=mImage*nImage;
FinalImage=zeros(nImage,mImage,'uint16');
FileID = tifflib('open',FileTif,'r');
rps = tifflib('getField',FileID,Tiff.TagID.RowsPerStrip);
sind=1;
eind=ppf;
nframes=NumberofImages/4;
V3=nan(nframes * ppf,1);

fprintf('Opening tif...\n');
tic
for i=3:4:NumberofImages
   tifflib('setDirectory',FileID,i);
   rps = min(rps,nImage);
   for r = 1:rps:nImage
      row_inds = r:min(nImage,r+rps-1);
      stripNum = tifflib('computeStrip',FileID,r);
      FinalImage(row_inds,:) = tifflib('readEncodedStrip',FileID,stripNum);
      tmp1=FinalImage';
      V3(sind:eind)=tmp1(:);
   end
    sind=sind+ppf;
    eind=eind+ppf;
end
tifflib('close',FileID)
toc

%Now extract the flashtimes for channel 3
tV3=V3>3000; % we are using the empirically determined threshold of 3000 to identify flash on times
dtV3=diff(tV3); 
ont=find(dtV3==1);%this finds the first pixels of the flash
offt=find(dtV3==-1);%this finds the last pixels of the flash
ont = ont(1:numel(offt)); %throws out the last flash
dur=offt-ont;
L=ont(dur<30000 & dur>800);
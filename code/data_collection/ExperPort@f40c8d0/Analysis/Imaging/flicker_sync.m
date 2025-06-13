%sync_pmt_fsm()
%synchronizes the fsm times recorded by bcontrol with the tiffs recorded by scanimage
%uses the LED times as the sync signal

%Inputs
%   fname
%        File path of scanimage tif stack.  Assumes as four channel tif
%        where channels 3 and 4 are the voltage signal from the LEDs.
%   sessid
%       The session id number obtained from bdata

%Outpus
%  I have no idea what this function outputs, except that they are called b
%  and D.
function [b,D]=flicker_sync(sessid, fname)

fprintf('This may take a while....\n');
[L,R]=get_lights(fname);
[fsmL,fsmR]=get_fsm_light(sessid);


[lagL,bL,RL]=find_lag(fsmL,L);
[lagR,bR,RR]=find_lag(fsmR,R);


b=(bL+bR)/2;

D.lagL=lagL;
D.betaL=bL;
D.fsmL=fsmL;
D.residL=RL;

D.lagR=lagR;
D.betaR=bR;
D.fsmR=fsmR;
D.residR=RR;

function [lag,b,R]=find_lag(f,t)


X=xcorr(diff(f),diff(t));
    

[mx,mxi]=max(zscore(X));
if mx>4
    lag=abs((numel(X)+1)/2-mxi);
else
    lag=nan;
    fprintf('Could not find good lag');
end

samp=round(0.7*numel(t));

[b,BINT,R]=regress(f(1+lag:lag+samp),[t(1:samp) ones(samp,1)]);

keyboard
% Check r for lag and lag+1 and take the better one.


function [fsmL,fsmR]=get_fsm_light(sessid)

peh=get_peh(sessid);

fsmL=[];
fsmR=[];

for px=1:numel(peh)
    
    good_trial=false;
     fn=fieldnames(peh(px).states);
     led_states=find(strncmp('led',fn,3));
    for lx=1:numel(led_states)
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


function [L,R]=get_lights(fname)

h=imfinfo(fname);
%%
%C1=imread('/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif','Info',h(1:2),'Index',1:2);

%C2=imread('/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif','Info',h,'Index',2:4:40);
%%
ppf=h(1).Height*h(1).Width;

sind=1;
eind=ppf;
nframes=numel(h)/4;
V3=nan(nframes * ppf,1);
V4=nan(nframes * ppf,1);
for f=3:4:numel(h)
    
    
    tmp1=imread('/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif','Info',h,'Index',f);
    tmp1=tmp1';
    
    tmp2=imread('/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif','Info',h,'Index',f+1);
    tmp2=tmp2';
    V3(sind:eind)=tmp1(:);
    V4(sind:eind)=tmp2(:);

    sind=sind+ppf;
    eind=eind+ppf;
end

tV3=V3>3000;
%%

dtV3=diff(tV3);
ont=find(dtV3==1);
offt=find(dtV3==-1);
ont = ont(1:numel(offt));
dur=offt-ont;
L=ont(dur<30000 & dur>800);

tV4=V4>3000;
dtV4=diff(tV4);
ont=find(dtV4==1);
offt=find(dtV4==-1);
ont = ont(1:numel(offt));
dur=offt-ont;
R=ont(dur<30000 & dur > 800);






%C4=imread('/ratter/jerlich/Collaboration/Scott/S166_11_01001.tif','Info',h,'Index',4:4:40);
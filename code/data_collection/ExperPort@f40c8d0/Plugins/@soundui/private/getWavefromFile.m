function [LW, RW]=getWavefromFile(snd_name, sr, LVol, RVol)

global Solo_rootdir;
try
    try
        pname=bSettings('get','SOUND','Sound_Directory');
    catch
        pname=[Solo_rootdir filesep '..' filesep 'CNMC' filesep 'Sounds' filesep];
    end

    if pname(end)~=filesep
        pname=[pname filesep];
    end

    load([pname snd_name '.mat']);   
    % This file should contain a variable called mono_snd or stereo_snd 
    % and a variable called samp_rate
    
    % need to implement the sampling rate conversion.
    resamp=sr/samp_rate;

    if exist('mono_snd','var')
        mono_snd=interp(row(mono_snd),resamp);
        
        RW=RVol*mono_snd;
        LW=LVol*mono_snd;
    else
        stereo_snd=row(stereo_snd);
        RW=RVol*interp(stereo_snd(1,:),resamp);
        LW=LVol*interp(stereo_snd(2,:),resamp);
    end
    
    
    
catch
    LW=0;
    RW=0;
end



function x=row(x)

if size(x,1)>size(x,2)
    x=x';
else
    x=x;
end
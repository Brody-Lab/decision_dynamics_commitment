
function cleanEmulatorSounds
% This function checks the temp directory for FSM Emulator sounds and fixes
% them.

persistent CLEANED_NAME
persistent CLEANED_TIME


% Check if this is an emulator
%%
rigid = getRigID;
sound_server = bSettings('get','RIGS','sound_machine_server');



if isnan(rigid) || isequal(sound_server,'localhost') || isequal(sound_server,'127.0.0.1')
    try
        if ispc
            return;
        else
            tmp_dir='/tmp/';
        end
        
        olddir=cd;
        cd(tmp_dir);
        wav_files=dir('Sound*wav');
        
        for wx=1:numel(wav_files)
            this_wav=wav_files(wx).name;
            this_time=wav_files(wx).datenum;
            clnidx=strcmp(this_wav, CLEANED_NAME);
            % Have we cleaned this before?
            if any(clnidx)
                % check whether file is newer
                if this_time>CLEANED_TIME(clnidx)
                    err=clean_up_wave(this_wav);
                    CLEANED_TIME(clnidx)=this_time;
                end
            else
                % We have never seen this file before
                err=clean_up_wave(this_wav);
                CLEANED_TIME(end+1)=this_time;
                CLEANED_NAME{end+1}=this_wav;
                
            end
        end
        
        
        
    catch me
      %  showerror(me)
    end
    cd(olddir);
    
end
function err=clean_up_wave(wav_file)
err=0;
try
    [Y,fs, nbits]=wavread(wav_file);
    
    if size(Y,2)==0
        return
    end
    Y(1:5,:)=nan;
    Y(end-5:end,:)=nan;
    Y(:,1)=Y(:,1)-nanmean(Y(:,1));
    Y(:,2)=Y(:,2)-nanmean(Y(:,2));
    Y(1:5,:)=0;
    Y(end-5:end,:)=0;
    krn=normpdf(-3:0.05:0,0,1);
    krn_n=numel(krn);
    krn=krn./max(krn);
    r_krn=fliplr(krn);
    Y(1:krn_n,1)=Y(1:krn_n,1).*krn';
    Y(1:krn_n,2)=Y(1:krn_n,2).*krn';
    Y((end-krn_n+1):end,1)=Y((end-krn_n+1):end,1).*r_krn';
    Y((end-krn_n+1):end,2)=Y((end-krn_n+1):end,2).*r_krn';
    
    
    wavwrite(Y,fs,nbits,wav_file);
catch me
    err=1;
    showerror(me)
end

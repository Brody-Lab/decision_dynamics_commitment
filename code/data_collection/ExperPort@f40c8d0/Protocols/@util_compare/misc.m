% sound initialization; was in StateMatrixSection.m, section 'init'

    srate = SoundManagerSection(obj, 'get_sample_rate');

    % left and right are separate
    left_sound   = MakeBupperSwoop(srate, 10, 15, 15, 500, 500, 0, 1);
    left_sound   = [left_sound(:)' ; zeros(1, length(left_sound))];
    right_sound  = MakeBupperSwoop(srate, 10, 100, 100, 500, 500, 0, 1);
    right_sound  = [zeros(1, length(right_sound)) ; right_sound(:)'];
    t = 0:(1/srate):1; center_sound = 0.3*sin(2*pi*400*t);
        
    % fix actual sounds
    % left/right sounds are reward sounds?
    
    SoundManagerSection(obj, 'declare_new_sound', 'left_sound',   left_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'center_sound', center_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'right_sound',  right_sound);
    SoundManagerSection(obj, 'declare_new_sound', 'sfsg_sound',  0.1*(rand(1, srate)-0.5));
    SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');  

    
    
  
  % more initialization stuff
  % put all this below to next case somewhere else...
  
  DispParam(obj, 'nTrials', 0, x, y); next_row(y);
  % For plotting with the pokesplot plugin, we need to tell it what
  % colors to plot with:

  
  
  SubheaderParam(obj, 'title', 'Utility Comparison', x, y); next_row(y);
  
  % Make the main figure window as wide as it needs to be and as tall as
  % it needs to be; that way, no matter what each plugin requires in terms of
  % space, we always have enough space for it.
  pos = get(value(myfig), 'Position');
  set(value(myfig), 'Position', [pos(1:2) x+240 y+25]);

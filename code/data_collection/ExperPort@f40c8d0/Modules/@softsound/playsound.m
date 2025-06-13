function [] = playsound(sm, trigger)
   
    debugging = 0;
    
    if (trigger < 0),
       fprintf(1, ['WARNING: STOPPING sounds (%d) in @softsm is not yet ' ...
                   'supported.  Sorry.. :(\n'], -trigger);
       return;
    end;
    
   mydata = get(sm.myfig, 'UserData');
   
   if (trigger < 0),
       warning(sprintf(['Ignoring stop request for trigger %d as this is unimplemented in softsound'],-trigger));
       return;
   end;
   
   if ~ismember(trigger, mydata.allowed_trigs),
      error(['trigger must be one of ' sprintf('%d ',mydata.allowed_trigs)]);
   end;

   soundname = ['sound' num2str(trigger)];
   drawnow;
   if debugging, fprintf(1, 'Hop 1\n'); end;

   % The global playing soft sounds control:
   global softsound_play_sounds;
   if ~isempty(softsound_play_sounds) && softsound_play_sounds == 0,
      fprintf(1, ['global softsound_play_sounds==0 : NOT playing sound ' ...
                  '%d\n'], trigger);
      return;
   end;
   
   switch computer,
      case {'MAC', 'MACI'}
       st = dbstack('-completenames');
       pathstr   = fileparts(st(1).file);
       writedir  = [pathstr  filesep 'soundserver'];       
       soundfile = [writedir filesep soundname '.wav'];
       gofile    = [writedir filesep 'soundserver.go'];

       if ~exist(writedir, 'dir'),
          success = mkdir(writedir);
          if ~success, error(['Couldn''t make directory ' writedir]); end;
       end;
       
       while exist(gofile, 'file'), 
          fprintf(2, ['Waiting for soundserver to process previous ' ...
                      'sound-- is the server running for sure? See ' ...
                      '@softsound/README.txt\n']);
          pause(0.033); drawnow;
       end;
       
       if ~isempty(mydata.(soundname)),
          drawnow;
          if debugging, fprintf(1, 'Hop 2\n'); end;
          wavwrite(mydata.(soundname)', mydata.samplerate, soundfile);
          wavwrite(0, mydata.samplerate, gofile);

          if debugging, fprintf(1, 'Hop 3\n'); end;          
          drawnow;
          if debugging, fprintf(1, 'Hop 4\n'); end;          
       end;
       return;
      
    otherwise
     sound(mydata.(soundname)', mydata.samplerate);
   end;
   

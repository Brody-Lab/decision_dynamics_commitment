function sm = softsound(a)
   
   if nargin==0,

      myfig = figure('Visible', 'off');
      
      sr=bSettings('get','SOUND','sound_sample_rate');
      if isnan(sr)
      sr=8000;
      end
      mydata = struct( ...
          'samplerate',    sr,   ...
          'allowed_trigs', [1:32]  ...
          );   
          
          
      for i=1:32,
        mydata = setfield(mydata, ['sound' num2str(i)], []);
      end;
        
      set(myfig, 'UserData', mydata);
      
      sm = struct('myfig', myfig);      
      sm = class(sm, 'softsound');

      Initialize(sm);
      return;
      
   elseif isa(ssm, 'softsm'),
      ssm = a;
      return;
      
   else
      error(['Don''t understand this argument for creation of a ' ...
             'softsound']);
   end;
   
          
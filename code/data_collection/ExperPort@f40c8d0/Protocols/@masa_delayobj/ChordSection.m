function  [x, y]  =  ChordSection(obj,action, x,  y)

GetSoloFunctionArgs;
% SoloFunction('ChordSection', 'rw_args',{}, ...
%      'ro_args', {'n_done_trials'});

% Deals with chord generation and uploading for a protocol.
% init: Initialises UI parameters specifying types of sound; calls 'make' and 'upload'
% make: Generates chord for the upcoming trial
% upload: The chord is set to be sound type "1" in the RPBox

global fake_rp_box state_machine_server
persistent sound_samp_rate snd_noise snd_low snd_high

switch action,
 case 'init'
  fig = gcf; rpbox('InitRP3StereoSound'); figure(fig);
  
  oldx = x; oldy = y;  x = 5; y = 5;
  SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
  
  MenuParam(obj, 'SmallTone', {'Low','High'},1, x, y);next_row(y);
% large be automatically the opposite tone
% low tone is 6 kHz, high tone is 14 kHz
  
  EditParam(obj, 'NoiseLoudness',  -2,  x, y);   next_row(y);
  EditParam(obj, 'SoundSPL',     70,  x, y);   next_row(y);
  EditParam(obj, 'SoundDur',    0.08,  x, y);   next_row(y);
  set(value(myfig), ...
      'Visible', 'on', 'MenuBar', 'none', 'Name', 'Chord Parameters', ...
      'NumberTitle', 'off', 'CloseRequestFcn', ...
      ['ChordSection(' class(obj) '(''empty''), ''chord_param_hide'')']);
  
  screen_size = get(0, 'ScreenSize');
  set(value(myfig),'Position',[670 screen_size(4)-370, 210 90]);
  
  x = oldx; y = oldy; figure(fig);
  MenuParam(obj, 'ChordParameters', {'view', 'hidden'}, 1, x, y); next_row(y, 1.5);
  set_callback({ChordParameters}, {'ChordSection', 'chord_param_view'});
  
  sound_samp_rate=get_generic('sampling_rate');
         
      duration=value(SoundDur);
      risefall=5;
      t=0:(1/(sound_samp_rate)):duration;
      t=t(1:(end-1));
      snd = zeros(1,length(t));
        
      snd_noise=(10^((-45)/20))*rand(1,length(t));
      if fake_rp_box==2,
          switch state_machine_server,
              case 'rtlinuxrig1',
                  snd_low=snd+10^((-46)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-49)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig2',
                  snd_low=snd+10^((-53)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-40.5)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig3',
                  snd_low=snd+10^((-42)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-42)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig4',
                  snd_low=snd+10^((-40)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-29)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig11', %need to calibrate
                  snd_low=snd+10^((-49.5)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-34)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig12', %need to calibrate
                  snd_low=snd+10^((-54)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-47.5)/20)*(sin(2*pi*14000*t));
              case '192.168.0.201', %rtlinuxrig1 changed its name
                  snd_low=snd+10^((-46)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-49)/20)*(sin(2*pi*14000*t));
              case '192.168.0.146', %rtlinuxrig3 changed its name
                  snd_low=snd+10^((-42)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-42)/20)*(sin(2*pi*14000*t));
              case '192.168.1.114', %B1 rig
                  snd_low=snd+10^((-46)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-42)/20)*(sin(2*pi*14000*t));
              case '192.168.1.11', %B2 rig
                  snd_low=snd+10^((-42)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-38)/20)*(sin(2*pi*14000*t));
              case 'rtlinuxrig13', %need to be calibrated
                  snd_low=snd+10^((-42)/20)*(sin(2*pi*6000*t));
                  snd_high=snd+10^((-38)/20)*(sin(2*pi*14000*t));
                  
          end;

          Edge=MakeEdge( sound_samp_rate, risefall );
          LEdge=length(Edge);
          % Put a cos^2 gate on the leading and trailing edges.
          snd_low(1:LEdge)=snd_low(1:LEdge) .* fliplr(Edge);
          snd_low((end-LEdge+1):end)=snd_low((end-LEdge+1):end) .* Edge;
          snd_high(1:LEdge)=snd_high(1:LEdge) .* fliplr(Edge);
          snd_high((end-LEdge+1):end)=snd_high((end-LEdge+1):end) .* Edge;
      end;
  
  ChordSection(obj, 'make_upload');
  ChordSection(obj, 'make_upload_othersounds');
  
 case 'make_upload'            
      %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      attenuation = 70-value(SoundSPL);
      risefall=5;
      duration=value(SoundDur);

      t=0:(1/(sound_samp_rate)):duration;
      t=t(1:(end-1));
      snd = zeros(1,length(t));
      
      switch value(SmallTone),
          case 'Low',
              if fake_rp_box==2,
                  sound_small=(10^(-attenuation/20))*snd_low;
                  sound_large=(10^(-attenuation/20))*snd_high;
              elseif fake_rp_box==3,
                  sound_small = MakeChord(sound_samp_rate, 70-SoundSPL, ...
                      6000, 1, SoundDur*1000, 5);
                  sound_large = MakeChord(sound_samp_rate, 70-SoundSPL, ...
                      14000, 1, SoundDur*1000, 5);
              end;
          case 'High',
              if fake_rp_box==2,
                  sound_small=(10^(-attenuation/20))*snd_high;
                  sound_large=(10^(-attenuation/20))*snd_low;
              elseif fake_rp_box==3,
                  sound_small = MakeChord(sound_samp_rate, 70-SoundSPL, ...
                      14000, 1, SoundDur*1000, 5);
                  sound_large = MakeChord(sound_samp_rate, 70-SoundSPL, ...
                      6000, 1, SoundDur*1000, 5);
              end;
      end;
      
      %tone for fake_cin (small_large)
      sound_small_large=[sound_small sound_large];
          
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      sm = rpbox('getsoundmachine');
      sm = SetSampleRate(sm, sound_samp_rate);
      sm = LoadSound(sm, 1, sound_small, 'both', 0, 0); %tone for small
      sm = LoadSound(sm, 2, sound_large, 'both', 0, 0); %tone for large
      sm = LoadSound(sm, 3, sound_small_large, 'both', 0, 0); %tone for fake_cin
      sm = rpbox('setsoundmachine', sm);
 
 case 'make_upload_othersounds'      
%       % make chord %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       attenuation = 70-value(ChordSPL);
%       duration=ITImax+1;
% 
%       t=0:(1/(sound_samp_rate)):duration;
%       t=t(1:(end-1));
%       chord = zeros(1,length(t));
% 
%       if fake_rp_box==2, 
%       switch state_machine_server,
%           case 'rtlinuxrig1',
%               valL4k_sqsq2_0=31.4745; valR4k_sqsq2_0=37.0552;
%               valL4k_sqsq2_1=29.2207; valR4k_sqsq2_1=19.9124;
%               valL4k_sqsq2_2=26.3571; valR4k_sqsq2_2=29.4750;
%               valL4k_sqsq2_3=22.3377; valR4k_sqsq2_3=22.9938;
%               valL4k_sqsq2_4=30.8949; valR4k_sqsq2_4=27.9666;
%               valL4k_sqsq2_5=25.1831; valR4k_sqsq2_5=12.6256;
%               valL4k_sqsq2_6=20.9485; valR4k_sqsq2_6=23.3621;
%               valL4k_sqsq2_7=24.8013; valR4k_sqsq2_7=35.0951;
%           case 'rtlinuxrig2',
%               valL4k_sqsq2_0=35.7048; valR4k_sqsq2_0=36.8530;
%               valL4k_sqsq2_1=27.9991; valR4k_sqsq2_1=20.7935;
%               valL4k_sqsq2_2=23.4617; valR4k_sqsq2_2=28.5163;
%               valL4k_sqsq2_3=19.8249; valR4k_sqsq2_3=27.5578;
%               valL4k_sqsq2_4=22.3357; valR4k_sqsq2_4=23.9502;
%               valL4k_sqsq2_5=31.5192; valR4k_sqsq2_5=33.6413;
%               valL4k_sqsq2_6=27.0136; valR4k_sqsq2_6=29.0971;
%               valL4k_sqsq2_7=15.5537; valR4k_sqsq2_7=27.3841;
%           case 'rtlinuxrig3',
%               valL4k_sqsq2_0=33.4735; valR4k_sqsq2_0=31.9783;
%               valL4k_sqsq2_1=23.9197; valR4k_sqsq2_1=21.8303;
%               valL4k_sqsq2_2=22.9440; valR4k_sqsq2_2=21.9337;
%               valL4k_sqsq2_3=27.6132; valR4k_sqsq2_3=23.5196;
%               valL4k_sqsq2_4=27.9217; valR4k_sqsq2_4=23.8710;
%               valL4k_sqsq2_5=31.2517; valR4k_sqsq2_5=23.8372;
%               valL4k_sqsq2_6=20.5807; valR4k_sqsq2_6=13.3595;
%               valL4k_sqsq2_7=29.0298; valR4k_sqsq2_7=20.8503;
%           case 'rtlinuxrig4',
%               valL4k_sqsq2_0=31.9616; valR4k_sqsq2_0=33.9960;
%               valL4k_sqsq2_1=27.7783; valR4k_sqsq2_1=26.1126;
%               valL4k_sqsq2_2=26.8784; valR4k_sqsq2_2=26.6866;
%               valL4k_sqsq2_3=23.3755; valR4k_sqsq2_3=15.9951;
%               valL4k_sqsq2_4=24.2441; valR4k_sqsq2_4=25.8376;
%               valL4k_sqsq2_5=33.2510; valR4k_sqsq2_5=29.4539;
%               valL4k_sqsq2_6=20.6955; valR4k_sqsq2_6=16.3960;
%               valL4k_sqsq2_7=19.7377; valR4k_sqsq2_7=16.0913;
%       end;
% 
%       chord_l= chord ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_0)/20)*(sin(2*pi*4000*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_1)/20)*(sin(2*pi*4000*sqrt(sqrt(2))*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_2)/20)*(sin(2*pi*4000*sqrt(2)*t)); ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_3)/20)*(sin(2*pi*4000*sqrt(sqrt(2))*sqrt(2)*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_4)/20)*(sin(2*pi*8000*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_5)/20)*(sin(2*pi*8000*sqrt(sqrt(2))*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_6)/20)*(sin(2*pi*8000*sqrt(2)*t)) ...
%           +1/16*10^((-attenuation-valL4k_sqsq2_7)/20)*(sin(2*pi*8000*sqrt(sqrt(2))*sqrt(2)*t));
%       chord_r= chord ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_0)/20)*(sin(2*pi*4000*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_1)/20)*(sin(2*pi*4000*sqrt(sqrt(2))*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_2)/20)*(sin(2*pi*4000*sqrt(2)*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_3)/20)*(sin(2*pi*4000*sqrt(sqrt(2))*sqrt(2)*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_4)/20)*(sin(2*pi*8000*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_5)/20)*(sin(2*pi*8000*sqrt(sqrt(2))*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_6)/20)*(sin(2*pi*8000*sqrt(2)*t)) ...
%           +1/16*10^((-attenuation-valR4k_sqsq2_7)/20)*(sin(2*pi*8000*sqrt(sqrt(2))*sqrt(2)*t));
%       
%       chord_data=[chord_l;chord_r];
%       
%       elseif fake_rp_box==3,
%           %       base_freq_chord = 1;
%           base_freq_chord = 4;
%           n_tones_chord = 8;
%           %       sound_len_chord = max([itimax,vad_iti])+2;
%           sound_len_chord = 1;
%           ramp_dur_chord = 0.005;
%           sound_spl_chord = value(ChordSPL);
%           chord = MakeChord(sound_samp_rate,  70-sound_spl_chord, ...
%               base_freq_chord*1000, value(n_tones_chord), ...
%               sound_len_chord*1000, ramp_dur_chord*1000);
%           chord_data = [chord; chord];
%       end;
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      noise_b_amp = 10^(NoiseLoudness+0.5);
      noise_b_len = 0.06;
      noise_b_data ... 
       = noise_b_amp*rand(2,floor(noise_b_len*sound_samp_rate));
   
      noise_amp = 10^NoiseLoudness;
      noise_len = 3;
      noise_data ... 
       = noise_amp*rand(2,floor(noise_len*sound_samp_rate));  
        
      sm = rpbox('getsoundmachine');
      sm = SetSampleRate(sm, sound_samp_rate);
%       sm = LoadSound(sm, 100, chord_data(:,1:0.1*sound_samp_rate), 'both', 0, 0);
      sm = LoadSound(sm, 111, noise_b_data, 'both', 0, 0);
      sm = LoadSound(sm, 112, noise_data, 'both', 0, 0);
      sm = rpbox('setsoundmachine', sm);
                       
 case 'delete'            , % ------------ case DELETE ----------
  delete(value(myfig));
  
 case 'chord_param_view',   % ------- case CHORD_PARAM_VIEW
  switch value(ChordParameters)
   case 'hidden',
    set(value(myfig), 'Visible', 'off');
    
   case 'view',
    set(value(myfig), 'Visible', 'on');
  end;

 case 'chord_param_hide',
  ChordParameters.value = 'hidden';
  set(value(myfig), 'Visible', 'off');
    
 otherwise
  error(['Don''t know how to handle action ' action]);
end;

return;
    

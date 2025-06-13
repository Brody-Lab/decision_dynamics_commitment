

sounddir = '/Users/carlos/Matlab/ExperPort2/Modules/@softsound';
writedir = [sounddir filesep 'soundserver'];

soundfile = [writedir filesep 'testsound.wav'],
gofile    = [writedir filesep 'soundserver.go'];

sound = rand(24414,1);

played = 0;
while(1),
   write_time = clock;
   wavwrite(sound, 48828, soundfile);
   wavwrite(0, 48828, gofile);
   pausetime = 0.53 - etime(clock, write_time),
   pause(pausetime);
   played = played+1,
end;

% mystartup;

srate = 22e06/1024;

c = MakeChord(srate, 10, 1000, 1, 500, 50);
sound(c, srate);

c = MakeChord(srate, 10, sqrt(1000*15000), 1, 500, 50);
sound(c, srate);

c = MakeChord(srate, 10, 15000, 1, 500, 50);
sound(c, srate);


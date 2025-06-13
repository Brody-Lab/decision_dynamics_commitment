For sounds to be played asynchronously on the Mac, ./soundserver.sh
must be running in the background, and /usr/local/bin/playsound must
exist and be executable.

Also, @softsound/kill_by_name.pl and @softsound/soundserver.sh must have 
executable permissions. To ensure this, you can do the following from Matlab 
when in the main ExperPort directory:

  >> ! chmod 755 Modules/@softsound/kill_by_name.pl
  >> ! chmod 755 Modules/@softsound/soundserver.sh


All you need to do is make sure /usr/local/bin/playsound exists and is 
executable; the server should start automatically when required (@softsound
is automatically set to restart a background soundserver.sh
on initialization or reinitialization).

To nevertheless ask whether soundserver.sh is running, do, from a Unix prompt:

  % ps auxw | grep soundserver


If you try tunning the server yourself, do it so it runs in background:

  % ./sounderver.sh &



The executable /usr/local/bin/playsound comes from compiling a simple
Mac 10.4 shell application downloaded from
http://steike.com/PlaySound. That code is also available right here, in the 
subdirectory steike_playsound.

             
#!/bin/csh

set nonomatch
if ( $#argv != 0 ) then
    echo ""
    echo "$0 Usage:"
    echo ""
    echo "Run this without any arguments. It will go into infinite loop"
    echo "without returning until killed. While in this loop, it will "
    echo "repeatedly look for files called *.wav and soundserver.go in"
    echo " the cwd/soundserver directory (where cwd is the active directory "
    echo "when $0 was run)."
    echo "   When it finds a soundserver.go file, it moves all *.wav "
    echo "files into cwd/soundserver/AlreadyPlayed, and in parallel calls"
    echo "/usr/local/bin/playsound on each of the *.wav files, removing "
    echo "each file as soon as it has been played. After setting off these "
    echo "play-remove sequences, soundserver.go is itself removed."
    echo ""
    echo "   The executable /usr/local/bin/playsound came from compiling"
    echo "a simple Mac 10.4 shell application downloaded from "
    echo "http://steike.com/PlaySound. It is also available on"
    echo "http://sonnabend.cshl.org/~carlos/tmp/steike_playsound.zip."
    echo ""
    echo "The directories soundserver and soundserver/AlreadyPlayed are"
    echo "created if they don;t already exist."
    echo ""
    exit
endif


# Check that playsound exists. If not, complain and exit!
if ( ! -ex /usr/local/bin/playsound ) then
    echo "Cannot find an executable /usr/local/bin/playsound."
    echo "Soundserver exiting-- no sounds will be played!"
    exit(-1);
endif


set rootdir = "$cwd"

# Make sure all relevant directories exist
if ( ! -ed "$rootdir/soundserver" ) then
    mkdir "$rootdir/soundserver"
endif
if ( ! -ed "$rootdir/soundserver/AlreadyPlayed" ) then
    mkdir "$rootdir/soundserver/AlreadyPlayed"
endif

cd "$rootdir/soundserver"

# Remove all old files
\rm -f *.wav
\rm -f soundserver.go
\rm -f AlreadyPlayed/*


# Go into constant server mode
while 1
    if ( -e soundserver.go ) then
	foreach wavfile ( *.wav ) 
	    if ( "$wavfile" != "*.wav" ) then
		mv $wavfile AlreadyPlayed
		set toplay = "AlreadyPlayed/$wavfile"
		( /usr/local/bin/playsound $toplay ; \rm $toplay ) &
	    endif
	end
	\rm soundserver.go
    endif
    sleep 0.05
end

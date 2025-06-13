# ExperPort
All the code for BControl and running the Rodent Training Facility

# Setting up at home
The following are instructions for setting up at home. These are enough to start Dispatcher up, open a protocol, and be able to load and view data files.  They are not yet enough for being able to *run* and test a protocol at home. As of May 2022, these instructions work for Matlab 2022a.

1. Clone the https://github.com/Brody-Lab/ExperPort repository. 
* Note: cloning the repository to a folder in a mapped network drive, rather than to a folder in a local drive, may cause `bdata` to fail. 
3. To connect to `bdata` (one way to interact with the mySQL databases, and the way the rigs do it) you simply need to have the MySQLUtility subfolder in the ExperPort repo in your path and run `bdata_connect` to initialize the connection. This should be platform- and version-independent! If you do not intend to start Dispatcher or work with protocols and data/settings files you can stop here. Otherwise continue.
4. Clone the https://github.com/Brody-Lab/Protocols repository
5. Copy `ExperPort/Settings/Settings_Default.conf` to `ExperPort/Settings/Settings_Custom.conf`
6. In the new `Settings_Custom.conf`,
  * Edit this line to put in the path to your ExperPort directory, as in this example:
  * `GENERAL; Main_Code_Directory; /Users/carlos/Github/ExperPort`
  * Edit this line to put in the path to your SoloData directory, as in this example:
  * `GENERAL; Main_Code_Directory; /Users/carlos/Github/SoloData`
  * Edit this line to put in the path to the Protocols repository that sits outside ExperPort, as in this example:
  * `GENERAL; Protocols_Directory; ./Protocols:../Protocols`
  * Edit this line to tell it to use a local host sound server, as in this example:
  * `RIGS; sound_machine_server;     localhost;`
  * Edit this line, if needed, to make sure it says fake_rp-Box 3, for the Matlab emulator:
  * `RIGS; fake_rp_box;          3;`
1. Comment out these two lines in `mystartup.m`

   `% addpath([pwd filesep 'Protocols' filesep 'NewParamTester'])`
   
   `% addpath([pwd filesep 'Protocols' filesep 'SigmoidSamp7'])`
8. VPN into Princeton. If you forget to do this, Matlab will hang when trying to connext to bdata, and you might have to kill Matlab and start it again.
9. Start up Matlab, and change directory to wherever you cloned ExperPort
10. Run this within Matlab:  `addpath Protocols/; addpath MySQLUtility/ ; addpath Utility/ ; addpath Utility/Zut`
11. Run this within Matlab: `mystartup; newstartup; dispatcher init`
12. you're good to go, you can load a Protocol either through the menu on the Dispatcher window, or by running, in Matlab,
  `dispatcher set_protocol PROTOCOL_NAME` where `PROTOCOL_NAME` might be something like `PWM`, for example (no @ sign preceding it.
13. To load a data file after you've started a protocol, click on the green "Load Data" button in the protocol window. If needed, in the window that comes up, click on "options" at the bottom left, to ungray-out your data file and make it loadable.

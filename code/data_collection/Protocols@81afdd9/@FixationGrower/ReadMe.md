# DMS 2.0
Delayed Match to Sample 2.0 Protocol. Upgrading from `DMS` and base code initially written with `PWM2`

## Repo Overview

`DMS2.m` - Primary protocol script that organizes GUI initialization, trial preparation, and end of training logic (e.g. SQL uploads). Specific tasks are organized by subscripts described below.

`SMA_*.m` - Finite state machines that determines flow during a trial given the shaping variables. Which SMA is used depends on variable set by user/curricula. Spoke and Habituation are used early in shaping, Cpoke is the primary uage. See cpoke [diagram](https://docs.google.com/drawings/d/1TdGXWv2zME2ZIzvdt-MyJcfGsiPKddUEM4NUAQwQRmo/edit) or spoke [diagram](https://docs.google.com/drawings/d/1SoBx0KA85c8heaQppBEhXACblAK_Ehk5E0UzrogbloM/edit).

`HistorySection.m` - tracks what happened on previous trial(s). For example, what was the stimulus? What did the animal answer? Etc.

`SideSection.m` - Samples which side (L/R) to use for next trial based on probabilities than can be influenced by `AntibiasSection.m` to control for motor biases.

`StimulusSection.m` - Given the side and current stimulus space, generates sound stimuli for the next trial. 

`ShapingSection.m` - This is where all the variables used to shape behavior are kept. For example, answer retry, reward-guides, etc. The settings of this section large dictate the `SMA.m`

`TrainingSection.m`- Section for selecting curricula and keeping track of stage specific items (e.g. number of trials in a stage).

`TS_*.m` - Curriculum files. Each file is a specific curricula with a set of progressive stages, completion logic and parameters.

## GUI
![image](https://github.com/Brody-Lab/Protocols/assets/53059059/405a3b44-cbb9-4173-b291-b58702bf85dd)


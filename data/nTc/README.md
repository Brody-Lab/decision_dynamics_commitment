This spreadsheet lists decision commitment times from Luo & Kim (2025). Each row corresponds to a single trial.

* **`recording_id`**: String that identifies the animal and the recording date. The table includes sessions from multiple animals and days.

* **`index_in_Trials`**: Index of this trial within all trials in that recording session. Note that the Trials table includes only trials in which the rat maintained fixation and completed the trial.

* **`stereoclick_time_s`**: Stimulus onset time (in seconds). The first click of every stimulus is a simultaneous click from the left and right speakers, referred to as the “stereoclick.” This time is defined separately for each recording session, so the same value in two different `recording_id`s refers to different absolute times.

* **`movementtime_s`**: Time (in seconds) after the stereoclick at which the animal’s movement response was first detected.

* **`commitment_timestep`**: The 10 ms bin (time step) after the stereoclick at which commitment was detected on that trial.

* **`commitment_time_s`**: Commitment time (in seconds) relative to the stereoclick (stimulus onset) on that trial.

* **`cpoke_in`**: Time (in seconds) at which the animal initiated fixation (center poke in).

* **`gamma` (\(\gamma\))**: The logarithm of the ratio of the right to left click rates used to generate the stochastic click stimulus on each trial. The total click rate is always 40 clicks/s, so if \(R\) is the right click rate and \(L\) is the left click rate,

$$

R + L = 40 \\
\gamma = log (R/L) \\
L\exp(\gamma) = R \\
L = \frac{40}{1 + \exp(\gamma)} \\
R = \frac{40\exp(\gamma)} {1+\exp(\gamma)}

$$

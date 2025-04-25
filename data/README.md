
# Processed data
For reproducing the figures in the manuscript, processed data files are stored within this repository.

# Raw data

Due to the large size of the raw data, they are stored at [https://doi.org/10.5061/dryad.sj3tx96dm](https://doi.org/10.5061/dryad.sj3tx96dm)

All data are stored in MATLAB (.mat) files. There are 115 files, each corresponding to one daily recording session from a rat performing an auditory decision-making task. Each file is named as "<rat ID>_YYYY_MM_DD<suffix>.mat" according to the name of the test subject and the date of the recording.

The data include the spike times for all recorded units as well as the timing of the stimuli (e.g. auditory clicks) and the animal's actions (e.g. inserting its nose into the center port) for all trials.

Two variables are contained in each file:

## Cells

This is a MATLAB "struct" containing the spike times and the identifying information of each recorded unit. It contains the following fields:

* *anatom_loc_mm*: Anterior-posterior (AP), medial-lateral (ML), and dorsal-ventral (DV) distance of each unit relative to the bregma skull landmark
* *bank*: The recording electrodes of Neuropixels 1.0 probes are organized into different banks, and this indicates the bank of each unit.
* *cell*_*area*: brain region of each unit
  * dmFC: dorsomedial frontal cortex, overlapping the areas "M2" and "Cg1" in the Paxinos and Watson Rat Brain Atlas (6th edition)
  * mPFC: medial prefrontal cortex (PW areas PrL and IL)
  * dStr: dorsal striatum (PW area "CPu")
  * vStr: ventral striatum
  * M1: primary motor cortex
  * FOF: frontal orienting fields
* *cell_hemi*: hemisphere of each unit
* *clusterNotes*: notes added during manual curation of spike sorted clusters
* *dist_from_tip_um:* distance of each unit from the tip of the Neuropixels 1.0 probe, in microns
* *electrode*: Neuropixels 1.0 recording site of each unit
* *meta*: metadata
  * *meta.ap_meta* contains information about the Neuropixels 1.0 recording saved by the SpikeGLX acquisition application
* *rat*: name of the rat subject
* *raw_spike_time_s:* cell array containing the spike times of each unit
* *sessid:* identification of the session in the BControl behavioral control platform

Metrics of cluster isolation quality:

* *unitCount*: total number of spikes 
* *unitISIRatio*: The ratio of the number of interspike intervals (ISI) less than 2ms to the number of interspike interval less than 20ms
* *unitIsoDist:* Isolation distance: This is another quality metric of spikesorted clusters described in Neymotion et al., 2011* J. Neurosci* (PMID: 22072690)
* *unitLRatio:* L-ratio
* *unitVppRaw: *Peak-to-peak voltage (uV) of the mean raw waveform at the  recording electrode with the largest amplitude
* *waveform*.*mean**uV:* mean raw waveform at the peak recording site. This has the format of number-of-units by number-of-samples. See *meta.ap_meta.imSampRate* for the sampling rate (typically 30000 Hz).
* *waveform.meanWfGlobalRaw* mean raw waveform across all recording sites

## Trials

A structure with information about the task and behavior on each of N trials. Key fields include:

* *stateTimes* : a structure with fields of length N for each task event, giving the times according to the BControl clock, when they occurred on each trial.
  * *sending_trialnum*: beginning of the in which the trial number (encoded as an eight bit number) is emitted through the digital output
  * *wait_for_cpoke*: beginning of the a state that waits for the animal to poke into the center port
  * *cpoke_in*: beginning of the state in which the animal inserts its nose into the center poke.
  * *cpoke_req_end*: end of the required time when the animal must insert its nose into the center poke
  * *break*: beginning of the violation state, which corresponds to the animal removing its nose from the center port before the minimum required time is up
  * *clicks_on*: beginning of the sound wave
  * *clicks_off*: end of the sound wave
  * *wait_for_spoke*: beginning of the state waiting for the animal to poke either the left or right port
  * *feedback*: beginning of either a reward or error state
  * *error*: beginning of an error state
  * *left_reward*: beginning of a reward state occurring at the left port
  * *right_reward*: beginning of a reward state occurring at the right port
  * *spoke*: beginning of the state when the animal pokes left or right
  * *cpoke_out*: [inferred](https://github.com/Brody-Lab/labwide_PBups_analysis/blob/master/get_cpoke_out_time.m) time when the animal removes its nose from the center port and begins its movement toward a side port
  * *cleaned_up*: beginning of the final state in each trial during which waves are turned off
* *is_hit* : a boolean vector of length N stating whether reward was delivered on each trial.
* *violated* : a boolean vector of length N stating whether the animal broke fixation on each trial.
* *pokedR* : a boolean vector of length N indicating the animal's choice on each trial.
* *gamma* : a vector of length N stating what the signal level was on each trial (the log of the ratio of right / left click generative rates)
* *trial_type* : a character vector of length N indicating the type of trial ("a" = accumulation, "f" = free choice, "s" = side LED)
* *stim_dur_s* : a vector of length N stating the stimulus durations of each trial
* *leftBups*,*rightBups* : a cell array of length N listing the times (in seconds relative to stimulus onset, i.e., *stateTimes.clicks_on*) of the left and right clicks on each trial
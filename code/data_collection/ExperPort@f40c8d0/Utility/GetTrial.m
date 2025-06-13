function trial = GetTrial
% TRIAL = GETTRIAL 
% Return the number of the current trial
global exper

	trial = exper.control.param.trial.value;
	
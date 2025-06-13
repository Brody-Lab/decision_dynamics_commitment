function [] = tonedur(rat, task, date)

	load_datafile(rat, task, date);
	tdl = cell2mat(saved_history.ChordSection_Tone_Dur_L);
	tdr = cell2mat(saved_history.ChordSection_Tone_Dur_R);

	figure;
	plot(1:length(tdl),tdl,'-r'); hold on;
	plot(1:length(tdr),tdr,'.b');

	

function ind = chan_index(names)
% IND = CHAN_INDEX(NAMES)
% Returns the indices of analog input channels.
% NAMES is either a string is cell array of strings:
% CHANINDEX('cha')
% CHANINDEX({'cha','chb'})
% Returns [] if no matches are found.

	if iscell(names)
		ind = [];
		for n=1:length(names)
			ch = daqfind('channelname',names{n});
			ind = [ind get(ch{1},'Index')];
		end
	else
		ch = daqfind('channelname',names{n});
		ind = get(ch{1},'Index');
	end

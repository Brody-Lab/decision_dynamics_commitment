function UpdateReviewParams(module,trial)
global exper

	sf = sprintf('exper.%s.param',module);
	s = evalin('caller',sf);
	fields = fieldnames(s);
	
	% go through all the parameters
	for i=1:length(fields)
        sfs = sprintf('%s.%s',sf,fields{i});
        % updated only the ones that are saved
        save = getp(sfs,'save');
        if save
            trial_vals = getp(sfs,'trial');
            val = trial_vals{trial};
            format = getp(sfs,'format');
            if ~isempty(format)
                switch format
                case 'clock'
                    str = sprintf('%02d:%02d:%02d',val(4),val(5),round(val(6)));
                case '%d'
                    str = sprintf(format,round(val));
                otherwise
                    str = sprintf(format,val);
                end
            else
                str = val;
            end
            h = findobj('tag',sprintf('%s.%s',module,fields{i}));
            set(h,'string',str);
        end
	end


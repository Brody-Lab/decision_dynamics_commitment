
function showlatestdata(varargin)
% THis should be run from an experimenter directory.



oldd=cd;  % SAVE THE DIRECTORY WHERE THIS WAS CALLED FROM.
rd=dir;   % Get the list of rats in this directory
try
	for rdx=1:numel(rd)

		if rd(rdx).name(1)=='.' || isequal('CVS',rd(rdx).name)
			% ignore the CVS subdirectory and the . and .. directories\
		elseif rd(rdx).isdir==0
			% not a rat
		else

			do_flag=0; % a flag of whether or not to go into this rat folder.
			if nargin==0
				do_flag=1;  % The default is to go into every rat folder
			else
				ratstodo=varargin{1};  % If a list of strings was passed in check the current folder against all the strings
				for j=1:numel(ratstodo)
					this_rat=lower(ratstodo{j});
					this_dir=lower(rd(rdx).name);
					tt=strfind(this_dir, this_rat);  % It doesn't have to be an exact match!!
					if ~isempty(tt)
						do_flag=1;
						break;
					end
				end
			end

			



				if do_flag
						cd(rd(rdx).name);
				df=dir('data_@ProAnti*');

					try
						proantiAnal2(df(end).name);
					catch
						fprintf(1,'failed to do analysis for %s\n',cd);
						showerror(lasterror);
					end
					cd('..')
				end


			end
		end
		catch
			'oooops'
	end
	cd(oldd)